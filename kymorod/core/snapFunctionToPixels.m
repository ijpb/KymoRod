function [px, py, res] = snapFunctionToPixels(image, curve, S)
%FUNCTIONTOIMAGE find pixel positions of a curve with values
%
%   [PX, PY, S2] = functionToImage(IMG, CURVE, S)
%   
%   Input arguments:
%   IMG     an image, used to determine the size of the result
%   CURVE   the skeleton, as a N-by-2 array of coordinates
%   S       curvilinear abscissa, as a N-by-1 array
%
%   Output arguments:
%   PX      a list of x-indices in image coordinate
%   PY      a list of y-indices in image coordinate
%   S2      the average of the values grouped by pixel position
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

warning('Deprecated: use "snapCurveToPixel" instead');


% size of result image
dim  = size(image);

% extract curve coordinates, and convert to pixel coordinates
px = round(curve(:, 1));
py = round(curve(:, 2));

% keep only curve points within image bounds
insideFlag = px >= 1 & px <= dim(2) & py >= 1 & py <= dim(1);
px = px(insideFlag);
py = py(insideFlag);
S  = S(insideFlag);

% compute linear indices in image 
inds = sub2ind(dim, py, px);

% indentify unique positions
[uninds, ia, ic] = unique(inds); %#ok<ASGLU>
px = px(ia);
py = py(ia);

% compute average value of function for each unique index
res = zeros(length(uninds), 1);
for i = 1:length(uninds)
    uni = uninds(i);
    res(i) = mean(S(inds == uni));
end

% sort results in ascending order of function value
[res, inds] = sort(res);
px = px(inds);
py = py(inds);
