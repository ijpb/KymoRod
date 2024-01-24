classdef KymoRodData < handle
% Class for storing the data of the "KymoRod" application.
%
% This class contains a reference to the current settings, the currently
% loaded data, and most of the data processing methods. 
%
% KR = KymoRodData()
% Creates a new KymoRod data structure with default settings
%
% KR = KymoRodData(SETTINGS)
% Creates a new KymoRod data structure with pre-determined settings
%

%% Static Properties
properties (Constant)
    % Identifier of the application version.
    % Used for display in About dialog and for file releases.
    %
    % Uses the "VersionNumber" class in the lib package.
    %
    % Examples:
    % appliVersion = VersionNumber(0, 12, 1);   % release
    % appliVersion = VersionNumber(0, 12, 2, 'SNAPSHOT'); % dev version
    appliVersion = VersionNumber(0, 13, 0, 'SNAPSHOT');

    % identifier of class version, used for saving and loading files
    serialVersion = VersionNumber(0, 13, 0);
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

    % informations to retrieve intensity images
    % (for computing the intensity kymograph)
    intensityImagesNameList = {};
    intensityImagesDir = '';
    intensityImagesFilePattern = '*.*';

    % flag indicating whether images are loaded in memory or read from
    % files only when necessary
    inputImagesLazyLoading = true;

    % informations to select images from input directory
    firstIndex = 1;
    lastIndex = 1;
    indexStep = 1;

    % the size of frame images, to prepare possibility of displaying
    % results without reading images
    frameImageSize = [0 0];

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

    % list of radius values, in millimetres
    radiusList = {};

    % coordinates of the first point of the skeleton for each image.
    % (in pixels)
    originPosition = {};

    % the curvilinear abscissa of each skeleton, in a cell array
    abscissaList;

    % (obsolete) the curvilinear abscissa after alignment procedure
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

    % intensity kymograph, computed by evaluating the intensity of
    % another image on the positions of the skeletons
    intensityImage;

    % the type of kymograph used for display
    % should be one of 'radius' (default), 'verticalAngle',
    % 'curvature', 'elongation', 'intensity'
    kymographDisplayType = 'radius';

    % the relative abscissa of the graphical cursor, between 0 and 1.
    % Default value is .5, corresponding to the middle of the skeleton.
    cursorRelativeAbscissa = 0.5;
end


%% Constructor
methods
    function obj = KymoRodData(varargin)
        % Create a new data structure for storing application data.
        %
        % KR = KymoRodData()
        % Creates a new KymoRod data structure with default settings
        %
        % KR = KymoRodData(SETTINGS)
        % Creates a new KymoRod data structure with pre-determinated
        % settings

        % creates '.kymorod' directory if it does not exist
        logdir = fullfile(getuserdir, '.kymorod');
        if ~exist(logdir, 'dir')
            mkdir(logdir);
        end

        % create logger to user log file
        logFile = fullfile(getuserdir, '.kymorod', 'kymorod.log');
        obj.logger = log4m.getLogger(logFile);

        % setup log levels
        setLogLevel(obj.logger, log4m.DEBUG);
        setCommandWindowLevel(obj.logger, log4m.WARN);

        % log the object instanciation
        versionString = char(KymoRodData.appliVersion);
        obj.logger.info('KymoRod', ...
            ['Create new KymoRod instance, V-' versionString]);

        % initialize settings of the new appli
        if ~isempty(varargin) && isa(varargin{1}, 'KymoRodSettings')
            obj.settings = varargin{1};
        else
            obj.settings = KymoRodSettings;
        end
    end
end


