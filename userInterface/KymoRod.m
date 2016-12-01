classdef KymoRod < handle
% Class for storing data of the "KymoRod" application
%
% This class contains a reference to the current settings, the currently
% loaded data, and most of the data processing methods. 
%
% KR = KymoRod()
% Creates a new KymoRod data structure with default settings
%
% KR = KymoRod(SETTINGS)
% Creates a new KymoRod data structure with pre-determined settings
%
    
    %% Static Properties
    properties (Constant)
        % identifier of application version, for display in About dialog
        % and for file releases
        appliVersion = VersionNumber(0, 11, 0, 'SNAPSHOT');

        % identifier of class version, used for saving and loading files
        serialVersion = VersionNumber(0, 11, 0);
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
        
        % list of images to process.
        % If lazy loading option is set to true, this array is not used.
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
        
        % the curvilinear abscissa after alignment procedure
        alignedAbscissaList;
        
        % the angle with the vertical of each point of each skeleton, in a
        % cell array
        verticalAngleList;
        
        % the curvature of each point of each skeleton, in a cell array
        curvatureList;
        
        % the displacement of a point to the next similar point
        displacementList;
        
        % the displacement after smoothing and resampling
        smoothedDisplacementList;
        
        % elongation, computed by derivation of smoothed displacement
        elongationList;
        
        
        % reconstructed image of skeleton radius in absissa and time
        radiusImage;
        
        % reconstructed image of angle with vertical in absissa and time
        verticalAngleImage;
        
        % reconstructed image of curvature in absissa and time
        curvatureImage;
        
        % final result: elongation as a function of position and time
        elongationImage;
        
        
        % the type of kymograph used for display
        % should be one of 'radius' (default), 'verticalAngle',
        % 'curvature', 'elongation'.
        kymographDisplayType = 'radius';
        
        % the relative abscissa of the graphical cursor, between 0 and 1.
        % Default value is .5, corresponding to the middle of the skeleton.
        cursorRelativeAbscissa = 0;
    end
    
    
    %% Constructor
    methods
        function this = KymoRod(varargin)
            % Create a new data structure for storing application data
            %
            % KR = KymoRod()
            % Creates a new KymoRod data structure with default settings
            %
            % KR = KymoRod(SETTINGS)
            % Creates a new KymoRod data structure with pre-determinated
            % settings
            
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
            versionString = char(KymoRod.appliVersion);
            this.logger.info('KymoRod', ...
                ['Create new KymoRod instance, V-' versionString]);
            
            % initialize settings of the new appli
            if ~isempty(varargin) && isa(varargin{1}, 'KymoRodSettings')
                this.settings = varargin{1};
            else
                this.settings = KymoRodSettings;
            end
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
            % Return the image corresponding to the given frame
            if this.inputImagesLazyLoading
                filePath = fullfile(this.inputImagesDir, this.imageNameList{index});
                image = imread(filePath);
            else
                image = this.imageList{index};
            end
        end
        
        function image = getSegmentableImage(this, index)
            % Return the image that can be used for computing segmentation
            % (without smoothing)
            image = getImage(this, index);
            if ndims(image) > 2 %#ok<ISMAT>
                switch lower(this.settings.imageSegmentationChannel)
                    case 'red',     image = image(:,:,1);
                    case 'green',   image = image(:,:,2);
                    case 'blue',    image = image(:,:,3);
                end
            end
        end
        
        function loadImageData(this)
            % Read image data
            % Load images, or simply read file names depending on the value
            % of the "inputImagesLazyLoading" property
            
            if this.inputImagesLazyLoading
                computeImageNames(this);
            else
                readAllImages(this);
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
            
            imageNames = cell(nFrames, 1);
            disp('Read all image names');
            
            % allocate memory for local variables
            parfor_progress(nFrames);
            parfor i = 1:nFrames
                fileName = fileList(i).name;
                imageNames{i} = fileName;
                parfor_progress;
            end
            parfor_progress(0);
            
            this.imageNameList = imageNames;

        end
        
        function nFiles = getFileNumber(this)
            % compute the number of files matching input dir and name pattern

            % read all files in specified directory
            inputDir = this.inputImagesDir;
            pattern  = this.inputImagesFilePattern;
            fileList = dir(fullfile(inputDir, pattern));
            
            % ensure no directory is load
            fileList = fileList(~[fileList.isdir]);
            nFiles = length(fileList);
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
            images = cell(nImages, 1);
            imageNames = cell(nImages, 1);

            % keep variables outside parfor loop to ensure avoiding overhead
            inputDir = this.inputImagesDir;
            channelName = lower(this.settings.imageSegmentationChannel);

            disp('Read all images');
            
            % read each image
            parfor_progress(nImages);
            parfor i = 1:nImages
                fileName = fileList(i).name;
                imageNames{i} = fileName;
                img = imread(fullfile(inputDir, fileName));
                
                % in case of color image, select which channel should be kept
                if ndims(img) > 2 %#ok<ISMAT>
                    switch channelName
                        case 'red',     img = img(:,:,1); 
                        case 'green',   img = img(:,:,2); 
                        case 'blue',    img = img(:,:,3); 
                        case 'intensity', img = rgb2gray(img);
                        otherwise
                            error(['could not recognise channel name: ' channelName]);
                    end
                end
                images{i} = img;
                
                parfor_progress;
            end
            parfor_progress(0);
            
            % keep loaded data in app
            this.imageList = images;
            this.imageNameList = imageNames;
            
            setProcessingStep(this, ProcessingStep.Selection);
        end
    end
    
    
    %% Image segmentation

    methods
        function seg = getSegmentedImage(this, index)
            % Return the specified frame after smoothing and binarization
            
            img = getSmoothedImage(this, index);
            thresh = this.thresholdValues(index);
            seg = img > thresh;
        end

        function imgf = getSmoothedImage(this, index)
            % Get the image after smoothing for use by threshold method.
            
            img = getSegmentableImage(this, index);
            
            switch this.settings.imageSmoothingMethod
                case 'none'
                    % no smoothing -> simply copy image
                    imgf = img;
                    
                case 'boxFilter'
                    % smooth with flat box filter
                    radius = this.settings.imageSmoothingRadius;
                    diam = 2 * radius + 1;
                    imgf = imfilter(img, ones(diam, diam) / diam^2, 'replicate');
                    
                case 'gaussian'
                    % smooth with gaussian filter
                    radius = this.settings.imageSmoothingRadius;
                    diam = 2 * radius + 1;
                    h = fspecial('gaussian', [diam diam], radius);
                    imgf = imfilter(img, h, 'replicate');
                    
                otherwise
                    error(['Can not handle smoothing method: ' ...
                        this.settings.imageSmoothingMethod]);
            end
        end
        
        function setThresholdValues(this, values)
            % manually set up the values for threshold
            %
            % setThresholdValues(KYMO, VALUES)
            %   VALUES should be an array with as many elements as the
            %   number of frames.
            % setThresholdValues(KYMO, VAL)
            %   VAL should be a scalar value.
            
            % check dimension of input array
            if length(values) == 1
                values = repmat(values, 1, frameNumber(this));
            end
            if length(values) ~= frameNumber(this)
                error('The number of values should match number of frames');
            end

            % update local variables
            values = values(:)';
            this.baseThresholdValues = values;
            this.thresholdValues = values;
            
            % update processing step
            setProcessingStep(this, ProcessingStep.Threshold);
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
            
            % Compute the threshold values
            disp('Segmentation');
            hDialog = msgbox(...
                {'Computing image thresholds,', 'please wait...'}, ...
                'Segmentation');
            
            % temporay array for storing result
            baseValues = zeros(1, nImages);
            
            % compute threshold values
            switch this.settings.thresholdMethod
                case 'maxEntropy'
                    parfor_progress(nImages);
                    parfor i = 1 : nImages
                        img = getSegmentableImage(this, i);
                        baseValues(i) = maxEntropyThreshold(img);
                        parfor_progress;
                    end
                    parfor_progress(0);
                    
                case 'Otsu'
                    parfor_progress(nImages);
                    parfor i = 1 : nImages
                        img = getSegmentableImage(this, i);
                        baseValues(i) = round(graythresh(img) * 255);
                        parfor_progress;
                    end
                    parfor_progress(0);
                    
                otherwise
                    error(['Could not recognize threshold method: ' ...
                        this.settings.thresholdMethod]);
            end
            
            this.baseThresholdValues = baseValues;
            
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
            contours = cell(nFrames, 1);
            this.contourList = cell(nFrames, 1);

            % iterate over images
            parfor_progress(nFrames);
            parfor i = 1:nFrames
                % add black border around each image, to ensure continuous contours
                img = getSegmentableImage(this, i);
                img = imAddBlackBorder(img);
                threshold = this.thresholdValues(i);
                contours{i} = segmentContour(img, threshold);
                
                parfor_progress;
            end
            parfor_progress(0);
            
            this.contourList = contours;

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
            skelList    = cell(nFrames, 1);
            radList     = cell(nFrames, 1);
            contListMm  = cell(nFrames, 1);
            skelListMm  = cell(nFrames, 1);
            originList  = cell(nFrames, 1);
            
            disp('Skeletonization');
            hDialog = msgbox(...
                {'Computing skeletons from contours,', 'please wait...'}, ...
                'Skeletonization');
            
            t0 = tic;
            parfor_progress(nFrames);
            parfor i = 1:nFrames
                % extract current contour
                contour = getContour(this, i);
                if smooth ~= 0
                    contour = smoothContour(contour, smooth);
                end
                
                % scale contour in user unit (and convert from microns to millimeters)
                contour = contour * this.settings.pixelSize / 1000;
                
                % apply filtering depending on contour type
                contour2 = filterContour(contour, 200, organShape);
                
                % extract skeleton of current contour
                [skel, rad] = contourSkeleton(contour2, originDirection);
                
                % keep skeleton in pixel units
                skelPx = skel * 1000 / this.settings.pixelSize;
                skelList{i} = skelPx;
                radList{i} = rad;
                
                % coordinates of first point of skeleton
                origin = skel(1,:);
                originList{i} = origin;
                
                % align contour at bottom left and reverse y-axis (user coordinates)
                contour2 = [contour(:,1) - origin(1), -(contour(:,2) - origin(2))];
                contListMm{i} = contour2;
                
                % align skeleton at bottom left, and reverse y axis
                skel2 = [skel(:,1) - origin(1), -(skel(:,2) - origin(2))];
                skelListMm{i} = skel2;
                
                parfor_progress;
            end
            parfor_progress(0);
            
            % copy temporary arrays to KymoRod instance
            this.skeletonList       = skelList;
            this.radiusList         = radList;
            this.scaledContourList  = contListMm;
            this.scaledSkeletonList = skelListMm;
            this.originPosition     = originList;
            
            t1 = toc(t0);
            disp(sprintf('elapsed time: %6.2f mn', t1 / 60)); %#ok<DSPS>
            
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
            displList = cell(nFrames-step, 1);
            
            parfor_progress(nFrames - step);
            parfor i = 1:nFrames - step
                % index of next skeleton
                i2 = i + step;

                % compute displacement between current couple of frames
                displ = computeFrameDisplacement(this, i, i2);
                displList{i} = displ;
                parfor_progress;
                
            end
            parfor_progress(0);
            
            this.displacementList = displList;
        end
        
        function displ = computeFrameDisplacement(this, i, i2)
            % Computes displacement between frames i and i2, and update
            % corresponding displacment.
            %
            % Usage:
            % DISPL = computeFrameDisplacement(KYMO, IND1, IND2);
            %
            % Assumes the class field 'displacementList' is already
            % initialized to the required size.
       
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
            if length(SK1) <= 2*80 || length(SK2) <= 2*80
                % case of too small skeletons
                msg = sprintf('Skeletons %d or %d has not enough vertices', i, i2);
                this.logger.warn('KymoRod.computeFrameDisplacement', msg);
                warning(msg); %#ok<SPWRN>
                displ = [1 0; 1 1];
                return;
            end
            
            displ = computeDisplacement(SK1, SK2, S1, S2, img1, img2, ws, L);
            
            % check result is large enough
            if size(displ, 1) == 1
                msg = sprintf('Displacement from frame %d to frame %d resulted in small array', i, i2);
                this.logger.warn('KymoRod.computeFrameDisplacement', msg);
                warning(msg); %#ok<SPWRN>
                displ = [1 0;1 1];
                return;
            end
        end
        
        function computeElongations(this)
            % Compute elongation curves for all skeleton curves
            %
            %   computeElongations(KYMO)
            %

            % Elongation
            disp('Elongation');
            this.logger.info('KymoRod.computeElongations', ...
                'Compute elongations');

            % initialize results
            n = length(this.displacementList);
            E2 = cell(n, 1);
            Elg = cell(n, 1);

            % iterate over displacement curves
            parfor_progress(n);
            parfor i = 1:n
                [Elg{i}, E2{i}] = computeFrameElongation(this, i);
                parfor_progress;
            end
            parfor_progress(0);

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
        
        function [Elg, E2] = computeFrameElongation(this, index)
            % Compute elongation curve for a specific frame
            % 
            % [ELG, E2] = computeFrameElongation(KYMO, INDEX)
            %   ELG: array of elongation
            %   E2:  smoothed displacement for the frame
            
            % get current array of displacement
            E2 = getFilteredDisplacement(this, index);
            
            % check validity of size
            if length(E2) <= 20
                E2 = [0 0;1 0];
                Elg = [0 0;1 0];
                return;
            end
            
            % get some settings
            t0      = this.settings.timeInterval;
            step    = this.settings.displacementStep;
            ws2     = this.settings.windowSize2;

            % Compute elongation by spatial derivation of the displacement
            Elg = computeElongation(E2, t0, step, ws2);
        end
        
        function E2 = getFilteredDisplacement(this, index)
            % Smooth the curve and remove errors using kernel smoothers
            %
            % E2 = filterFrameDisplacement(KYMO, INDEX);
            %
            
            % get current array of displacement
            E = this.displacementList{index};
            
            % check validity of size
            if length(E) <= 20
                E2 = [0 0;1 0];
                return;
            end
            
            % call the computational function
            E2 = filterDisplacement(E);
        end
        
        function img = getKymographMatrix(this)
            % Return the array of values representing the current kymograph
            % (defined by this.kymographDisplayType)
            
            switch this.kymographDisplayType
                case 'radius'
                    img = this.radiusImage;
                    
                case 'verticalAngle'
                    img = this.verticalAngleImage;
                    
                case 'curvature'
                    img = this.curvatureImage;
                    
                case 'elongation'
                    img = this.elongationImage;
            end
        end
    end
    
    
    %% Display methods

    methods
        function varargout = showCurrentKymograph(this)
            % Display the current kymograph on a new figure
            
            % get floating-point image corresponding to kymograph
            img = getKymographMatrix(this);

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
            title(this.kymographDisplayType);
            
            if nargout > 0
                varargout = {hImg};
            end
        end
    end
    
    methods
        function varargout = showKymograph(this, type)
            % Display the kymograph result on a new figure
            % 
            % deprecated: use showCurrentKymograph instead
            
            warning('KymoRod:showKymoGraph', ...
                'KymoRod.showKymoGraph() is deprecated, use showCurrentKymograph instead');
            
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
            fprintf(f, '# KymoRod version: %s (%s)\n', ...
                char(this.appliVersion), fileInfo.date);
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
            fprintf(f, 'cursorRelativeAbscissa = %8.6f\n', this.cursorRelativeAbscissa);
            fprintf(f, '\n');
            
            % close the file
            fclose(f);
        end
        
         function save(this, fileName)
             % save instance fields in a .mat file, converting to struct
             %
             % Example:
             %    save(app, 'savedKymo.mat');
             %    app2 = load('savedKymo.mat');
             
             % convert to a structure to save fields
             warning('off', 'MATLAB:structOnObject');
             appStruct = struct(this); 
             
             % also convert fields that are classes to structs or char
             appStruct.settings = struct(this.settings);
             appStruct.processingStep = char(this.processingStep);
             appStruct.appliVersion = char(this.appliVersion);
             appStruct.serialVersion = char(this.serialVersion);
             
             % clear some unnecessary data
             appStruct.logger = [];
             
             % save as a struct
             save(fileName, '-struct', 'appStruct');
         end
    end % I/O Methods
    
    
    %% Static methods
    methods (Static)
        function app = read(fileName)
            % Initialize a new instance of "KymoRod" from saved text file
            %
            % See also
            %    load, write
            
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
            % Initialize a new KymoRod instance from a saved binary file
            %
            % Example
            %    save(app, 'savedKymo.mat');
            %    app2 = load('savedKymo.mat');
            %
            % See also
            %   read, save
            
            % load fields from within the mat file
            data = load(fileName);
            
            if ~isfield(data, 'serialVersion')
                error('Require a KymoRod binary file from at least version 0.8');
            end
            
            % special case of 0.8 version
            if isnumeric(data.serialVersion)
                data.serialVersion = '0.8.0';
            end
            
            % parse version number from version string
            version = VersionNumber(data.serialVersion);
            if version.major == 0 && version.minor == 11
                app = KymoRod.load_V_0_11(data);
            elseif version.major == 0 && ismember(version.minor, [8 10])
                % just to fix bug introduced in version 0.10.0
                app = KymoRod.load_V_0_8(data);
            else
                error('Could not parse file with serial version %s', ...
                    char(data.serialVersion));
            end
            
            % post-processing
            if ~app.inputImagesLazyLoading && ismepty(app.imagesList)
                readAllImages(app);
            end
            if isempty(app.baseThresholdValues)
                app.baseThresholdValues = app.thresholdValues;
            end
        end
        
        function app = load_V_0_11(data)
            % Initialize a new instance from a structure with 0.8 format
            % (corresponds to KymoRod applications 0.11.x and upward)
            
            % creates a new empty instance
            app = KymoRod();

            fields = fieldnames(data);
            for i = 1:length(fields)
                name = fields{i};
                value = data.(name);
                
                % iterate over specific cases
                if any(strcmpi(name, {'appliVersion', 'serialVersion', 'logger'}))
                    % do not override static fields
                    continue;
                elseif strcmpi(name, 'settings')
                    % Initialize settings
                    KymoRodSettings.fromStruct(data.settings);
                elseif strcmpi(name, 'processingStep')
                    app.processingStep = ProcessingStep.parse(value);
                else
                    % otherwise, use generic processing
                    
                    % check that the field exists 
                    if ~isfield(data, name)
                        warning(['Try to initialize an unknown field: ' name]);
                        continue;
                    end
                    
                    % simply copy the value of the field
                    app.(name) = value;
                end
            end
        end
   
        function app = load_V_0_8(data)
            % Initialize a new instance from a structure with 0.8 format
            % (corresponds to KymoRod applications 0.8.x to 0.10.x)
            
            % creates empty instance
            app = KymoRod();

            % parse settings from structure        
            app.settings = KymoRodSettings.fromStruct(data.settings);
            
            % copy parameters
            app.processingStep          = ProcessingStep.parse(data.processingStep);
            app.currentFrameIndex       = data.currentFrameIndex;
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
    
end % end class declaration