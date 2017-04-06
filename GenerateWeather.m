%% Read Meteorology.h5
file='D:\OneDrive - Columbia University\2017Spring\Research\Data\BJ_Meteorology.h5';
%h5disp(file);
tb=table();
tb.Date=h5read(file,'/date');
tb.Weather=h5read(file,'/Weather')';
tb.Temperature=h5read(file,'/Temperature');
tb.WindSpeed=h5read(file,'/WindSpeed');
tb(1:5,:)
%% unzip data
import NYCTaxi.*
file_dir='S:\DataBackup\Weather';
unzipdata(file_dir);
%% select Central Park Station
file_path=fullfile(file_dir,'Weather_NYC_CentralPark_2009_2017.csv');
opts=detectImportOptions(file_path);
opts.VariableNames{strcmp('REPORTTPYE',opts.VariableNames)}='Reporttype'; %correct a typo
charlist={'HOURLYVISIBILITY','HOURLYDRYBULBTEMPF','HOURLYDRYBULBTEMPC',...
    'HOURLYDewPointTempF','HOURLYDewPointTempC','HOURLYWindDirection',...
    'HOURLYStationPressure','HOURLYPressureChange','HOURLYSeaLevelPressure',...
    'HOURLYPrecip','HOURLYAltimeterSetting','DAILYPrecip'};
numlist={'DAILYMaximumDryBulbTemp','DAILYMinimumDryBulbTemp','DAILYAverageDryBulbTemp',...
    'DAILYDeptFromNormalAverageTemp','DAILYAverageRelativeHumidity','DAILYAverageDewPointTemp',...
    'DAILYAverageWetBulbTemp','DAILYHeatingDegreeDays','DAILYCoolingDegreeDays',...
    'DAILYAverageStationPressure','DAILYAverageSeaLevelPressure','DAILYAverageWindSpeed',...
    'DAILYSustainedWindSpeed','DAILYSustainedWindDirection'};
opts=setvartype(opts,charlist,'char');
opts=setvartype(opts,numlist,'double');
monthly_ind=find(strncmpi('Monthly',opts.VariableNames,7)); % index for 'Monthly*' columns
opts=setvartype(opts,monthly_ind,'char');

tb=readtable(file_path,opts);% read all columns and rows
tb.Properties.VariableNames= capitalize(lower(tb.Properties.VariableNames)); %change Uppercase Var Names to Lowercase

tb_hourly=tb(:,strncmpi('hourly',tb.Properties.VariableNames,6)|...
    strncmpi('date',tb.Properties.VariableNames,7)|...
    strncmpi('Reporttype',tb.Properties.VariableNames,7));

tb_daily=tb(strcmp(tb.Reporttype,'SOD'),strncmpi('daily',tb.Properties.VariableNames,5)|...
    strncmpi('date',tb.Properties.VariableNames,7)|...
    strncmpi('REPORTTPYE',tb.Properties.VariableNames,7));
%% Clean data
% for each char type varible if end with s, remove s, if end with T, fill with previous, if end with
% M, Nan;
S = vartype('cellstr');
tb_daily(:,S);
