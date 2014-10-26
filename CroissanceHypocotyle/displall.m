function E = displall(SK,S,pic,scale,shift,ws,we,step)
% DISPLALL identifies growth areas : the displacement
%
% E = displall(SK, S, pic, scale, shift, ws, we, step)
%
% SK: 	the skeleton
% S: 	the curvilinear abscissa 
% pic:  directory of pictures (given by openall())
% scale: the scale, defined in parstart
% shift: coordinates of the origin of the skeleton, bottom left
% ws: 	size of the correlating window
% we: 	unnecessary in this program
% step: step between two measurements of displacement
%
% E: a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file

E = cell(length(SK)-step, 1);

parfor_progress(length(SK));
parfor i = 1:length(SK) - step
% for i=1:length(SK)-step
    
	% index of next skeleton
	i2 = i + step;
	
	% check if the two skeletons are large enough
    if length(SK{i}) > 2.*80 && length(SK{i2}) > 2.*80
        E{i} = elong5(SK{i}, SK{i2}, S{i}, S{i2}, pic{i}, pic{i2}, ...
			scale, shift{i}, shift{i2}, ws, we); 
		
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
