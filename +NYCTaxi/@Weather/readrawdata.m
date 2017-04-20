function tb=readrawdata(obj)
file_name=obj.file_name;
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
end