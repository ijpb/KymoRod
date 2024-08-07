function tests = test_fromToStruct
% Test suite for the file fromToStruct.
%
%   Test suite for the file fromToStruct
%
%   Example
%   test_fromToStruct
%
%   See also
%     fromToStruct

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2021-01-03,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2021 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

xc = 50; yc = 40; R = 30;
t = linspace(0, pi, 50)';
x = R * cos(t) + xc;
y = R * sin(t) + yc;
poly = kymorod.data.Midline([x y]);
computeAbscissas(poly);

str = toStruct(poly);
poly2 = kymorod.data.Midline.fromStruct(str);

assertTrue(testCase, isa(poly2, 'kymorod.data.Midline'));
