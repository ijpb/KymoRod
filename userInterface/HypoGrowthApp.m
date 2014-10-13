classdef HypoGrowthApp < handle
    % Data Class for Application "HypoGrowth"
    %   
    
    properties
        % Step of processing, to know which data are initialized, and which
        % ones need to be computed.
        %
        % Valid steps:
        % 'none'
        % 'selection'
        % 'threshold'
        % 'contour'
        % 'skeleton'
        % 'kymogram'
        currentStep = 'none';
        
        % index of current frame for display
        currentFrameIndex = 1;
        
        % list of images to process
        imageList = {};
        
        % informations to retrieve input image
        imageNameList = {};
        inputImagesDir = '';
        
        % informations to select images from input directory
        firstIndex = 1;
        lastIndex = 1;
        indexStep = 1;
        
        % spatial calibration of input images
        pixelSize = 1;
        pixelSizeUnit = '';
        
        % time interval between two frames
        timeInterval = 10;
        timeIntervalUnit = 'min';
        
        % the list of threshold values used to segment images
        thresholdValues = [];
        
        % length of window for smoothing coutours
        contourSmoothingSize = 200;
        
        % list of contours, one polygon by cell, in pixel unit
        countourList = {};
        
        % list of skeletons, one curve by cell, in pixel unit
        skeletonList = {};
        
        % list of radius values
        radiusList = {};
        
        % maybe more to come...
    end
    
    methods
    end
    
end

