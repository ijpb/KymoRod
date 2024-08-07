function tests = test_Midline
% Test suite for the file Midline.
%
%   Test suite for the file Midline
%
%   Example
%   test_Midline
%
%   See also
%     Midline

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2020-12-31,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE - BIA-BIBS.

tests = functiontests(localfunctions);


function test_constructor(testCase) %#ok<*DEFNU>
% Test call of function without argument.

c = kymorod.data.Midline([0 0 ; 10 0; 10 10; 20 10]);

assertTrue(testCase, isa(c, 'kymorod.data.Midline'));


