function tests = test_vertexCurvature_Younes
% Test suite for the file computeCurvature_Younes.
%
%   Test suite for the file computeCurvature_Younes
%
%   Example
%   test_computeCurvature_Younes
%
%   See also
%     computeCurvature_Younes

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

vertexCurvature_Younes(poly, 10);

assertEqual(testCase, poly.Curvatures(20), 1./R, 'AbsTol', 0.001);
assertEqual(testCase, poly.Curvatures(50), 1./R, 'AbsTol', 0.001);

