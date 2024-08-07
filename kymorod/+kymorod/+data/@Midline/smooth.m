function res = smooth(obj, W)
% Smooth the midline using moving average.
%
%   PATH2 = smooth(PATH, W)
%   W is the size of the smoothing frame, in number of vertices.
%
%   Example
%   smooth
%
%   See also
%     kymorod.core.signal.movingAverage
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% if frame is too small, return this midline.
if W < 2
    res = obj;
    return;
end

% expand each extremity using point symetry
path = obj.Coords;
path2 = [...
    2*path(1, :)-path(W+1:-1:2,:) ; ...
    path ; ...
    2*path(end,:)-path(end-1:-1:end-W, :)];

% apply smoothing
path2 = kymorod.core.signal.movingAverage(path2, W);

% remove extremities
dw = floor(W/2);
res = kymorod.data.Midline(path2(W+dw+1:end-W+dw, :), obj.Abscissas);

res.Radiusses = obj.Radiusses;
res.Curvatures = obj.Curvatures;
