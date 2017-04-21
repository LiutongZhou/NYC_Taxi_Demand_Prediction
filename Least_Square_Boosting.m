%% Least Square Boosting Model
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
%% synchronize with weather data and add holiday marks
Demand=Demand.add_holiday_mark;
Demand.Demand=synchronize(Demand.Demand,weather.data,'first','nearest');
tb=Demand.Stack;
tb=timetable2table(tb);tb.Datetime=[];
temptb1=array2table( tb.HourlyWeatherType,'VariableNames',regexprep(weather.HourlyWeatherTypes,'\s+','_'));
temptb2=array2table( tb.DailyWeatherType,'VariableNames',strcat('Daily_',regexprep(weather.DailyWeatherTypes,'\s+','_')));
tb=[temptb1,temptb2,tb];clearvars temptb1 temptb2
tb.DailyWeatherType=[];tb.HourlyWeatherType=[];
%% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);

%% Tune Hyperparameters and Train an LSBoosting 
rng default
tic
md = fitrensemble(trainingset,'pickups',...
    'PredictorNames',{'timeofday','dayofweek','season','datenum','RegionID','is_holiday'...
    'Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip','Dailysnowfall','Dailysustainedwindspeed'},...
    'CategoricalPredictors',{'is_holiday','RegionID','season','dayofweek'},...
    'Method','LSBoost',...
    'Learner',  templateTree('PredictorSelection','interaction-curvature',...
    'NumVariablesToSample',7,'MaxNumSplits',40000),...
    'NumLearningCycles',13,'LearnRate',0.45135,'NPrint',5)
   % 'OptimizeHyperparameters',{'NumLearningCycles','MaxNumSplits','LearnRate','NumVariablesToSample'},...
   % 'HyperparameterOptimizationOptions',struct('Repartition',true,...
   % 'AcquisitionFunctionName','expected-improvement-per-second-plus',...
   % 'Holdout',0.1,...
  %  'MaxObjectiveEvaluations',10))
disp('Training Completed')
toc

%% Validation
validation=metrics (testset.pickups , md.predict(testset) );
disp('Held-out test validation results:')
disp(validation.results)
figure;
plot(md.loss(testset,'pickups','mode','cumulative'));
xlabel('Number of trees'); ylabel('MSE');

%% compact tree and save
md=removeLearners(md.compact,6:md.NumTrained);
