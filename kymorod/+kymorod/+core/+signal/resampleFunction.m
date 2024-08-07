function Y2 = resampleFunction(X, Y, X2)
% Resample a (X,Y) function using new X basis.
%
%   Y2 = resampleFunction(X, Y, X2)
%
%   Example
%   resampleFunction
%
%   See also
%     resampleSkeletonCurve
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% check input dimensions
n = length(X);
if length(Y) ~= n
    error('require same number of values for X and Y inputs');
end

% allocate memory for result
n2 = length(X2);
Y2 = zeros(n2, 1);

% iterate over positions in result
for i = 1:n2
    % index of surrounding values before and after sampling position
    ind0 = find(X <= X2(i), 1, 'last');
    ind1 = find(X >= X2(i), 1, 'first');
    
    if ind0 == ind1
        % get position of a vertex in input polyline
        Y2(i) = Y(ind0);
        continue;
    end
    
    % the two values to interpolate
    pt0 = Y(ind0);
    pt1 = Y(ind1);
    
    % weights associated to each value
    l0 = X2(i) - X(ind0);
    l1 = X(ind1) - X2(i);
    
    % linear interpolation of values
    if (l0 + l1) > max(X2) * 1e-12
        Y2(i, :) = (pt0 * l1 + pt1 * l0) / (l0 + l1);
    else
        % if neighbors are too close, do not use interpolation
        Y2(i, :) = pt0;
    end
end

