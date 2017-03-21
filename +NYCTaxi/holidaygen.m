function list=holidaygen(startdate,enddate,dir)
%holidaygen Generate a US_Holiday.txt file in Data directory
%   startdate: eg. '2016-01-01'
%   enddate: eg. '2016-12-31'
%   dir: eg. 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\holidays.txt'
%   output: a txt file, each line looks like yyyymmdd

list=holidays(datetime(startdate,'Locale','en_US'),datetime(enddate,'Locale','en_US'));
list.Format='yyyyMMdd';
i=1;
while i<=length(list)
    switch char(day(list(i),'name'))
        case 'Friday'
            list=[list(1:i); list(i)+days(1); list(i)+days(2); list(i+1:end)];
            i=i+3;
        case 'Saturday'
            list=[list(1:i); list(i)+days(1); list(i+1:end)];
            i=i+2;
        case 'Sunday'
            list=[list(1:i-1); list(i)-days(1); list(i:end)];
            i=i+2;
        case 'Monday'
            list=[list(1:i-1); list(i)-days(2); list(i)-days(1); list(i:end)];
            i=i+3;
        otherwise
            i=i+1;
    end
end
list=string(list)';
fileid=fopen(dir,'w');
fprintf(fileid,'%s\r\n',list);
end

