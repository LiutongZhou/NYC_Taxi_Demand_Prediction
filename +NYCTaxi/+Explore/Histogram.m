function h=Histogram(file_dir)
%Histogram h=Histogram(file_dir) plots the histogram for filters and return
%the (histogram)  graphics object handle h
% input: e.g. 'S:\DataBackup\cleanyellow\cleanyellow*.csv'

ds=datastore(file_dir,'Delimiter',',','ReadSize','file');
preview(ds)
%% Read
tt=tall(ds);
%% Plot
f=figure('PaperType','usletter','Position',[0 0 1024 1080]);
subplot(4,2,1)
histogram(tt.trip_distance,135,'Normalization','probability','LineStyle','none','BinLimits',[0,14]);
xlabel('Trip distance (miles)');ylabel('Frequency');
subplot(4,2,2)
histogram(tt.duration,150,'Normalization','probability','LineStyle','none','BinLimits',[0,60]);
xlabel('Trip duration (minutes)');ylabel('Frequency');
subplot(4,2,3)
histogram(tt.trip_distance./(tt.duration/60),150,'Normalization','probability','LineStyle','none','BinLimits',[0,40]);
xlabel('Average speed (mph)');ylabel('Frequency');
subplot(4,2,4)
histogram(tt.fare_amount./tt.trip_distance,165,'Normalization','probability','LineStyle','none','BinLimits',[2,12]);
xlabel('Fare rate ( USD/mile)');ylabel('Frequency');
subplot(4,2,5)
histogram(tt.pickup_latitude,150,'Normalization','probability','LineStyle','none','BinLimits',[40.66,40.84]);
xlabel('Latitude');ylabel('Frequency');
subplot(4,2,6)
histogram(tt.pickup_longitude,150,'Normalization','probability','LineStyle','none','BinLimits',[-74.02,-73.92]);
xlabel('Longitude');ylabel('Frequency');
subplot(4,2,7)
histogram(tt.trip_distance./tt.straight_line_dist,150,'Normalization','probability','LineStyle','none','BinLimits',[0.95,2.5]);
xlabel('Winding Factor');ylabel('Frequency');
subplot(4,2,8)
histogram(tt.straight_line_dist,150,'Normalization','probability','LineStyle','none','BinLimits',[0,8]);
xlabel('Euclidean distance (miles)');ylabel('Frequency');
%% Return
f=gcf;
h=[f.Children.Children]';
end
