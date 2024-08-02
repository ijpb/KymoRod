function [Elg, E2] = elgall(E, t0, step, ws)
%ELGALL Compute the elongation from displacement vector
%
% [Elg, E2] = elgall(E, t0, step, ws)
%
% E: 	a N-by-2 array containing a curvilinear abscissa and a displacement
% t0: 	time between two frames, in minutes
% ws: 	size of the correlation window
% step: step between two measurements of displacement
%
% Return:
% Elg: a vector at 2 dimensions with for each points, the elongation and the curvilinear abscissa relative at neighbors pixels
% E2: a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa. But smooth by kernel smoother and whitout errors
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file

E2 = E;
parfor_progress(length(E));

parfor i = 1:length(E)
   
    if length(E{i}) > 20
        % Smooth the curve and remove errors using kernel smoothers
        E2{i} = aberrant3(E{i});
        
        % Compute elongation by spatial derivation of the displacement
        Elg{i} = displelg(E2{i}, t0, step, ws);        
    else
        % case of very small vectors
        Elg{i} = [0 0;1 0];
    end
    parfor_progress;

end
parfor_progress(0);
