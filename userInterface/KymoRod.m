classdef KymoRod < handle
    % Class for Application "KymoRod"
    % 
    % This class contains a reference to the current settings, the data
    % currently loaded, and most processing methods.
    
    %% Static Properties
    properties (Constant)
        % identifier of class version, used for saving and loading files
        serialVersion = 0.8;
    end
    
    %% Properties
    properties
        
        % an instance of log4m, for logging.
        logger;
        
        % the set of settings for the different processing steps
        % as an instance of KymoRodSettings.
        settings;
        
        % Step of processing, to know which data are initialized, and which
        % ones need to be computed. Default is "None".
        % See the class ProcessingStep for details.
        processingStep = ProcessingStep.None;
        
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
        inputImagesLazyLoading = true;
        
        % informations to select images from input directory
        firstIndex = 1;
        lastIndex = 1;
        indexStep = 1;
        
        % the list of threshold values used to segment images
        thresholdValues = [];
        
        % the list of threshold values computed automatically, without
        % manual correction
        baseThresholdValues = [];
        
        % list of contours, one polygon by cell, in pixel unit (old 'CTVerif')
        contourList = {};
        
        % list of contours after rescaling, and translation wrt skeleton
        % origin (old CT).
        scaledContourList = {};
        
        % list of skeletons, one curve by cell, in pixel unit (old SKVerif)
        skeletonList = {};
        
        % list of skeletons after rescaling, and translation wrt first
        % point of skeleton (old 'SK').
        scaledSkeletonList = {};
        
        % list of radius values (old 'rad')
        radiusList = {};
        
        % coordinates of the first point of the skeleton for each image
        originPosition = {};
        
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
        
        
        % reconstructed image of skeleton radius in absissa and time
        radiusImage;
        
        % reconstructed image of angle with vertical in absissa and time
        verticalAngleImage;
        
        % reconstructed image of curvature in absissa and time
        curvatureImage;
        
        % final result: elongation as a function of position and time
        elongationImage;
    end
    
    
    %% Constructor
    methods
        function this = KymoRod(varargin)
            % Create a new data structure for storing application data
            
            % creates '.kymorod' directory if it does not exist
            logdir = fullfile(getuserdir, '.kymorod');
            if ~exist(logdir, 'dir')
                mkdir(logdir);
            end
            
            % create logger to user log file
            logFile = fullfile(getuserdir, '.kymorod', 'kymorod.log');
            this.logger = log4m.getLogger(logFile);
            
            % setup log levels
            setLogLevel(this.logger, log4m.DEBUG);
            setCommandWindowLevel(this.logger, log4m.WARN);
            
            % log the object instanciation
            versionString = num2str(KymoRod.serialVersion);
            this.logger.info('KymoRod', ...
                ['Create new KymoRod instance, V-' versionString]);
            
            % initialize new default settings
            this.settings = KymoRodSettings;
            
        end
    end
    
    
    %% Processing step management
    methods
        function step = getProcessingStep(this)
            step = this.processingStep;
        end
        
        function setProcessingStep(this, newStep)
            % changes the current processing step, and clear outdated variables
            
            % to comply with previous version
            if ischar(newStep)
                warning('Specifying processing step as a string is obsolete');
                
                switch lower(newStep)
                    case 'none',        newStep = ProcessingStep.None;
                    case 'selection',   newStep = ProcessingStep.Selection;
                    case 'threshold',   newStep = ProcessingStep.Threshold;
                    case 'contour',     newStep = ProcessingStep.Contour;
                    case 'skeleton',    newStep = ProcessingStep.Skeleton;
                    case 'elongation',  newStep = ProcessingStep.Elongation;
                    case 'kymograph',   newStep = ProcessingStep.Kymograph;
                    otherwise
                        error(['Unrecognised processing step: ' newStep]);
                end
                
            end
            
            this.logger.debug('KymoRod.setProcessingStep', ...
                ['Set processing step to ' char(newStep)]);
            

            % update inner data depending on processing step
            switch newStep
                case ProcessingStep.None
                    % clear all data, including input image info
                    clearImageData();
                    
                case ProcessingStep.Selection
                    % select new image batch: clear all computed data
                    clearSegmentationData();
                    
                case ProcessingStep.Threshold
                    clearContourData();
                    
                case ProcessingStep.Contour
                    clearSkeletonData();
                    
                case ProcessingStep.Skeleton
                    % skeletons are updated. Need to recompute displacement
                    % and elongation data
                    clearElongationData();
                    
                case ProcessingStep.Elongation
                    % ??? should add displacement step ?
