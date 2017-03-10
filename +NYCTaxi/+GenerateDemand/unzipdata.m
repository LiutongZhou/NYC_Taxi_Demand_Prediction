function unzipdata(file_dir)
%% Unzip data in the specified folder

if ~exist('file_dir','var')
    file_dir='S:\DataBackup\cleanyellow';
end
gunzip(fullfile(file_dir,'*.zip'),file_dir);
delete(fullfile(file_dir,'*.zip'));
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