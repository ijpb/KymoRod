function [Elg E2]=elgall(E,t0,step,ws)
%ELGALL Compute the elongation 
%[Elg E2]=elgall(E,t0,step,ws)
%
%  E : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. gave by dispall()
% t0 : time between two pictures (min) define at the begin of parstart
% ws : size of the correalting window
% step : step between two measurements of displacement
%
% Return : Elg : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa relative at neighbors pixels
% E2 : a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. But smooth by kernel smoother and whitout errors
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file
E2=E;
parfor_progress(length(E));

parfor i=1:length(E)
   
    if length(E{i})>20
        E2{i}=aberrant3(E{i});
        Elg{i}=displelg(E2{i},t0,step,ws);        
    else
        Elg{i}=[0 0;1 0];
    end
    parfor_progress;

end
parfor_progress(0);
