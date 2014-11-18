function [SK, diam, ordre] = skeletonBranches(V, V_F, F, dist, jp, j, m, pere)
% Hierarchisation of a voronoi diagram
%
% (attention: fonction recursive!)
%
% V     : vertex corodinates
% V_F   : degree of each vertex (between 1 and 3)
% F     : list of neighbors of each vertex
% dist  : distance between each vertex and initial contour
% jp    : vertex index at previsou step
% j     : index of starting vertex
% m     : index of branch around current vertex
% pere  : parent node
% 
% renvoie:
% SK: un tableau de cellule contenant les branches, chaque branche sous la
% forme d'un tableau N-by-2 de coordonnees
% diam: diametres locaux
% ordre : topologie du graphe

% some global variables
% N         branch index
% SQ4:
% diam2:    diameter of each branch
% ordre2:


persistent N SQ4 diam2 ordre2;

hold on;

% initialization during first call
if pere == 0 && m == 0
    % index of current branch
    N = 1;
    
    % list of branches, and list of branch radius
    SQ4 = [];
    diam2 = [];
    
    % list of parents for each branch
    ordre2 = [];
end

% vertex index within the branch
i = 1;

% initialize current branch with current vertex
% (branch = vertex list + radius list);
SK1(i, 1) = V(j, 1);
SK1(i, 2) = V(j, 2);
diam1(i)  = dist(j);

% find terminal (degree=1) ou internal (degree=2) vertices
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
end

% store current branch
SQ4{N} = SK1;
diam2{N} = diam1;
    
% store branch order from initial vertex
if N == 1
    ordre2{N} = 1;
else
    ordre2{N} = [ordre2{pere} N];
end

% current branch will be used as parent for other branches concurrent to
% the current vertex, if such branches exist
if V_F(j) > 1
    % index of current branch is used to identify parent of other branches
    pere = N;
    
    % identify the vertices corresponding to child branche initiations
    j2 = F{j}(F{j} ~= jp);
    
    if length(j2) ~= 2
        error(['Branching points should generate 2 children, not ' num2str(length(j2))]);
    end
        
    % initialize a new branch from each of the child vertices
    N = N + 1;
    skeletonBranches(V, V_F, F, dist, j, j2(1), 1, pere);
    
    N = N + 1;    
    skeletonBranches(V, V_F, F, dist, j, j2(2), 2, pere);    
end

% rename variables
SK      = SQ4;
diam    = diam2;
ordre   = ordre2;

