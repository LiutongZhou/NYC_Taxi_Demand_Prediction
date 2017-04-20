%% Random Forest
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
import NYCTaxi.*
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
% Construct training Table
tb=Demand.Stack;
%% synchronize with weather data
Demand.Demand=synchronize(Demand.Demand,weather.data,'first','nearest');
tb=Demand.Stack;
tb=timetable2table(tb);
tb.Datetime=[];
temptb1=array2table( tb.HourlyWeatherType,'VariableNames',regexprep(weather.HourlyWeatherTypes,'\s+','_'));
temptb2=array2table( tb.DailyWeatherType,'VariableNames',strcat('Daily_',regexprep(weather.DailyWeatherTypes,'\s+','_')));
tb=[temptb1,temptb2,tb];
clearvars temptb1 temptb2
tb.DailyWeatherType=[];tb.HourlyWeatherType=[];
%% split into training and testing set
n=floor(height(tb)*0.9);
trainingset=tb(1:n,:);
testset=tb(n+1:end,:);
%% train
rng default
tic
md = fitrensemble(trainingset,'pickups',...
    'PredictorNames',{'timeofday','dayofweek','season','datenum','RegionID',...
    'Hourlydrybulbtempc','Dailysnowfall','Dailysustainedwindspeed'},...
    'Method','LSBoost',...
    'Learner',  'tree',...
    'NumLearningCycles',10)
   % 'OptimizeHyperparameters',{'NumLearningCycles','MaxNumSplits','LearnRate'},...
   % 'HyperparameterOptimizationOptions',struct('Repartition',true,...
   % 'AcquisitionFunctionName','expected-improvement-plus',...
   % 'Holdout',0.1,...
  %  'MaxObjectiveEvaluations',10))
disp('Training Random Forest Completed')
  toc
%% Add holiday
%% Validation
validation=metrics (testset.pickups , md.predict(testset) );
disp('Held-out test validation results:')
disp(validation.results)
