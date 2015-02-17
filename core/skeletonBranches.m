function [SK, diam, order] = skeletonBranches(V, V_F, F, dist, jp, j, m, parent)
% Hierarchisation of a voronoi diagram
%
%   (attention: fonction recursive!)
%   [SK, diam, order] = skeletonBranches(V, V_F, F, dist, jp, j, m, parent)
%
%   Input arguments:
%   V       vertex corodinates
%   V_F     degree of each vertex (between 1 and 3)
%   F       list of neighbors of each vertex
%   dist    distance between each vertex and initial contour
%   jp      vertex index at previsou step
%   j       index of starting vertex
%   m       index of branch around current vertex
%   parent  index of parent branch
% 
%   Output arguments:
%   SK      a cell array containing the branches, each branch being given 
%           as a list of N-by-2 coordinates of adjacent vertices
%   diam    a cell array containing the diameter for each vertex of the
%           skeleton
%   order   contains the topology of the skeleton graph
%

% some global variables
% N         branch index
% SQ4:
% diam2:    diameter of each branch
% order2:


persistent N SQ4 diam2 order2;

hold on;

% initialization during first call
if parent == 0 && m == 0
    % index of current branch. First branch has index 1 by definition.
    N       = 1;
    
    % list of branches, and list of branch radius
    SQ4     = [];
    diam2   = [];
    
    % list of parents for each branch
    order2  = [];
end

% % vertex index within the branch
% i = 1;

% initialize current branch with node vertex and current vertex
% (branch = vertex list + radius list);
SK1 = V([jp j], :);
diam1  = dist([jp j])';

% SK1(i, 1) = V(j, 1);
% SK1(i, 2) = V(j, 2);
% diam1(i)  = dist(j);

i = 2;

% find terminal (degree=1) or internal (degree=2) vertices
if V_F(j) < 3
    % find index of next vertex along the current branch
    jind = F{j} ~= jp;
    jp = j;
    j = F{j}(jind);
    V_F(j) = V_F(j) - 1;
    
    % iterate while current vertex is terminal
    while V_F(j) == 1
        % add current vertex to the current branch
        i = i + 1;
        SK1(i, 1) = V(j, 1);
        SK1(i, 2) = V(j, 2);
        diam1(i) = dist(j);

        % find index of next vertex along the current branch
        jind = F{j} ~= jp;
        jp = j;
        j = F{j}(jind);
        V_F(j) = V_F(j) - 1; 
    end
    
    % add last vertex to the current branch
    % TODO: check why j could be empty...
    if ~isempty(j)
        i = i + 1;
        SK1(i, 1) = V(j, 1);
        SK1(i, 2) = V(j, 2);
        diam1(i) = dist(j);
    end
end

% store current branch in global variables
SQ4{N}      = SK1;
diam2{N}    = diam1;
    
% store succession of branch indices to reach the initial branch
if N == 1
    order2{N} = 1;
else
    order2{N} = [order2{parent} N];
end

% current branch will be used as parent for other branches concurrent to
% the current vertex, if such branches exist
if V_F(j) > 1
    % index of current branch is used to identify parent of other branches
    parent = N;
    
    % identify the vertices corresponding to child branch initiations
    j2 = F{j}(F{j} ~= jp);
    
    % initialize a new branch from each of the child vertices
    % (any number of children is allowed, though the expected number is 2)
    for k = 1:length(j2)
        N = N + 1;
        skeletonBranches(V, V_F, F, dist, j, j2(k), k, parent);
    end   
end

% rename variables
SK      = SQ4;
diam    = diam2;
order   = order2;

