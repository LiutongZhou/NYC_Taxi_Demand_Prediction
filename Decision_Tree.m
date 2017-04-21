%% Decision Tree Regression
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
% Construct training Table
tb=Demand.Stack;
%% plot dropoff and pickups at a busy region
lat=40.758027;lon= -73.985234;
ind = setpostn(zeros(Demand.R.RasterSize),Demand.R,lat,lon);
subtb=tb(timerange('2016-03-01','2016-03-07'),{'RegionID','pickups','dropoffs'});
subtb=subtb(double(subtb.RegionID)==ind,{'pickups','dropoffs'});
plot(subtb.Datetime,subtb.Variables,'LineWidth',1.5,'DatetimeTickFormat','uu/M/dd');
legend('Number of Pickups','Number of Dropoffs');
title('Pickup and Dropoff Counts at Time Square');
%% construct trainnig and test set
%delete datetime column
tb=timetable2table(tb); tb.Datetime=[];
% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% tune Hyperparameters
tree = fitrtree(trainingset,'pickups','OptimizeHyperparameters','all',...
    'HyperparameterOptimizationOptions',struct('Holdout',0.1,...
    'AcquisitionFunctionName',    'expected-improvement-plus',...
    'MaxObjectiveEvaluations',10));
disp(tree.HyperparameterOptimizationResults)
% Use the results to train a new, optimized tree.
%% train 1
tic
tree=fitrtree( trainingset,'pickups','PredictorNames',trainingset.Properties.VariableNames(1:5),...
    'PredictorSelection','interaction-curvature',...
    'CategoricalPredictors',{'dayofweek','season'},'MinLeafSize',3);%For boosting decision trees, set 'PredictorSelection' to default
disp('Training regression tree completed')
toc
%% Evaluate
% held-out test
validation=metrics (testset.pickups , tree.predict(testset) );
disp('Held-out test validation results:')
disp(validation.results)
%view feature importance
imp = table(tree.PredictorNames',tree.predictorImportance',...
    'VariableNames',{'PredictorNames','Importance'});
imp=sortrows(imp,'Importance','descend');
disp(imp)

%% synchronize with weather data
Demand.Demand=synchronize(Demand.Demand,weather.data,'first','nearest');
tb=Demand.Stack;
tb=timetable2table(tb);tb.Datetime=[];
% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% tune 2
tree = fitrtree(trainingset,...
    'pickups~RegionID+timeofday+dayofweek+season+datenum+Hourlywindspeed+Hourlyprecip+Hourlydrybulbtempc',...
    'OptimizeHyperparameters','all',...
    'HyperparameterOptimizationOptions',struct('Holdout',0.1,...
    'AcquisitionFunctionName',    'expected-improvement-plus',...
    'MaxObjectiveEvaluations',10));
disp(tree.HyperparameterOptimizationResults)
% Use the results to train a new, optimized tree.
%% train 2: with weather added
tic
tree=fitrtree( trainingset,...
    'pickups~RegionID+timeofday+dayofweek+season+datenum+Hourlywindspeed+Hourlyprecip+Hourlydrybulbtempc',...
    'PredictorSelection','interaction-curvature',...
    'CategoricalPredictors',{'dayofweek','season'},'MinLeafSize',3);%For boosting decision trees, set 'PredictorSelection' to default
disp('Training regression tree completed')
toc

%% Add Weather and Holiday
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
Demand=Demand.add_holiday_mark;
Demand.Demand=synchronize(Demand.Demand,weather.data,'first','nearest');
tb=Demand.Stack;tb=timetable2table(tb);
% split into train and test set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% train 3
tic
tree=fitrtree( trainingset,...
    'pickups~RegionID+timeofday+dayofweek+season+datenum+Hourlywindspeed+Hourlyprecip+Hourlydrybulbtempc+Dailysnowfall+is_holiday',...
    'PredictorSelection','interaction-curvature',...
    'CategoricalPredictors',{'dayofweek','season','is_holiday'},'MinLeafSize',3);
disp('Training regression tree completed')
toc
% held-out test
validation=metrics (testset.pickups , tree.predict(testset) );
disp('Held-out test validation results:')
disp(validation.results)
%% save tree
%save('D:\OneDrive - Columbia University\2017Spring\Research\model.mat', 'model')
