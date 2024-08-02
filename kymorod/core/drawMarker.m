function varargout = drawMarker(point, varargin)
%DRAWMARKER Draw a marker at a specified position on current axis
%
%   drawMarker(POS)
%   drawMarker(POS, 'r', 'lineWidth', 2)
%
%   Example
%   drawMarker
%
%   See also
%   drawContour, drawSkeleton
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-10-28,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

defaultStyle = {'marker', 'd', 'linestyle', 'none'};
if isempty(varargin)
    varargin = defaultStyle;
else
    n = length(varargin);
    if 2 * floor(n / 2) == n
        % number of arguments is even -> ensure marker is specified
        varargin = [defaultStyle, varargin];
    end
end

if nargout == 0
    plot(point(:,1), point(:,2), varargin{:});
else
    h = plot(point(:,1), point(:,2), varargin{:});
    varargout = {h};
end