function DemandMapper( data,~,intermKVStore,time_interval,Z,R)
%DEMANDMAPPER Mapper for DemandGen
% DemandMapper( data,~,intermKVStore,time_interval,Z,R)
% time_interval : in minutes

% remove missing
% data=rmmissing(data,'DataVariables',@isnumeric);

%% clipping the records within Manhattan, return index pick_in and drop_in
pick_in=NYCTaxi.isinManhattan_mex(data.pickup_latitude,data.pickup_longitude);
drop_in=NYCTaxi.isinManhattan_mex(data.dropoff_latitude,data.dropoff_longitude);

%% Splitting the data into two clipped sets
% the dataset for pickups in Manhattan
data_pick=data(pick_in,{'pickup_datetime','pickup_latitude','pickup_longitude','passenger_count'});
% the dataset for dropoffs in Manhattan
data_drop=data(drop_in,{'dropoff_datetime','dropoff_latitude','dropoff_longitude','passenger_count'});

%% binning time according to the specified time_interval
data_pick=binning_time(data_pick);
data_drop=binning_time(data_drop);

%% Generating the Pickups Matrix in this chunk
[intermKeys,~,idc] = unique(cellstr(data_pick.time), 'stable');
n=length(intermKeys);
intermVals=cell([n,1]);
for i=1:n
    ind=i==idc;
    [row, col] = setpostn(Z, R, data_pick.pickup_latitude(ind), data_pick.pickup_longitude(ind));
   %value: demand matrix
    intermVals{i}=accumarray([row,col,ones(length(row),1)],data_pick.passenger_count(ind),[R.RasterSize,2]);
end
addmulti(intermKVStore,intermKeys,intermVals);

%% Generating the Dropoffs Matrix in this chunk
[intermKeys,~,idc] = unique(cellstr(data_drop.time), 'stable');
n=length(intermKeys);
intermVals=cell([n,1]);
for i=1:n
    ind=i==idc;
    [row, col] = setpostn(Z, R, data_drop.dropoff_latitude(ind), data_drop.dropoff_longitude(ind));
    %value: demand matrix
    intermVals{i}=accumarray([row,col,2*ones(length(row),1)],data_drop.passenger_count(ind),[R.RasterSize,2]);
end
addmulti(intermKVStore,intermKeys,intermVals);

%% subrutine 1: binning time according to the specified time_interval
    function data=binning_time(data)
        data.Properties.VariableNames{1}='time';
        data.time=datetime(data.time,'InputFormat','yyyy-MM-dd HH:mm:ss z','TimeZone','UTC');
        data.time.Minute= floor(data.time.Minute/time_interval)*time_interval;
        data.time.Second=0;
    end

end

