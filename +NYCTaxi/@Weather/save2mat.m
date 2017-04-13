function save2mat(obj,outputpath)



refined=obj.refine;

weather=struct('data',refined,...
    'DailyWeatherTypes',{obj.DailyWeatherTypes},...
    'HourlyWeatherTypes',{obj.HourlyWeatherTypes});
save(fullfile(outputpath,'Meteorology.mat'),'weather');

disp('Refined Weather Data saved to: ');
disp(fullfile(outputpath,'Meteorology.mat'));

end
