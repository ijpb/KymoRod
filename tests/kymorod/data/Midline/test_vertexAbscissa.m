function tests = test_vertexAbscissa
% Test suite for the file computeAbscissas.
%
%   Test suite for the file computeAbscissas
%
%   Example
%   test_computeAbscissas
%
%   See also
%     computeAbscissas

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-31,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);

function test_Simple(testCase) %#ok<*DEFNU>
% Test call of function without argument.

midline = kymorod.data.Midline([0 0 ; 10 0; 10 10; 20 10]);
computeAbscissas(midline);

assertTrue(testCase, isa(midline, 'kymorod.data.Midline'));
assertTrue(testCase, ~isempty(midline.Abscissas));
