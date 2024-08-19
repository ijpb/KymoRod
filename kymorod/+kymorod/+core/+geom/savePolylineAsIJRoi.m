function savePolylineAsIJRoi(poly, fileName)
%SAVEPOLYLINEASIJROI Save a polyline as ImageJ ROI file format.
%
%   savePolylineAsIJRoi(POLY, FILENAME)
%
%   Example
%   savePolylineAsIJRoi
%
%   See also
%   http://github.com/imagej/imagej1/blob/master/ij/io/RoiDecoder.java
%   http://github.com/DylanMuir/ReadImageJROI/blob/master/ReadImageJROI.m
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2017-09-22,    using Matlab 9.1.0.441655 (R2016b)
% Copyright 2017 INRA - Cepia Software Platform.

%% Open file

% open the file in binary write mode, and big-endian ordering
f = fopen(fileName, 'w+', 'b');


%% IJ Roi header

% 0-3 "Iout"
fwrite(f, 'Iout', 'char');

% 4-5 version (>=217)
fwrite(f, 217, 'int16');

% 6-7 ROI Type (used 4...)
fwrite(f, 4, 'int8');
fwrite(f, 0, 'int8');

% 8-15 ROI Bounding box
minCoords = round(min(poly, [], 1));
maxCoords = round(max(poly, [], 1));
fwrite(f, minCoords(2), 'int16');
fwrite(f, minCoords(1), 'int16');
fwrite(f, maxCoords(2), 'int16');
fwrite(f, maxCoords(1), 'int16');

% 16-17 number of coordinates
fwrite(f, size(poly, 1), 'uint16');

% 18-33	x1,y1,x2,y2 (straight line)
fwrite(f, zeros(4, 1), 'float32');

% 34-35	stroke width (v1.43i or later)
fwrite(f, 1, 'int16');

% 36-39   ShapeRoi size (type must be 1 if this value>0)
fwrite(f, 0, 'uint32');

% 40-43   stroke color (v1.43i or later)
fwrite(f, 1, 'uint32');

% 44-47   fill color (v1.43i or later)
fwrite(f, 1, 'uint32');

% 48-49   subtype (v1.43k or later)
fwrite(f, 0, 'int16');

% 50-51   options (v1.43k or later)
fwrite(f, 0, 'int16');

% 52-52   arrow style or aspect ratio (v1.43p or later)
fwrite(f, 0, 'uint8');

% 53-53   arrow head size (v1.43p or later)
fwrite(f, 0, 'uint8');

% 54-55   rounded rect arc size (v1.43p or later)
fwrite(f, 0, 'int16');

% 56-59   position
fwrite(f, 0, 'uint32');

% 60-63   header2 offset
fwrite(f, 64, 'uint32');


%% ROI Data

% 64-       x-coordinates (short), followed by y-coordinates
xCoords = round(poly(:,1) - minCoords(1));
fwrite(f, xCoords, 'int16');
yCoords = round(poly(:,2) - minCoords(2));
fwrite(f, yCoords, 'int16');


%% Finalisation

% close file
fclose(f);
