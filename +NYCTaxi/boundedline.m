function varargout = boundedline(varargin)
%BOUNDEDLINE Plot a line with shaded error/confidence bounds
%
% [hl, hp] = boundedline(x, y, b)
% [hl, hp] = boundedline(x, y, b, linespec)
% [hl, hp] = boundedline(x1, y1, b1, linespec1,  x2, y2, b2, linespec2)
% [hl, hp] = boundedline(..., 'alpha')
% [hl, hp] = boundedline(..., ax)
% [hl, hp] = boundedline(..., 'transparency', trans)
% [hl, hp] = boundedline(..., 'orientation', orient)
% [hl, hp] = boundedline(..., 'nan', nanflag)
% [hl, hp] = boundedline(..., 'cmap', cmap)
%
% Input variables:
%
%   x, y:       x and y values, either vectors of the same length, matrices
%               of the same size, or vector/matrix pair where the row or
%               column size of the array matches the length of the vector
%               (same requirements as for plot function).
%
%   b:          npoint x nside x nline array.  Distance from line to
%               boundary, for each point along the line (dimension 1), for
%               each side of the line (lower/upper or left/right, depending
%               on orientation) (dimension 2), and for each plotted line
%               described by the preceding x-y values (dimension 3).  If
%               size(b,1) == 1, the bounds will be the same for all points
%               along the line.  If size(b,2) == 1, the bounds will be
%               symmetrical on both sides of the lines.  If size(b,3) == 1,
%               the same bounds will be applied to all lines described by
%               the preceding x-y arrays (only applicable when either x or
%               y is an array).  Bounds cannot include Inf, -Inf, or NaN,
%
%   linespec:   line specification that determines line type, marker
%               symbol, and color of the plotted lines for the preceding
%               x-y values.
%
%   'alpha':    if included, the bounded area will be rendered with a
%               partially-transparent patch the same color as the
%               corresponding line(s).  If not included, the bounded area
%               will be an opaque patch with a lighter shade of the
%               corresponding line color.
%
%   ax:         handle of axis where lines will be plotted.  If not
%               included, the current axis will be used.
%
%   transp:     Scalar between 0 and 1 indicating with the transparency or
%               intensity of color of the bounded area patch. Default is
%               0.2.
%
%   orient:     direction to add bounds
%               'vert':   add bounds in vertical (y) direction (default)
%               'horiz':  add bounds in horizontal (x) direction 
%
%   nanflag:    Sets how NaNs in the boundedline patch should be handled
%               'fill':   fill the value based on neighboring values,
%                         smoothing over the gap
%               'gap':    leave a blank space over/below the line
%               'remove': drop NaNs from patches, creating a linear
%                         interpolation over the gap.  Note that this
%                         applies only to the bounds; NaNs in the line will
%                         remain.
%
%   cmap:       n x 3 colormap array.  If included, lines will be colored
%               (in order of plotting) according to this colormap,
%               overriding any linespec or default colors. 
%
% Output variables:
%
%   hl:         handles to line objects
%
%   hp:         handles to patch objects
%
% Example:
%
% x = linspace(0, 2*pi, 50);
% y1 = sin(x);
% y2 = cos(x);
% e1 = rand(size(y1))*.5+.5;
% e2 = [.25 .5];
% 
% ax(1) = subplot(2,2,1);
% [l,p] = boundedline(x, y1, e1, '-b*', x, y2, e2, '--ro');
% outlinebounds(l,p);
% title('Opaque bounds, with outline');
% 
% ax(2) = subplot(2,2,2);
% boundedline(x, [y1;y2], rand(length(y1),2,2)*.5+.5, 'alpha');
% title('Transparent bounds');
% 
% ax(3) = subplot(2,2,3);
% boundedline([y1;y2], x, e1(1), 'orientation', 'horiz')
% title('Horizontal bounds');
% 
% ax(4) = subplot(2,2,4);
% boundedline(x, repmat(y1, 4,1), permute(0.5:-0.1:0.2, [3 1 2]), ...
%             'cmap', cool(4), 'transparency', 0.5);
% title('Multiple bounds using colormap');


% Copyright 2010 Kelly Kearney

%--------------------
% Parse input
%--------------------

% Alpha flag

isalpha = cellfun(@(x) ischar(x) && strcmp(x, 'alpha'), varargin);
if any(isalpha)
    usealpha = true;
    varargin = varargin(~isalpha);
