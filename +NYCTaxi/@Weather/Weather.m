classdef Weather < handle
    %Weather Weather of NYC
    %   daily weather
    %   hourly weather
    %   raw weather data which also contains monthly weather
    
    properties
        path char
        file_name char
    end
    properties(Dependent,SetAccess=private)% derived properties
        rawdata table
        daily timetable
        hourly timetable
        refined timetable
    end
    properties(Hidden)      
        type_mapper;
    end
    methods
        function Weather=Weather(file_name)% constructor
            Weather.file_name=file_name;
            Weather.path= fileparts(file_name);
            S=load('+NYCTaxi/@Weather/WeatherTypeMapper.mat');
            Weather.type_mapper=S.type_mapper;
        end
        CleanWeather(Weather)
        ParseWeatherType(Weather)
    end
    %% Access Methods
    methods
        function rawdata=get.rawdata(Weather)
            rawdata=readrawdata(Weather);
        end      
        function tb_daily=get.daily(Weather)
            filename= fullfile(Weather.path,'Clean_Daily.csv') ;
            if exist(filename,'file')~=2 % if no Clean_Daily.csv in the path, generate it
                Weather.CleanWeather
            end
            opts = detectImportOptions ( filename );
            % choose snow precip /snow depth/ daily wearther type
            opts.SelectedVariableNames={'Date','Dailyweather','Dailysnowfall','Dailysnowdepth','Dailysustainedwindspeed'};
            tb_daily=readtable( filename,opts);
            tb_daily=table2timetable(tb_daily);
            tb_daily.Properties.DimensionNames{1}='Datetime';
        end
        function tb_hourly=get.hourly(Weather)
            filename= fullfile(Weather.path,'Clean_Hourly.csv') ;
            if exist(filename,'file')~=2 % if no Clean_Hourly.csv in the path, generate it
                Weather.CleanWeather
            end
            opts = detectImportOptions ( filename );
            opts.SelectedVariableNames={'Date','Hourlyprsentweathertype','Hourlydrybulbtempc','Hourlywindspeed','Hourlyprecip'};
            tb_hourly=readtable( filename,opts);
            tb_hourly.Properties.VariableNames([1,2])={'Datetime','HourlyWeatherType'};
            tb_hourly=table2timetable(tb_hourly);
        end     
        function refined=get.refined(Weather)
            %[~,]=Weather.ParseWeatherType;
        end
    end
    %% private methods (only for internal use)
    methods(Access=private, Hidden=true)
        tb=readrawdata(obj)
    end
end
