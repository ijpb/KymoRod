function [res, coeffs] = adjustDynamic(imgData)
% ADJUSTDYNAMIC Adapt values of image data to provide better display.
%
%   img2 = adjustDynamic(img)
%   Adjust contrast (value dynamic) of input image, and return result as a
%   uint8 image.
%
%   [img2, coeffs] = adjustDynamic(img);
%   Also returns the 1-by-2 row vector containing the coeffs such that:
%   img2 = img * coeffs(1) + coeffs(2);
%
%   Example
%   adjustDynamic
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2023-10-31,    using Matlab 23.2.0.2391609 (R2023b) Update 2
% Copyright 2023 INRAE.

% sort values that are valid (avoid NaN's and Inf's)
values = sort(imgData(isfinite(imgData)));
n = length(values);

% compute values that enclose (1-alpha) percents of all values
alpha = 0.01;
mini = values( floor((n-1) * alpha/2) + 1);
maxi = values( floor((n-1) * (1-alpha/2)) + 1);

% compute result image
a = 255.0 / double(maxi - mini);
res = (imgData - mini) * a;
res = uint8(res);

coeffs = [a -mini*a];
