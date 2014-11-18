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
L = zeros(nBranches, 1);

% compute euclidean length of each curve
for k = 1:nBranches
    branch = SQ{k};
    if length(branch) > 10
        S{k} = curvilinearAbscissa(branch);
        L(k) = S{k}(end);
    else
        % for small curves, replace by distance between extremities
        S{k} = 0;
        L(k) = sqrt(sum((branch(1,:) - branch(end,:)) .^ 2));
    end
end

% compute cumulated length of the curve
L2 = zeros(nBranches, 1);
for k = 1:nBranches
    L2(k) = sum(L(order{k}));
end

% find index of furthest curve
I = find(L2 == max(L2));
SQ2 = SQ{1};
R2 = R{1}';

% Case of two curves (can it happen ?)
if length(I) > 1
    for Ik = I
        IL = length(order{Ik});
    end
    I = Ik(IL == max(IL));
end

% concatenate the succession of vertices
for j = 2:length(order{I})
    % index of the curve to concatenate
    k = order{I}(j);
    
    % concatenate vertices and radius
    SQ2 = [SQ2 ; SQ{k}]; %#ok<AGROW>
    R2 = [R2 ; R{k}']; %#ok<AGROW>
end

