%% Decision Tree Regression
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
% Construct training Table
tb=Demand.Stack;
%% plot dropoff and pickups at a busy region
subtb=tb(timerange('2016-03-01','2016-03-07'),{'RegionID','pickups','dropoffs'});
subtb=subtb(double(subtb.RegionID)==250,{'pickups','dropoffs'});
plot(subtb.Datetime,subtb.Variables,'LineWidth',1.5,'DatetimeTickFormat','uu/M/dd');
legend('Number of Pickups','Number of Dropoffs')
%% construct trainnig and test set
%delete datetime column
tb=timetable2table(tb);
tb.Datetime=[];
% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% train 1
tic
tree=fitrtree( trainingset,'pickups','PredictorNames',trainingset.Properties.VariableNames(1:5),...
    'PredictorSelection','interaction-curvature',...
    'CategoricalPredictors',{'dayofweek','season'},'MinLeafSize',3);%For boosting decision trees, set 'PredictorSelection' to default
disp('Training regression tree completed')
toc
%% tune Hyperparameters
tree = fitrtree(trainingset,'pickups','OptimizeHyperparameters','all',...
    'HyperparameterOptimizationOptions',struct('Holdout',0.1,...
    'AcquisitionFunctionName',    'expected-improvement-plus',...
    'MaxObjectiveEvaluations',10))
% Use the results to train a new, optimized tree.
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
tb=timetable2table(tb);
tb.Datetime=[];
%temptb1=array2table( tb.HourlyWeatherType,'VariableNames',regexprep(weather.HourlyWeatherTypes,'\s+','_'));
%temptb2=array2table( tb.DailyWeatherType,'VariableNames',strcat('Daily_',regexprep(weather.DailyWeatherTypes,'\s+','_')));
%tb=[temptb1,temptb2,tb];
clearvars temptb1 temptb2
tb.DailyWeatherType=[];tb.HourlyWeatherType=[];
%% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% train 2: with weather added
tic
tree=fitrtree( trainingset,...
    'pickups~RegionID+timeofday+dayofweek+season+datenum+Hourlywindspeed+Hourlyprecip+Hourlydrybulbtempc',...
    'PredictorSelection','interaction-curvature',...
    'CategoricalPredictors',{'dayofweek','season'},'MinLeafSize',3);%For boosting decision trees, set 'PredictorSelection' to default
disp('Training regression tree completed')
toc
%% tune 2
tree = fitrtree(trainingset,...
    'pickups~RegionID+timeofday+dayofweek+season+datenum+Hourlywindspeed+Hourlyprecip+Hourlydrybulbtempc',...
    'OptimizeHyperparameters','all',...
    'HyperparameterOptimizationOptions',struct('Holdout',0.1,...
    'AcquisitionFunctionName',    'expected-improvement-plus',...
    'MaxObjectiveEvaluations',10))
% Use the results to train a new, optimized tree.

%% save tree
%save('D:\OneDrive - Columbia University\2017Spring\Research\model.mat', 'model')
