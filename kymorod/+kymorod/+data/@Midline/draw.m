function varargout = draw(obj, varargin)
% DRAW Draw the midline as a continuous curve.
%
%   draw(ML)
%
%   Example
%   draw(ML)
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2021-01-03,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE.

ax = gca;
if ishandle(obj)
    ax = obj;
    obj = varargin{1};
    varargin(1) = [];
end

% plot the curve, with eventually optional parameters
h = plot(ax, obj.Coords(:,1), obj.Coords(:,2), varargin{:});

% format output arguments
if nargout > 0
     varargout = {h};
end
