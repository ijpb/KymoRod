classdef HypoGrowthAppData < handle
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
        inputImagesFilePattern = '*.*';
        
        % flag indicating whether images are loaded in memory or read from
        % files only when necessary
        inputImagesLazyLoading = false;
        
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
        % point of skeleton (old 'SK').
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
        
        % the number of points used to discretize signal on each skeleton
        finalResultLength = 500;
        
        % the curvilinear abscissa of each skeleton, in a cell array
        abscissaList;
        
        % the angle with the vertical of each point of each skeleton, in a
        % cell array 
        verticalAngleList;
        
        % the curvature of each point of each skeleton, in a cell array 
        curvatureList;
        
        % the displacement of a point to the next similar point
        displacementList;
        
        smoothedDisplacementList;
        
        elongationList;
        
        elongationImage;
        
        % reconstructed image of curvature in absissa and time
        curvatureImage;
        
        % reconstructed image of angle with vertical in absissa and time
        verticalAngleImage;
        
        % reconstructed image of skeleton radius in absissa and time
        radiusImage;
    end
    
    % Constructor
    methods
        function this = HypoGrowthAppData(varargin)
            % Create a new data structure for storing application data
        end
    end
    
   
    % Data access methods
    methods
        function image = getImage(this, index)
            if this.inputImagesLazyLoading
                filePath = fullfile(this.inputImagesDir, this.imageNameList{index});
                image = imread(filePath);
            else
                image = this.imageList{index};
            end
        end
        
        function readAllImages(this)
            % load all images based on settings
            % refresh imageList and imageNameList
            
            % read all files in specified directory
            fileList = dir(fullfile(this.inputImagesDir, this.inputImagesFilePattern));
            
            % ensure no directory is load (can happen under linux)
            fileList = fileList(~[fileList.isdir]);

            % select images corresponding to indices selection
            fileIndices = this.firstIndex:this.indexStep:this.lastIndex;
            fileList = fileList(fileIndices);
            nImages = length(fileList);
            
            % allocate memory
            this.imageList = cell(nImages, 1);
            this.imageNameList = cell(nImages, 1);
            
            % read each image
            for i = 1:nImages
                fileName = fileList(i).name;
                this.imageNameList{i} = fileName;
                img = imread(fullfile(this.inputImagesDir, fileName));
                
                % keep only the red channel of color images
                if ndims(img) > 2 %#ok<ISMAT>
                    img = img(:,:,1);
                end
                this.imageList{i} = img;
            end
            
        end
    end
    
    
    % input / output methods
    methods
        function saveSettings(this, fileName)
            % Save the different options used to compute kymographs
            
            % open in text mode, erasing content if it exists
            f = fopen(fileName, 'w+t');
            if f == -1
                errordlg(['Could not open file for writing: ' fileName]);
                return;
            end
 
            % write header
            fprintf(f, '# KymoRod Settings\n');
            fprintf(f, '# %s\n', datestr(now,0));
            fprintf(f, '\n');
            
            
            % informations to retrieve input image
            fprintf(f, 'inputImagesDir = %s\n', this.inputImagesDir);
            fprintf(f, 'inputImagesFilePattern = %s\n', this.inputImagesFilePattern);
            string = HypoGrowthAppData.booleanToString(this.inputImagesLazyLoading);
            fprintf(f, 'inputImagesLazyLoading = %s\n', string);
            fprintf(f, '\n');
            
            % informations to select images from input directory
            fprintf(f, 'firstIndex = %d\n', this.firstIndex);
            fprintf(f, 'lastIndex = %d\n', this.lastIndex);
            fprintf(f, 'indexStep = %d\n', this.indexStep);
            fprintf(f, '\n');
                    
            % spatial calibration of input images
            fprintf(f, 'pixelSize = %f\n', this.pixelSize);
            fprintf(f, 'pixelSizeUnit = %s\n', this.pixelSizeUnit);
            fprintf(f, '\n');
            
            % time interval between two frames
            fprintf(f, 'timeInterval = %f\n', this.timeInterval);
            fprintf(f, 'timeIntervalUnit = %s\n', this.timeIntervalUnit);
            fprintf(f, '\n');
        
            % length of window for smoothing coutours
            fprintf(f, 'contourSmoothingSize = %d\n', this.contourSmoothingSize);
            fprintf(f, '\n');
            
            % smoothing window size for computation of curvature
            fprintf(f, 'curvatureSmoothingSize = %d\n', this.curvatureSmoothingSize);
            fprintf(f, '\n');
            
            % info for computation of elongation
            fprintf(f, 'windowSize1 = %d\n', this.windowSize1);
            fprintf(f, 'windowSize2 = %d\n', this.windowSize2);
            fprintf(f, 'displacementStep = %d\n', this.displacementStep);
            fprintf(f, 'finalResultLength = %d\n', this.finalResultLength);
            fprintf(f, '\n');
           
            % info about current step of the process
            fprintf(f, 'currentStep = %s\n', this.currentStep);
            fprintf(f, 'currentFrameIndex = %d\n', this.currentFrameIndex);
            fprintf(f, '\n');
        
            % close the file
            fclose(f);
        end
    end
    
    % Static methods 
    methods (Static)
        function app = readFromFile(fileName)
            
            % create new empty appdata class
            app = HypoGrowthAppData();
            
            % open in text mode, erasing content if it exists
            f = fopen(fileName, 'rt');
            if f == -1
                errordlg(['Could not open file for reading: ' fileName]);
                return;
            end
 
            while true
                % read lines until end of file
                line = fgetl(f);
                if line == -1
                    break;
                end
                
                % avoid empty lines and comment lines
                line = strtrim(line);
                if isempty(line) || line(1) == '#'
                    continue;
                end
                
                % extract tokens
                tokens = strsplit(line, '=');
                if length(tokens) < 2
                    continue;
                end
                
                % cleanup tokens
                key = strtrim(tokens{1});
                value = strtrim(tokens{2});
                
                % interpret values of tokens
                switch lower(key)
                    case lower('inputImagesDir')
                        app.inputImagesDir = value;
                    case lower('inputImagesFilePattern')
                        app.inputImagesFilePattern = value;
                    case lower('inputImagesLazyLoading')
                        app.inputImagesLazyLoading = strcmp(value, 'true');
                        
                    case lower('firstIndex')
                        app.firstIndex = str2double(value);
                    case lower('lastIndex')
                        app.lastIndex = str2double(value);
                    case lower('indexStep')
                        app.indexStep = str2double(value);
                        
                    case lower('pixelSize')
                        app.pixelSize = str2double(value);
                    case lower('pixelSizeUnit')
                        app.pixelSizeUnit = value;
                        
                    case lower('timeInterval')
                        app.timeInterval = str2double(value);
                    case lower('timeIntervalUnit')
                        app.timeIntervalUnit = value;
                        
                    case lower('contourSmoothingSize')
                        app.contourSmoothingSize = str2double(value);
                    case lower('curvatureSmoothingSize')
                        app.curvatureSmoothingSize = str2double(value);
                    case lower('windowSize1')
                        app.windowSize1 = str2double(value);
                    case lower('windowSize2')
                        app.windowSize2 = str2double(value);
                    case lower('displacementStep')
                        app.displacementStep = str2double(value);
                    case lower('finalResultLength')
                        app.finalResultLength = str2double(value);
                    
                    case lower('currentStep')
                        app.currentStep = value;
                    case lower('currentFrameIndex')
                        app.currentFrameIndex = str2double(value);
                    
                    otherwise
                        warning(['Unrecognized parameter: ' key]);
                end
            end
            
            % close file
            fclose(f);
        end
    end
    
    % some utility methods
    methods (Static, Access = private)
        function string = booleanToString(bool)
             if bool
                string = 'true';
            else
                string = 'false';
            end
        end
    end
end