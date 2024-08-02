function res = functionToImage(image, curve, S)
%FUNCTIONTOIMAGE Create an image of the curvilinear abscissa of a skeleton
%
% res = functionToImage(image, curve, S)
% (rewritten from FuncToPic)
%
% image:    an image, used to determine the size of the result
% curve: 	the skeleton, as a N-by-2 array of corodinates
% S: 		curvilinear abscissa, as a N-by-1 array
%
%
% Return an image containing the average curvilinear abscissa in each
% pixel.
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% determine size of result image
dim = size(image);

% allocate memory
res = zeros(dim);

% extract curve coordinates
px = round(curve(:, 1));
py = round(curve(:, 2));

% keep only curve points within image bounds
insideFlag = px >= 1 & px <= dim(2) & py >= 1 & py <= dim(1);
px = px(insideFlag);
py = py(insideFlag);
S  = S(insideFlag);

% compute linear indices in image 
inds = sub2ind(dim, py, px);

% compute average for each unique index
uninds = unique(inds);
for i = 1:length(uninds)
    uni = uninds(i);
    res(uni) = mean(S(inds == uni));
end


