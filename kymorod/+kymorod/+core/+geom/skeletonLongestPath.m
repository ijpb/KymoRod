function [path, rads] = skeletonLongestPath(skel, startIndex)
% Extract the longest path from a skeleton and start vertex.
%
%   [PATH, RADLIST] = skeletonLongestPath(SKEL, STARTINDEX)
%
%   Example
%   skeletonLongestPath
%
%   See also
%     polygonSkeleton
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-10,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% check input
if ~isstruct(skel)
    error('First aregument must be a struct with ''vertices'' and ''adjList'' fields');
end

% extract edge info, or re-create it if necessary
if isfield(skel, 'edges')
    edges = skel.edges;
else
    edges = adjacencyListToEdges(skel.adjList);
end

% compute edge lengths
edgeLengths = grEdgeLengths(skel.vertices, edges);

% create "Graph" object, with edge weights corresponding to edge lengths
G = graph(edges(:,1), edges(:,2), edgeLengths);

% propagate distance from given index, and identify index of furthest
% vertex
[~, dists] = shortestpathtree(G, startIndex);
[~, endIndex] = max(dists);

% identifies index of vertices on the path
pathVertexInds = shortestpath(G, startIndex, endIndex);

% create polyline, and keep the list of associated radiusses
path = skel.vertices(pathVertexInds, :);
rads = skel.radius(pathVertexInds);
