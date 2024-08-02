function res = imAddBlackBorder(img)
%IMADDBLACKBORDER Add a black border around the image
%
%   res = imAddBlackBorder(img)
%
%   Example
%     img = imread('rice.png');
%     img2 = imAddBlackBorder(img);
%     imshow(img2);
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% new image with one pixel more in each direction
res = zeros(size(img) + 2, class(img)); %#ok<ZEROLIKE>

% copy original image in the middle of new image
res(2:end-1, 2:end-1) = img;
