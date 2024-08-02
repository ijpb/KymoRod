function S = curvilinearAbscissa(curve)
%CURVILINEARABSCISSA Compute the curvilinear abscissa of a curve
%
% S = curvilinearAbscissa(CURVE)
% CURVE: a N-by-2 array containing coordinates of curve vertices
% S:     a N-by-1 array containing the curvilinear abscissa of each vertex,
%        starting at zero.
% 
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 Add comments about the file
%   2014-10-27 rewrite from 'parametrize' function in MatGeom.

% process points in 2D
S = [0 ; cumsum(hypot(diff(curve(:,1)), diff(curve(:,2))))];
