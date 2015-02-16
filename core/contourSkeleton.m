function [SK, R] = contourSkeleton(CT, dir2)
%CONTOURSKELETON Skeletonization of a contour by voronoisaition
%
%   [SK, R] = contourSkeleton(CT, dir2)
%   Rewritten from "skel55b" after removing contour filtering, and cleaning
%   up code.
%   
%
%   CT:     Contour of the figure
%   dir2:   Position of the initial point of the skeleton
%
%   Outputs: 
%   SK: 	the resulting skeleton, as a N-by-2 array of vertex coordinates
%   R:  	Radius associated to each vertex of the contour
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

% iterate over cells to identify the indices of germs surrounding each
% vertex
for i = 1:nGerms
    % iterate over the neighbor cells
    for j = 1:length(C{i})
        % index of current neighbor cell
        ind_ij = C{i}(j);
        
        % first vertex is at infinity, and should not be considered
        if ind_ij == 1
            continue;
        end
        
        % update the list of neighbors of each neighbor
        neighInds(ind_ij, neighCount(ind_ij)) = i;
        neighCount(ind_ij) = neighCount(ind_ij) + 1;
    end
end

% for each voronoi vertex, compute the distance to original contour,
% using the array computed at previous step
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

% identify starting point of the skeleton, using apriori direction
switch dir2
    case 'left'
        [tmp, startIndex] = max((-V(:,1)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'right'
        [tmp, startIndex] = max((V(:,1)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'bottom'
        [tmp, startIndex] = max((V(:,2)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
    case 'top'
        [tmp, startIndex] = max((-V(:,2)) .* (degrees==1).*insideFlag); %#ok<ASGLU>
end


% Hierarchisation of the voronoi diagram
j = startIndex;
jp = j;
[SK, R, order] = skeletonBranches(V, degrees, neighbors, dist, jp, j, 0, 0);

% the skeleton SK is the largest branch of the diagram
[SK, R] = skeletonLargestPath(SK, order, R);