%                     clearResultImages();
                    
                case ProcessingStep.Kymograph
                    % final processing step: nothing to clear!
                    
                otherwise
                    error(['Unrecognised processing step: ' newStep]);
            end
            
            % update current processing step
            this.processingStep = newStep;
            
            function clearImageData()
                this.imageList = {};
                this.imageNameList = {};
                
                clearSegmentationData();
            end
            
            function clearSegmentationData()
                this.baseThresholdValues = [];
                this.thresholdValues = [];
                
                clearContourData();
            end
            
            function clearContourData()
                this.contourList = {};
                this.scaledContourList = {};
                
                clearSkeletonData();
            end
            
            function clearSkeletonData()
                this.skeletonList = {};
                this.scaledSkeletonList = {};
                this.radiusList = {};
                this.originPosition = {};
                
                clearElongationData();
            end
            
            function clearElongationData()
                this.abscissaList = {};
                this.verticalAngleList = {};
                this.curvatureList = {};
                this.displacementList = {};
                this.smoothedDisplacementList = {};
                this.elongationList = {};
                
                clearResultImages();
            end
            
            function clearResultImages()
                this.curvatureImage = [];
                this.verticalAngleImage = [];
                this.radiusImage = [];
                this.elongationImage = [];
            end
        end
    end
    
    %% Compute everything
    
    methods
        function computeAll(this)
            % Computes everything assuming settings and image info are correct 
            computeImageNames(this);
            computeThresholdValues(this);
            computeContours(this);
            computeSkeletons(this);
            computeCurvaturesAndAbscissa(this);
            computeDisplacements(this);
            computeElongations(this);
        end
    end
    
    
    %% Image selection
    methods
        function n = frameNumber(this)
            % return the total number of images selected for processing
            n = length(this.imageNameList);
        end
        
        function image = getImage(this, index)
            if this.inputImagesLazyLoading
                filePath = fullfile(this.inputImagesDir, this.imageNameList{index});
                image = imread(filePath);
            else
                image = this.imageList{index};
            end
        end
        
        function image = getSegmentableImage(this, index)
            % Return the image that can be used for computing segmentation
            image = getImage(this, index);
            if ndims(image) > 2 %#ok<ISMAT>
                switch lower(this.settings.imageSegmentationChannel)
                    case 'red',     image = image(:,:,1);
                    case 'green',   image = image(:,:,2);
                    case 'blue',    image = image(:,:,3);
                end
            end
        end
        
        function computeImageNames(this)
            % update list of image names from input directory and indices

            % read all files in specified directory
            inputDir = this.inputImagesDir;
            pattern  = this.inputImagesFilePattern;
            fileList = dir(fullfile(inputDir, pattern));
            
            % ensure no directory is load
            fileList = fileList(~[fileList.isdir]);
            
            % select images corresponding to indices selection
            fileIndices = this.firstIndex:this.indexStep:this.lastIndex;
            fileList = fileList(fileIndices);
            nFrames = length(fileList);
            
            % allocate memory for local variables
            this.imageNameList = cell(nFrames, 1);
            for i = 1:nFrames
                fileName = fileList(i).name;
                this.imageNameList{i} = fileName;
            end
        end
        
        function readAllImages(this)
            % load all images based on settings
            % refresh imageList and imageNameList
            
            % read all files in specified directory
            fileList = dir(fullfile(this.inputImagesDir, this.inputImagesFilePattern));
            
            % ensure no directory is load
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
                
                % in case of color image, select which channel should be kept
                if ndims(img) > 2 %#ok<ISMAT>
                    switch lower(app.settings.imageSegmentationChannel)
                        case 'red',     img = img(:,:,1); 
                        case 'green',   img = img(:,:,2); 
                        case 'blue',    img = img(:,:,3); 
                        case 'intensity', img = rgb2gray(img);
                        otherwise
                            error(['could not recognise channel name: ' channelName]);
                    end
                end
                this.imageList{i} = img;
            end
        end
    end
    
    
    %% Image segmentation

    methods
        function seg = getSegmentedImage(this, index)
            img = getSegmentableImage(this, index);
            thresh = this.thresholdValues(index);
            seg = img > thresh;
        end
        
        function computeThresholdValues(this)
            % compute threshold values for all images
            
            this.logger.info('KymoRod.computeThresholdValues', ...
                'Compute Image Thresholds');
            
            if this.processingStep == ProcessingStep.None
                error('need to have images selected');
            end
            
            nImages = frameNumber(this);
            this.baseThresholdValues = zeros(nImages, 1);
            
            % Compute the contour
            disp('Segmentation');
            hDialog = msgbox(...
                {'Computing image thresholds,', 'please wait...'}, ...
                'Segmentation');
            
            % compute threshold values
            switch this.settings.thresholdMethod
                case 'maxEntropy'
                    parfor_progress(nImages);
                    for i = 1 : nImages
                        img = getSegmentableImage(this, i);
                        this.baseThresholdValues(i) = maxEntropyThreshold(img);
                        parfor_progress;
                    end
                    parfor_progress(0);
                    
                case 'Otsu'
                    parfor_progress(nImages);
                    for i = 1 : nImages
                        img = getSegmentableImage(this, i);
                        this.baseThresholdValues(i) = ...
                            round(graythresh(img) * 255);
                        parfor_progress;
                    end
                    parfor_progress(0);
                    
                otherwise
                    error(['Could not recognize threshold method: ' ...
                        this.settings.thresholdMethod]);
            end
            
            % reset current threshold to base values
            this.thresholdValues = this.baseThresholdValues;
            
            if ishandle(hDialog)
                close(hDialog);
            end

            setProcessingStep(this, ProcessingStep.Threshold);
        end
    end
    
    %% Contour computation

    methods
        function contour = getContour(this, index)
            if this.processingStep < ProcessingStep.Contour
                error('need to have contours computed');
            end
            contour = this.contourList{index};
        end
        
        function contour = getSmoothedContour(this, index)
            if this.processingStep < ProcessingStep.Contour
                error('need to have contours computed');
            end
            contour = this.contourList{index};
            smooth = this.settings.contourSmoothingSize;
            contour = smoothContour(contour, smooth);
        end
        
        function computeContours(this)
            % compute the contour for each image
            
            this.logger.info('KymoRod.computeContours', ...
                'Compute binary images contours');
            
            if this.processingStep < ProcessingStep.Threshold
                error('need to have threshold computed');
            end
            
            disp('Contour extraction...');
            hDialog = msgbox(...
                {'Performing Contour extraction,', 'please wait...'}, ...
                'Contour Extraction');
            
            nFrames = frameNumber(this);
            
            % allocate memory for contour array
            this.contourList = cell(nFrames, 1);

            % iterate over images
            parfor_progress(nFrames);
            for i = 1:nFrames
                % add black border around each image, to ensure continuous contours
                img = getSegmentableImage(this, i);
                img = imAddBlackBorder(img);
                threshold = this.thresholdValues(i);
                this.contourList{i} = segmentContour(img, threshold);
                
                parfor_progress;
            end
            
            parfor_progress(0);
            if ishandle(hDialog)
                close(hDialog);
            end

            setProcessingStep(this, ProcessingStep.Contour);
        end
    end
   
    
    %% Skeletons computation

    methods
        function skel = getSkeleton(this, index)
            if this.processingStep < ProcessingStep.Skeleton
                error('need to have skeletons computed');
            end
            skel = this.skeletonList{index};
        end
        
        function computeSkeletons(this)
            % compute all skeletons from smoothed contours
            
            this.logger.info('KymoRod.computeSkeletons', ...
                'Compute skeletons from contours');

            if this.processingStep < ProcessingStep.Contour
                error('need to have contours computed');
            end
            
            % number of images
            nFrames = frameNumber(this);
            
            smooth = this.settings.contourSmoothingSize;
            
            organShape = 'boucle';
            originDirection = this.settings.firstPointLocation;
            
            % allocate memory for results
            this.skeletonList = cell(nFrames, 1);
            this.radiusList = cell(nFrames, 1);
            this.scaledContourList = cell(nFrames, 1);
            this.scaledSkeletonList = cell(nFrames, 1);
            this.originPosition = cell(nFrames, 1);
            
            disp('Skeletonization');
            hDialog = msgbox(...
                {'Computing skeletons from contours,', 'please wait...'}, ...
                'Skeletonization');
            
            parfor_progress(nFrames);
            for i = 1:nFrames
                % extract current contour
                contour = getContour(this, i);
                if smooth ~= 0
                    contour = smoothContour(contour, smooth);
                end
                
                % scale contour in user unit
                contour = contour * this.settings.pixelSize / 1000;
                
                % apply filtering depending on contour type
                contour2 = filterContour(contour, 200, organShape);
                
                % extract skeleton of current contour
                [skel, rad] = contourSkeleton(contour2, originDirection);
                
                % keep skeleton in pixel units
                skelPx = skel * 1000 / this.settings.pixelSize;
                this.skeletonList{i} = skelPx;
                this.radiusList{i} = rad;
                
                % coordinates of first point of skeleton
                origin = skel(1,:);
                this.originPosition{i} = origin;
                
                % align contour at bottom left and reverse y-axis (user coordinates)
                contour2 = [contour(:,1) - origin(1), -(contour(:,2) - origin(2))];
                this.scaledContourList{i} = contour2;

                % align skeleton at bottom left, and reverse y axis
                skel2 = [skel(:,1) - origin(1), -(skel(:,2) - origin(2))];
                this.scaledSkeletonList{i} = skel2;
                
                parfor_progress;
            end
            
            parfor_progress(0);
            if ishandle(hDialog)
                close(hDialog);
            end
    
            setProcessingStep(this, ProcessingStep.Skeleton);
        end
    end
    
    
    %% Displacement and Elongation computation
    
    methods
        function img = getImageForDisplacement(this, index)
            % returns the image for computing displacement.
            % In case of color image, returns the green channel by default.
            img = getImage(this, index);
            if ndims(img) > 2 %#ok<ISMAT>
                img = img(:,:,2);
            end
        end
        
        function computeCurvaturesDisplacementAndElongation(this)

            if this.processingStep < ProcessingStep.Skeleton
                error('need to have skeletons computed');
            end
            
            % Curvature and normalisation of abscissa
            computeCurvaturesAndAbscissa(this);
            
            % Displacement (may require some time...)
            computeDisplacements(this);
            
            % Elongation
            computeElongations(this);
        end
        
        function computeCurvaturesAndAbscissa(this)
            % compute curvilinear abscissa, angle and curvature of all skeletons
            
            disp('Compute angles and curvature');
            this.logger.info('KymoRod.computeCurvaturesAndAbscissa', ...
                'Compute curvatures, angles, and curvilinear abscissa');

            % Compute smoothed curvature curves
            smooth  = this.settings.curvatureSmoothingSize;
            [S, A, C] = computeCurvatureAll(this.scaledSkeletonList, smooth);
            
            % Alignment of all the results
            disp('Alignment of curves');
            Sa = alignAbscissa(S, this.radiusList);
            
            % store within class
            this.abscissaList        = Sa;
            this.verticalAngleList   = A;
            this.curvatureList       = C;
            
            computeCurvaturesAndAbscissaImages(this);
        end
        
        function computeCurvaturesAndAbscissaImages(this)
            nx  = this.settings.finalResultLength;
            Sa  = this.abscissaList;
            
            this.curvatureImage     = reconstruct_Elg2(nx, this.curvatureList, Sa);
            this.verticalAngleImage = reconstruct_Elg2(nx, this.verticalAngleList, Sa);
            this.radiusImage        = reconstruct_Elg2(nx, this.radiusList, Sa);
        end
        
        function computeDisplacements(this)
            % Compute displacements between all couples of frames

            disp('Displacement');
            this.logger.info('KymoRod.computeDisplacements', ...
                'Compute displacements');
            
            % settings
            ws = this.settings.windowSize1;
            L = 4 * ws * this.settings.pixelSize / 1000;
            this.logger.debug('KymoRod.computeDisplacements', ...
                sprintf('Value of L=%f', L));
            
            nFrames = frameNumber(this);
            step    = this.settings.displacementStep;
            
            % allocate memory for result
            this.displacementList = cell(nFrames-step, 1);

            parfor_progress(nFrames);
            parfor i = 1:nFrames - step
                % index of next skeleton
                i2 = i + step;

                % compute displacement between current couple of frames
                computeFrameDisplacement(this, i, i2);
                parfor_progress;
                
            end
            parfor_progress(0);
        end
        
        function computeFrameDisplacement(this, i, i2)
            % Computes displacement between frames i and i2, and update
            % corresponding displacment.
            %
            % assumes the class field 'displacementList' is already
            % initialized to the required size.

            assert(i <= length(this.displacementList), ...
                'Class field ''displacementList'' is not correctly initialized');
            
            % local data
            SK1 = this.skeletonList{i};
            SK2 = this.skeletonList{i2};
            S1  = this.abscissaList{i};
            S2  = this.abscissaList{i2};
            img1 = getImageForDisplacement(this, i);
            img2 = getImageForDisplacement(this, i2);
            
            % settings
            ws = this.settings.windowSize1;
            L = 4 * ws * this.settings.pixelSize / 1000;
                
            % check if the two skeletons are large enough
            if length(SK1) > 2*80 && length(SK2) > 2*80
