function Y = movingAverage(X, W)
% Smooth a signal by applying recursive moving average filter.
%
%   Y = movingAverage(X, W)
%   X is the signal to smooth, W is the size (width) of the smoothing
%   window, Y is the result of the smoothing.
%   Extremities are processed by duplicating first and last values.
%
%   Example
%     ti = linspace(0.1, 0.9, 10)'; ti(end) = []; n = length(ti);
%     ti2 = linspace(0.9, 0.1, 10)'; ti2(end) = [];
%     xi = [ti ; 0.9*ones(n, 1) ; ti2 ; 0.1*ones(n, 1)];
%     yi = [0.1*ones(n, 1) ; ti ; 0.9*ones(n, 1) ; ti2];
%     poly = [xi yi];
%     figure; hold on; axis([0 1 0 1]);
%     drawPolygon(poly, 'k'); drawPoint(poly, 'k.');
%     poly2 = kymorod.core.signal.movingAverage(poly, 3);
%     drawPolygon(poly2, 'm');
%   
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% INRAE - BIA Research Unit - BIBS Platform (Nantes)
% Created: 2020-08-12,    using Matlab 9.8.0.1323502 (R2020a)
% Copyright 2020 INRAE.

% number of points to process
nv = length(X);

% duplicate end points
X = X([ones(1, W) 1:nv], :);

% allocate memory for result
Y = zeros(size(X));          

% initialize moving average
Y(W+1,:) = sum(X(1:W, :));

% recursive moving average
for iv = W+2:nv+W
    Y(iv,:) = Y(iv-1,:) + X(iv,:) - X(iv-W,:);
end
Y = Y / W;

% remove trailing extremities
Y = Y(W+1:end, :);
