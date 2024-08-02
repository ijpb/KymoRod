function E = computeDisplacementPxAll(SK, S, pic, ws, step)
% COMPUTEDISPLACEMENTPXALL compute displacement between all couples of images
%
% E = computeDisplacementPxAll(SK, S, pic, scale, shift, ws, we, step)
% (rewritten from displall)
%
% SK: 		the list of skeletons, as a cell array
% S: 		the list of curvilinear abscissa, as a cell array
% pic:  	the list of images
% ws: 		size of the window for computing displacement
% step: 	step between two measurements of displacement
%
% E: a vector at 2 dimensions with for each points, the displacement and
% the curvilinear abscissa 
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

% Note: deprecated, now direclty computed from within the KymoRod class)


nFrames = length(SK);
E = cell(nFrames-step, 1);

parfor_progress(nFrames);
parfor i = 1:nFrames - step
	% index of next skeleton
	i2 = i + step;
	
	% check if the two skeletons are large enough
    if length(SK{i}) > 2*80 && length(SK{i2}) > 2*80 %#ok<PFBNS>
        E{i} = computeDisplacementPx(SK{i}, SK{i2}, S{i}, S{i2}, pic{i}, pic{i2}, ws);  %#ok<PFBNS>
		
		% check result is large enough
        if size(E{i},1) == 1
            E{i} = [1 0;1 1];
        end
            
    else
		% case of too small skeletons
        E{i} = [1 0; 1 1];
        
    end
    parfor_progress;

end
parfor_progress(0);
