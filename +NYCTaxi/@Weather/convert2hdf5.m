function convert2hdf5(file_dir)
%convert2hdf5 convert .mat weather data to .h5  data
%eg. file_dir='D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology.mat';
%    convert2hdf5(file_dir);

%% write numeric vars

load(file_dir)

[filepath,filename,~]=fileparts(file_dir);
file_dir=fullfile(filepath,[filename,'.h5']);

h5create(file_dir,'/Temperature',size(weather.data.Hourlydrybulbtempc));
h5write(file_dir, '/Temperature', weather.data.Hourlydrybulbtempc);
 
h5create(file_dir,'/HourlyWindSpeed',size(weather.data.Hourlywindspeed));
h5write(file_dir, '/HourlyWindSpeed', weather.data.Hourlywindspeed);

h5create(file_dir,'/HourlyPrecipitation',size(weather.data.Hourlyprecip));
h5write(file_dir, '/HourlyPrecipitation', weather.data.Hourlyprecip);

h5create(file_dir,'/HourlyWeatherType',size(weather.data.HourlyWeatherType));
h5write(file_dir, '/HourlyWeatherType',double(full(weather.data.HourlyWeatherType)));

h5create(file_dir,'/DailySnowFall',size(weather.data.Dailysnowfall));
h5write(file_dir, '/DailySnowFall', weather.data.Dailysnowfall);

h5create(file_dir,'/DailySnowDepth',size(weather.data.Dailysnowdepth));
h5write(file_dir, '/DailySnowDepth', weather.data.Dailysnowdepth);

h5create(file_dir,'/SustainedWindSpeed',size(weather.data.Dailysustainedwindspeed));
h5write(file_dir, '/SustainedWindSpeed', weather.data.Dailysustainedwindspeed);

h5create(file_dir,'/DailyWeatherType',size(weather.data.DailyWeatherType));
h5write(file_dir, '/DailyWeatherType',double( full(weather.data.DailyWeatherType)));
%%  write cell string

datetime=cellstr(datestr(weather.data.Datetime,'yyyy-mm-dd HH:MM:SS'));
writecellstr(file_dir,'Datetime',datetime);
writecellstr(file_dir,'DailyWeatherTypes',weather.DailyWeatherTypes);
writecellstr(file_dir,'HourlyWeatherTypes',weather.HourlyWeatherTypes);


%%
disp('mat file has been converted to')
disp(file_dir)
h5disp(file_dir);
end
function writecellstr(file_dir,datasetname,mycellstr)
% write mycellstr to a new dataset named datasetname in the hdf5 file : file_dir
fid = H5F.open(file_dir,'H5F_ACC_RDWR','H5P_DEFAULT');
type_id = H5T.copy('H5T_C_S1');
H5T.set_size(type_id,'H5T_VARIABLE');
%H5T.set_strpad(type_id,'H5T_STR_NULLTERM');

dims = size(mycellstr,1);
maxdims = H5ML.get_constant_value('H5S_UNLIMITED');
space_id = H5S.create_simple(1,dims,maxdims);

%{
H5T.set_size(type_id,4);
dims = [6 3];
h5_dims = fliplr(dims);
h5_maxdims = h5_dims;
space_id = H5S.create_simple(2,h5_dims,h5_maxdims);
%}
%dcpl = 'H5P_DEFAULT';
dcpl = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(dcpl,2); % 2 strings per chunk
dset_id = H5D.create(fid,datasetname,type_id,space_id,dcpl);

% Write data
H5D.write(dset_id,type_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',mycellstr);

%close file
H5P.close(dcpl);
H5S.close(space_id);
H5T.close(type_id);
H5D.close(dset_id);
H5F.close(fid);
end
