function varargout = drawSkeleton(skeleton, varargin)
%DRAWSKELETON Draw a skeleton on current axis
%
%   drawSkeleton(SK)
%   drawSkeleton(SK, 'r', 'lineWidth', 2)
%   Draws the skeleton SK on the current axis. SK must be a N-by-2 array
%   containing the coordinates of the vertices.
%
%   Example
%   drawSkeleton
%
%   See also
%   drawContour
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

if nargout == 0
    plot(skeleton(:,1), skeleton(:,2), varargin{:});
else
    h = plot(skeleton(:,1), skeleton(:,2), varargin{:});
    varargout = {h};
end

