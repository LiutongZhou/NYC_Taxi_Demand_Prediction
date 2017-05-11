function [dataarray,time,poly_area,h ]= DemandQuery(obj, querytime,lat_lon,varargin)
%%DemandQuery [dataarray,time ]= obj.DemandQuery(querytime,lat_lon)
%             [dataarray,time,poly_area ]= obj.DemandQuery(querytime,lat_lon)
%             [dataarray,time,poly_area,h ]= obj.DemandQuery(querytime,lat_lon,'Type','timeseries')
%Query Demand values for the specified time (or time range) and locations
%   input:
%       -Demand and R: The generated Timetable Demand and Refrence Object
%       R. These are properties of the Demand object.
%
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
%                   lat_lon polygon specified, return the values within polygon. 
%                   The out put demand is normalized by area and time (unit: number of people / miles^2/hour)
%       -time: the timestamp vector. time(i) is the timestamp for dataarray(i,:,:,:)
%       -polygonarea: area of the input polygonal region in miles^2

%parse input parameters
p=inputParser; addParameter(p,'Type','none'); parse(p,varargin{:});

%% if Demand is not sorted sort first
Demand=obj.Demand;
R=obj.R;
if ~issorted(Demand)% Add Robustness
    Demand=sortrows(Demand) ;
end
%% if query time is a time stamp, do single time query
if ischar(querytime)% Add robustness
    querytime=cellstr(querytime);
end

[~,dt] = isregular(Demand); %get time interval of table -->  dt
if isnan(dt) % check demand validity
    ME = MException('MyComponent:DemandIrregular', 'The Demand time table is irregular');
    throw(ME);
end
if length(querytime)==1
    tb=Demand(withtol(querytime,dt),:); % query control time points
    switch height(tb)
        case 3 % if three control time points, then the query timestamp happens to be a record in the middle
            dataarray=tb{2,1}{:}./cellarea(R)/hours(dt);    % output the queried Demand values
        case 2 % if two control time points, then apply linear interpolation
            v=cat(ndims(tb.demand{1})+1,tb.demand{:});
            v=shiftdim(v,ndims(v)-1);
            dataarray= squeeze(interp1(tb.time,v,datetime(querytime)));
            dataarray=dataarray./cellarea(R)/hours(dt);
    end
    time=querytime{:};
    %% if query time is a time range
elseif length(querytime)==3
    % selecting subset of data by time range
    S = timerange(querytime{1},querytime{2},'closed');
    tb=Demand(S,:);
    % format data into 4-d array v
    v=cat(ndims(tb.demand{1})+1,tb.demand{:});
    v=v./cellarea(R)/hours(dt);%normalize by area and time interval
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
    dataarray=zeros(2,size(normalized_demand,4));% the fist dimension: pickup/dropoff, the second dimension: time
    for time_window=1:size(normalized_demand,4)
        for flag=1:2
            F=griddedInterpolant({lat,lon},...
                flipud( normalized_demand(:,:,flag,time_window)    )    );
            %integrate interpolation function over region          
            dataarray(flag,time_window)=NYCTaxi.intpoly(@(lat,lon)F(lat,lon),...
                lat_lon(:,1),lat_lon(:,2));
        end
    end
end
if nargout>=3 % output polygon area if three ouputs
    poly_area=areaint(lat_lon(:,1),lat_lon(:,2),wgs84Ellipsoid('sm'));
end
%% Visualization
switch p.Results.Type
    case 'TimeSeries'
        h= tsplot(time,dataarray);
    case 'DensityMatrix'
     h= Density_Matrix(time,dataarray);
end
end


%% Subrutines
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

function h=tsplot(time,Y)
% plot Y vs time
time=time(:);
if size(Y,2)==length(time)
    Y=Y';
end%Robust Control

h=plot(time,Y,'LineWidth',1.5, 'DatetimeTickFormat','MMMM dd, HH:mm');
ylabel('Density (pickups / miles^2 / hour)');
ax=gca;
ax.XLim.Format='u-M-dd HH:mm';
ax.XAxis.MinorTick='on';
ax.XAxis.MinorTickValues=time;
ax.XGrid='on';
ax.XTickLabel{end}=max(time.Year);
ax.XTick(end)=max(time);
legend('pickup density','dropoff density');
end

function im=Density_Matrix(time,dataarray)
%Density_Matrix Density_Matrix(time,dataarray) plots density matrix
tb=timetable(time(:),dataarray(1,:)',dataarray(2,:)',...
    'VariableNames',{'pickup_density','dropoff_density'});
tb.hour=hour(tb.Time);
tb.day=day(tb.Time);
n_days=numel(unique(tb.day));
n_hours=numel(unique(tb.hour));
ind=sub2ind([n_days,n_hours],tb.day-(min(tb.day)-1),tb.hour+1);
Density=zeros(n_days,n_hours);
Density(ind)=tb.pickup_density;
%% Visualize
im=imagesc([min(tb.hour),max(tb.hour)],[min(tb.day),max(tb.day)],Density);
colormap hot;c=colorbar;c.Label.String='Density (pickup/miles^2/hour)';
ax=gca;
ax.XTick=0:23;xlabel('Hour');
ax.YTick=1:2:31;ylabel('Day');
ax.YAxis.MinorTickValues=2:2:30;
ax.YAxis.MinorTick='on';
ylim([min(tb.day)-0.5,max(tb.day)+0.5]);
end
