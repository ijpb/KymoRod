function res = calibrate(obj, calib, varargin)
%CALIBRATE Apply spatial calibration to this MidLine.
%
%   ML2 = calibrate(ML, CALIB)
%
%   Example
%   calibrate
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2024-08-09,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE.

coords2 = obj.Coords .* calib.PixelSize + calib.PixelOrigin;
abscissa2 = obj.Abscissas * calib.PixelSize(1);

res = kymorod.data.MidLine(coords2, abscissa2);

if ~isempty(obj.Radiusses)
    res.Radiusses = obj.Radiusses * calib.PixelSize(1);
end

if ~isempty(obj.Curvatures)
    res.Curvatures = obj.Curvatures / calib.PixelSize(1);
end