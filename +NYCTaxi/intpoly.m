function z=intpoly(f,x,y)
%intpoly z=intpoly(f,x,y) integrate function f(x,y) over the polygon defined by [x,y]
%   input:
%       -f: a function handle that takes in (x,y)
%   ouput:
%       -z: the value of f integrated over the polygon
% example: 
% fill([0,1,2],[0,1,0],'b') %this is the triangle region
% f=@(x,y)exp(x+y);
% z=intpoly(f,[0,1,2],[0,1,0]) will integrate f over the
% triangle region defined by its three verteces (0,0), (1,1) and (2,0)
% ver.1.0
% By: Liutong Zhou
% 2017/3/25
if isrow(x)
    x=x';
end
if isrow(y)
    y=y';
end
% delete duplicate verterces
mypolygon=unique([x,y],'rows','stable');
x=mypolygon(:,1);
y=mypolygon(:,2);

%[x,y]=poly2cw(x,y);
[xmin,ind1]=min(x);
x=circshift(x,-(ind1-1));
y=circshift(y,-(ind1-1));
[xmax,ind2]=max(x);
if y(2) >y(end)
    up=1:ind2;
    down=[ind2:length(x),1];
else
    down=1:ind2;
    up=[ind2:length(x),1];
end
x_down=x(down);y_down=y(down);% down points
x_up=x(up);y_up=y(up);% up points
%% robust control
[~,duplicates]=findduplicate(x_down);
if ~isempty(duplicates)
    ind= duplicates==x_down;
    y_down(ind)=min(y_down(ind));
    temp=unique([x_down,y_down],'rows','stable');
    x_down=temp(:,1);y_down=temp(:,2);
end
%robust control
[~,duplicates]=findduplicate(x_up);
if ~isempty(duplicates)
    ind= duplicates==x_up;
    y_up(ind)=max(y_up(ind));
    temp=unique([x_up,y_up],'rows','stable');
    x_up=temp(:,1);y_up=temp(:,2);
end
%% integrate
ymin=@(xx)interp1(x_down,y_down,xx) ;%regional lower bound
ymax=@(xx)interp1(x_up,y_up,xx) ;%regional  upper bound
z=integral2(f,xmin,xmax,ymin,ymax);
end

function [ind,varargout]=findduplicate(X)
%findduplicate findduplicate(X) returns a linear index ind for duplicate
%records in X. findduplicate treat each row in X as a record. 
%   input: 
%       -X: vector, array, table or timetable. 
%   output: 
%       -ind: linear index for duplicated records in X, including the first
%       value of the duplicates
%       -duplicated values: optional
%   tip: to find duplicate values in a matrix, use findduplicate(X(:))

[~,uniqueid,~]=unique(X,'rows');
ind=setdiff(1:size(X,1),uniqueid);
if nargout==2
    varargout{1}=unique(X(ind,:));
end
end




