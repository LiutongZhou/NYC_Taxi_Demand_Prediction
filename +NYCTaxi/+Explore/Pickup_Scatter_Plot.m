function f=Pickup_Scatter_Plot(tt)
%Pickup_Scatter_Plot f=Pickup_Scatter_Plot(tt)
%
f(1)=figure(1);
h=binScatterPlot(tt.pickup_longitude,tt.pickup_latitude,...
                linspace(-74.06,-73.77,1920),linspace(40.61,40.91,1080));
h.Normalization='probability';
h.LineStyle='none';
h.FaceAlpha=1;h.EdgeAlpha=0;
set(gca,'Color',[0,0,0]);
xlabel('Longitude');ylabel('Latitude');zlabel('Frequency');
title('Taxi Pickup Density Scatter Plot');
%f(1)=gcf;
f(2)=figure(2);
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
%f(2)=gcf;
savefig(f,'./figures/BinScatter_of_Pickups_in_Whole_NYC.fig ','compact');
end
