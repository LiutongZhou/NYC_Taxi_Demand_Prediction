%% Random Forest
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

%% Train and Tune
tic
md = TreeBagger(10,trainingset,'pickups', 'PredictorNames',...
    {'timeofday','dayofweek','season','datenum','RegionID','is_holiday'...
    'Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip','Dailysnowfall','Dailysustainedwindspeed'},...
    'CategoricalPredictors',{'is_holiday','RegionID','season','dayofweek'},...
    'Method','regression',    'PredictorSelection','interaction-curvature',...
    'OOBPredictorImportance','on',...
    'NumPrint',5,'Options',statset('UseParallel',true));
disp('Training Completed')
toc
%% Validation
validation=metrics (testset.pickups , md.predict(testset) );
disp('Held-out test validation results:')
disp(validation.results)
figure;
plot(md.error(testset,'pickups','mode','cumulative'));
xlabel('Number of trees'); ylabel('MSE');

%% feature importance analysis
imp = md.OOBPermutedPredictorDeltaError;
imp=table(md.PredictorNames',imp','VariableNames',{'Predictor','Importance'});
imp=sortrows(imp,'Importance','descend');
disp(imp);



