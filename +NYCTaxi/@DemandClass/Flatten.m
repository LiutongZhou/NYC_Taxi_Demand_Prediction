function [pickups,dropoffs]=Flatten(obj)
%Flatten [pickups,dropoffs]=Flatten(obj) Convert Demand Table to flattened pickup and
%drop up timetables

%% Demand to array
Array=cat(4,obj.Demand.demand{:});
Array=squeeze(reshape(Array,1,[],2,size(Array,4)));
pickups=squeeze(Array(:,1,:))';
dropoffs=squeeze(Array(:,2,:))';

%% array to table
pickups=array2timetable(pickups,obj.Demand.time);
dropoffs=array2timetable(dropoffs,obj.Demand.time);
%% Datetime to add datenum+timeofday + dayofweek +season colmns
pickups=parse_datetime(pickups);
dropoffs=parse_datetime(dropoffs);
end
function tb=array2timetable(array,time)
varnames=cellstr(    num2str( ...
      (     1:size(array,2)     )','region%d')...
    );
tb=array2table(array,'VariableNames',varnames);
tb.Datetime=time;
tb=table2timetable(tb,'RowTimes','Datetime');
end
function tb=parse_datetime(tb)
% add datenum+timeofday + dayofweek +season colmns to timetable
tb.datenum=datenum(tb.Properties.RowTimes);
tb.timeofday=hours(timeofday(tb.Properties.RowTimes));% in hours
tb.dayofweek=categorical(weekday(tb.Properties.RowTimes));
tb.season=season(tb.Properties.RowTimes);
end
function seasons=season(datetime)
% convert datetime to season
monthvec=month(datetime);
seasons=zeros(length(monthvec),1);
% spring
cond= monthvec==3|monthvec==4|monthvec==5;
seasons(cond)=1;
% summer
cond= monthvec==6|monthvec==7|monthvec==8;
seasons(cond)=2;
% autumn
cond= monthvec==9|monthvec==10|monthvec==11;
seasons(cond)=3;
% winter
cond= monthvec==12|monthvec==1|monthvec==2;
seasons(cond)=4;

seasons=categorical(seasons);
end
