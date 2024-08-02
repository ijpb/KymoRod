function varargout = snapCurveToPixels(S, curve)
%SNAPCURVETOPIXELS Round coordinates of a parameterized curve
%
%   [S2, CURVE2] = snapCurveToPixels(S, CURVE)
%   Compute an equivalent curve whose vertex coordinates are rounded to
%   nearest integer, keeping average curvilinear abscissa for each vertex.
%
%   Input arguments:
%   S       curvilinear abscissa of the curve, as a N-by-1 array
%   CURVE   the coordinates of the curve vertices, as a N-by-2 array
%
%   Output arguments:
%   S2      the average of the values grouped by pixel position
%   CURVE2  the curve with round coordinates
%
%   [S2, PX2, PY2] = snapCurveToPixels(S, CURVE)
%   Returns the coordinates of the output curve in two separate arrays.
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% extract curve coordinates, and convert to pixel coordinates
px = round(curve(:, 1));
py = round(curve(:, 2));

% indentify unique positions
[~, inds, uninds] = unique([px py], 'rows');
px = px(inds);
py = py(inds);

% compute average value of function for each unique index
res = zeros(length(inds), 1);
for i = 1:length(inds)
    res(i) = mean(S(uninds == i));
end

% sort results in ascending order of function value
[S2, order] = sort(res);

% format output arguments
if nargout > 2
    varargout = {S2, px(order), py(order)};
else
    varargout = {S2, [px(order) py(order)]};
end


