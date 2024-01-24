classdef KymoRodSettings < handle
    % Stores the settings for a "KymoRod" application
    %
    
    %% Properties
    properties
        %% Calibration
        
        % spatial calibration of input images
        pixelSize = 1000 / 253;
        
        % The unit name for spatial calibration. Default value is 'µm'
        pixelSizeUnit = 'µm';
        
        % time interval between two frames. Default value is 10.
        timeInterval = 10;
        % The unit name for time interval. Default value is 'min'
        timeIntervalUnit = 'min';
        
        
        %% Segmentation
        
        % specify the smoothing method applied on gray-scale image before
        % segmentation. Should be one of 'none', 'boxFilter', 'gaussian'
        imageSmoothingMethod = 'boxFilter';
        
        % the radius of the smoothing filter applied on gray scale image
        % before segmentation
        imageSmoothingRadius = 2;

        % in case of color images, specify the channel used for segmentation
        imageSegmentationChannel = 'red';
        
        % the stategy for setting up the threshold method on each image
        % Can be one of {'auto'}, 'manual'.
        thresholdStrategy = 'auto';
        
        % the method for computing threshold on each image
        % Can be one of {'maxEntropy'}, 'Otsu'.
        thresholdMethod = 'maxEntropy';
        

        %% Contour and skeleton
        
        % length of window for smoothing coutours. Default value is 20.
        contourSmoothingSize = 20;
        
        % location of the first point of the skeleton.
        % Can be one of 'bottom' (default), 'top', 'left', 'right'.
        firstPointLocation = 'bottom';
        

        %% Curvature and angle
        
        % smoothing window size for computation of curvature.  
        % Default value is 10.
        curvatureSmoothingSize = 10;
        
        % the number of points used to discretize signal on each skeleton.
        % Default value is 500.
        finalResultLength = 500;


        %% Displacement
        
        % in case of color images, specify the channel used for computing
        % displacement
        displacementChannel = 'red';
        
        % length of displacement (in pixels). Default value is 2.
        displacementStep = 2;
        
        % size of first correlation window (in pixels). Default value is 5.
        windowSize1 = 5;
        
        
        %% Displacement Smoothing and Elongation
        % displacement curves are smoothed using bilateral filtering
        
        % smooth displacement curve giving more weight to spatially closer values. 
        % Default value is 0.1.
        displacementSpatialSmoothing = .1;
        
        % smooth displacement curve giving more weight to similar values
        % Default value is 1e-2.
        displacementValueSmoothing = 1e-2;
        
        % discretisation step of the filtered displacement curve
        % Default value is 5e-3.
        displacementResamplingDistance = 5e-3;
        
        % size of second correlation window (in pixels). Not used anymore?
        windowSize2 = 20;
        

        %% Intensity kymographs
        
        intensityImagesChannel = 'red';
        
    end
    
    %% Constructor
    methods
        function this = KymoRodSettings(varargin)
            % Create a new data structure for storing application data
            
            if ~isempty(varargin)
                var1 = varargin{1};
                if isa(var1, 'KymoRodSettings')
                    % copy each field of the data structure
                    names = properties(var1);
                    for i = 1:length(names)
                        this.(names{i}) = var1.(names{i});
                    end
                else
                    error(['Unable to create KymoRodSettings from object of class ' class(var1)]);
                end
            end
        end
        
    end % end of constructor methods
    
    
    %% input / output methods
    methods
        function write(this, fileName)
            % Save the different options used to compute kymographs
            %
            % usage:
            %   write(SETTINGS, FILENAME)
            
            % open in text mode, erasing content if it exists
            f = fopen(fileName, 'w+t');
            if f == -1
                errordlg(['Could not open file for writing: ' fileName]);
                return;
            end
 
            % write header
            fprintf(f, '# KymoRod Settings\n');
            fprintf(f, '# %s\n', char(datetime("now")));
            fprintf(f, '\n');
            
            % write current settings
            writeSettings(this, f);
            
            % close the file
            fclose(f);
        end
        
        function writeSettings(this, f)
            % write current settings into an opened file 
             
            % spatial calibration of input images
            fprintf(f, 'pixelSize = %g\n', this.pixelSize);
            fprintf(f, 'pixelSizeUnit = %s\n', this.pixelSizeUnit);
            fprintf(f, '\n');
            
            % time interval between two frames
            fprintf(f, 'timeInterval = %g\n', this.timeInterval);
            fprintf(f, 'timeIntervalUnit = %s\n', this.timeIntervalUnit);
            fprintf(f, '\n');

            % smoothing of images before threshold
            fprintf(f, 'imageSmoothingMethod = %s\n', this.imageSmoothingMethod);
            fprintf(f, 'imageSmoothingRadius = %d\n', this.imageSmoothingRadius);

            % the method used for computing thresholds
            fprintf(f, 'imageSegmentationChannel = %s\n', this.imageSegmentationChannel);
            fprintf(f, 'thresholdStrategy = %s\n', this.thresholdStrategy);
            fprintf(f, 'thresholdMethod = %s\n', this.thresholdMethod);
            
            % length of window for smoothing coutours
            fprintf(f, 'contourSmoothingSize = %d\n', this.contourSmoothingSize);
            fprintf(f, '\n');
            
            % information for computation of skeletons
            fprintf(f, 'firstPointLocation = %s\n', this.firstPointLocation);
            fprintf(f, '\n');
           
            % smoothing window size for computation of curvature
            fprintf(f, 'curvatureSmoothingSize = %d\n', this.curvatureSmoothingSize);
            fprintf(f, 'finalResultLength = %d\n', this.finalResultLength);
            fprintf(f, '\n');
            
            % info for computation of displacement
            fprintf(f, 'displacementChannel = %s\n', this.displacementChannel);
            fprintf(f, 'displacementStep = %d\n', this.displacementStep);
            fprintf(f, 'windowSize1 = %d\n', this.windowSize1);

            % info for filtering displacement curves
            fprintf(f, 'displacementSpatialSmoothing = %f\n', this.displacementSpatialSmoothing);
            fprintf(f, 'displacementValueSmoothing = %f\n', this.displacementValueSmoothing);
            fprintf(f, 'displacementResamplingDistance = %f\n', this.displacementResamplingDistance);
            fprintf(f, 'windowSize2 = %d\n', this.windowSize2);
            fprintf(f, '\n');
            
            % info for computing intensity kymograph
            fprintf(f, 'intensityImagesChannel = %s\n', this.intensityImagesChannel);
            
        end
        
    end % end of I/O non static methods
    
    % Static methods 
    methods (Static)
        function settings = fromPrefs(prefs)
            % Create new settings from user preferences.

            % create new empty class
            settings = KymoRodSettings(prefs.settings);
        end

        function settings = read(fileName)
            % Initialize a new instance of "KymoRodSettings" from saved file
            %
            % usage:
            % SETTINGS = KymoRodSettings.read(FILENAME);
            
            % create new empty class
            settings = KymoRodSettings();
            
            % open in text reading mode
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
                    case lower('pixelSize')
                        settings.pixelSize = str2double(value);
                    case lower('pixelSizeUnit')
                        settings.pixelSizeUnit = value;
                        
                    case lower('timeInterval')
                        settings.timeInterval = str2double(value);
                    case lower('timeIntervalUnit')
                        settings.timeIntervalUnit = value;
            
                    case lower('imageSmoothingMethod')
                        settings.imageSmoothingMethod = value;
                    case lower('imageSmoothingRadius')
                        settings.imageSmoothingRadius = str2double(value);

                    case lower('imageSegmentationChannel')
                        settings.imageSegmentationChannel = value;
                    case lower('thresholdStrategy')
                        settings.thresholdStrategy = value;
                    case lower('thresholdMethod')
                        settings.thresholdMethod = value;

                    case lower('contourSmoothingSize')
                        settings.contourSmoothingSize = str2double(value);
                        
                    case lower('firstPointLocation')
                        settings.firstPointLocation = value;
        
                    case lower('curvatureSmoothingSize')
                        settings.curvatureSmoothingSize = str2double(value);
                        
                    case lower('finalResultLength')
                        settings.finalResultLength = str2double(value);
                    
                    case lower('displacementChannel')
                        settings.displacementChannel = value;
                    case lower('displacementStep')
                        settings.displacementStep = str2double(value);
                    case lower('windowSize1')
                        settings.windowSize1 = str2double(value);
                        
                    case lower('displacementSpatialSmoothing')
                        settings.displacementSpatialSmoothing = str2double(value);
                    case lower('displacementValueSmoothing')
                        settings.displacementValueSmoothing = str2double(value);
                    case lower('displacementResamplingDistance')
                        settings.displacementResamplingDistance = str2double(value);
                    case lower('windowSize2')
                        settings.windowSize2 = str2double(value);
                        
                    case lower('intensityImagesChannel')
                        settings.intensityImagesChannel = value;
                        
                    % do not process parameters previously stored in
                    % .settings files.
                    case lower({...
                            'inputImagesDir', ...
                            'inputImagesFilePattern', ...
                            'inputImagesLazyLoading', ...
                            'firstIndex', ...
                            'lastIndex', ...
                            'indexStep', ...
                            'thresholdValues', ...
                            'currentStep', ...
                            'currentFrameIndex', ...
                            })
                        
                    otherwise
                        warning(['Unrecognized parameter: ' key]);
                end
            end
            
            % close file
            fclose(f);
        end
        
        function res = fromStruct(data)
            % Initialize a new instance of "KymoRodSettings" from a struct
            
            % initialize new instance
            res = KymoRodSettings();
            
            fields = fieldnames(data);
            for i = 1:length(fields)
                name = fields{i};
                value = data.(name);
                
                % check that the field exists
                if ~isfield(data, name)
                    warning(['Try to initialize an unknown field: ' name]);
                    continue;
                end
                
                % simply copy the value of the field
                res.(name) = value;
            end
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
