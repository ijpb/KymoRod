function Elg = computeElongation(dep, t0, step, ws)
%COMPUTEELONGATION Compute elongation by spatial derivation of the displacement
% 
%   Elg = computeElongation(dep, t0, step)
%
%   Input arguments:
%   E:      a N-by-2 array containing the curvilinear abscissa and the
%           displacement of current skeleton
%   t0: 	time between two frames, in minutes
%   ws: 	size of the correlation window
%   step:   step between two measurements of displacement
%
%   Output arguments:
%   Elg:    a N-by-2 array containing the curvilinear abscissa and the
%           elongation computed for each point
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% allocate memory for elongation result
Elg = zeros(size(dep));

% convert into seconds
dt = t0 * step * 60;

% compute elongation as the derivative of displacement
for i = (1+ws):(size(dep,1)-ws)
    Elg(i,2) = (dep(i+ws,2) - dep(i-ws,2)) / (dep(i+ws,1) - dep(i-ws,1)) / dt;
end

% copy curvilinear abscissa
Elg(:, 1) = dep(:, 1);
