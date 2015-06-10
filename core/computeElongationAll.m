function [Elg, E2] = computeElongationAll(E, t0, step, ws)
%COMPUTEELONGATIONALL Compute the elongation from displacement vector
%
%   [Elg, E2] = computeElongationAll(E, t0, step, ws)
%   (rewritten from function elgall)
%
%   Input arguments:
%   E:      a cell array containing the curvilinear abscissa and the
%           displacement of each skeleton
%   t0: 	time between two frames, in minutes
%   ws: 	size of the correlation window
%   step:   step between two measurements of displacement
%
%   Output arguments:
%   Elg:    a N-by-2 array containing the curvilinear abscissa and the
%           elongation computed for each point
%   E2:     a N-by-2 array containing the curvilinear abscissa and the
%           smoothed and filtered displacement computed for each point
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file

% initialize results
E2 = E;
Elg = cell(length(E), 1);

% iterate over displacement curves
parfor_progress(length(E));
parfor i = 1:length(E)
   
    if length(E{i}) > 20
        % Smooth the curve and remove errors using kernel smoothers
        E2{i} = filterDisplacement(E{i});
        
        % Compute elongation by spatial derivation of the displacement
        Elg{i} = computeElongation(E2{i}, t0, step, ws);        
    else
        % case of very small vectors
        Elg{i} = [0 0;1 0];
    end
    parfor_progress;

end
parfor_progress(0);
