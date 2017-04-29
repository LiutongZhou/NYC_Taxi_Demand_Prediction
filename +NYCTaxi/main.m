clear;clc;close all;
import NYCTaxi.*
%% unzip data downloaded from google cloud
file_dir='S:\DataBackup\cleanyellow';
unzipdata(file_dir)

%% Generate Demand
files=dir(file_dir);
files=files(~[files.isdir]);
filenames=fullfile({files.folder}',{files.name}');
ds = datastore(fullfile(file_dir,'*.csv'),'Delimiter',',','TreatAsMissing', 'NA','ReadSize','file');
%ds = datastore(filenames(1),'Delimiter',',','TreatAsMissing', 'NA','ReadSize','file');
ds.SelectedVariableNames = {'pickup_datetime', 'dropoff_datetime', ...
                            'pickup_longitude','pickup_latitude',...
                            'dropoff_longitude','dropoff_latitude','passenger_count'};
clearvars files filenames;

% latlimit [40.680276,40.882530], lonlimit [-74.036206,-73.909863]  
% in NYC 0.009 lat ~=1km and 0.0119lon ~= 1km
[Demand,R]=GenerateDemand.DemandGen(ds,60,[40.680276,40.882530],[-74.036206,-73.909863],[32,32]);
save('D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat','Demand','R');

%% save to hdf5
% x=h5read('D:\Downloads\BJ16_M32x32_T30_InOut.h5','/data');
% h5disp('D:\Downloads\BJ16_M32x32_T30_InOut.h5');
GenerateDemand.Demand2hdf5(Demand,'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.h5')

%% Generate Holidays
holidaygen('2014-07-01','2016-06-30',...
    'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\holidays.txt');




