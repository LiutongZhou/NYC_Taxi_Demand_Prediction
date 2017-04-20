%% Two Layer ANN
cd F:\Augustinus\Documents\GitHub\NYC_Taxi_Demand_Prediction
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
Demand.Demand=synchronize(Demand.Demand,...
    weather.data(:,{'Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip','Dailysnowfall'}),...
    'first','nearest');
tb=Demand.Stack;
% add lat lon column
n=numel(unique(tb.Datetime));
tb.Lat=repmat(Demand.Lat(:),n,1);
tb.Lon=repmat(Demand.Lon(:),n,1);
tb.timeofday=categorical(tb.timeofday,'Ordinal',true);
tb.RegionID=double(tb.RegionID);
%% Construct training matrix
response=sparse(tb.pickups);
predictor=tb(:,setdiff(tb.Properties.VariableNames,{'pickups','dropoffs','Datetime','RegionID'}));
varnames={'timeofday','dayofweek','season'};%set these features to be categorical
X=[];
for i=varnames
X=[X,sparse(dummyvar(predictor{:,i}))];
end
X=[X,predictor{:, setdiff(    predictor.Properties.VariableNames,...
                              varnames    ) ...
               }];

%% split to train set and test set
n=round(0.9*size(X,1));
train_X=X(1:n,:);
train_Y=response(1:n,:);
test_X=X(n+1:end,:);
test_Y=response(n+1:end,:);
%% Construct Network
net1=fitnet(10);
net1=configure(net1,full(train_X'),full(train_Y'));
view(net1);
%% train
net_trained = train(net1,full(train_X'),full(train_Y'),'useParallel','yes');
%% Validate
out= net_trained(test_X');
evaluation=metrics(test_Y(:),out(:));
evaluation.results
