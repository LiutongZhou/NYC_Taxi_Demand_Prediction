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
tic
[Demand,R]=NYCTaxi.GenerateDemand.DemandGen(ds,60,[40.680276,40.882530],[-74.036206,-73.909863],0.5);
toc
save('.\Data\Demand.mat','Demand','R');

%% save to hdf5
% x=h5read('D:\Downloads\BJ16_M32x32_T30_InOut.h5','/data');
demand_tensor=cat(4,Demand.demand{:});
h5create('Data/demand.h5','/demand_tensor',size(demand_tensor));
h5write('Data/demand.h5', '/demand_tensor', demand_tensor);

% write date string
datetime=cellstr(datestr(Demand.time,'yyyymmddHH'));

fid = H5F.open('Data/demand.h5','H5F_ACC_RDWR','H5P_DEFAULT');

type_id = H5T.copy('H5T_C_S1');
H5T.set_size(type_id,'H5T_VARIABLE');
%H5T.set_strpad(type_id,'H5T_STR_NULLTERM');

dims = size(datetime,1);
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
dset_id = H5D.create(fid,'datetime',type_id,space_id,dcpl);


% Write data
H5D.write(dset_id,type_id,'H5S_ALL','H5S_ALL','H5P_DEFAULT',datetime);

%close file
H5P.close(dcpl);
H5S.close(space_id);
H5T.close(type_id);
H5D.close(dset_id);
H5F.close(fid);
h5disp('Data/demand.h5');


