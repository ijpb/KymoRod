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
dim  = size(image);

% allocate memory
res = zeros(dim);
count = zeros(dim);

% extract curve coordinates
px = round(curve(:, 1));
py = round(curve(:, 2));

% keep only curve points within image bounds
inds = find(px >= 1 & px <= dim(2) & py >= 1 & py <= dim(1));

% for i = 1:size(func, 1)
for i = 1:length(inds)
	% compute indices in image space
    indi = py(inds(i));
    indj = px(inds(i));

	% add current abscissa
    res(indi, indj) = res(indi, indj) + S(inds(i));
    
    % increment count
    count(indi, indj) = count(indi, indj) + 1;
end

% normalisation
res = res ./ count;

