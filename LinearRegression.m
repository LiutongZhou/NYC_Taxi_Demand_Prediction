%% Regression

load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
%% Flatten Demand
array=Demand.Demand2Array;
array=squeeze(reshape(array,1,[],2,size(array,4)));
pickups=squeeze(array(:,1,:))';
dropoffs=squeeze(array(:,2,:))';
%% Construct Table
tb_pickups=array2table(pickups);
tb_pickups.Datetime=Demand.Demand.time;
tb_pickups=table2timetable(tb_pickups);
subtb=tb_pickups(timerange('2016-01-01','2016-01-15'),250);
plot(subtb.Datetime,subtb.Variables)
%% Construct Predictors: time of the day, day of the week, season of the year + weather
mvregress()
%% synchronize with weather data
tb=synchronize(Demand,weather.data,'first','nearest');
%%
[beta,sigma,E,V] = mvregress(Xcell,Y);