%                 E = computeDisplacementPx(SK1, SK2, S1, S2, img1, img2, ws);
                E = computeDisplacement(SK1, SK2, S1, S2, img1, img2, ws, L);
                
                % check result is large enough
                if size(E, 1) == 1
                    this.logger.warn('KymoRod.computeFrameDisplacement', ...
                        sprintf('Displacement from frame %d to frame %d resulted in small array', i, i2));
                    E = [1 0;1 1];
                end
            else
                % case of too small skeletons
                this.logger.warn('KymoRod.computeFrameDisplacement', ...
                    sprintf('Skeletons %d or %d has not enough vertices', i, i2));
                E = [1 0; 1 1];
            end
            
            % store result
            this.displacementList{i} = E;
        end
        
        function computeElongations(this)
            % Compute elongation curves for all skeleton curves

            % Elongation
            disp('Elongation');
            this.logger.info('KymoRod.computeElongations', ...
                'Compute elongations');

            E       = this.displacementList;
            ws2     = this.settings.windowSize2;
            step    = this.settings.displacementStep;
            [Elg, E2] = computeElongationAll(E, this.settings.timeInterval, step, ws2);

            % store results
            this.smoothedDisplacementList = E2;
            this.elongationList = Elg;
            
            %  Space-time mapping
            this.logger.info('KymoRod.computeElongations', ...
                'Reconstruct elongation kymograph');
            nx = this.settings.finalResultLength;
            this.elongationImage = reconstruct_Elg2(nx, Elg);

            setProcessingStep(this, ProcessingStep.Elongation);
        end
    end
    
    
    %% Display methods

    methods
        function varargout = showKymograph(this, type)
            % Display the kymograph result on a new figure
            
            if nargin < 2
                type = 'elongation';
            end
            
            switch type
                case 'elongation', img = this.elongationImage;
                case 'radius', img = this.radiusImage;
                case 'curvature', img = this.curvatureImage;
                case 'verticalAngle', img = this.verticalAngleImage;
            end

            % compute display extent for elongation kymograph
            minCaxis = min(img(:));
            maxCaxis = max(img(:));
            
            % compute references for x and y axes
            timeInterval = this.settings.timeInterval;
            xdata = (0:(size(img, 2)-1)) * timeInterval * this.indexStep;
            Sa = this.abscissaList{end};
            ydata = linspace(Sa(1), Sa(end), this.settings.finalResultLength);
            
            % display current kymograph
            hImg = imagesc(xdata, ydata, img);
            
            % setup display
            set(gca, 'YDir', 'normal');
            caxis([minCaxis, maxCaxis]); colorbar;
            colormap jet;
            
            % annotate
            xlabel(sprintf('Time (%s)', this.settings.timeIntervalUnit));
            ylabel(sprintf('Geodesic position (%s)', this.settings.pixelSizeUnit));
            title(type);
            
            if nargout > 0
                varargout = {hImg};
            end
        end
    end
    
    %% Input / output methods
    methods
        function write(this, fileName)
            % Save in a text file the different options used to compute kymographs
            
            this.logger.info('KymoRod.write', ...
                ['Save kymorod object in file: ' fileName]);

            % open in text mode, erasing content if it exists
            f = fopen(fileName, 'w+t');
            if f == -1
                errordlg(['Could not open file for writing: ' fileName]);
                return;
            end
            
            % write header
            fprintf(f, '# KymoRod Analysis Info\n');
            fprintf(f, '# saved: %s\n', datestr(now,0));
            
            % save also modification date of the main class          
            baseDir = fileparts(which('KymoRod'));
            fileInfo = dir(fullfile(baseDir, 'KymoRod.m'));
            fprintf(f, '# KymoRod version: %s\n', fileInfo.date);
            fprintf(f, '\n');
            
            % 
            fprintf(f, '# ----- Image File Infos -----\n\n');

            % informations to retrieve input image
            fprintf(f, 'inputImagesDir = %s\n', this.inputImagesDir);
            fprintf(f, 'inputImagesFilePattern = %s\n', this.inputImagesFilePattern);
            
            % informations to select images from input directory
            fprintf(f, 'firstIndex = %d\n', this.firstIndex);
            fprintf(f, 'lastIndex = %d\n', this.lastIndex);
            fprintf(f, 'indexStep = %d\n', this.indexStep);
            fprintf(f, '\n');
            
            string = KymoRod.booleanToString(this.inputImagesLazyLoading);
            fprintf(f, 'inputImagesLazyLoading = %s\n', string);
            fprintf(f, '\n');
            
            % 
            fprintf(f, '# ----- Generic Settings -----\n\n');

            writeSettings(this.settings, f);
            
            fprintf(f, '# ----- Dataset-specific settings -----\n\n');

            nFrames = frameNumber(this);
            pattern = ['thresholdValues =' repmat(' %d', 1, nFrames) '\n'];
            fprintf(f, pattern, this.thresholdValues);
            fprintf(f, '\n');
            
            fprintf(f, '# ----- Workflow infos -----\n\n');

            % info about current step of the process
            fprintf(f, 'currentStep = %s\n', char(this.processingStep));
            fprintf(f, 'currentFrameIndex = %d\n', this.currentFrameIndex);
            fprintf(f, '\n');
            
            % close the file
            fclose(f);
        end
        
         function save(this, fileName)
             % save instance fields in a .mat file
             
             % convert to a structure to save fields
             warning('off', 'MATLAB:structOnObject');
             appStruct = struct(this); 
             
             % also convert fields that are classes to structs or char
             appStruct.settings = struct(this.settings);
             appStruct.processingStep = char(this.processingStep);
             
             % save as a struct
             save(fileName, '-struct', 'appStruct');
         end
    end % I/O Methods
    
    
    %% Static methods
    methods (Static)
        function app = read(fileName)
            % Initialize a new instance of "KymoRod" from saved text file
            
            % create new empty appdata class
            app = KymoRod();
            
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
                    case lower('inputImagesDir')
                        app.inputImagesDir = value;
                    case lower('inputImagesFilePattern')
                        app.inputImagesFilePattern = value;
                    case lower('imageSegmentationChannel')
                        app.imageSegmentationChannel = value;
                        
                    case lower('inputImagesLazyLoading')
                        app.inputImagesLazyLoading = strcmp(value, 'true');
                        
                    case lower('firstIndex')
                        app.firstIndex = str2double(value);
                    case lower('lastIndex')
                        app.lastIndex = str2double(value);
                    case lower('indexStep')
                        app.indexStep = str2double(value);
                        
                    case lower('pixelSize')
                        app.settings.pixelSize = str2double(value);
                    case lower('pixelSizeUnit')
                        app.settings.pixelSizeUnit = value;
                        
                    case lower('timeInterval')
                        app.settings.timeInterval = str2double(value);
                    case lower('timeIntervalUnit')
                        app.settings.timeIntervalUnit = value;
                        
                    case lower('thresholdMethod')
                        app.settings.thresholdMethod = value;
                    case lower('thresholdValues')
                        tokens = strsplit(value, ' ');
                        app.thresholdValues = str2num(char(tokens')); %#ok<ST2NM>
                        
                    case lower('contourSmoothingSize')
                        app.settings.contourSmoothingSize = str2double(value);
                    case lower('curvatureSmoothingSize')
                        app.settings.curvatureSmoothingSize = str2double(value);
                        
                    case lower('firstPointLocation')
                        app.settings.firstPointLocation = value;
                        
                    case lower('windowSize1')
                        app.settings.windowSize1 = str2double(value);
                    case lower('windowSize2')
                        app.settings.windowSize2 = str2double(value);
                    case lower('displacementStep')
                        app.settings.displacementStep = str2double(value);
                    case lower('finalResultLength')
                        app.settings.finalResultLength = str2double(value);
                        
                    case {lower('processingStep'), lower('currentStep')}
                        app.processingStep = ProcessingStep.parse(value);
                    case lower('currentFrameIndex')
                        app.currentFrameIndex = str2double(value);
                        
                    otherwise
                        warning(['Unrecognized parameter: ' key]);
                end
            end
            
            % close file
            fclose(f);
        end
        
        function app = load(fileName)
           
            % load fields from within the mat file
            data = load(fileName);
            
            if ~isfield(data, 'serialVersion')
                error('Require a KymoRod binary file from at least version 0.8');
            end
            
            switch data.serialVersion
                case 0.8
                    app = KymoRod.load_V08(data);
                otherwise
                    error('Could not parse file with version %f', ...
                         data.serialVersion);
            end
            
            % post-processing
            if ~app.inputImagesLazyLoading && ismepty(app.imagesList)
                readAllImages(app);
            end
            if isempty(app.baseThresholdValues)
                app.baseThresholdValues = app.thresholdValues;
            end
        end
        
        function app = load_V08(data)
            % Initialize a new instance from a structure 
            
            % creates empty instance
            app = KymoRod();

            % parse settings from structure        
            app.settings = KymoRodSettings.fromStruct(data.settings);
            
            % copy parameters
            app.imageList               = data.imageList;
            app.imageNameList           = data.imageNameList;
            app.inputImagesDir          = data.inputImagesDir;
            app.inputImagesFilePattern  = data.inputImagesFilePattern;
            app.inputImagesLazyLoading  = data.inputImagesLazyLoading;
            app.firstIndex              = data.firstIndex;
            app.lastIndex               = data.lastIndex;
            app.indexStep               = data.indexStep;
            app.thresholdValues         = data.thresholdValues;
            app.baseThresholdValues     = data.baseThresholdValues;
            app.contourList             = data.contourList;
            app.scaledContourList       = data.scaledContourList;
            app.skeletonList            = data.skeletonList;
            app.scaledSkeletonList      = data.scaledSkeletonList;
            app.radiusList              = data.radiusList;
            app.originPosition          = data.originPosition;
            app.abscissaList            = data.abscissaList;
            app.verticalAngleList       = data.verticalAngleList;
            app.curvatureList           = data.curvatureList;
            app.displacementList        = data.displacementList;
            app.smoothedDisplacementList= data.smoothedDisplacementList;
            app.elongationList          = data.elongationList;
            app.radiusImage             = data.radiusImage;
            app.verticalAngleImage      = data.verticalAngleImage;
            app.curvatureImage          = data.curvatureImage;
            app.elongationImage         = data.elongationImage;
            app.currentFrameIndex       = data.currentFrameIndex;
            
            app.processingStep          = ProcessingStep.parse(data.processingStep);

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