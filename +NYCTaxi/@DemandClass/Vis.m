function  [h,f]=Vis(obj,querytime ,type)
%VIS Visualize Demand Matrix 

%% validate parameter
p=inputParser;
addRequired(p,'DemandObj',@(x)isa(x,'NYCTaxi.DemandClass'));
addRequired(p,'time');
validationFcn=@(x) ismember(x,{'image','bar'});
addRequired(p,'Type',validationFcn );
parse(p,obj,querytime,type);
demand=obj.DemandQuery(querytime);

%% Set demand tensor
if ndims(demand)==3
    demand=demand(:,:,1); %visualize one frame 
    cmin=min(demand(:));
    cmax=max(demand(:));
elseif ndims(demand)==4
    demand=shiftdim(demand,1);%visualzie many frames
    demand=squeeze(demand(:,:,1,:));
    % set color axis limit
    cmin=min(demand(:));
    cmax=max(demand(:));
else
    error('Unexpected Results');
end
%% Visualize n frames
n=size(demand,3);
f(1:n)=figure;
switch p.Results.Type
%% imagesc
case 'image'
    h(1:n)=imagesc;% init array
    for i=1:n
        f(i)=figure(i);
        h(i)=imagesc(demand(:,:,i),[cmin,cmax]);
        colormap jet;
    end
%% Bar3
case 'bar'
    for i=1:n
        f(i)=figure(i);
        bar3d(demand(:,:,i));
        caxis([cmin,cmax]);
        zlim([cmin,cmax]);
    end
end
%% Geo show Base Map
nycshape=shaperead('nycshape\manhattan.shp',...
    'Selector',{@(BoroName) strcmpi(BoroName,'Manhattan'),'BoroName'},'UseGeoCoords',true) ;
%figure
usamap(zeros(R.RasterSize),R);framem off
axesm
f1=geoshow(nycshape);
view(3);
%% Contour on top of Geoshape base map
usamap(zeros(R.RasterSize),R);
[~,ct]=contourfm(demand,R);
cb=contourcbar(gca,'Location','southoutside');
cb.XLabel.String='Demand';
%{
contourcmap('jet', 'Colorbar', 'on', ...
   'Location', 'horizontal', ...
   'TitleString', 'Contour Intervals in Meters');
%}
for i=1:floor(length(ct.Children)/2)
    ct.Children(i).ZData=ones(size(ct.Children(i).XData))*2000;
    ct.Children(i).Color='red';
ct.Children(i).LineWidth=0.001;
end
for i=ceil(length(ct.Children)/2):length(ct.Children);ct.Children(i).FaceAlpha=0.5;ct.Children(i).FaceAlpha=0.3;end
%% Surface Plot on top of Contour
usamap(zeros(R.RasterSize),R);
f=geoshow(demand,R,'DisplayType','surface',...
                   'FaceAlpha',0.6,...
                   'CData',demand,...
                   'ZData',demand+100);
daspectm('m',0.5)
%tightmap
maptool
%% Mesh Plot
%usamap(zeros(R.RasterSize),R);
f4=geoshow(demand,R,'DisplayType','mesh');
set(f4,{'FaceAlpha','EdgeColor','EdgeAlpha','ZData'},{0,[0,0,0],0.5,zeros(size(demand))})
colormap jet
title('Manhattan');
%% texture Mesh Map on top of Mesh Base Map
usamap(zeros(R.RasterSize),R);
f5=geoshow(demand,R,'DisplayType','texturemap');
maptool
%% add stem bar
h=stem3m(40.8,-74,1000,'LineWidth',10)


%% test overlay
load_settings
load 'F:\Augustinus\Documents\MATLAB\TallArraysBigDataDemo-NYCTaxiData\wms'

figure                                                  % create a new figure
usamap(R2.LatitudeLimits, R2.LongitudeLimits);                               % limit to New York area
geoshow(A, R)  
                                       % flip image

% plot all data, unfiltered
figure
im=imagesc(R2.LongitudeLimits,R2.LatitudeLimits, flipud(A))                          % show raster map
hold on 
                                                % don't overwrite
tt=tall(ds);
ttSubarray = gather(head(tt,1000));
xbinedges = linspace(R2.LongitudeLimits(1),R2.LongitudeLimits(2),R2.RasterSize(2));      % x-axis bin edges
ybinedges = linspace(R2.LatitudeLimits(1),R2.LatitudeLimits(2),R2.RasterSize(1)); % set colormap
colormap jet   
h=histogram2(ttSubarray.pickup_longitude, ...             % overlay histogram...
    ttSubarray.pickup_latitude, ...                     % ...in 2D style
    xbinedges, ybinedges, ...                                                                   
    'FaceAlpha', 0.95,'EdgeAlpha',0.5,'FaceColor','flat')
nyc_lat = 40.7;                                         % NYC's latitude
dar = [1, cosd(nyc_lat), 1]; 
caxis([0 threshold])                                    % make color axis scaling consistent
daspect(dar)                                            % adjust ratio
set(gca,'ydir','normal'); 

%% Animation

% %% vis
% for i=1:size(Demand,3)
%     grid2image(Demand(:,:,i),R);
%     drawnow;
%     im{i} = frame2im(getframe(gcf));
%     i=i+1;
%     clf;
% end
% 
% filename = 'visdemand.gif'; % Specify the output file name
% for i = 1:length( im)
%     [A,map] = rgb2ind(im{i},256);
%     if i == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1/30);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1/30);
%     end
%    
% end
end

