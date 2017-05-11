function b=bar3d(demand,varargin)
%bar barplot for demand matrix

%% init
p=inputParser;
p.FunctionName='bar3d';
addOptional(p,'type','3d',@(x)ismember(x,{'2d','3d'}));
parse(p,varargin{:});
%% Plot
b=bar3(demand);
set(b,{'FaceColor','FaceAlpha','EdgeAlpha'},{'interp',1,0.2});
set(b,{'CData'},{b.ZData}');
if strcmp(p.Results.type,'2d')
    view(2);
end
c=colormap('jet');c(1,:)=1;colormap(c);
c=colorbar(gca,'Location','eastoutside');
c.Label.String='Pickup Demand';
c.Label.Rotation=90;
c.Label.HorizontalAlignment='center';
ax=gca;
ax.XTick=0:2:size(demand,2);
ax.YTick=0:2:size(demand,1);
ax.XAxis.MinorTickValues=ax.XTick(1:end-1)+1;
ax.YAxis.MinorTickValues=ax.YTick(1:end-1)+1;
ax.XMinorTick='on';ax.YMinorTick='on';
xlim([0,size(demand,2)+1]);ylim([0,size(demand,1)+1]);
end
