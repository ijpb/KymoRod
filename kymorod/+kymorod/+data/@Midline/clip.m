function res = clip(obj, bounds)
%CLIP Clip the midline by retaining only vertices within the bounds.
%
%   RES = clip(MID, BOUNDS)
%   BOUNDS must be [XMIN XMAX YMIN YMAX].
%
%   Example
%   clip
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-20,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

xmin = bounds(1);
xmax = bounds(2);
ymin = bounds(3);
ymax = bounds(4);

okX = obj.Coords(:,1) >= xmin & obj.Coords(:,1) <= xmax;
okY = obj.Coords(:,2) >= ymin & obj.Coords(:,2) <= ymax;
inds = okX & okY;

res = kymorod.data.Midline(obj.Coords(inds, :), obj.Abscissas(inds));
if ~isempty(obj.Radiusses)
    res.Radiusses = obj.Radiusses(inds);
end
if ~isempty(obj.Curvatures)
    res.Curvatures = obj.Curvatures(inds);
end
