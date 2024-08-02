function Elg = displelg(dep, t0, step, ws)
%DISPLELG Compute elongation by spatial derivation of the displacement
% 
% Elg = displelg(dep, t0, step)
%
% dep: 	a N-by-2 array containing the curvilinear abscissa and the local 
%		displacement (difference of curvilinear abscissa with next frame)
% t0: 	time between two pictures (min) define at the begin of parstart
% ws: 	size of the derivative window (in number of points)
% step: step between two measurements of displacement
%
% Return 
% Elg: 	a N-by-2 array containing for each point, the displacement and the curvilinear abscissa relative at neighbors pixels
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

%dep(:,1)=moving_average(dep(:,1),5);
%dep(:,2)=moving_average(dep(:,2),5);

Elg = zeros(size(dep));

% convert into seconds
dt = t0 * step * 60;

% compute elongation as the derivative of displacement
% for i = ws+1:size(dep,1)-ws
for i = 1+ws:size(dep,1)-ws
    Elg(i,2) = (dep(i+ws,2) - dep(i-ws,2)) / (dep(i+ws,1) - dep(i-ws,1)) / dt;
end

% copy curvilinear abscissa
Elg(:, 1) = dep(:, 1);
