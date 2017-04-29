clear;
file_path='S:\DataBackup\cleanyellow\*.csv';
ds=datastore(file_path, 'Delimiter', ',', ...
                        'TreatAsMissing', 'NA', ...
                        'ReadSize', 'file' );
ds.SelectedVariableNames = {'pickup_datetime', 'passenger_count','trip_distance','duration'};
preview(ds);
tt=tall(ds);
head(tt)
%% init parameters
tt.pickup_datetime=datetime(tt.pickup_datetime,'InputFormat','yyyy-MM-dd HH:mm:ss z','TimeZone','UTC');
tt.speed=tt.trip_distance ./ (tt.duration/60);
%% add parameters
dayofweek=weekday(tt.pickup_datetime);
hourofday=hour(tt.pickup_datetime);
isweekend=isweekend(tt.pickup_datetime);
%% set up out-of-memory calculation: statistics per day of week
G=findgroups(dayofweek,hourofday);
tmp=splitapply( @(dis,dr,sp,pc,dow,hod) {mean(dis),mean(dr),mean(sp),sum(pc), dow(1),hod(1)},...
                                         tt.trip_distance, tt.duration, tt.speed, tt.passenger_count,...
                dayofweek, hourofday, G);
%% set up out-of-memory calculation: statistics per isweekend or isweekday
lowci= @(x) mean(x) + std( x ) *  (-1.645);
upci = @(x) mean(x) + std( x ) *  (1.645);
G=findgroups(isweekend,hourofday);
tmp2 = splitapply( @(dis,dr,sp,pc,isw,hod){ mean(dis), mean(dr), mean(sp), sum(pc)./(isw(1)*2+~isw(1)*5),...
                                            lowci(dis), lowci(dr), lowci(sp), ...
                                            upci(dis), upci(dr), upci(sp), ...
                                            isw(1),hod(1)},...
                   tt.trip_distance, tt.duration, tt.speed, tt.passenger_count, ...
                   isweekend,hourofday, G);
%% Issue calculation and Gather Results
[tb,tb2]=gather(tmp,tmp2);
% arrange Statistics per day of week
tb=cell2table(tb,'VariableNames',{'Trip_distance','Duration','Average_Speed','Pickups','Day_of_week','Hour'});
% arrange Statistics per isweekend or isweekday
tb2=cell2table(tb2,'VariableNames',{'mean_distance','mean_duration','mean_speed','mean_pickups',...
    'lowci_distance','lowci_duration','lowci_speed',...
    'upci_distance', 'upci_duration', 'upci_speed',...
    'isweekend', 'hour'});
for i={'lowci_distance','lowci_duration','lowci_speed'}
    tb2{ tb2.(i{:})<0,i}=0;
end
%% release memory
clearvars -except tb tb2
%%  Plot statistics per day of week
varnames={'Average trip distance (miles)','Average duration (min)',...
          'Average speed (mph)', 'Pickups (persons per hour)'};
for i=1:length(varnames)
   f(i)= figure('PaperType','usletter','Position',[348.2000 276.2000 695.2000 368.0000]);
   % subplot(2,2,i);
    X=reshape(tb.Hour,[],7) ; Y=reshape(  tb{:,i},[],7);
    h=plot(     X , Y       );
    set(h,{'Marker'},{'.'; 'o'; '+'; 'x'; '*'; 's'; 'd'})
    h=gca;h.XTick=0:23;h.YGrid='on';xlim([0,23])
    ylabel(varnames{i});xlabel('Hour of day');
    legend('Sun.','Mon.','Tue.','Wed.','Thu.','Fri.','Sat.','Location','northeastoutside');
    title('Statistics per day of week')
end
if exist('figures','dir')~=7, mkdir('figures'),end
savefig(f,'./figures/Satistics_by_day_of_week.fig ','compact');
close(f);
%% Plot statistics per isweekend or isweekday
labelnames={'Average trip distance (miles)','Average duration (min)',...
          'Average speed (mph)', 'Pickups (persons per hour)'};
varnames={'mean_distance','mean_duration','mean_speed','mean_pickups'};
for i=1:4
    f(i)=figure('PaperType','usletter','Position',[348.2000 276.2000 695.2000 368.0000]);
    X=reshape(tb2.hour,[],2) ; Y=reshape(  tb2.(varnames{i}),[],2);
    if ismember(i,[1,2,3])
        lowerror=tb2.(varnames{i}) - tb2.( regexprep(varnames{i},'^\w+_(w*)','lowci_$1'));
        uperror= tb2.( regexprep(varnames{i},'^\w+_(w*)','upci_$1'))-tb2.(varnames{i});
        bounds=cat(2, reshape( lowerror,[],1,2),...
                      reshape( uperror ,[],1,2));
        [h,p]=NYCTaxi.boundedline(     X , Y ,  bounds ,'alpha','transparency', 0.15); 
        outlinebounds(h, p);
        title('Estimated 90% confidence interval')
    else
        h=plot(X,Y);
    end  
    set(h,{'Marker','LineStyle','LineWidth'},{ 'o','-',1;  '*','--',1;});
    h=gca;h.XTick=0:23;h.YGrid='on';xlim([0,23])
    ylabel(labelnames{i});xlabel('Hour of day');
    legend('Weekend','Weekday', 'Average by Weekend','Average by Weekday','Location','northeastoutside'); 
end
if exist('figures','dir')~=7, mkdir('figures'),end
savefig(f,'./figures/Satistics_by_isweekend.fig ','compact');
close(f)
