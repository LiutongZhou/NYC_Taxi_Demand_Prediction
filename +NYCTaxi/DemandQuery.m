function [dataarray,time ]= DemandQuery(Demand,R, querytime,lat_lon)
%DemandQuery [dataarray,time ]= DemandQuery(Demand,R, querytime,lat_lon)
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
%                   the polygon
%       -time: the timestamp vector. time(i) is the timestamp for dataarray(i,:,:,:)

%% if Demand is not sorted sort first
if ~issorted(Demand)
    Demand=sortrows(Demand) ;
end

%% if query time is a time stamp, do single time query
if ischar(querytime)% robust control
    querytime=cellstr(querytime);
end
if length(querytime)==1
    [~,dt] = isregular(Demand); %get time interval of table -->  dt
    tb=Demand(withtol(querytime,dt),:); % query control time points
    switch height(tb)
        case 3 % if three control time points, then the query timestamp happens to be a record
            dataarray=tb{2,1}{:};    % output the queried Demand values
        case 2 % if two control time points, then apply linear interpolation
            v=cat(ndims(tb.demand{1})+1,tb.demand{:});
            v=shiftdim(v,ndims(v)-1);
            dataarray= squeeze(interp1(tb.time,v,datetime(querytime)));
    end
    time=querytime{:};
    %% if query time is a time range
elseif length(querytime)==3
    % selecting subset of data by time range
    S = timerange(querytime{1},querytime{2},'closed');
    tb=Demand(S,:);
    % format data into 4-d array v
    v=cat(ndims(tb.demand{1})+1,tb.demand{:});
    v=shiftdim(v,ndims(v)-1); % shift last dimension to the first dimension
    time=datetime(querytime{1}):querytime{3}:datetime(querytime{2}); % generate query time points time
    dataarray= squeeze(interp1(tb.time,v,time));
end
%% If [lat,lon] specified, extract value within polygon
if exist('lat_lon','var')
    if size(lat_lon,1)<3
        ME = MException('myComponent:inputError','lat_lon must correctly define a polygon(s)');
        throw(ME);
    end% robust control
    %% first project [lat,lon] to planar cartesian x-y coordinates
    % set projecttion parameters
    usamap(zeros(R.RasterSize),R);
    mstruct=getm(gca);
    close all
    mstruct.geoid = wgs84Ellipsoid('sm');
    mstruct = defaultm(mstruct);
    % project raster cellgrids to x-y plane
    [Lon,Lat]=meshgrid(...
        R.LongitudeLimits(1):R.CellExtentInLongitude: R.LongitudeLimits(2),...
        R.LatitudeLimits(1):R.CellExtentInLatitude: R.LatitudeLimits(2)...
        );
    Lat=flipud(Lat);
    [X,Y]=mfwdtran(mstruct,Lon,Lat);
    [polyx,polyy]=mfwdtran(mstruct,lat_lon(:,2),lat_lon(:,1)); %convert polygon geo coordinates to x-y coordinates
    %% next Normalize the demand array by cell areas
    Yedges=-diff(Y,1,1);Yedges(:,1)=[];
    Xedges= -diff(X,1,2);Xedges(1,:)=[];
    area=Xedges.*Yedges;
    if ndims(dataarray)==3
        normalized_demand = dataarray./area;
    else
        normalized_demand=shiftdim(shiftdim(dataarray,1)./area,3);
    end 
    %% finally integrate within region. set x y limits to bounding box of polygon
    % get the polygon bounding box for integration limits
    
    %integrate interpolation over region
    q = integral2(fun,xmin,xmax,ymin,ymax)
end
    function i=region(xq,yq) % return 1 if points is in polygon and 0 otherwise
        i=inpolygon(xq,yq,polyx,polyy);
    end
end
