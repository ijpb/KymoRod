function tests = test_snapToPixels
% Test suite for the file snapToPixels.
%
%   Test suite for the file snapToPixels
%
%   Example
%   test_snapToPixels
%
%   See also
%     snapToPixels

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-01-02,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

xc = 50; yc = 40; R = 30;
t = linspace(0, pi, 200)';
x = R * cos(t) + xc;
y = R * sin(t) + yc;
poly = kymorod.data.Midline([x y]);
computeAbscissas(poly);

calib = kymorod.data.Calibration();
poly2 = snapToPixels(poly, calib);

assertTrue(testCase, isa(poly2, 'kymorod.data.Midline'));
