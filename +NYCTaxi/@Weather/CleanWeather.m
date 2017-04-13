function CleanWeather(Weather)
%%CleanWeather CleanWeather(file_dir) generate clean daily and hourly weather data from raw data
% Input the raw weather data eg. '..path\data.csv'
% The generated data are stored in the same directory as the input raw data

%% Clean raw data and save cleaned data to the same directory
% read data
tic
file_name=Weather.file_name;
opts=detectImportOptions(file_name);

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

tb=readtable(file_name,opts);% read all columns and rows
tb.Properties.VariableNames= capitalize(lower(tb.Properties.VariableNames)); %change Uppercase Var Names to Lowercase

% Clean raw data
% for each char type varible if end with s, remove s,

tb=sortrows (tb,'Date');
S = vartype ('cellstr');

% replace string that starts with [space]+digits and end with 1 or more 's's with only the numeric part
delete_redundants= @(x)regexprep(x,'(^\s*\d+)s+','$1','ignorecase');
tb(:,S)=varfun (delete_redundants,tb,'InputVariables',@iscellstr);

% fill T,Ts, M with previous
tb=standardizeMissing(tb,{'T','Ts'},'DataVariables',@iscellstr);
writetable(tb,fullfile( fileparts(file_name), 'Clean_Weather.csv') )
disp(['Raw data cleaned and saved to ',fullfile( fileparts(file_name), 'Clean_Weather.csv') ]);
toc

%% Subset raw table to hourly and daily tables
tb_hourly=tb(~strcmp(tb.Reporttype,'SOD'),strncmpi('hourly',tb.Properties.VariableNames,6)|...
    strncmpi('date',tb.Properties.VariableNames,7)|...
    strncmpi('Reporttype',tb.Properties.VariableNames,7));

tb_daily=tb(strcmp(tb.Reporttype,'SOD'),strncmpi('daily',tb.Properties.VariableNames,5)|...
    strncmpi('date',tb.Properties.VariableNames,7)|...
    strncmpi('REPORTTPYE',tb.Properties.VariableNames,7));

%% Clean Daily table and write to disk
tb_daily.Reporttype=[];
S=vartype('cellstr');

original_col_order=tb_daily.Properties.VariableNames;
selected_cols = setdiff( tb_daily(1,S).Properties.VariableNames, {'Dailyweather'} );

tb_temp=varfun( @str2double, tb_daily,'InputVariables',selected_cols);
tb_temp.Properties.VariableNames=selected_cols;
tb_daily(:,selected_cols)=[];
tb_daily=[tb_daily,tb_temp];
tb_daily=tb_daily(:,original_col_order);

tb_daily=fillmissing(tb_daily,'linear','DataVariables',@isnumeric);
writetable(tb_daily,fullfile(fileparts(file_name),'Clean_Daily.csv'));
disp(['Clean daily weather is generated and saved to ',...
    fullfile( fileparts(file_name), 'Clean_Daily.csv') ]);
toc

%% Clean Hourly table and write to disk
tb_hourly.Reporttype=[];
S=vartype('cellstr');

original_col_order=tb_hourly.Properties.VariableNames;
selected_cols = setdiff( tb_hourly(1,S).Properties.VariableNames,...
    {'Hourlyskyconditions','Hourlyprsentweathertype'} );

tb_temp=varfun( @str2double, tb_hourly,'InputVariables',selected_cols);
tb_temp.Properties.VariableNames=selected_cols;
tb_hourly(:,selected_cols)=[];
tb_hourly=[tb_hourly,tb_temp];
tb_hourly=tb_hourly(:,original_col_order);

tb_hourly=fillmissing(tb_hourly,'linear','DataVariables',@isnumeric);
writetable(tb_hourly,fullfile(fileparts(file_name),'Clean_Hourly.csv'));

disp(['Clean Hourly weather is generated and saved to ',...
    fullfile( fileparts(file_name), 'Clean_Hourly.csv') ]);
toc
disp('Clean Weather Completed!')
end
