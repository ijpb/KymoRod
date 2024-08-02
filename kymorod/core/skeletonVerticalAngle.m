function A = skeletonVerticalAngle(SK, ws)
% SKELETONVERTICALANGLE Compute angle according to the vertical of a skeleton
%
% A = skeletonVerticalAngle(SK, WS)
% Compute the angle with the vertical of skeleton vertices. Tangent vector
% is obtained by finite differences of vertex coordinates at i+/-WS. 
% SK: skeleton of the figure, as a N-by-2 array of vertex coordinates
% WS: is the size of the derivative window
%
% Return A: value of the angle A
% 
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% number of vertices
n = length(SK);

% allocate memory
A = zeros(n, 1);

% compute angle of remaining points
for i = ws+1:n-ws
	dx = SK(i+ws,1) - SK(i-ws,1);
	dy = SK(i+ws,2) - SK(i-ws,2);
	A(i) = atan2(dx, dy);
end

% add smoothing
if length(A(ws+1:n-ws)) > 2 * ws
    A(ws+1:n-ws) = moving_average(A(ws+1:n-ws), ws);
end

% complete missing values at extremities
A(1:ws) = A(ws+1);
A(n-ws:end) = A(end-ws-1);