else
    usealpha = false;
end

% Axis

isax = cellfun(@(x) isscalar(x) && ishandle(x) && strcmp('axes', get(x,'type')), varargin);
if any(isax)
    hax = varargin{isax};
    varargin = varargin(~isax);
else
    hax = gca;
end

% Transparency

[found, trans, varargin] = parseparam(varargin, 'transparency');

if ~found
    trans = 0.2;
end

if ~isscalar(trans) || trans < 0 || trans > 1
    error('Transparency must be scalar between 0 and 1');
end

% Orientation

[found, orient, varargin] = parseparam(varargin, 'orientation');

if ~found
    orient = 'vert';
end

if strcmp(orient, 'vert')
    isvert = true;
elseif strcmp(orient, 'horiz')
    isvert = false;
else
    error('Orientation must be ''vert'' or ''horiz''');
end


% Colormap

[hascmap, cmap, varargin] = parseparam(varargin, 'cmap');


% NaN flag

[found, nanflag, varargin] = parseparam(varargin, 'nan');
if ~found
    nanflag = 'fill';
end
if ~ismember(nanflag, {'fill', 'gap', 'remove'})
    error('Nan flag must be ''fill'', ''gap'', or ''remove''');
end

% X, Y, E triplets, and linespec

[x,y,err,linespec] = deal(cell(0));
while ~isempty(varargin)
    if length(varargin) < 3
        error('Unexpected input: should be x, y, bounds triplets');
    end
    if all(cellfun(@isnumeric, varargin(1:3)))
        x = [x varargin(1)];
        y = [y varargin(2)];
        err = [err varargin(3)];
        varargin(1:3) = [];
    else
        error('Unexpected input: should be x, y, bounds triplets');
    end
    if ~isempty(varargin) && ischar(varargin{1})
        linespec = [linespec varargin(1)];
        varargin(1) = [];
    else
        linespec = [linespec {[]}];
    end 
end    

%--------------------
% Reformat x and y
% for line and patch
% plotting
%--------------------

% Calculate y values for bounding lines

plotdata = cell(0,7);

