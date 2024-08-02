function CT = segmentContour(img, thres)
% SEGMENTCONTOUR Segment the contour in a gray level image with a given threshold
%
% CT = segmentContour(IMG, THRESH)
% (rewritten from function 'cont')
% Computes the isovalue contour lines in gray level image IMG, and keep the
% largest one. Return the resulting contour in a N-by-2 array containing
% vertex coordinates. 
%
% Input arguments
% IMG: 		a grey level image
% THRESH: 	the treshold value
%

% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 Add comments about the file
%   2014-12-08 rewrite using less memory and avoiding code duplication

% Compute all contours at isovalue given by threshold
C = contourc(double(img), [thres, thres]);

% size of the contour matrix array
nCoords = size(C, 2);

% Compute the number of contours, by jumping from 'contour header' to
% 'contour header', and compute their size (as number of vertices).
nContours = 0;
offset = 1;
while offset < nCoords
    nContours = nContours + 1;
    offset = offset + C(2, offset) + 1;
end

% compute the length and the offset of each individual contour
contourLength = zeros(nContours, 1);
contourOffset = zeros(nContours, 1);
offset = 1;
for iContour = 1:nContours
    nv = C(2, offset);
    contourLength(iContour) = nv;
    contourOffset(iContour) = offset;
    offset = offset + nv + 1;
end

% identify largest contour
[lengthMax, indMax] = max(contourLength);

% allocate memory for contour
CT = zeros(lengthMax, 2);

% extract coordinates of largest contour
offset = contourOffset(indMax);
CT(:,1) = C(1, (1:lengthMax) + offset);
CT(:,2) = C(2, (1:lengthMax) + offset);

% remove double vertices in contour
CT = removeDoubleVertices(CT);
