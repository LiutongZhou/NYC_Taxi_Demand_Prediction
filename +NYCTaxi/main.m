%% unzip data downloaded from google cloud
clear;clc;close all;
file_dir='S:\DataBackup\cleanyellow';
try
    NYCTaxi.GenerateDemand.unzipdata(file_dir)
catch 
end

%% Generate Demand
files=dir(file_dir);
files=files(~[files.isdir]);
filenames=fullfile({files.folder}',{files.name}');
ds = datastore(filenames,'Delimiter',',','TreatAsMissing', 'NA');
%ds = datastore(filenames{1},'Delimiter',',','TreatAsMissing', 'NA');
ds.SelectedVariableNames = {'pickup_datetime', 'dropoff_datetime', 'pickup_longitude',...
    'pickup_latitude','dropoff_longitude','dropoff_latitude','passenger_count','trip_distance','duration'};
clear files filenames;

% latlimit [40.680276,40.882530], lonlimit [-74.036206,-73.909863]  
% in NYC 0.009 lat ~=1km and 0.0119lon ~= 1km
[Demand,R]=NYCTaxi.GenerateDemand.DemandGen(ds,60,[40.680276,40.882530],[-74.036206,-73.909863],0.5);
save('Demand.mat','Demand','R');

% %% save to hdf5
% h5create('demand.h5','/demand_cube',size(Demand));
% h5write('demand.h5', '/demand_cube', Demand)
% h5create('demand.h5', '/time_axis',size(unique_time))
% h5write('demand.h5', '/time_axis',str2mat(unique_time))
% 
% %h_dist=histogram(tb.trip_distance);
% %stat=gather([min(duration),mean(duration),max(duration)]);
