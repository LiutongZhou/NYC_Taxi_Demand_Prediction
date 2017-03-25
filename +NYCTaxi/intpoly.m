function z=intpoly(f,x,y)
%intpoly(f,x,y) integrate function f(x,y) over the convex polygon defined by [x,y]
%   input: 
%       -f: a function handle that takes in (x,y)
%   ouput:
%       -z: the value of f integrated over the polygon
%[x,y]=poly2cw(x,y);
if isrow(x)
    x=x';
end
if isrow(y)
    y=y';
end

xmin=min(x);xmax=max(x);
sep_x1=xmin;
sep_x2=xmax;
sep_y1=y(x==xmin);
sep_y2= y(x==xmax);
bench_y=interp1([sep_x1(1);sep_x2(1)],[sep_y1(1);sep_y2(1)],x);
up=y>=bench_y;% logical index for up points
down=y<=bench_y;% logical index for lower points
ymin=@(xx)interp1(x(down),y(down),xx) ;%regional lower bound
ymax=@(xx)interp1(x(up),y(up),xx) ;%regional  upper bound
z=integral2(f,xmin,xmax,ymin,ymax);
end
