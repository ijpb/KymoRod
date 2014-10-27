function varargout = drawContour(contour, varargin)
%DRAWCONTOUR Draw a contour on current axis
%
%   drawContour(CT)
%   drawContour(CT, 'r', 'lineWidth', 2)
%
%   Example
%   drawContour
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@grignon.inra.fr
% Created: 2014-08-21,    using Matlab 8.3.0.532 (R2014a)
% Copyright 2014 INRA - Cepia Software Platform.

if nargout == 0
    plot(contour(:,1), contour(:,2), varargin{:});
else
    h = plot(contour(:,1), contour(:,2), varargin{:});
    varargout = {h};
end

