function [daily_weather,hourly_weather]=ParseWeatherType(weather)
%ParseWeatherType [daily_weather,hourly_weather]=weather.ParseWeatherType

%% Initialize parameters
daily_type_keys=weather.type_mapper(1:9,1);
daily_type_values=weather.type_mapper(1:9,2);
hourly_type_keys=weather.type_mapper(10:end,1);
hourly_type_values=weather.type_mapper(10:end,2);
tb_daily=weather.daily;
tb_hourly=weather.hourly;

%% Parsing Weather Types
% step 1.string split dailyweather type
% step 2. map type list cell string to weather types (categories)
% step 3 for each tokennized weather type column, use grp2idx to decide which
% group the type is and then 
% step 4 put 1 in the corresponding columns of dummy matrix and 0s elesewhere

% for daily weather
list=cellfun(@(x) strsplit(x,{' '}),tb_daily.Dailyweather,'UniformOutput',false); % step 1
decode= @(cell_string) categorical(cell_string, daily_type_keys, daily_type_values); %step 2
daily_weather_types=cellfun( decode,list,'UniformOutput',false);

% for hourly weather
list=cellfun(@(x) strsplit(x,{' ','|'}),tb_hourly.HourlyWeatherType ,'UniformOutput',false); %step 1
decode= @(cell_string) categorical(cell_string, hourly_type_keys, hourly_type_values); %step 2
hourly_weather_types=cellfun(decode,list,'UniformOutput',false);

%% step 3 and step 4
%for daily weather
[daily_dummy,daily_weather_label]=cate2dummy(daily_weather_types);
tb_daily_weather=array2table(daily_dummy,'VariableNames',...
    regexprep(daily_weather_label,'\s+','_') );
%for hourly weather
[hourly_dummy,hourly_weather_label]=cate2dummy(hourly_weather_types);
tb_hourly_weather=array2table(hourly_dummy,'VariableNames',...
    regexprep( hourly_weather_label ,'\s+','_') );

%% Reorganize data
tb_daily_weather.Datetime=tb_daily.Datetime;
tb_daily_weather=table2timetable(tb_daily_weather);
tb_hourly_weather.Datetime=tb_hourly.Datetime;
tb_hourly_weather=table2timetable(tb_hourly_weather);

%% Encapsulate results
daily_weather=struct('label',{daily_weather_label},...
    'dummy',daily_dummy,'table',tb_daily_weather);
hourly_weather=struct('label',{hourly_weather_label},...
    'dummy',hourly_dummy,'table',tb_hourly_weather);
%% Set Weather object Properties
weather.DailyWeatherTypes=daily_weather_label;
weather.HourlyWeatherTypes=hourly_weather_label;
end

%% Subrutine
function [dummy,label]=cate2dummy(catcell)
%cate2dummy Given a cellarray containing categorical vector values, output
%the dummy matrix and the category labels for each column of dummy matrix
%   -input:
%       catcell: a cell. catcell{i} contains weather categories for the
%       i-th record
%   -output:
%       dummy: a dummy matrix. dummy(i,:) are the binary dummy variables
%       indicating which category of weather the i-th record has
%       label: length(label)=size(dummy,2), the label{i} is the label for the i-th
%       category

label=categories( catcell{1} );
Gidx=cellfun( @grp2idx,catcell,'UniformOutput',false );

%% create dummy
n=length(Gidx);
% dummy=false(n,length(label));
subs=[];
for i =1:n
    ind=ismissing( Gidx{i} );% logical index for missing values in Gidx{i}
    if any( ~ind ) % if any value of the ith record is not missing
        tempj=Gidx{i}(~ind);
        tempj=unique(tempj);
        tempi=repmat(i, length(tempj) ,1 );
        subs=[ subs; [tempi,tempj(:)] ];
    end
end
    
dummy= sparse ( subs(:,1), subs(:,2), true ,n, length(label), size(subs,1) ); % size(dummy)=n*length(label), and has size(subs,1) nonzeros     
end
