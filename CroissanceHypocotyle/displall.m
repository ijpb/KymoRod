function E=displall(SK,S,pic,scale,shift,ws,we,step)
%DISPLALL identifies growth areas : the displacement
%E=displall(SK,S,pic,scale,shift,ws,we,step)
%
%SK : the skeleton
%S : the  curvilinear abscissa 
%pic : pic : directory of pictures (gave by openall())
%scale : the scale, define in parstart
%shift : Coordinates of the origin of the skeleton, bottom left
%ws : size of the correalting window
%we : unnecessary in this program
%step : step between two measurements of displacement
%
% Return E , a vector at 2 dimensions with for each points, the displacement and the curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file
E=cell(length(SK)-step,1);
parfor_progress(length(SK));

parfor i=1:length(SK)-step
% for i=1:length(SK)-step
   

    if length(SK{i})>2.*80 && length(SK{i+step})>2.*80
        E{i}=elong5(SK{i},SK{i+step},S{i},S{i+step},pic{i},pic{i+step},scale,shift{i},shift{i+step},ws,we); 
        if size(E{i},1)==1
            E{i}=[1 0;1 1];
        end
            
    else
        E{i}=[1 0;1 1];
        
    end
    parfor_progress;

end
parfor_progress(0);
