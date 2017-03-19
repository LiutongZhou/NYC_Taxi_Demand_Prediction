function DemandMapper( data,~,intermKVStore,time_interval,Z,R)
%DEMANDMAPPER Mapper for DemandGen
% DemandMapper( data,~,intermKVStore,time_interval,Z,R)
% time_interval : in minutes

% remove missing
% data=rmmissing(data,'DataVariables',@isnumeric);

% clipping the records within Manhattan
in=NYCTaxi.isinManhattan_mex(data.pickup_latitude,data.pickup_longitude);
data(~in,:)=[];

data.pickup_datetime=datetime(data.pickup_datetime,'InputFormat','yyyy-MM-dd HH:mm:ss z','TimeZone','UTC');
data.dropoff_datetime=datetime(data.dropoff_datetime,'InputFormat','yyyy-MM-dd HH:mm:ss z','TimeZone','UTC');

% binning time according to time_interval
data.pickup_datetime.Minute= floor(data.pickup_datetime.Minute/time_interval)*time_interval;
data.pickup_datetime.Second=0;
% find the unique key:time in this chunk
[intermKeys,~,idc] = unique(cellstr(data.pickup_datetime), 'stable');
n=length(intermKeys);
intermVals=cell([n,1]);
for i=1:n
    ind=i==idc;
    [row, col] = setpostn(Z, R, data.pickup_latitude(ind), data.pickup_longitude(ind));
    %value: demand matrix
    intermVals{i}=accumarray([row,col],data.passenger_count(ind),size(Z));
end
addmulti(intermKVStore,intermKeys,intermVals);
end


