function res = imSetBordersValue(img, varargin)
%IMSETBORDERSVALUE Set the border pixels to the specified value
%
%   IMG2 = imSetBordersValue(IMG, VALUE)
%
%   Example
%   img = imread('rice.png');
%   img2 = imSetBordersValue(img, 0);
%   imshow(img2);
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

value = 0;
if ~isempty(varargin)
    value = varargin{1};
end

res = img;
res([1 end], :) = value;
res(:, [1 end]) = value;
