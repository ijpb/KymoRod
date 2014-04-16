function [S A C]=curvall(SK,ws)
%[S A C]=curvall(SK,ws)
%Compute the curvilinear abscissa S, the angle A with the vertical, and the
%curvature C of the Skeleton SK.
%ws is the size of the derivative window

S=cell(length(SK),1);
A=cell(length(SK),1);
C=cell(length(SK),1);
parfor_progress(length(SK));

for i=1:length(SK)
    
    
    %Check that the length of the skeleton is not too small
    if length(SK{i})>2*ws
        %Computation of the curvilinear abscissa
        S{i}=curvilin(SK{i});
        %Computation of the angle A and tghe curvature C
        [A{i} C{i}]=curvature(SK{i},S{i},ws);
    else
        %if the length is too smal gives standard size of 0 in order to
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
