%% Times series ANN
cd F:\Augustinus\Documents\GitHub\NYC_Taxi_Demand_Prediction
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
%% Construct training matrix
tb=Demand.Flatten;
X=tb{:,strncmp(tb.Properties.VariableNames,'region',6)};
ind=find(all(X==0));% sub for all zero-columns
% X(X==0)=1;
n=round(0.9*size(X,1));
train=X(1:n,:);
test=X(n+1:end,:);
%% 
