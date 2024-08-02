function [SQ2, R2] = skeletonLargestPath(SQ, order, R)
% SKELETONLARGESTPATH Identifies largest path within a skeleton
%
% usage:
% [SQ2, R2] = skeletonLargestPath(BRANCHES, ORDER, R)
%
% Input arguments:
% BRANCHES: a cell array containing the list of coordinates for vertices
%           of each branch
% order:    topological description of the skeleton
% R:        a cell array containing the radius associated to each vertex of
%           each branch
%
% Output arguments:
% SQ2   a N-by-2 array containing vertex coordinates along the largest path
%       within the skeleton
% R     a N-by-1 array containing radius assocated to each vertex within
%       the path.
%

% initialize results
nBranches = length(SQ);
S = cell(nBranches, 1);
branchLengths = zeros(nBranches, 1);

% compute euclidean length of each curve
for k = 1:nBranches
    branch = SQ{k};
    if length(branch) > 10
        S{k} = curvilinearAbscissa(branch);
        branchLengths(k) = S{k}(end);
    else
        % for small curves, replace by distance between extremities
        S{k} = 0;
        branchLengths(k) = sqrt(sum((branch(1,:) - branch(end,:)) .^ 2));
    end
end

% compute cumulated length of the curve
L2 = zeros(nBranches, 1);
for k = 1:nBranches
    L2(k) = sum(branchLengths(order{k}));
end

% find index of furthest curve
I = find(L2 == max(L2));
SQ2 = SQ{1};
R2 = R{1}';

% Case of several curves with max length
if length(I) > 1
    IL = zeros(1, length(I));
    for k = 1:length(I)
        IL(k) = length(order{I(k)});
    end
    ind = find(IL == max(IL));
    ind = ind(1);
    I = I(ind);
end

% concatenate the succession of vertices
for j = 2:length(order{I})
    % index of the curve to concatenate
    k = order{I}(j);
    
    % concatenate vertices and radius
    SQ2 = [SQ2 ; SQ{k}]; %#ok<AGROW>
    R2 = [R2 ; R{k}']; %#ok<AGROW>
end

