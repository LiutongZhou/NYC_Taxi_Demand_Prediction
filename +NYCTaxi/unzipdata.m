function unzipdata(file_dir)
%%unzipdata unzipdata(file_dir) Unzip data in the specified folder
% example: unzipdata('S:\DataBackup\Weather')

files=dir(fullfile(file_dir,'*.zip'));
if isempty(files)
    return
end

try
    gunzip(fullfile(file_dir,'*.zip'),file_dir);
catch ME
    if strcmp(ME.identifier,'MATLAB:gunzip:notGzipFormat')      
        for i=1:length(files)
            unzip(fullfile(files(i).folder,files(i).name),file_dir);
        end
    end
end

delete(fullfile(file_dir,'*.zip'));
%% rename
files=dir(file_dir);
files=files(~[files.isdir]);
for i=1:length(files)
    [~,~,ext_name]=fileparts(files(i).name);
    if isempty(ext_name)
        filename=fullfile(files(i).folder,files(i).name);
        movefile(filename,[filename,'.csv']);
    end
end
end