htemp = figure('visible', 'off');
for ix = 1:length(x)
    
    % Get full x, y, and linespec data for each line (easier to let plot
    % check for properly-sized x and y and expand values than to try to do
    % it myself) 
    
    try
        if isempty(linespec{ix})
            hltemp = plot(x{ix}, y{ix});
        else
            hltemp = plot(x{ix}, y{ix}, linespec{ix});
        end
    catch
        close(htemp);
        error('X and Y matrices and/or linespec not appropriate for line plot');
    end
    
    linedata = get(hltemp, {'xdata', 'ydata', 'marker', 'linestyle', 'color'});
    
    nline = size(linedata,1);
    
    % Expand bounds matrix if necessary
    
    if nline > 1
        if ndims(err{ix}) == 3
            err2 = squeeze(num2cell(err{ix},[1 2]));
        else
            err2 = repmat(err(ix),nline,1);
        end
    else
        err2 = err(ix);
    end
    
    % Figure out upper and lower bounds
    
    [lo, hi] = deal(cell(nline,1));
    for iln = 1:nline
        
        x2 = linedata{iln,1};
        y2 = linedata{iln,2};
        nx = length(x2);
        
        if isvert
            lineval = y2;
        else
            lineval = x2;
        end
            
        sz = size(err2{iln});
        
        if isequal(sz, [nx 2])
            lo{iln} = lineval - err2{iln}(:,1)';
            hi{iln} = lineval + err2{iln}(:,2)';
        elseif isequal(sz, [nx 1])
            lo{iln} = lineval - err2{iln}';
            hi{iln} = lineval + err2{iln}';
        elseif isequal(sz, [1 2])
            lo{iln} = lineval - err2{iln}(1);
            hi{iln} = lineval + err2{iln}(2);
        elseif isequal(sz, [1 1])
            lo{iln} = lineval - err2{iln};
            hi{iln} = lineval + err2{iln};
        elseif isequal(sz, [2 nx]) % not documented, but accepted anyways
            lo{iln} = lineval - err2{iln}(:,1);
            hi{iln} = lineval + err2{iln}(:,2);
        elseif isequal(sz, [1 nx]) % not documented, but accepted anyways
            lo{iln} = lineval - err2{iln};
            hi{iln} = lineval + err2{iln};
        elseif isequal(sz, [2 1]) % not documented, but accepted anyways
            lo{iln} = lineval - err2{iln}(1);
            hi{iln} = lineval + err2{iln}(2);
        else
            error('Error bounds must be npt x nside x nline array');
        end 
            
    end
    
    % Combine all data (xline, yline, marker, linestyle, color, lower bound
    % (x or y), upper bound (x or y) 
    
    plotdata = [plotdata; linedata lo hi];
        
end
close(htemp);

% Override colormap

if hascmap
    nd = size(plotdata,1);
    cmap = repmat(cmap, ceil(nd/size(cmap,1)), 1);
    cmap = cmap(1:nd,:);
    plotdata(:,5) = num2cell(cmap,2);
end


%--------------------
% Plot
%--------------------

% Setup of x and y, plus line and patch properties

nline = size(plotdata,1);
[xl, yl, xp, yp, marker, lnsty, lncol, ptchcol, alpha] = deal(cell(nline,1));

for iln = 1:nline
    xl{iln} = plotdata{iln,1};
    yl{iln} = plotdata{iln,2};
%     if isvert
%         xp{iln} = [plotdata{iln,1} fliplr(plotdata{iln,1})];
%         yp{iln} = [plotdata{iln,6} fliplr(plotdata{iln,7})];
%     else
%         xp{iln} = [plotdata{iln,6} fliplr(plotdata{iln,7})];
%         yp{iln} = [plotdata{iln,2} fliplr(plotdata{iln,2})];
%     end
    
    [xp{iln}, yp{iln}] = calcpatch(plotdata{iln,1}, plotdata{iln,2}, isvert, plotdata{iln,6}, plotdata{iln,7}, nanflag);
    
    marker{iln} = plotdata{iln,3};
    lnsty{iln} = plotdata{iln,4};
    
    if usealpha
        lncol{iln} = plotdata{iln,5};
        ptchcol{iln} = plotdata{iln,5};
        alpha{iln} = trans;
    else
        lncol{iln} = plotdata{iln,5};
        ptchcol{iln} = interp1([0 1], [1 1 1; lncol{iln}], trans);
        alpha{iln} = 1;
    end
end
    
% Plot patches and lines

if verLessThan('matlab', '8.4.0')
    [hp,hl] = deal(zeros(nline,1));
else
    [hp,hl] = deal(gobjects(nline,1));
end


for iln = 1:nline
    hp(iln) = patch(xp{iln}, yp{iln}, ptchcol{iln}, 'facealpha', alpha{iln}, 'edgecolor', 'none', 'parent', hax);
end

for iln = 1:nline
    hl(iln) = line(xl{iln}, yl{iln}, 'marker', marker{iln}, 'linestyle', lnsty{iln}, 'color', lncol{iln}, 'parent', hax);
end

%--------------------
% Assign output
%--------------------

nargoutchk(0,2);

if nargout >= 1
    varargout{1} = hl;
end

if nargout == 2
    varargout{2} = hp;
end

%--------------------
% Parse optional 
% parameters
%--------------------

function [found, val, vars] = parseparam(vars, param)

isvar = cellfun(@(x) ischar(x) && strcmpi(x, param), vars);

if sum(isvar) > 1
    error('Parameters can only be passed once');
end

if any(isvar)
    found = true;
    idx = find(isvar);
    val = vars{idx+1};
    vars([idx idx+1]) = [];
else
    found = false;
    val = [];
end

%----------------------------
% Calculate patch coordinates
%----------------------------

function [xp, yp] = calcpatch(xl, yl, isvert, lo, hi, nanflag)

ismissing = isnan([xl;yl;lo;hi]);

% If gap method, split

if any(ismissing(:)) && strcmp(nanflag, 'gap')
    
    tmp = [xl;yl;lo;hi];
   
    idx = find(any(ismissing,1));
    n = diff([0 idx length(xl)]);
    
    tmp = mat2cell(tmp, 4, n);
    isemp = cellfun('isempty', tmp);
    tmp = tmp(~isemp);
    
    tmp = cellfun(@(a) a(:,~any(isnan(a),1)), tmp, 'uni', 0);
    isemp = cellfun('isempty', tmp);
    tmp = tmp(~isemp);
    
    xl = cellfun(@(a) a(1,:), tmp, 'uni', 0);
    yl = cellfun(@(a) a(2,:), tmp, 'uni', 0);
    lo = cellfun(@(a) a(3,:), tmp, 'uni', 0);
    hi = cellfun(@(a) a(4,:), tmp, 'uni', 0);
else
    xl = {xl};
    yl = {yl};
    lo = {lo};
    hi = {hi};
end

[xp, yp] = deal(cell(size(xl)));

for ii = 1:length(xl)

    iseq = ~verLessThan('matlab', '8.4.0') && isequal(lo{ii}, hi{ii}); % deal with zero-width bug in R2014b/R2015a

    if isvert
        if iseq
            xp{ii} = [xl{ii} nan(size(xl{ii}))];
            yp{ii} = [lo{ii} fliplr(hi{ii})];
        else
            xp{ii} = [xl{ii} fliplr(xl{ii})];
            yp{ii} = [lo{ii} fliplr(hi{ii})];
        end
    else
        if iseq
            xp{ii} = [lo{ii} fliplr(hi{ii})];
            yp{ii} = [yl{ii} nan(size(yl{ii}))];
        else
            xp{ii} = [lo{ii} fliplr(hi{ii})];
            yp{ii} = [yl{ii} fliplr(yl{ii})];
        end
    end
    
    if strcmp(nanflag, 'fill')
        xp{ii} = inpaint_nans(xp{ii}', 4);
        yp{ii} = inpaint_nans(yp{ii}', 4);
    elseif strcmp(nanflag, 'remove')
        isn = isnan(xp{ii}) | isnan(yp{ii});
        xp{ii} = xp{ii}(~isn);
        yp{ii} = yp{ii}(~isn);
    end
    
end

if strcmp(nanflag, 'gap')
    [xp, yp] = singlepatch(xp, yp);
else
    xp = xp{1};
    yp = yp{1};
end

function B=inpaint_nans(A,method)
% INPAINT_NANS: in-paints over nans in an array
% usage: B=INPAINT_NANS(A)          % default method
% usage: B=INPAINT_NANS(A,method)   % specify method used
%
% Solves approximation to one of several pdes to
% interpolate and extrapolate holes in an array
%
% arguments (input):
%   A - nxm array with some NaNs to be filled in
%
%   method - (OPTIONAL) scalar numeric flag - specifies
%       which approach (or physical metaphor to use
%       for the interpolation.) All methods are capable
%       of extrapolation, some are better than others.
%       There are also speed differences, as well as
%       accuracy differences for smooth surfaces.
%
%       methods {0,1,2} use a simple plate metaphor.
%       method  3 uses a better plate equation,
%                 but may be much slower and uses
%                 more memory.
%       method  4 uses a spring metaphor.
%       method  5 is an 8 neighbor average, with no
%                 rationale behind it compared to the
%                 other methods. I do not recommend
%                 its use.
%
%       method == 0 --> (DEFAULT) see method 1, but
%         this method does not build as large of a
%         linear system in the case of only a few
%         NaNs in a large array.
%         Extrapolation behavior is linear.
%         
%       method == 1 --> simple approach, applies del^2
%         over the entire array, then drops those parts
%         of the array which do not have any contact with
%         NaNs. Uses a least squares approach, but it
%         does not modify known values.
%         In the case of small arrays, this method is
%         quite fast as it does very little extra work.
%         Extrapolation behavior is linear.
%         
%       method == 2 --> uses del^2, but solving a direct
%         linear system of equations for nan elements.
%         This method will be the fastest possible for
%         large systems since it uses the sparsest
%         possible system of equations. Not a least
%         squares approach, so it may be least robust
%         to noise on the boundaries of any holes.
%         This method will also be least able to
%         interpolate accurately for smooth surfaces.
%         Extrapolation behavior is linear.
%
%         Note: method 2 has problems in 1-d, so this
%         method is disabled for vector inputs.
%         
%       method == 3 --+ See method 0, but uses del^4 for
%         the interpolating operator. This may result
%         in more accurate interpolations, at some cost
%         in speed.
%         
%       method == 4 --+ Uses a spring metaphor. Assumes
%         springs (with a nominal length of zero)
%         connect each node with every neighbor
%         (horizontally, vertically and diagonally)
%         Since each node tries to be like its neighbors,
%         extrapolation is as a constant function where
%         this is consistent with the neighboring nodes.
%
%       method == 5 --+ See method 2, but use an average
%         of the 8 nearest neighbors to any element.
%         This method is NOT recommended for use.
%
%
% arguments (output):
%   B - nxm array with NaNs replaced
%
%
% Example:
%  [x,y] = meshgrid(0:.01:1);
%  z0 = exp(x+y);
%  znan = z0;
%  znan(20:50,40:70) = NaN;
%  znan(30:90,5:10) = NaN;
%  znan(70:75,40:90) = NaN;
%
%  z = inpaint_nans(znan);
%
%
% See also: griddata, interp1
%
% Author: John D'Errico
% e-mail address: woodchips@rochester.rr.com
% Release: 2
% Release date: 4/15/06


% I always need to know which elements are NaN,
% and what size the array is for any method
[n,m]=size(A);
A=A(:);
nm=n*m;
k=isnan(A(:));

% list the nodes which are known, and which will
% be interpolated
nan_list=find(k);
known_list=find(~k);

% how many nans overall
nan_count=length(nan_list);

% convert NaN indices to (r,c) form
% nan_list==find(k) are the unrolled (linear) indices
% (row,column) form
[nr,nc]=ind2sub([n,m],nan_list);

% both forms of index in one array:
% column 1 == unrolled index
% column 2 == row index
% column 3 == column index
nan_list=[nan_list,nr,nc];

% supply default method
if (nargin<2) || isempty(method)
  method = 0;
elseif ~ismember(method,0:5)
  error 'If supplied, method must be one of: {0,1,2,3,4,5}.'
end

% for different methods
switch method
 case 0
  % The same as method == 1, except only work on those
  % elements which are NaN, or at least touch a NaN.
  
  % is it 1-d or 2-d?
  if (m == 1) || (n == 1)
    % really a 1-d case
    work_list = nan_list(:,1);
    work_list = unique([work_list;work_list - 1;work_list + 1]);
    work_list(work_list <= 1) = [];
    work_list(work_list >= nm) = [];
    nw = numel(work_list);
    
    u = (1:nw)';
    fda = sparse(repmat(u,1,3),bsxfun(@plus,work_list,-1:1), ...
      repmat([1 -2 1],nw,1),nw,nm);
  else
    % a 2-d case
    
    % horizontal and vertical neighbors only
    talks_to = [-1 0;0 -1;1 0;0 1];
    neighbors_list=identify_neighbors(n,m,nan_list,talks_to);
    
    % list of all nodes we have identified
    all_list=[nan_list;neighbors_list];
    
    % generate sparse array with second partials on row
    % variable for each element in either list, but only
    % for those nodes which have a row index > 1 or < n
    L = find((all_list(:,2) > 1) & (all_list(:,2) < n));
    nl=length(L);
    if nl>0
      fda=sparse(repmat(all_list(L,1),1,3), ...
        repmat(all_list(L,1),1,3)+repmat([-1 0 1],nl,1), ...
        repmat([1 -2 1],nl,1),nm,nm);
    else
      fda=spalloc(n*m,n*m,size(all_list,1)*5);
    end
    
    % 2nd partials on column index
    L = find((all_list(:,3) > 1) & (all_list(:,3) < m));
    nl=length(L);
    if nl>0
      fda=fda+sparse(repmat(all_list(L,1),1,3), ...
        repmat(all_list(L,1),1,3)+repmat([-n 0 n],nl,1), ...
        repmat([1 -2 1],nl,1),nm,nm);
    end
  end
  
  % eliminate knowns
  rhs=-fda(:,known_list)*A(known_list);
  k=find(any(fda(:,nan_list(:,1)),2));
  
  % and solve...
  B=A;
  B(nan_list(:,1))=fda(k,nan_list(:,1))\rhs(k);
  
 case 1
  % least squares approach with del^2. Build system
  % for every array element as an unknown, and then
  % eliminate those which are knowns.

  % Build sparse matrix approximating del^2 for
  % every element in A.
  
  % is it 1-d or 2-d?
  if (m == 1) || (n == 1)
    % a 1-d case
    u = (1:(nm-2))';
    fda = sparse(repmat(u,1,3),bsxfun(@plus,u,0:2), ...
      repmat([1 -2 1],nm-2,1),nm-2,nm);
  else
    % a 2-d case
    
    % Compute finite difference for second partials
    % on row variable first
    [i,j]=ndgrid(2:(n-1),1:m);
    ind=i(:)+(j(:)-1)*n;
    np=(n-2)*m;
    fda=sparse(repmat(ind,1,3),[ind-1,ind,ind+1], ...
      repmat([1 -2 1],np,1),n*m,n*m);
    
    % now second partials on column variable
    [i,j]=ndgrid(1:n,2:(m-1));
    ind=i(:)+(j(:)-1)*n;
    np=n*(m-2);
    fda=fda+sparse(repmat(ind,1,3),[ind-n,ind,ind+n], ...
      repmat([1 -2 1],np,1),nm,nm);
  end
  
  % eliminate knowns
  rhs=-fda(:,known_list)*A(known_list);
  k=find(any(fda(:,nan_list),2));
  
  % and solve...
  B=A;
  B(nan_list(:,1))=fda(k,nan_list(:,1))\rhs(k);
  
 case 2
  % Direct solve for del^2 BVP across holes

  % generate sparse array with second partials on row
  % variable for each nan element, only for those nodes
  % which have a row index > 1 or < n
  
  % is it 1-d or 2-d?
  if (m == 1) || (n == 1)
    % really just a 1-d case
    error('Method 2 has problems for vector input. Please use another method.')
    
  else
    % a 2-d case
    L = find((nan_list(:,2) > 1) & (nan_list(:,2) < n));
    nl=length(L);
    if nl>0
      fda=sparse(repmat(nan_list(L,1),1,3), ...
        repmat(nan_list(L,1),1,3)+repmat([-1 0 1],nl,1), ...
        repmat([1 -2 1],nl,1),n*m,n*m);
    else
      fda=spalloc(n*m,n*m,size(nan_list,1)*5);
    end
    
    % 2nd partials on column index
    L = find((nan_list(:,3) > 1) & (nan_list(:,3) < m));
    nl=length(L);
    if nl>0
      fda=fda+sparse(repmat(nan_list(L,1),1,3), ...
        repmat(nan_list(L,1),1,3)+repmat([-n 0 n],nl,1), ...
        repmat([1 -2 1],nl,1),n*m,n*m);
    end
    
    % fix boundary conditions at extreme corners
    % of the array in case there were nans there
    if ismember(1,nan_list(:,1))
      fda(1,[1 2 n+1])=[-2 1 1];
    end
    if ismember(n,nan_list(:,1))
      fda(n,[n, n-1,n+n])=[-2 1 1];
    end
    if ismember(nm-n+1,nan_list(:,1))
      fda(nm-n+1,[nm-n+1,nm-n+2,nm-n])=[-2 1 1];
    end
    if ismember(nm,nan_list(:,1))
      fda(nm,[nm,nm-1,nm-n])=[-2 1 1];
    end
    
    % eliminate knowns
    rhs=-fda(:,known_list)*A(known_list);
    
    % and solve...
    B=A;
    k=nan_list(:,1);
    B(k)=fda(k,k)\rhs(k);
    
  end
  
 case 3
  % The same as method == 0, except uses del^4 as the
  % interpolating operator.
  
  % del^4 template of neighbors
  talks_to = [-2 0;-1 -1;-1 0;-1 1;0 -2;0 -1; ...
      0 1;0 2;1 -1;1 0;1 1;2 0];
  neighbors_list=identify_neighbors(n,m,nan_list,talks_to);
  
  % list of all nodes we have identified
  all_list=[nan_list;neighbors_list];
  
  % generate sparse array with del^4, but only
  % for those nodes which have a row & column index
  % >= 3 or <= n-2
  L = find( (all_list(:,2) >= 3) & ...
            (all_list(:,2) <= (n-2)) & ...
            (all_list(:,3) >= 3) & ...
            (all_list(:,3) <= (m-2)));
  nl=length(L);
  if nl>0
    % do the entire template at once
    fda=sparse(repmat(all_list(L,1),1,13), ...
        repmat(all_list(L,1),1,13) + ...
        repmat([-2*n,-n-1,-n,-n+1,-2,-1,0,1,2,n-1,n,n+1,2*n],nl,1), ...
        repmat([1 2 -8 2 1 -8 20 -8 1 2 -8 2 1],nl,1),nm,nm);
  else
    fda=spalloc(n*m,n*m,size(all_list,1)*5);
  end
  
  % on the boundaries, reduce the order around the edges
  L = find((((all_list(:,2) == 2) | ...
             (all_list(:,2) == (n-1))) & ...
            (all_list(:,3) >= 2) & ...
            (all_list(:,3) <= (m-1))) | ...
           (((all_list(:,3) == 2) | ...
             (all_list(:,3) == (m-1))) & ...
            (all_list(:,2) >= 2) & ...
            (all_list(:,2) <= (n-1))));
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(all_list(L,1),1,5), ...
      repmat(all_list(L,1),1,5) + ...
        repmat([-n,-1,0,+1,n],nl,1), ...
      repmat([1 1 -4 1 1],nl,1),nm,nm);
  end
  
  L = find( ((all_list(:,2) == 1) | ...
             (all_list(:,2) == n)) & ...
            (all_list(:,3) >= 2) & ...
            (all_list(:,3) <= (m-1)));
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(all_list(L,1),1,3), ...
      repmat(all_list(L,1),1,3) + ...
        repmat([-n,0,n],nl,1), ...
      repmat([1 -2 1],nl,1),nm,nm);
  end
  
  L = find( ((all_list(:,3) == 1) | ...
             (all_list(:,3) == m)) & ...
            (all_list(:,2) >= 2) & ...
            (all_list(:,2) <= (n-1)));
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(all_list(L,1),1,3), ...
      repmat(all_list(L,1),1,3) + ...
        repmat([-1,0,1],nl,1), ...
      repmat([1 -2 1],nl,1),nm,nm);
  end
  
  % eliminate knowns
  rhs=-fda(:,known_list)*A(known_list);
  k=find(any(fda(:,nan_list(:,1)),2));
  
  % and solve...
  B=A;
  B(nan_list(:,1))=fda(k,nan_list(:,1))\rhs(k);
  
 case 4
  % Spring analogy
  % interpolating operator.
  
  % list of all springs between a node and a horizontal
  % or vertical neighbor
  hv_list=[-1 -1 0;1 1 0;-n 0 -1;n 0 1];
  hv_springs=[];
  for i=1:4
    hvs=nan_list+repmat(hv_list(i,:),nan_count,1);
    k=(hvs(:,2)>=1) & (hvs(:,2)<=n) & (hvs(:,3)>=1) & (hvs(:,3)<=m);
    hv_springs=[hv_springs;[nan_list(k,1),hvs(k,1)]];
  end

  % delete replicate springs
  hv_springs=unique(sort(hv_springs,2),'rows');
  
  % build sparse matrix of connections, springs
  % connecting diagonal neighbors are weaker than
  % the horizontal and vertical springs
  nhv=size(hv_springs,1);
  springs=sparse(repmat((1:nhv)',1,2),hv_springs, ...
     repmat([1 -1],nhv,1),nhv,nm);
  
  % eliminate knowns
  rhs=-springs(:,known_list)*A(known_list);
  
  % and solve...
  B=A;
  B(nan_list(:,1))=springs(:,nan_list(:,1))\rhs;
  
 case 5
  % Average of 8 nearest neighbors
  
  % generate sparse array to average 8 nearest neighbors
  % for each nan element, be careful around edges
  fda=spalloc(n*m,n*m,size(nan_list,1)*9);
  
  % -1,-1
  L = find((nan_list(:,2) > 1) & (nan_list(:,3) > 1)); 
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([-n-1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end
  
  % 0,-1
  L = find(nan_list(:,3) > 1);
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([-n, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end

  % +1,-1
  L = find((nan_list(:,2) < n) & (nan_list(:,3) > 1));
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([-n+1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end

  % -1,0
  L = find(nan_list(:,2) > 1);
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([-1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end

  % +1,0
  L = find(nan_list(:,2) < n);
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end

  % -1,+1
  L = find((nan_list(:,2) > 1) & (nan_list(:,3) < m)); 
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([n-1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end
  
  % 0,+1
  L = find(nan_list(:,3) < m);
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([n, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end

  % +1,+1
  L = find((nan_list(:,2) < n) & (nan_list(:,3) < m));
  nl=length(L);
  if nl>0
    fda=fda+sparse(repmat(nan_list(L,1),1,2), ...
      repmat(nan_list(L,1),1,2)+repmat([n+1, 0],nl,1), ...
      repmat([1 -1],nl,1),n*m,n*m);
  end
  
  % eliminate knowns
  rhs=-fda(:,known_list)*A(known_list);
  
  % and solve...
  B=A;
  k=nan_list(:,1);
  B(k)=fda(k,k)\rhs(k);
  
end

% all done, make sure that B is the same shape as
% A was when we came in.
B=reshape(B,n,m);


% ====================================================
%      end of main function
% ====================================================
% ====================================================
%      begin subfunctions
% ====================================================
function neighbors_list=identify_neighbors(n,m,nan_list,talks_to)
% identify_neighbors: identifies all the neighbors of
%   those nodes in nan_list, not including the nans
%   themselves
%
% arguments (input):
%  n,m - scalar - [n,m]=size(A), where A is the
%      array to be interpolated
%  nan_list - array - list of every nan element in A
%      nan_list(i,1) == linear index of i'th nan element
%      nan_list(i,2) == row index of i'th nan element
%      nan_list(i,3) == column index of i'th nan element
%  talks_to - px2 array - defines which nodes communicate
%      with each other, i.e., which nodes are neighbors.
%
%      talks_to(i,1) - defines the offset in the row
%                      dimension of a neighbor
%      talks_to(i,2) - defines the offset in the column
%                      dimension of a neighbor
%      
%      For example, talks_to = [-1 0;0 -1;1 0;0 1]
%      means that each node talks only to its immediate
%      neighbors horizontally and vertically.
% 
% arguments(output):
%  neighbors_list - array - list of all neighbors of
%      all the nodes in nan_list

if ~isempty(nan_list)
  % use the definition of a neighbor in talks_to
  nan_count=size(nan_list,1);
  talk_count=size(talks_to,1);
  
  nn=zeros(nan_count*talk_count,2);
  j=[1,nan_count];
  for i=1:talk_count
    nn(j(1):j(2),:)=nan_list(:,2:3) + ...
        repmat(talks_to(i,:),nan_count,1);
    j=j+nan_count;
  end
  
  % drop those nodes which fall outside the bounds of the
  % original array
  L = (nn(:,1)<1)|(nn(:,1)>n)|(nn(:,2)<1)|(nn(:,2)>m); 
  nn(L,:)=[];
  
  % form the same format 3 column array as nan_list
  neighbors_list=[sub2ind([n,m],nn(:,1),nn(:,2)),nn];
  
  % delete replicates in the neighbors list
  neighbors_list=unique(neighbors_list,'rows');
  
  % and delete those which are also in the list of NaNs.
  neighbors_list=setdiff(neighbors_list,nan_list,'rows');
  
else
  neighbors_list=[];
end


function varargout = singlepatch(varargin)
%SINGLEPATCH Concatenate patches to be plotted as one
%
% [xp, yp, zp, ...] = singlepatch(x, y, z, ...)
%
% Concatenates uneven vectors of x and y coordinates by replicating the
% last point in each polygon.  This allows patches with different numbers
% of vertices to be plotted as one, which is often much, much more
% efficient than plotting lots of individual patches.  
%
% Input variables:
%
%   x:   cell array, with each cell holding a vector of coordinates
%        associates with a single patch.  The input variables must all be
%        of the same size, and usually will correspond to x, y, z, and c
%        data for the patches.
%
% Output variables:
%
%   xp:  m x n array of coordinates, where m is the maximum length of the
%        vectors in x and n is numel(x).  

% Copyright 2015 Kelly Kearney

if nargin ~= nargout
    error('Must supply the same number of input variables as output variables');
end

nv = nargin;
vars = varargin;

sz = cellfun(@size, vars{1}(:), 'uni', 0);
sz = cat(1, sz{:});

if all(sz(:,1) == 1)
    for ii = 1:nv
        vars{ii} = catuneven(1, NaN, vars{ii}{:})';
    end
%     x = catuneven(1, NaN, x{:})';
%     y = catuneven(1, NaN, y{:})';
elseif all(sz(:,2) == 1)
    for ii = 1:nv
        vars{ii} = catuneven(2, NaN, vars{ii}{:});
    end
%     x = catuneven(2, NaN, x{:});
%     y = catuneven(2, NaN, y{:});
else
    error('Inputs must be cell arrays of vectors');
end

[ii,jj] = find(isnan(vars{1}));

ind = accumarray(jj, ii, [size(vars{1},2) 1], @min); 
ij1 = [ii jj];
ij2 = [ind(jj)-1 jj];
idx1 = sub2ind(size(vars{1}), ij1(:,1), ij1(:,2));
idx2 = sub2ind(size(vars{1}), ij2(:,1), ij2(:,2));

for ii = 1:nv
    vars{ii}(idx1) = vars{ii}(idx2);
end

varargout = vars;

