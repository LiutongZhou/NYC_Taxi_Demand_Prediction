function in = isinManhattan(lat,lon )
%isinManhattan returns 1 if point [lat,lon] is in Manhattan and 0 otherwise
%   
load('nycshape\ManhattanBoundary.mat','-mat','ManhattanBoundary');
in=inpolygon(lat,lon,ManhattanBoundary.Latitude,ManhattanBoundary.Longitude);
end

