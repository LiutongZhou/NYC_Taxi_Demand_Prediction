file_path='S:\DataBackup\yellow*.csv';
ds=datastore(file_path,'Delimiter', ',', ...
                        'TreatAsMissing', 'NA');
ds.SelectedVariableNames={'pickup_longitude','pickup_latitude'};
preview(ds)
tt=tall(ds);
%% Scatter Plot
figure
h=binScatterPlot(tt.pickup_longitude,tt.pickup_latitude,...
                linspace(-74.06,-73.77,1920),linspace(40.61,40.91,1080));
h.Normalization='probability';
h.LineStyle='none';
h.FaceAlpha=1;h.EdgeAlpha=0;
set(gca,'Color',[0,0,0]);
xlabel('Longitude');ylabel('Latitude');zlabel('Frequency');
title('Taxi Pickup Density Scatter Plot');
f(1)=gcf;
figure
h2=binScatterPlot(tt.pickup_longitude,tt.pickup_latitude,...
                linspace(-74.06,-73.77,300),linspace(40.61,40.91,250));
h2.DisplayStyle='bar3';
h2.FaceAlpha=1;
h2.FaceColor=[0.8,0.8,0.8];
xlabel('Longitude');ylabel('Latitude');zlabel('Frequency');
title('Taxi Pickup Density Scatter Plot');
h2.Normalization='probability';
grid off
view(3);
f(2)=gcf;
savefig(f,'./figures/Scatter.fig ','compact');
close(f);

%% Histogram
%histogram(tt.fare_amount,'LineStyle','none','Normalization','pdf')
