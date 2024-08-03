function tests = test_TimeLapseImage
% Test suite for the file TimeLapseImage.
%
%   Test suite for the file TimeLapseImage
%
%   Example
%   test_TimeLapseImage
%
%   See also
%     TimeLapseImage

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-07,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% prepare
fileName = 'test_write_timelapse.json';
if exist(fileName, 'file') > 0
    delete(fileName);
end

% file pattern for segmentation of hypocotyles
inputDir = fullfile('..', '..', 'data', 'cropTif');
pattern = 'img*.tif';

% Create the data structure to access the images.
imageSet = kymorod.data.SelectedFilesImageSeries(inputDir, pattern);
timeLapse = kymorod.data.TimeLapseImage(imageSet);

% change default calibration of time-lapse image
timeLapse.Calibration.PixelSize = 0.00205;
timeLapse.Calibration.PixelSizeUnit = 'mm';
timeLapse.Calibration.TimeInterval = 6.0;
timeLapse.Calibration.TimeIntervalUnit = 'min';

write(timeLapse, fileName);
timeLapse2 = kymorod.data.TimeLapseImage.read(fileName);

assertTrue(testCase, isa(timeLapse2, 'kymorod.data.TimeLapseImage'));
calib2 = timeLapse2.Calibration;
assertTrue(testCase, isa(calib2, 'kymorod.data.Calibration'));
assertEqual(testCase, calib2.PixelSize, 0.00205, .0001);

% cleanup
delete(fileName);
