function Demand2hdf5(Demand,file_dir)
%%Demand2hdf5 convert timetable Demand to hdf5
% inmput: 
%   -Demand: timetable
%   -file_dir: filepath eg. './Data/demand.h5'

% write 4-d demand tensor
demand_tensor=cat(4,Demand.demand{:});
h5create(file_dir,'/demand_tensor',size(demand_tensor));
h5write(file_dir, '/demand_tensor', demand_tensor);

% write date string
datetime=cellstr(datestr(Demand.time,'yyyy-mm-dd HH:MM:SS'));

fid = H5F.open(file_dir,'H5F_ACC_RDWR','H5P_DEFAULT');

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
h5disp(file_dir);
disp(['file saved to ',file_dir]);
end
