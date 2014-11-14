function S_n = removeDoubleVertices(S)
%removeDoubleVertices Removes double vertices in a closed contour
%
% S2 = removeDoubleVertices(S)
% S: 	the initial contour
% S2:   contour without double vertices
%

% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

% compute distances between adjacent vertices
d_S = abs(S - circshift(S, 1));

% find indices of multiple vertices
d_S = sum(d_S, 2) == 0;

% derivation of binary signal of multiple vertices
d_S = diff(d_S([1:end 1]));

% identifies beginning and end of groups of multiple vertices
f_pos = find(d_S == 1);
f_neg = find(d_S == -1);

% number of groups of multiple vertices
s_f = length(f_pos);

% set abscissa of multiple vertices to zero
S_n = S;
for i = 1:s_f
  S_n(f_pos(i):f_neg(i)-1, :) = 0;
end

% keep only non-multiple vertices
S_n = S_n(S_n(:,1) > 0,:);
