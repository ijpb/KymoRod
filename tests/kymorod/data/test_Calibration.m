function tests = test_Calibration
% Test suite for the file Calibration.
%
%   Test suite for the file Calibration
%
%   Example
%   test_Calibration
%
%   See also
%     Calibration

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-07,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_WriteRead(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% prepare
fileName = 'test_write_calib.calib';
if exist(fileName, 'file') > 0
    delete(fileName);
end

calib = createSampleCalibration();

write(calib, fileName);

calib2 = kymorod.data.Calibration.read(fileName);

assertEqual(testCase, calib2.PixelSize,         calib.PixelSize);
assertEqual(testCase, calib2.PixelSizeUnit,     calib.PixelSizeUnit);
assertEqual(testCase, calib2.TimeInterval,      calib.TimeInterval);
assertEqual(testCase, calib2.TimeIntervalUnit,  calib.TimeIntervalUnit);

% cleanup
delete(fileName);


function calib = createSampleCalibration()

calib = kymorod.data.Calibration();
calib.PixelSize = 2.5;
calib.PixelSizeUnit = 'µm';
calib.TimeInterval = 10;
calib.TimeIntervalUnit = 'mn';
