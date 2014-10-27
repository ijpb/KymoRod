function [S, A, C] = curvall(SK, ws)
%CURVALL Compute curvature info for all skeletons
% 
% [S, A, C] = curvall(SK, WS)
% SK    the list of skeletons, defined by a N-by-1 cell array
% WS    the width of the smoothing window, used to compute vertical angles
%
% Return: 
% S     the curvilinear abscissa, array of cell
% A     the angle with the vertical, array of cell
% C     the curvature array of each skeleton, array of cell
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 Add comments about the file

% allocate memory for results
S = cell(length(SK), 1);
A = cell(length(SK), 1);
C = cell(length(SK), 1);
parfor_progress(length(SK));

parfor i = 1:length(SK)
    curve = SK{i};
    
    % Check that the length of the skeleton is not too small
    if size(curve, 1) > 2 * ws
        % Computation of the curvilinear abscissa
%         S{i} = curvilin(SK{i});
        S{i} = curvilinearAbscissa(curve);
        
		% Computation of the angle A and the curvature C
        [A{i}, C{i}] = curvature(curve, S{i}, ws);
    else
        % if the length is too small use a dummy abscissa and zeros angle
        S{i} = (1:10)';
        A{i} = 0.*S{i};
        C{i} = 0.*S{i};
    end
    parfor_progress;

end
parfor_progress(0);

if length(S{end}) == 10
    S{end} = S{end-1};
end
