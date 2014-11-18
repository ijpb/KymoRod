function [SK, R] = contourSkeleton(CT, dir2)
%CONTOURSKELETON Skeletonization of a contour by voronoisaition
%
% [SK, R] = contourSkeleton(CT, dir2)
% Rewrittent from "skel55b" after removing contour filtering, and cleaning
% up code.
%
% CT: 	Contour of the figure
% dir2: Position of the initial point of the skeleton
%
% Outputs: 
% SK: 	the resulting skeleton, as a N-by-2 array of vertex coordinates
% R:  	Radius associated to each vertex of the contour
%
%
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file

% Compute Voronoi Diagram of boundary points
[V, C] = voronoin(CT);

% compute number of elements of each array
nGerms      = size(CT, 1);
nVertices   = size(V, 1);
nCells      = size(C, 1);

% Detection of the points inside the contour
insideFlag = inpolygon(V(:,1), V(:,2), CT(:,1), CT(:,2));

% indices of neighbors of each vertex (three by construction)
neighInds = zeros(nVertices, 3);
neighCount = ones(nVertices, 1);

% For each cell, identify indices of neighbor cells, and count them
for i = 1:nGerms
    % iterate over the neighbor cells
    for j = 1:length(C{i})
        % index of current neighbor cell
        ind_ij = C{i}(j);
        
        % first vertex is at infinity, and should not be considered
        if ind_ij == 1
            continue;
        end
        
        neighInds(ind_ij, neighCount(ind_ij)) = i;
        neighCount(ind_ij) = neighCount(ind_ij) + 1;
    end
end

% pour chaque sommet de Voronoi, calcule la distance au contour, en prenant
% un des germes detectes a l'etape precedente
dist = zeros(nVertices, 1);
for i = 2:nVertices
    dist(i) = norm(CT(neighInds(i,1),:) - V(i,:));
end

% data structure for storing the skeleton
% neighbors contains for each vertex, the list of neighbor indices 
% degrees contains the number of neighbors (can be 1 for terminal vertices,
% 2 for middle vertices or 3 for junction vertices).
neighbors = cell(nVertices, 1);
degrees = zeros(nVertices, 1);

% iterate on voronoi cells to compute skeleton, avoiding first cell which
% is located at infinity
for i = 2:nCells
    
    % iterate on neighbors of current cell
    h = length(C{i});
    for k = 1:h
        % index of current vertex
        iVertex = C{i}(k);
        
        % process only vertices within the contour
        if insideFlag(iVertex) == 0
            continue;
        end
            
        % Compute indices of previous and next vertices
        iPrev = C{i}(mod(k - 2, h) + 1);
        iNext = C{i}(mod(k, h) + 1);
        
        % add neighbors only if the are within the contour
        if insideFlag(iPrev) == 1
            degrees(iVertex) = degrees(iVertex) + 1;
            neighbors{iVertex}(degrees(iVertex)) = iPrev;
        end
        
        if insideFlag(iNext) == 1
            degrees(iVertex) = degrees(iVertex) + 1;
            neighbors{iVertex}(degrees(iVertex)) = iNext;
        end
        
        % avoid duplicate indices
        if degrees(iVertex) > 0
            neighbors{iVertex} = unique(neighbors{iVertex});
            degrees(iVertex) = length(neighbors{iVertex}');
        end
    end
end

% identify starting point of the skeleton
switch dir2
    case 'left'
        [R_ma, R_ma_ind] = min((-V(:,1)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'right'
        [R_ma, R_ma_ind] = max((V(:,1)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'bottom'
        [R_ma, R_ma_ind] = max((V(:,2)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'top'
        [R_ma, R_ma_ind] = min((-V(:,2)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
end


% F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un sommet externe
% v_F_d cardinal de F_d pour chaque sommet
% F_i, v_F_i idem sommet inetrieurs
% Fils_d_i=sommet interne c�te � c�te dans une cellule de voronoi avec un
% sommet externe
% F_d=sommet externe c�te � c�te dans une cellule de voronoi avec un
% sommet interne

j = R_ma_ind;
jp = j;

% Hierarchisation of the voronoi diagram
[SK2, R2, ordre] = branche(V, degrees, neighbors, dist, jp, j, 0, 0);

% the skeleton SK is the largest branch of the diagram
[SK, R] = bigbranche(SK2, ordre, R2);

