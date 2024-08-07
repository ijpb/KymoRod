function res = snapToPixels(obj, calib)
% Snap coordinates of a parameterized midline.
%
%   MIDLINE2 = snapToPixels(MIDLINE, CALIB)
%   Compute an equivalent curve whose vertex coordinates are rounded to
%   nearest integer, keeping average curvilinear abscissa for each vertex.
%   Curvilinear abscissa are recomputed.
%
%
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

S = obj.Abscissas;

path2 = pointToIndex(calib, obj.Coords);

% extract curve coordinates, and convert to pixel coordinates
px = round(path2(:, 1));
py = round(path2(:, 2));

% indentify unique positions
[~, inds, uninds] = unique([px py], 'rows');
px = px(inds);
py = py(inds);

% compute average value of curvilinear abscissa for each unique index
S2 = zeros(length(inds), 1);
for i = 1:length(inds)
    S2(i) = mean(S(uninds == i));
end

% sort new pixels according to curvilinear abscissa
[S2, inds] = sort(S2);

% create new midline
res = kymorod.data.Midline([px(inds) py(inds)], S2);
