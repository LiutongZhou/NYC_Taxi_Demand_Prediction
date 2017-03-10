function [Demand,R]= DemandGen(ds,time_interval,LatLimit,LonLimit,cell_edge_length )
%DemandGen Generate Demand Matrices for each time window
%   Demand = DemandGen(ds,time_interval,R )
%   Output:
%       -Demand: A timetable Demand
%       -R: georef object
%   Input:
%       -ds: datastore
%       -time_interval: in minutes. eg. 60
%       -LatLimit: eg. [40.680276,40.882530]
%       -LonLimit:  eg. [-74.036206,-73.909863]
%       -cell_edge_length: in miles. eg. 0.5

%% Init
cellExtentInLatitude=fzero(@(x) deg2sm( distance(40.75,-73.97,40.75+x,-73.97))-cell_edge_length, [0,1]);
cellExtentInLongitude=fzero(@(x) deg2sm( distance(40.75,-73.97,40.75,-73.97+x))-cell_edge_length, [0,1]);
R=georefcells(LatLimit,LonLimit,cellExtentInLatitude, cellExtentInLongitude);
%% Mapreduce Demand Generation
Z=zeros(R.RasterSize);
delete(gcp('nocreate'));
try
    result = mapreduce(ds, ...
        @(data,info,kvs)NYCTaxi.GenerateDemand.MapReducer.DemandMapper(data,info,kvs,time_interval,Z,R),...
        @(intermKey, intermValIter, outKVStore)NYCTaxi.GenerateDemand.MapReducer.DemandReducer(intermKey, intermValIter, outKVStore,Z),...
        mapreducer(parpool('local',4)));
catch ME
    warning(ME.message);
    delete(gcp('nocreate'));
    mapreducer(0);
    result = mapreduce(ds, ...
        @(data,info,kvs)NYCTaxi.GenerateDemand.MapReducer.DemandMapper(data,info,kvs,time_interval,Z,R),...
        @(intermKey, intermValIter, outKVStore)NYCTaxi.GenerateDemand.MapReducer.DemandReducer(intermKey, intermValIter, outKVStore,Z) ...
        );
end
Demand=readall(result);
Demand.Properties.VariableNames={'time','demand'};
Demand.time=datetime(Demand.time);
Demand=table2timetable(Demand);
Demand=sortrows(Demand,'time');
end

