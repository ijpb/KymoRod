function [poly2, vals] = removeDoubleVertices(poly, vals)
%REMOVEDOUBLEVERTICES Removes double vertices in a closed contour
%
%   POLY2 = removeDoubleVertices(POLY)
%   Removes all double vertices (adjacent vertices with same coordinates)
%   in the original polygon given by POLY.
%   POLY 	the initial contour, as a N-by-2 list of coordinates
%   POLY2   the resulting contour without double vertices
%
%   [POLY2, VALS2] = removeDoubleVertices(POLY, VALS)
%   where VALS is a N-by-1 array containing a measure associated to each
%   vertex, returns the sieved array of values.
%

% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% find indices of multiple vertices from distance between adjacent vertices
isMul = sum(abs(poly - circshift(poly, 1)), 2) == 0;

% derivation of binary signal of multiple vertices
isMul = diff(isMul([1:end 1]));

% identifies beginning and end of ranges of multiple vertices
startInds = find(isMul == 1);
endInds = find(isMul == -1);

% number of groups of multiple vertices
nRanges = length(startInds);

% drop the begining of multiple vertices ranges
inds = true(size(poly, 1), 1);
for i = 1:nRanges
    inds(startInds(i):endInds(i)-1, :) = 0;
end
poly2 = poly(inds, :);

% eventually process array of values
if nargin > 1
    vals = vals(inds);
end
