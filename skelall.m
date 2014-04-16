function [SK CT shift rad]=skelall(pic,thres,scale,dir,dirbegin)
%[SK CT shift rad]=skelall(pic,thres,scale,dir)
%Gives the contour CT, the skeleton SK and the radius R of the plants 
%on each image pic
%A threshold thres must be defined so that only plants can be cut from the
%background


CT=cell(length(pic),1);
SK=cell(length(pic),1);
shift=cell(length(pic),1);
rad=cell(length(pic),1);

parfor_progress(length(pic));
parfor i=1:length(pic)

    
    %Contour
    CT2=cont(pic{i},thres(i));
    %Scaling from pixel to mm
    CT2=setsc(CT2,scale);
    %Smoothing
    CT2(:,1)=moving_average(CT2(:,1),60);
    CT2(:,2)=moving_average(CT2(:,2),60);
    %Skeletonization
    [SK{i} CT{i} shift{i} rad{i}]=skel55(CT2,dir,dirbegin);
    parfor_progress;
   
end


parfor_progress(0);