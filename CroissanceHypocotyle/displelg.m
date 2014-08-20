function Elg=displelg(dep,t0,step,ws)
%DISPLELG Compute the elongation Elg by spatial derivation of the displacement between t0*step times 
%Elg=displelg(dep,t0,step)
%
% dep : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. But smooth by kernel smoother and whitout errors. gave by aberrant3()
% t0 : time between two pictures (min) define at the begin of parstart
% ws : size of the correalting window
% step : step between two measurements of displacement
%
% Return Elg : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa relative at neighbors pixels
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

%dep(:,1)=moving_average(dep(:,1),5);
%dep(:,2)=moving_average(dep(:,2),5);
Elg=zeros(size(dep));

for i=1+ws:size(dep,1)-ws
    Elg(i,2)=(dep(i+ws,2)-dep(i-ws,2))/(dep(i+ws,1)-dep(i-ws,1))/(t0*step*60);
end

Elg(:,1)=dep(:,1);
