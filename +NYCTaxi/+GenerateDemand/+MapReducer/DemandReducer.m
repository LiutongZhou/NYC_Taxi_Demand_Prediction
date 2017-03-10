function DemandReducer(intermKey, intermValIter, outKVStore,Z)
%DEMANDREDUCER Reducer for DemandGen
%   DemandReducer(intermKey, intermValIter, outKVStore,Z)
Demand_mat=Z;
while intermValIter.hasnext
    Demand_mat=Demand_mat+intermValIter.getnext;
end
outKVStore.add(intermKey,Demand_mat);
end

