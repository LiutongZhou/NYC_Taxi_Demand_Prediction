%% Two Layer ANN
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
% add holiday and weather
Demand=Demand.add_holiday_mark;
Demand.Demand=synchronize(Demand.Demand,...
    weather.data(:,{'Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip','Dailysnowfall'}),...
    'first','nearest');
tb=Demand.Stack;
% add lat lon column
n=numel(unique(tb.Datetime));
tb.Lat=repmat(Demand.Lat(:),n,1);
tb.Lon=repmat(Demand.Lon(:),n,1);
% add polynomial terms if necessary
%tb.timeofday_power4=tb.timeofday.^4;
tb.timeofday=categorical(tb.timeofday,'Ordinal',true);
tb.RegionID=double(tb.RegionID);
tb.is_holiday=double(tb.is_holiday);

%% Construct training matrix X and response Y
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
% Normalization
for i=1:size(X,2);
    if ~all(X(:,i)==0 | X(:,i)==1)
        X(:,i)=zscore(X(:,i));
    end
end

%% split to train set and test set
n=round(0.95*length(response));
train_X=X(round(n/2):n,:);
train_Y=response(round(n/2):n,:);
test_X=X(n+1:end,:);
test_Y=response(n+1:end,:);
clearvars X response tb predictor
%% Construct Network
net1=fitnet(10);
net1=configure(net1,full(train_X'),full(train_Y'));
view(net1);
%% train
net_trained = train(net1,full(train_X'),full(train_Y'),'useParallel','yes','useGPU','yes');
%% Validate
out= net_trained(test_X');
evaluation=metrics(test_Y(:),out(:));
evaluation.results
