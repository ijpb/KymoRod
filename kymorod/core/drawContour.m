function varargout = drawContour(contour, varargin)
%DRAWCONTOUR Draw a contour on current axis
%
%   drawContour(CT)
%   drawContour(CT, 'r', 'lineWidth', 2)
%   Draws the contour CT on the current axis. CT must be a N-by-2 array
%   containing the coordinates of the vertices.
%
%   Example
%   drawContour
%
%   See also
%   drawSkeleton
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

% create indices to plot closed contours
inds = [1:size(contour,1) 1];

if nargout == 0
    plot(contour(inds,1), contour(inds,2), varargin{:});
else
    h = plot(contour(inds,1), contour(inds,2), varargin{:});
    varargout = {h};
end

