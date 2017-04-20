classdef DemandClass
    %DEMANDCLASS �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        Demand
        R
        Lat
        Lon
    end
    
    methods
        function obj=DemandClass(file_dir)
            S=load(file_dir);
            obj.Demand=S.Demand;
            obj.R=S.R;
%% recover Lat Lon
            r=obj.R.RasterSize(1);c=obj.R.RasterSize(2);
            [row,col]=ndgrid(1:r,1:c);
            [lat,lon]=setltln(zeros(obj.R.RasterSize),obj.R,row(:),col(:));
            obj.Lat=reshape(lat,obj.R.RasterSize);
            obj.Lon=reshape(lon,obj.R.RasterSize);
        end
        [pickups,dropoffs]=Flatten(obj);
        tb=Stack(obj);
    end
    
end

