classdef Weather < handle
    %Weather Weather of NYC
    %   daily weather
    %   hourly weather
    %   raw weather data which also contains monthly weather
    
    properties
        path char
        file_name char
        rawdata table
        daily timetable
        hourly timetable
        DailyWeatherTypes
        HourlyWeatherTypes
    end
    
    properties(Hidden)
        type_mapper;
    end
    
    methods %ordinary methods
        function Weather=Weather(file_name)% constructor
            Weather.file_name=file_name;
            Weather.path= fileparts(file_name);
            Weather.rawdata=readrawdata(Weather);
            Weather.daily=getdaily(Weather);
            Weather.hourly=gethourly(Weather);
            S=load('+NYCTaxi/@Weather/WeatherTypeMapper.mat');
            Weather.type_mapper=S.type_mapper;
        end
        CleanWeather(Weather)
        [daily_weather,hourly_weather]=ParseWeatherType(Weather)
        function refined=refine(Weather)
            [dailywt,hourlywt]=Weather.ParseWeatherType;
            tb_daily=Weather.daily(:,2:end);
            tb_daily.DailyWeatherType=dailywt.dummy;
            tb_hourly=Weather.hourly(:,2:end);
            tb_hourly.HourlyWeatherType=hourlywt.dummy;
            refined=synchronize(tb_hourly,tb_daily,'first','nearest');
        end
        save2mat(obj,outputpath)
    end
    methods(Static)
        convert2hdf5(file_dir)
    end
    methods(Access=private, Hidden=true)% private methods (only for internal use)
        tb=readrawdata(obj)
        function tb_daily=getdaily(Weather)
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
        function tb_hourly=gethourly(Weather)
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
    end
end
