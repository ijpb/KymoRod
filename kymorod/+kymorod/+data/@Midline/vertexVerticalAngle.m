function angles = vertexVerticalAngle(obj, ws)
%VERTEXVERTICALANGLE Computes the vertical angle for each vertex.
%
%   ANGLES = vertexVerticalAngle(MIDLINE)
%
%   Example
%   computeVerticalAngles
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-06-17,    using Matlab 9.14.0.2206163 (R2023a)
% Copyright 2024 INRAE.

if ~exist('ws', 'var')
    ws = 2;
end

% precompute indices
n = size(obj.Coords, 1);
inds1 = 1:(n-2*ws);
inds2 = (1+2*ws):n;

% compute angle of inner points
dx = obj.Coords(inds2, 1) - obj.Coords(inds1, 1);
dy = obj.Coords(inds2, 2) - obj.Coords(inds1, 2);
innerAngles = atan2(dx, dy);

% add smoothing
if length(innerAngles) > 2 * ws
    innerAngles = kymorod.data.signal.movingAverage(innerAngles, ws);
end

% complete missing values at extremities
angles = [repmat(innerAngles(1), ws, 1) ; innerAngles ; repmat(innerAngles(end), ws, 1)];
