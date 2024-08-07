function tests = test_resample
% Test suite for the file resample.
%
%   Test suite for the file resample
%
%   Example
%   test_resample
%
%   See also
%     resample

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-01-02,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

xc = 50; yc = 40; R = 30;
t = linspace(0, pi, 100)';
x = R * cos(t) + xc;
y = R * sin(t) + yc;
poly = kymorod.data.Midline([x y]);
computeAbscissas(poly);

poly2 = resample(poly, 2);

assertTrue(testCase, isa(poly2, 'kymorod.data.Midline'));


function test_ResampleRadiusses(testCase) %#ok<*DEFNU>
% Test call of function without argument.

xc = 50; yc = 40; R = 30;
t = linspace(0, pi, 100)';
x = R * cos(t) + xc;
y = R * sin(t) + yc;
poly = kymorod.data.Midline([x y]);
poly.Radiusses = linspace(5, 15, 100)';
computeAbscissas(poly);

poly2 = resample(poly, 2);

assertTrue(testCase, isa(poly2, 'kymorod.data.Midline'));
assertFalse(testCase, isempty(poly2.Radiusses));
assertEqual(testCase, size(poly2.Coords, 1), size(poly2.Radiusses, 1));
