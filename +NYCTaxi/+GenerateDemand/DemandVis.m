function [ output_args ] = DemandVis( demand,R )
%DEMANDVIS 此处显示有关此函数的摘要
%   此处显示详细说明
demand=Demand.demand{1}(:,:,1);

%% imagesc
figure
im=imagesc(demand);

%% Geo show Base Map
nycshape=shaperead('nycshape\manhattan.shp',...
    'Selector',{@(BoroName) strcmpi(BoroName,'Manhattan'),'BoroName'},'UseGeoCoords',true) ;
figure
usamap(zeros(R.RasterSize),R);
f1=geoshow(nycshape);
%% Contour on top of Geoshape base map
usamap(zeros(R.RasterSize),R);
contourfm(demand,R)
cb=contourcbar(gca,'Location','southoutside');
cb.XLabel.String='haha';
%contourcmap('jet', 'Colorbar', 'on', ...
   'Location', 'horizontal', ...
   'TitleString', 'Contour Intervals in Meters');

%% Surface Plot on top of Contour
usamap(zeros(R.RasterSize),R);
f=geoshow(demand,R,'DisplayType','surface','ZData',demand+2500,'CData',demand)
f.FaceAlpha=0.5;
view(3)
tightmap
daspectm('m',2)

%% Mesh Base Map
usamap(zeros(R.RasterSize),R);
f4=geoshow(Demand.demand{1}(:,:,1),R,'DisplayType','mesh')
%% texture Mesh Map on top of Mesh Base Map
usamap(zeros(R.RasterSize),R);
f5=geoshow(demand,R,'DisplayType','texturemap');
%% 3-D lighted shaded relief of regular data grid on top of texture Mesh Map
usamap(zeros(R.RasterSize),R);
f2= meshlsrm(demand,R,[0,90]);
maptool
%% add stem bar
h=stem3m(40.8,-74,1000,'LineWidth',10)

%% Manhattan All Year Round
 colormap(gray(256)) 

%% Bar
b=bar3(Demand.demand{1}');
lift=20*max(max(b(1).ZData));
for k = 1:length(b)
    b(k).CData = b(k).ZData;
    b(k).FaceColor = 'interp';
    b(k).FaceAlpha=1;
    b(k).EdgeAlpha=0.25;
  %  b(k).EdgeColor=[1 1 1];
  b(k).ZData=b(k).ZData+lift
end
c=colormap('jet');
c(1,:)=1;
colormap(c);
colorbar
hold on
contour(Z);
axis off;
grid2image(Demand.demand{1},R)
figure
usamap(Z,R)
geoshow(Z,R,'DisplayType','texturemap')

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