%% Processing step management
methods
    function step = getProcessingStep(obj)
        step = obj.processingStep;
    end

    function setProcessingStep(obj, newStep)
        % changes the current processing step and clear outdated variables.

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
                case 'intensity',   newStep = ProcessingStep.Intensity;
                otherwise
                    error(['Unrecognised processing step: ' newStep]);
            end
        end

        obj.logger.debug('KymoRodData.setProcessingStep', ...
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

            case ProcessingStep.Intensity
                % An additional step after elongation histogram

            otherwise
                error(['Unrecognised processing step: ' newStep]);
        end

        % update current processing step
        obj.processingStep = newStep;

        function clearImageData()
            obj.imageList = {};
            obj.imageNameList = {};

            clearSegmentationData();
        end

        function clearSegmentationData()
            obj.baseThresholdValues = [];
            obj.thresholdValues = [];

            clearContourData();
        end

        function clearContourData()
            obj.contourList = {};
            obj.scaledContourList = {};

            clearSkeletonData();
        end

        function clearSkeletonData()
            obj.skeletonList = {};
            obj.scaledSkeletonList = {};
            obj.radiusList = {};
            obj.originPosition = {};

            clearElongationData();
        end

        function clearElongationData()
            obj.abscissaList = {};
            obj.verticalAngleList = {};
            obj.curvatureList = {};
            obj.displacementList = {};
            obj.smoothedDisplacementList = {};
            obj.elongationList = {};

            clearResultImages();
        end

        function clearResultImages()
            obj.curvatureImage = [];
            obj.verticalAngleImage = [];
            obj.radiusImage = [];
            obj.elongationImage = [];
        end
    end
end

%% Compute everything

methods
    function computeAll(obj)
        % Computes everything assuming settings and image info are correct.
        computeImageNames(obj);
        computeThresholdValues(obj);
        computeContours(obj);
        computeSkeletons(obj);
        computeSkeletonAlignedAbscissa(obj);
        computeAnglesAndCurvatures(obj);
        computeDisplacements(obj);
        computeCurvaturesAndAbscissa(obj);
        computeDisplacements(obj);
        computeElongations(obj);
    end
end


%% Image selection
methods
    function n = frameNumber(obj)
        % return the total number of images selected for processing.
        n = length(obj.imageNameList);
    end

    function image = getImage(obj, index)
        % Return the image corresponding to the given frame.
        if obj.inputImagesLazyLoading
            filePath = fullfile(obj.inputImagesDir, obj.imageNameList{index});
            image = imread(filePath);
        else
            image = obj.imageList{index};
        end
    end

    function image = getSegmentableImage(obj, index)
        % Return the image that can be used for computing segmentation.
        % (without smoothing)

        % get the image
        image = getImage(obj, index);

        % extract the channel used for segmentation
        if ndims(image) > 2 %#ok<ISMAT>
            switch lower(obj.settings.imageSegmentationChannel)
                case 'red',     image = image(:,:,1);
                case 'green',   image = image(:,:,2);
                case 'blue',    image = image(:,:,3);
            end
        end

        % eventually converts to uint8
        if isa(image, 'uint16') && ndims(image) == 2 %#ok<ISMAT>
            image = imAdjustDynamic(image, 0.1);
        end
    end

    function loadImageData(obj)
        % Read image data.
        % Load images, or simply read file names depending on the value
        % of the "inputImagesLazyLoading" property

        if obj.inputImagesLazyLoading
            computeImageNames(obj);
        else
            readAllImages(obj);
        end
    end

    function computeImageNames(obj)
        % Update list of image names from input directory and indices.

        % read all files in specified directory
        inputDir = obj.inputImagesDir;
        pattern  = obj.inputImagesFilePattern;
        fileList = dir(fullfile(inputDir, pattern));

        % ensure no directory is load
        fileList = fileList(~[fileList.isdir]);

        % select images corresponding to indices selection
        fileIndices = obj.firstIndex:obj.indexStep:obj.lastIndex;
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

        obj.imageNameList = imageNames;
    end

    function nFiles = getFileNumber(obj)
        % compute the number of files matching input dir and name pattern.

        % read all files in specified directory
        inputDir = obj.inputImagesDir;
        pattern  = obj.inputImagesFilePattern;
        fileList = dir(fullfile(inputDir, pattern));

        % ensure no directory is load
        fileList = fileList(~[fileList.isdir]);
        nFiles = length(fileList);
    end

    function readAllImages(obj)
        % load all images based on settings.
        % refresh imageList and imageNameList

        % read all files in specified directory
        fileList = dir(fullfile(obj.inputImagesDir, obj.inputImagesFilePattern));

        % ensure no directory is load
        fileList = fileList(~[fileList.isdir]);

        % select images corresponding to indices selection
        fileIndices = obj.firstIndex:obj.indexStep:obj.lastIndex;
        fileList = fileList(fileIndices);
        nImages = length(fileList);

        % allocate memory
        images = cell(nImages, 1);
        imageNames = cell(nImages, 1);

        % keep variables outside parfor loop to ensure avoiding overhead
        inputDir = obj.inputImagesDir;
        channelName = lower(obj.settings.imageSegmentationChannel);

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
        obj.imageList = images;
        obj.imageNameList = imageNames;

        setProcessingStep(obj, ProcessingStep.Selection);
    end
end


%% Image segmentation

methods
    function seg = getSegmentedImage(obj, index)
        % Return the specified frame after smoothing and binarization.

        img = getSmoothedImage(obj, index);
        thresh = obj.thresholdValues(index);

        seg = img > thresh;
    end

    function imgf = getSmoothedImage(obj, index)
        % Get the image after smoothing for use by threshold method.

        img = getSegmentableImage(obj, index);

        switch obj.settings.imageSmoothingMethod
            case 'none'
                % no smoothing -> simply copy image
                imgf = img;

            case 'boxFilter'
                % smooth with flat box filter
                radius = obj.settings.imageSmoothingRadius;
                diam = 2 * radius + 1;
                imgf = imfilter(img, ones(diam, diam) / diam^2, 'replicate');

            case 'gaussian'
                % smooth with gaussian filter
                radius = obj.settings.imageSmoothingRadius;
                diam = 2 * radius + 1;
                h = fspecial('gaussian', [diam diam], radius);
                imgf = imfilter(img, h, 'replicate');

            otherwise
                error(['Can not handle smoothing method: ' ...
                    obj.settings.imageSmoothingMethod]);
        end
    end

    function setThresholdValues(obj, values)
        % manually set up the values for threshold.
        %
        % setThresholdValues(KYMO, VALUES)
        %   VALUES should be an array with as many elements as the
        %   number of frames.
        % setThresholdValues(KYMO, VAL)
        %   VAL should be a scalar value.

        % check dimension of input array
        if length(values) == 1
            values = repmat(values, 1, frameNumber(obj));
        end
        if length(values) ~= frameNumber(obj)
            error('The number of values should match number of frames');
        end

        % update local variables
        values = values(:)';
        obj.baseThresholdValues = values;
        obj.thresholdValues = values;

        % update processing step
        setProcessingStep(obj, ProcessingStep.Threshold);
    end

    function computeThresholdValues(obj)
        % compute threshold values for all images.

        obj.logger.info('KymoRodData.computeThresholdValues', ...
            'Compute Image Thresholds');

        if obj.processingStep == ProcessingStep.None
            error('need to have images selected');
        end

        nImages = frameNumber(obj);
        obj.baseThresholdValues = zeros(nImages, 1);

        % Compute the threshold values
        disp('Segmentation');
        hDialog = msgbox(...
            {'Computing image thresholds,', 'please wait...'}, ...
            'Segmentation');

        % temporay array for storing result
        baseValues = zeros(1, nImages);

        % compute threshold values
        switch obj.settings.autoThresholdMethod
            case 'maxEntropy'
                parfor_progress(nImages);
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    baseValues(i) = maxEntropyThreshold(img);
                    parfor_progress;
                end
                parfor_progress(0);

            case 'Otsu'
                parfor_progress(nImages);
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    baseValues(i) = round(graythresh(img) * 255);
                    parfor_progress;
                end
                parfor_progress(0);

            otherwise
                error(['Could not recognize threshold method: ' ...
                    obj.settings.autoThresholdMethod]);
        end

        obj.baseThresholdValues = baseValues;

        % reset current threshold to base values
        obj.thresholdValues = obj.baseThresholdValues;

        if ishandle(hDialog)
            close(hDialog);
        end

        setProcessingStep(obj, ProcessingStep.Threshold);
    end
end


%% Methods for contour computation
methods
    function contour = getContour(obj, index)
        if obj.processingStep < ProcessingStep.Contour
            error('need to have contours computed');
        end
        contour = obj.contourList{index};
    end

    function contour = getSmoothedContour(obj, index)
        if obj.processingStep < ProcessingStep.Contour
            error('need to have contours computed');
        end
        contour = obj.contourList{index};
        smooth = obj.settings.contourSmoothingSize;
        contour = smoothContour(contour, smooth);
    end

    function computeContours(obj)
        % Compute the contour for each image.

        obj.logger.info('KymoRodData.computeContours', ...
            'Compute binary images contours');

        if obj.processingStep < ProcessingStep.Threshold
            error('need to have threshold computed');
        end

        disp('Contour extraction...');
        hDialog = msgbox(...
            {'Performing Contour extraction,', 'please wait...'}, ...
            'Contour Extraction');

        nFrames = frameNumber(obj);

        % allocate memory for contour array
        contours = cell(nFrames, 1);
        obj.contourList = cell(nFrames, 1);

        % iterate over images
        parfor_progress(nFrames);
        parfor i = 1:nFrames
            % add black border around each image, to ensure continuous contours
            img = getSegmentableImage(obj, i);
            img = imAddBlackBorder(img);
            threshold = obj.thresholdValues(i);
            contours{i} = segmentContour(img, threshold);

            parfor_progress;
        end
        parfor_progress(0);

        obj.contourList = contours;

        if ishandle(hDialog)
            close(hDialog);
        end

        setProcessingStep(obj, ProcessingStep.Contour);
    end
end


%% Methods for skeletons computation
methods
    function skel = getSkeleton(obj, index)
        if obj.processingStep < ProcessingStep.Skeleton
            error('need to have skeletons computed');
        end
        skel = obj.skeletonList{index};
    end

    function skel = getScaledkeleton(obj, index)
        if obj.processingStep < ProcessingStep.Skeleton
            error('need to have skeletons computed');
        end
        skel = obj.scaledSkeletonList{index};
    end

    function computeSkeletons(obj)
        % compute all skeletons from smoothed contours.

        obj.logger.info('KymoRodData.computeSkeletons', ...
            'Compute skeletons from contours');

        if obj.processingStep < ProcessingStep.Contour
            error('need to have contours computed');
        end

        % number of images
        nFrames = frameNumber(obj);

        smooth = obj.settings.contourSmoothingSize;

        organShape = 'boucle';
        originDirection = obj.settings.skeletonOrigin;

        % allocate memory for results
        skelList    = cell(nFrames, 1);
        radList     = cell(nFrames, 1);
        contListMm  = cell(nFrames, 1);
        skelListMm  = cell(nFrames, 1);
        originList  = cell(nFrames, 1);

        disp('Skeletonization');
        % spatial resolution of images in millimetres
        resolMm = obj.settings.pixelSize / 1000;

        t0 = tic;
        parfor_progress(nFrames);
        parfor i = 1:nFrames
            % extract current contour
            contour = getContour(obj, i);
            if smooth ~= 0
                contour = smoothContour(contour, smooth);
            end

            % apply filtering depending on contour type
            contour2 = filterContour(contour, 200, organShape);

            % extract skeleton of current contour
            [skel, rad] = contourSkeleton(contour2, originDirection);
            skelList{i} = skel;

            % convert radius list to millimetres
            radList{i} = rad * resolMm;

            % coordinates of first point of skeleton (in pixels)
            origin = skel(1,:);

            % keep it after conversion in mm
            originList{i} = origin;

            % align contour at bottom left and reverse y-axis (user coordinates)
            contour2 = [contour(:,1) - origin(1), -(contour(:,2) - origin(2))];
            contListMm{i} = contour2 * resolMm;

            % align skeleton at bottom left, and reverse y axis
            skel2 = [skel(:,1) - origin(1), -(skel(:,2) - origin(2))];
            skelListMm{i} = skel2 * resolMm;

            parfor_progress;
        end
        parfor_progress(0);

        % copy temporary arrays to KymoRodData instance
        obj.skeletonList       = skelList;
        obj.radiusList         = radList;
        obj.scaledContourList  = contListMm;
        obj.scaledSkeletonList = skelListMm;
        obj.originPosition     = originList;

        t1 = toc(t0);
        disp(sprintf('elapsed time: %6.2f mn', t1 / 60)); %#ok<DSPS>

        setProcessingStep(obj, ProcessingStep.Skeleton);
    end
end


%% Displacement and Elongation computation

methods
    function img = getImageForDisplacement(obj, index)
        % Return the image for computing displacement.
        % In case of color image, returns the green channel by default.
        img = getImage(obj, index);
        if ndims(img) > 2 %#ok<ISMAT>
            % TODO: use channel
            img = img(:,:,2);
        end
    end

    function computeCurvaturesDisplacementAndElongation(obj)

        if obj.processingStep < ProcessingStep.Skeleton
            error('need to have skeletons computed');
        end

        % Compute curvilinear abscissa and align them
        computeSkeletonAlignedAbscissa(obj);

        % Compute vertical angle and curvatures
        computeAnglesAndCurvatures(obj);

        % Displacement (may require some time...)
        computeDisplacements(obj);

        % Elongation
        computeElongations(obj);
    end

    function computeSkeletonAlignedAbscissa(obj)
        % Compute curvlinear abscissa on skeleton and align them.

        disp('Compute angles and curvature');
        obj.logger.info('KymoRodData.computeSkeletonAlignedAbscissa', ...
            'Compute curvilinear abscissa of skeletons');

        % number of images
        nFrames = frameNumber(obj);

        % allocate memory for result
        S = cell(nFrames, 1);

        % iterate over skeletons
        for i = 1:nFrames
            S{i} = curvilinearAbscissa(obj.scaledSkeletonList{i});
        end

        % Alignment of all the results
        disp('Alignment of curves');
        Sa = alignAbscissa(S, obj.radiusList);

        % store within class
        obj.abscissaList = Sa;
    end

    function computeAnglesAndCurvatures(obj)
        % Compute angle and curvature of all skeletons.

        disp('Compute angles and curvature');
        obj.logger.info('KymoRodData.computeAnglesAndCurvatures', ...
            'Compute vertical angles and curvatures');

        % get input data
        SK = obj.scaledSkeletonList;
        S = obj.abscissaList;

        % size option for computing curvature
        smooth  = obj.settings.curvatureSmoothingSize;

        % allocate memory for results
        n = length(SK);
        A = cell(n, 1);
        C = cell(n, 1);

        % iterate over skeletons in the list
        parfor_progress(n);
        parfor i = 1:n
            curve = SK{i};
            % Check that the length of the skeleton is not too small
            if size(curve, 1) > 2 * smooth
                % Computation of the angle A and the curvature C
                [A{i}, C{i}] = computeCurvature(curve, S{i}, smooth);
            else
                % if the length is too small use a dummy abscissa and zeros angle
                A{i} = zeros(size(S{i}));
                C{i} = zeros(size(S{i}));
            end
            parfor_progress;

        end
        parfor_progress(0);

        % store within class
        obj.verticalAngleList   = A;
        obj.curvatureList       = C;

        computeCurvaturesAndAbscissaImages(obj);
    end

    function computeCurvaturesAndAbscissaImages(obj)
        nx  = obj.settings.finalResultLength;
        Sa  = obj.abscissaList;

        obj.curvatureImage     = kymographFromValues(Sa, obj.curvatureList, nx);
        obj.verticalAngleImage = kymographFromValues(Sa, obj.verticalAngleList, nx);
        obj.radiusImage        = kymographFromValues(Sa, obj.radiusList, nx);
    end

    function computeDisplacements(obj)
        % Compute displacements between all couples of frames.

        disp('Displacement');
        obj.logger.info('KymoRodData.computeDisplacements', ...
            'Compute displacements');

        % settings
        ws = obj.settings.windowSize1;
        L = 4 * ws * obj.settings.pixelSize / 1000;
        obj.logger.debug('KymoRodData.computeDisplacements', ...
            sprintf('Value of L=%f', L));

        nFrames = frameNumber(obj);
        step    = obj.settings.displacementStep;

        % allocate memory for result
        displList = cell(nFrames-step, 1);

        parfor_progress(nFrames - step);
        parfor i = 1:nFrames - step
            % index of next skeleton
            i2 = i + step;

            % compute displacement between current couple of frames
            displ = computeFrameDisplacement(obj, i, i2);
            displList{i} = displ;
            parfor_progress;

        end
        parfor_progress(0);

        obj.displacementList = displList;
    end

    function displ = computeFrameDisplacement(obj, i, i2)
        % Compute displacement between two frames.
        %
        % Usage:
        % DISPL = computeFrameDisplacement(KYMO, IND1, IND2);
        %
        % Assumes the class field 'displacementList' is already
        % initialized to the required size.

        % local data
        SK1 = obj.skeletonList{i};
        SK2 = obj.skeletonList{i2};
        S1  = obj.abscissaList{i};
        S2  = obj.abscissaList{i2};
        img1 = getImageForDisplacement(obj, i);
        img2 = getImageForDisplacement(obj, i2);

        % settings
        ws = obj.settings.windowSize1;
        L = 4 * ws * obj.settings.pixelSize / 1000;

        % check if the two skeletons are large enough
        if length(SK1) <= 2*80 || length(SK2) <= 2*80
            % case of too small skeletons
            msg = sprintf('Skeletons %d or %d has not enough vertices', i, i2);
            obj.logger.warn('KymoRodData.computeFrameDisplacement', msg);
            warning(msg); %#ok<SPWRN>
            displ = [1 0; 1 1];
            return;
        end

        displ = computeDisplacement(SK1, SK2, S1, S2, img1, img2, ws, L);

        % check result is large enough
        if size(displ, 1) == 1
            msg = sprintf('Displacement from frame %d to frame %d resulted in small array', i, i2);
            obj.logger.warn('KymoRodData.computeFrameDisplacement', msg);
            warning(msg); %#ok<SPWRN>
            displ = [1 0;1 1];
            return;
        end
    end

    function computeElongations(obj)
        % Compute elongation curves for all skeleton curves.
        %
        %   computeElongations(KYMO)
        %

        % Elongation
        disp('Elongation');
        obj.logger.info('KymoRodData.computeElongations', ...
            'Compute elongations');

        % initialize results
        n = length(obj.displacementList);
        E2 = cell(n, 1);
        Elg = cell(n, 1);

        % iterate over displacement curves
        parfor_progress(n);
        parfor i = 1:n
            [Elg{i}, E2{i}] = computeFrameElongation(obj, i);
            parfor_progress;
        end
        parfor_progress(0);

        % store results
        obj.smoothedDisplacementList = E2;
        obj.elongationList = Elg;

        %  Space-time mapping
        obj.logger.info('KymoRodData.computeElongations', ...
            'Reconstruct elongation kymograph');
        nx = obj.settings.finalResultLength;

        % prepare data for computing kymograph
        nFrames = length(Elg);
        S = cell(nFrames, 1);
        A = cell(nFrames, 1);
        for k = 1:nFrames
            signal = Elg{k};
            if ~isempty(signal)
                S{k} = signal(:, 1);
                A{k} = signal(:, 2);
            end
        end
        obj.elongationImage = kymographFromValues(S, A, nx);

        setProcessingStep(obj, ProcessingStep.Elongation);
    end

    function [Elg, E2] = computeFrameElongation(obj, index)
        % Compute elongation curve for a specific frame.
        %
        % [ELG, E2] = computeFrameElongation(KYMO, INDEX)
        %   ELG: array of elongation
        %   E2:  smoothed displacement for the frame

        % get current array of displacement
        E2 = getFilteredDisplacement(obj, index);

        % check validity of size
        if length(E2) <= 20
            E2 = [0 0;1 0];
            Elg = [0 0;1 0];
            return;
        end

        % get some settings
        t0      = obj.settings.timeInterval;
        step    = obj.settings.displacementStep;
        ws2     = obj.settings.windowSize2;

        % Compute elongation by spatial derivation of the displacement
        Elg = computeElongation(E2, t0, step, ws2);
    end

    function E2 = getFilteredDisplacement(obj, index)
        % Smooth the curve and remove errors using kernel smoothers.
        %
        % E2 = getFilteredDisplacement(KYMO, INDEX);
        %

        % get current array of displacement
        E = obj.displacementList{index};

        % check validity of size
        if length(E) <= 20
            E2 = [0 0;1 0];
            return;
        end

        % extract computation options
        LX      = obj.settings.displacementSpatialSmoothing;
        LY      = obj.settings.displacementValueSmoothing;
        dx      = obj.settings.displacementResamplingDistance;

        % shifts curvilinear abscissa to start at zero
        Smin = E(1,1);
        E(:,1) = E(:,1) - Smin;

        % apply curve smoothing
        [X, Y] = smoothAndFilterDisplacement(E, LX, LY, dx);
        if any(size(X) ~= size(Y))
            warning('arrays X and Y do not have same size...');
        end

        % add initial curvilinear abscissa
        E2 = [X + Smin, Y];
    end

    function computeIntensityKymograph(obj)
        % Comptue kymograph based on values within a list of images.

        % get number of frames
        n = length(obj.skeletonList);

        % allocate memory for result
        S2List = cell(n, 1);
        values = cell(n, 1);

        % iterate over pairs image+skeleton
        for i = 1:n
            % get skeleton and its curvilinear abscissa
            S = obj.abscissaList{i};
            skel = obj.skeletonList{i};

            % reduce skeleton to snap on image pixels
            [S2, skel2] = snapCurveToPixels(S, skel);
            S2List{i} = S2;

            % compute values within image
            img = obj.getIntensityImage(i);
            values{i} = imEvaluate(img, skel2);
        end

        % Compute kymograph using specified kymograph size
        nx = obj.settings.finalResultLength;
        obj.intensityImage = kymographFromValues(S2List, values, nx);
    end

    function image = getIntensityImage(this, index)
        filePath = fullfile(this.intensityImagesDir, this.intensityImagesNameList{index});
        image = imread(filePath);

        if ndims(image) > 2 %#ok<ISMAT>
            switch lower(this.settings.intensityImagesChannel)
                case 'red',     image = image(:,:,1);
                case 'green',   image = image(:,:,2);
                case 'blue',    image = image(:,:,3);
            end
        end
    end

    function img = getKymographMatrix(obj)
        % Return the array of values representing the current kymograph.
        % (defined by this.kymographDisplayType)

        switch obj.kymographDisplayType
            case 'radius'
                img = obj.radiusImage;
            case 'verticalAngle'
                img = obj.verticalAngleImage;
            case 'curvature'
                img = obj.curvatureImage;
            case 'elongation'
                img = obj.elongationImage;
            case 'intensity'
                img = obj.intensityImage;
        end
    end
end


%% Display methods

methods
    function varargout = showCurrentKymograph(obj)
        % Display the current kymograph on a new figure.

        % get floating-point image corresponding to kymograph
        img = getKymographMatrix(obj);

        % compute display extent for elongation kymograph
        minCaxis = min(img(:));
        maxCaxis = max(img(:));

        % compute references for x and y axes
        timeInterval = obj.settings.timeInterval;
        xdata = (0:(size(img, 2)-1)) * timeInterval * obj.indexStep;
        Sa = obj.abscissaList{end};
        ydata = linspace(Sa(1), Sa(end), obj.settings.finalResultLength);

        % display current kymograph
        hImg = imagesc(xdata, ydata, img);

        % setup display
        set(gca, 'YDir', 'normal');
        clim([minCaxis, maxCaxis]); colorbar;
        colormap jet;

        % annotate
        xlabel(sprintf('Time (%s)', obj.settings.timeIntervalUnit));
        ylabel(sprintf('Geodesic position (%s)', obj.settings.pixelSizeUnit));
        title(obj.kymographDisplayType);

        if nargout > 0
            varargout = {hImg};
        end
    end
end

methods
    function varargout = showKymograph(obj, type)
        % Display the kymograph result on a new figure.
        %
        % deprecated: use showCurrentKymograph instead

        warning('KymoRodData:showKymoGraph', ...
            'KymoRodData.showKymoGraph() is deprecated, use showCurrentKymograph instead');

        if nargin < 2
            type = 'elongation';
        end

        switch type
            case 'elongation', img = obj.elongationImage;
            case 'radius', img = obj.radiusImage;
            case 'curvature', img = obj.curvatureImage;
            case 'verticalAngle', img = obj.verticalAngleImage;
        end

        % compute display extent for elongation kymograph
        minCaxis = min(img(:));
        maxCaxis = max(img(:));

        % compute references for x and y axes
        timeInterval = obj.settings.timeInterval;
        xdata = (0:(size(img, 2)-1)) * timeInterval * obj.indexStep;
        Sa = obj.abscissaList{end};
        ydata = linspace(Sa(1), Sa(end), obj.settings.finalResultLength);

        % display current kymograph
        hImg = imagesc(xdata, ydata, img);

        % setup display
        set(gca, 'YDir', 'normal');
        clim([minCaxis, maxCaxis]); colorbar;
        colormap jet;

        % annotate
        xlabel(sprintf('Time (%s)', obj.settings.timeIntervalUnit));
        ylabel(sprintf('Geodesic position (%s)', obj.settings.pixelSizeUnit));
        title(type);

        if nargout > 0
            varargout = {hImg};
        end
    end
end


%% Input / output methods
methods
    function write(obj, fileName)
        % Save the different options in a text file.

        obj.logger.info('KymoRodData.write', ...
            ['Save kymorod object in file: ' fileName]);

        % open in text mode, erasing content if it exists
        f = fopen(fileName, 'w+t');
        if f == -1
            errordlg(['Could not open file for writing: ' fileName]);
            return;
        end

        % write header
        fprintf(f, '# KymoRod Analysis Info\n');
        fprintf(f, '# saved: %s\n', char(datetime("now")));

        % save also modification date of the main class
        baseDir = fileparts(which('KymoRodData'));
        fileInfo = dir(fullfile(baseDir, 'KymoRodData.m'));
        fprintf(f, '# KymoRod version: %s (%s)\n', ...
            char(obj.appliVersion), fileInfo.date);
        fprintf(f, '\n');

        %
        fprintf(f, '# ----- Image File Infos -----\n\n');

        % informations to retrieve input image
        fprintf(f, 'inputImagesDir = %s\n', obj.inputImagesDir);
        fprintf(f, 'inputImagesFilePattern = %s\n', obj.inputImagesFilePattern);

        % informations to retrieve intensity image
        fprintf(f, 'intensityImagesDir = %s\n', obj.intensityImagesDir);
        fprintf(f, 'intensityImagesFilePattern = %s\n', obj.intensityImagesFilePattern);

        % informations to select images from input directory
        fprintf(f, 'firstIndex = %d\n', obj.firstIndex);
        fprintf(f, 'lastIndex = %d\n', obj.lastIndex);
        fprintf(f, 'indexStep = %d\n', obj.indexStep);
        fprintf(f, '\n');

        string = KymoRodData.booleanToString(obj.inputImagesLazyLoading);
        fprintf(f, 'inputImagesLazyLoading = %s\n', string);
        fprintf(f, '\n');

        %
        fprintf(f, '# ----- Generic Settings -----\n\n');

        writeSettings(obj.settings, f);

        fprintf(f, '# ----- Dataset-specific settings -----\n\n');

        nFrames = frameNumber(obj);
        pattern = ['thresholdValues =' repmat(' %d', 1, nFrames) '\n'];
        fprintf(f, pattern, obj.thresholdValues);
        fprintf(f, '\n');

        fprintf(f, '# ----- Workflow infos -----\n\n');

        % info about current step of the process
        fprintf(f, 'currentStep = %s\n', char(obj.processingStep));
        fprintf(f, 'currentFrameIndex = %d\n', obj.currentFrameIndex);
        fprintf(f, 'cursorRelativeAbscissa = %8.6f\n', obj.cursorRelativeAbscissa);
        fprintf(f, '\n');

        % close the file
        fclose(f);
    end

    function save(obj, fileName)
        % save instance fields in a .mat file, converting to struct.
        %
        % Example:
        %    save(app, 'savedKymo.mat');
        %    app2 = load('savedKymo.mat');

        % convert to a structure to save fields
        warning('off', 'MATLAB:structOnObject');
        appStruct = struct(obj);

        % also convert fields that are classes to structs or char
        appStruct.settings = struct(obj.settings);
        appStruct.processingStep = char(obj.processingStep);
        appStruct.appliVersion = char(obj.appliVersion);
        appStruct.serialVersion = char(obj.serialVersion);

        % clear some unnecessary data
        appStruct.logger = [];

        % save as a struct
        save(fileName, '-struct', 'appStruct');
    end
end % I/O Methods


%% Static methods
methods (Static)
    function app = read(fileName)
        % Initialize a new instance of "KymoRodData" from saved text file.
        %
        % See also
        %    load, write

        % create new empty appdata class
        app = KymoRodData();

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
        % Initialize a new KymoRodData instance from a saved binary file.
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
        if version.major == 0 && ismember(version.minor, [11 12 13])
            % from version 11, changes concern only the Settings class,
            % that manages its own reading version
            app = KymoRodData.load_V_0_11(data);
        elseif version.major == 0 && ismember(version.minor, [8 10])
            % just to fix bug introduced in version 0.10.0
            app = KymoRodData.load_V_0_8(data);
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
        % Initialize a new instance from a structure with 0.8 format.
        % (corresponds to KymoRod applications 0.11.x and upward)

        % creates a new empty instance
        app = KymoRodData();

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
        % Initialize a new instance from a structure with 0.8 format.
        % (corresponds to KymoRod applications 0.8.x to 0.10.x)

        % creates empty instance
        app = KymoRodData();

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