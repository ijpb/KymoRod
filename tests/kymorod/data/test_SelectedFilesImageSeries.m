function tests = test_SelectedFilesImageSeries
% Test suite for the file SelectedFilesImageSeries.
%
%   Test suite for the file SelectedFilesImageSeries
%
%   Example
%   test_SelectedFilesImageSeries
%
%   See also
%     SelectedFilesImageSeries

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-03,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

% prepare
fileName = 'test_write_imageSeries.json';
if exist(fileName, 'file') > 0
    delete(fileName);
end

% file pattern for segmentation of hypocotyles
inputDir = fullfile('..', '..', 'data', 'cropTif');
pattern = 'img*.tif';

% Create the data structure to access the images.
imageSet = kymorod.data.SelectedFilesImageSeries(inputDir, pattern);

write(imageSet, fileName);
imageSet2 = kymorod.data.SelectedFilesImageSeries.read(fileName);

assertTrue(testCase, isa(imageSet2, 'kymorod.data.ImageSeries'));
assertEqual(testCase, imageCount(imageSet2), 51);

% cleanup
delete(fileName);



