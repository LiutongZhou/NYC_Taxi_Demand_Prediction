%% Prepare Data
import NYCTaxi.*
load 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Meteorology'
Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat');
% synchronize with weather data and add holiday marks
Demand=Demand.add_holiday_mark;
Demand.Demand=synchronize(Demand.Demand,weather.data,'first','nearest');
tb=Demand.Stack;
tb=timetable2table(tb);tb.Datetime=[];
temptb1=array2table( tb.HourlyWeatherType,'VariableNames',regexprep(weather.HourlyWeatherTypes,'\s+','_'));
temptb2=array2table( tb.DailyWeatherType,'VariableNames',strcat('Daily_',regexprep(weather.DailyWeatherTypes,'\s+','_')));
tb=[temptb1,temptb2,tb];clearvars temptb1 temptb2
tb.DailyWeatherType=[];tb.HourlyWeatherType=[];
%% Get Predictors X and response Y
Predictor_Names={'timeofday','dayofweek','season','datenum','RegionID','is_holiday',...
    'Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip','Dailysnowfall','Dailysustainedwindspeed'};
X=varfun(@double,tb,'InputVariables',Predictor_Names);
X=table2array(X);
Y=tb.pickups;
clearvars tb

%% XGBoosting
md=Model;
n=floor(0.02*size(X,1));

md.trainingset.Predictors = X(end-5*n:end-n-1,:);
md.trainingset.Response = Y(end-5*n:end-n-1,:);
md.testset.Predictors = X(end-n:end,:);
md.testset.Response =Y(end-n:end,:);
md.Type='XGBoost';
md.options.NumIter=uint32(500);
%% Optimize
shrinkageFactor = optimizableVariable('shrinkageFactor',[0.1,1],'Type','real');
maxTreeDepth=optimizableVariable('maxTreeDepth',[2,20],'Type','integer');
subsamplingFactor = optimizableVariable('subsamplingFactor',[0.1,0.5],'Type','real');
NumIter=optimizableVariable('NumIter',[500,10^4],'Type','integer','Transform','log');
fun = @(x)XGBoost.loss(x,md);
results = bayesopt(fun,[shrinkageFactor,maxTreeDepth,subsamplingFactor,NumIter],...
    'IsObjectiveDeterministic',true,'MaxObjectiveEvaluations',25,'MaxTime',60*60*5);

%% train
md.train;

%% Test model
md.Validate

