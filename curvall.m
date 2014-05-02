function [S A C]=curvall(SK,ws)
%CURVALL Compute the curvilinear abscissa S, the angle A with the vertical, and the curvature C of the Skeleton SK.
% %[S A C]=curvall(SK,ws)
% SK is the skeleton
% ws is the size of the derivative window, define at the begin
%
%
% Return : the curvilinear abscissa S, array of cell
% the angle A with the vertical, array of cell
% the curvature C of the Skeleton SK, array of cell
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file

S=cell(length(SK),1);
A=cell(length(SK),1);
C=cell(length(SK),1);
parfor_progress(length(SK));

parfor i=1:length(SK)
    
    
    %Check that the length of the skeleton is not too small
    if length(SK{i})>2*ws
        %Computation of the curvilinear abscissa
        S{i}=curvilin(SK{i});
        %Computation of the angle A and tghe curvature C
        [A{i} C{i}]=curvature(SK{i},S{i},ws);
    else
        %if the length is too small gives standard size of 0 in order to
        %avoid the errors
        S{i}=(1:10)';
        A{i}=0.*S{i};
        C{i}=0.*S{i};
        diam{i}=0.*S{i};
    end
    parfor_progress;

end
parfor_progress(0);

if length(S{end})==10
    S{end}=S{end-1};
end
