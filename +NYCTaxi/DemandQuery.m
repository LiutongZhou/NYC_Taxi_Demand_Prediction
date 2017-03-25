function [dataarray,time ]= DemandQuery(Demand,R, querytime,lat_lon)
%%DemandQuery [dataarray,time ]= DemandQuery(Demand,R, querytime,lat_lon)
%Query Demand values for the specified time (or time range) and locations
%   input:
%       -querytime: a timestamp like {'2016-01-01 10:00:00'}
%                   or a time range like {'starttime','endtime',timeinterval}
%                   if querytime is a timestamp, return Demand values for the specified time
%                   if querytime is a time range, return Demand values
%                   during range interpolated using specified timeinterval.
%                   eg. timeinterval= hours(1),minutes(15),seconds(100)...
%       -lat_lon: polygon points specified by [lat,lon] matrix
%   output:
%       -dataarray: 4-d array with the first dimension denoting time. and
%                   last dimension denoting pickup (1) or dropoff(2). If
%                   lat_lon polygon specified, return the values defined by
%                   the polygon. The out put demand is normalized by area (unit: number of people / miles^2)
%       -time: the timestamp vector. time(i) is the timestamp for dataarray(i,:,:,:)

%% if Demand is not sorted sort first
if ~issorted(Demand)% Add Robustness
    Demand=sortrows(Demand) ;
end
%% if query time is a time stamp, do single time query
if ischar(querytime)% Add robustness
    querytime=cellstr(querytime);
end
if length(querytime)==1
    [~,dt] = isregular(Demand); %get time interval of table -->  dt
    tb=Demand(withtol(querytime,dt),:); % query control time points
    switch height(tb)
        case 3 % if three control time points, then the query timestamp happens to be a record in the middle
            dataarray=tb{2,1}{:}./cellarea(R);    % output the queried Demand values
        case 2 % if two control time points, then apply linear interpolation
            v=cat(ndims(tb.demand{1})+1,tb.demand{:});
            v=shiftdim(v,ndims(v)-1);
            dataarray= squeeze(interp1(tb.time,v,datetime(querytime)));
            dataarray=dataarray./cellarea(R);
    end
    time=querytime{:};
    %% if query time is a time range
elseif length(querytime)==3
    % selecting subset of data by time range
    S = timerange(querytime{1},querytime{2},'closed');
    tb=Demand(S,:);
    % format data into 4-d array v
    v=cat(ndims(tb.demand{1})+1,tb.demand{:});
    v=v./cellarea(R);%normalize by area
    v=shiftdim(v,ndims(v)-1); % shift last dimension: time to the first dimension
    time=datetime(querytime{1}):querytime{3}:datetime(querytime{2}); % generate query time points time
    dataarray= squeeze(interp1(tb.time,v,time));% interp along time dimension
end
%% If [lat,lon] specified, extract value within polygon
if exist('lat_lon','var')
    if size(lat_lon,1)<3 % robust control
        ME = MException('myComponent:inputError','lat_lon must correctly define a polygon(s)');
        throw(ME);
    end
    %% first Normalize the demand array by cell areas :(lat*lon)
    area=R.CellExtentInLatitude*R.CellExtentInLongitude;
    if ndims(dataarray)==3
        normalized_demand = dataarray/area;
    else
        normalized_demand=shiftdim(dataarray,1)/area;
    end
    %% next integrate normalized_demand within region.
    %generate interpolation function
    lat=(R.LatitudeLimits(1):R.CellExtentInLatitude:R.LatitudeLimits(2))';
    lon=(R.LongitudeLimits(1):R.CellExtentInLongitude:R.LongitudeLimits(2))';
    lat=lat(1:end-1)+R.CellExtentInLatitude/2;
    lon=lon(1:end-1)+R.CellExtentInLongitude/2;
    dataarray=zeros(2,size(normalized_demand,4));
    for time_window=1:size(normalized_demand,4)
        for flag=1:2
            F=griddedInterpolant({lat,lon},...
                flipud( normalized_demand(:,:,flag,time_window)    )    );
            %integrate interpolation function over region
            
            %run an efficient algorithm
            
            dataarray(flag,time_window)=NYCTaxi.intpoly(@(lat,lon)F(lat,lon),...
                lat_lon(:,1),lat_lon(:,2));
                    
            %{
            %This is inefficient, use intpoly instead.
                warning('off');
                dataarray(flag,time_window)   = integral2(@(lat,lon)F(lat,lon).*region(lat,lon),...
                    min(lat_lon(:,1)),max(lat_lon(:,1)),min(lat_lon(:,2)),max(lat_lon(:,2)));
                warning('on');
             %}                   
        end
    end
end
%{
function i=region(qlat,qlon) % return 1 if query points is in polygon and 0 otherwise
        i=inpolygon(qlat,qlon,lat_lon(:,1),lat_lon(:,2));
    end
%}
end

function area=cellarea(R)
%cellarea area=cellarea(R)
%   input:
%       -R: Raster Geo Reference Object
%   output:
%       -area: cell areas in miles^2

[Lon,Lat]=meshgrid(...
    R.LongitudeLimits(1):R.CellExtentInLongitude: R.LongitudeLimits(2),...
    R.LatitudeLimits(1):R.CellExtentInLatitude: R.LatitudeLimits(2)...
    );
Lat=flipud(Lat);
area=areaquad(Lat(1:end-1,1:end-1),Lon(1:end-1,1:end-1),Lat(2:end,2:end),Lon(2:end,2:end),wgs84Ellipsoid('sm'));
end
