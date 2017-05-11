classdef DemandClass
    %DEMANDCLASS Construct the Demand Object by Calling DemandClass(file_dir)
    %   e.g. Demand=DemandClass( 'D:\OneDrive - Columbia University\2017Spring\Research\Data\Data\Demand.mat')
    
    properties
        Demand
        R
        Lat
        Lon
    end
    methods
        %Constructor
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
        Demand=add_holiday_mark(Demand);
        [dataarray,time,poly_area,h ]= DemandQuery(obj, querytime,lat_lon,varargin)
    end
    
end

