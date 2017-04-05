%% Read Meteorology.h5

file='D:\OneDrive - Columbia University\2017Spring\Research\Data\BJ_Meteorology.h5';
%h5disp(file);
tb=table();
tb.Date=h5read(file,'/date');
tb.Weather=[h5read(file,'/Weather')]';
tb.Temperature=h5read(file,'/Temperature');
tb.WindSpeed=h5read(file,'/WindSpeed');
tb(1:5,:)
%% unzip data

import NYCTaxi.*
file_dir='S:\DataBackup\Weather';
unzipdata(file_dire);
%% select Central Park Station

files=dir([file_dir,'\*.txt']);
files=fullfile({files.folder}',{files.name}');
tbs={};
for i=1:length(files)
ds=datastore(files{i},'Delimiter',{',','|'});
ds.SelectedFormats(:)={'%s'};
tbs{i}=ds;
end