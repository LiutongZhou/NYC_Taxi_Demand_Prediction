function z=intpoly(f,x,y)
%intpoly(f,x,y) integrate function f(x,y) over the polygon defined by [x,y]
%   input:
%       -f: a function handle that takes in (x,y)
%   ouput:
%       -z: the value of f integrated over the polygon
% example: z=intpoly(@f(x,y),[0,1,2],[0,1,0]) will integrate f over the
% triangle defined by its three verteces (0,0), (1,1) and (2,0)

if isrow(x)
    x=x';
end
if isrow(y)
    y=y';
end
[x,y]=poly2cw(x,y);
[x,y]=closePolygonParts(x,y);
[xmin,ind1]=min(x);
x=circshift(x,-(ind1-1));
y=circshift(y,-(ind1-1));
[xmax,ind2]=max(x);
if y(2) >y(end)
    up=1:ind2;
    down=[ind2+1:length(x),1];
else
    down=1:ind2;
    up=[ind2+1:length(x),1];
end
ymin=@(xx)interp1(x(down),y(down),xx) ;%regional lower bound
ymax=@(xx)interp1(x(up),y(up),xx) ;%regional  upper bound
z=integral2(f,xmin,xmax,ymin,ymax);
end
