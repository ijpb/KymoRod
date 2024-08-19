function mid = contourMidline(cnt, origin)
%CONTOURMIDLINE Compute midline of a contour with dense vertices.
%
%   MID = contourMidline(CNT, ORIGIN)
%
%   Example
%   contourMidline
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-19,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

% Compute skeleton (method in MatGeom).
skel = polygonSkeleton(cnt);

% choose the value used to discriminate extreme points
switch origin
    case 'left',    values = -skel.vertices(:, 1);
    case 'right',   values =  skel.vertices(:, 1);
    case 'bottom',  values =  skel.vertices(:, 2);
    case 'top',     values = -skel.vertices(:, 2);
end

% identify index of skeleton first point
[tmp, startIndex] = max(values); %#ok<ASGLU>

% computes the longest geodesic path starting from selected vertex
[path, rads] = kymorod.core.geom.skeletonLongestPath(skel, startIndex);

% create resulting midline
mid = kymorod.data.Midline(path);
mid.Radiusses = rads;