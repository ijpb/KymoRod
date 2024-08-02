function S_n = cleandouble(S)
%CLEANDOUBLE Removes double vertices in a contour
%
% S_n = cleandouble(S)
% S: 	the initial contour
% S_n   contour without double vertices
%

% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% compute distances between adjacent vertices
d_S = abs(S - circshift(S, 1));

% find indices of multiple vertices
d_S = sum(d_S')' == 0;

% derivation of binary signal of multiple vertices
d_S = d_S - circshift(d_S,1);

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
