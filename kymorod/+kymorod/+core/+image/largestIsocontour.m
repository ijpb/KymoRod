function cnt = largestIsocontour(img, value)
%LARGESTISOCONTOUR Compute largest isocontour within a grayscale image.
%
%   CNT = largestIsocontour(IMG, VALUE)
%   Computes the isovalue contour lines in the gray level image IMG, and
%   selects the largest one. Returns the resulting contour in a N-by-2
%   numeric array containing vertex coordinates. 
%
%   Example
%     largestIsocontour
%
%   See also
%     contourc
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-17,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

% Compute the matrix of contours at the given isovalue
C = contourc(double(img), [value, value]);

% size of the contour matrix array
nCoords = size(C, 2);

% Compute the number of contours, by jumping from 'contour header' to
% 'contour header', and keep their offset in the array.
nContours = 0;
offset = 1;
while offset < nCoords
    nContours = nContours + 1;
    offset = offset + C(2, offset) + 1;
end

% compute the length and the offset of each individual contour
lengths = zeros(nContours, 1);
offsets = zeros(nContours, 1);
offset = 1;
for iContour = 1:nContours
    nv = C(2, offset);
    lengths(iContour) = nv;
    offsets(iContour) = offset;
    offset = offset + nv + 1;
end

% identify largest contour
[lengthMax, indMax] = max(lengths);

% allocate memory for contour
cnt = zeros(lengthMax, 2);

% extract coordinates of largest contour
offset = offsets(indMax);
cnt(:,1) = C(1, (1:lengthMax) + offset);
cnt(:,2) = C(2, (1:lengthMax) + offset);
