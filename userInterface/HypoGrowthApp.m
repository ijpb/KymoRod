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
        % 'elongation'
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
        contourSmoothingSize = 20;
        
        % list of contours, one polygon by cell, in pixel unit (old 'CTVerif')
        contourList = {};
        
        % list of contours after rescaling, and translation wrt skeleton
        % origin (old CT).
        scaledContourList = {};
        
        % location of the first point of the skeleton. Can be one of 
        % 'bottom', 'top', 'left', 'right'. 
        firstPointLocation = 'bottom';
        
        % list of skeletons, one curve by cell, in pixel unit (old SKVerif)
        skeletonList = {};
        
        % list of skeletons after rescaling, and translation wrt first
        % point of skeleton (olf SK).
        scaledSkeletonList = {};
        
        % list of radius values (old 'rad')
        radiusList = {};
        
        % coordinates of the first point of the skeleton for each image
        originPosition = {};
        
        % smoothing window size for computation of curvature
        curvatureSmoothingSize = 10;
        
        % size of first correlation window (in pixels)
        windowSize1 = 15;
        % size of second correlation window (in pixels)
        windowSize2 = 20;
        
        % length of displacement (in pixels)
        displacementStep = 2;
        
        finalResultLength = 500;
        
        abscissaList;

        verticalAngleList;
        
        curvatureList;
        
        displacementList;
        
        elongationList;
        
        elongationImage;
        
        curvatureImage;
        
        verticalAngleImage;
        
        radiusImage;
    end
    
    methods
    end
    
end

