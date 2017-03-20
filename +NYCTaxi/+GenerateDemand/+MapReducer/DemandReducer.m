function DemandReducer(intermKey, intermValIter, outKVStore,Z)
%DEMANDREDUCER Reducer for DemandGen
%   DemandReducer(intermKey, intermValIter, outKVStore,Z)

% initialize Demand_mat to be a 3-d tensor: 2 by size(Z)
Demand_mat=zeros([size(Z),2]);%Z=zeros(R.RasterSize);

while intermValIter.hasnext
    Demand_mat=Demand_mat+intermValIter.getnext;
end
outKVStore.add(intermKey,Demand_mat);
end

