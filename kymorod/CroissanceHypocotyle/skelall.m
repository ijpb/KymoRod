function [SK, CT, shift, rad, CTVerif, SKVerif] = skelall(pic, thres, scale, dir, dirbegin)
%SKELALL compute skeleton for all images
%
% [SK, CT, shift, rad] = skelall(pic, thres, scale, dir, dirbegin)
% pic:      list of images, in a cell array
% thres:    the threshold value for each image
% scale:    the scale, define at the begin of parstart
% dir:      direction of the filters define at the begin of parstart
% dirbegin: start of the filter (left,right,top or bottom) define at the begin of parstart
%
% Gives the contour CT, the skeleton SK and the radius R of the plants 
% on each image.
% A threshold thres must be defined so that only plants can be cut from the background
%
% ------
%
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA ijpb

%   HISTORY
%   2014-04-16 : Add comments about the file


CT = cell(length(pic),1);
SK = cell(length(pic),1);
shift = cell(length(pic),1);
rad = cell(length(pic),1);

parfor_progress(length(pic));
parfor i = 1:length(pic)
    % compute contour
    CT2 = cont(pic{i}, thres(i));
    
    % Scaling from pixel to mm
    CT2 = setsc(CT2, scale);
    
    % Smoothing of the contour
    CT2(:,1) = moving_average(CT2(:,1), 60);
    CT2(:,2) = moving_average(CT2(:,2), 60);
    
    % skeletonization
    [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(CT2, dir, dirbegin);
    parfor_progress;
end


parfor_progress(0);
