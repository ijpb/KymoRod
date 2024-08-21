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

    % the current analysis, as an instance of 'Analysis' class.
    analysis;

    % the set of settings for the different processing steps
    % as an instance of KymoRodSettings.
    settings;

    % Step of processing, to know which data are initialized, and which
    % ones need to be computed. Default is "None".
    % See the class ProcessingStep for details.
    processingStep = ProcessingStep.None;

    % index of current frame for display
    currentFrameIndex = 1;

    % informations to retrieve intensity images
    % (for computing the intensity kymograph)
    intensityImagesNameList = {};
    intensityImagesDir = '';
    intensityImagesFilePattern = '*.*';

end


%% Legacy properties
% Properties defiend here are being replaced by the 'analysis' property.
properties
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
    % (deprecated)
    scaledContourList = {};

    % list of skeletons, one curve by cell, in pixel unit (old SKVerif)
    % (replaced by Midlines)
    skeletonList = {};

    % list of skeletons after rescaling, and translation wrt first
    % point of skeleton (old 'SK').
    % (deprecated)
    scaledSkeletonList = {};

    % list of radius values, in millimetres
    % (deprecated)
    radiusList = {};

    % coordinates of the first point of the skeleton for each image.
    % (in pixels)
    % (deprecated)
    originPosition = {};

    % the curvilinear abscissa of each skeleton, in a cell array
    % (deprecated)
    abscissaList;

    % (obsolete) the curvilinear abscissa after alignment procedure
    % (deprecated)
    alignedAbscissaList;

    % the angle with the vertical of each point of each skeleton, in a
    % cell array
    % (need to keep it until computation of vertical angle is totally useless) 
    verticalAngleList;

    % the curvature of each point of each skeleton, in a cell array
    % (deprecated)
    curvatureList;

    % the displacement of a point to the next similar point
    displacementList;

    % the displacement after smoothing and resampling
    smoothedDisplacementList;

    % elongation, computed by derivation of smoothed displacement
    elongationList;

    % reconstructed Kymograph of skeleton radius in absissa and time
    radiusKymograph;

    % reconstructed Kymograph of angle with vertical in absissa and time
    verticalAngleKymograph;

    % reconstructed Kymograph of curvature in absissa and time
    curvatureKymograph;

    % final result: elongation as a function of position and time
    elongationKymograph;

    % intensity kymograph, computed by evaluating the intensity of
    % another image on the positions of the skeletons
    intensityKymograph;


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
        
        % initializes new analysis
        obj.analysis = kymorod.app.Analysis;
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
            newStep = ProcessingStep.parse(newstep);
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
                clearDisplacementData();

            case ProcessingStep.Displacement
                clearFilteredDisplacementData();

            case ProcessingStep.FilteredDisplacement
                clearElongationData();

            case ProcessingStep.Elongation
                
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
            clear(obj.analysis.InputImages.ImageList);

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

            clearDisplacementData();
        end

        function clearDisplacementData()
            obj.abscissaList = {};
            obj.verticalAngleList = {};
            obj.curvatureList = {};
            obj.displacementList = {};

            clearFilteredDisplacementData();
        end

        function clearFilteredDisplacementData()
            obj.smoothedDisplacementList = {};

            clearElongationData();
        end

        function clearElongationData()
            obj.elongationList = {};

            clearResultKymographs();
        end

        function clearResultKymographs()
            obj.curvatureKymograph = [];
            obj.verticalAngleKymograph = [];
            obj.radiusKymograph = [];
            obj.elongationKymograph = [];
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
        computeFilteredDisplacements(obj);
        computeCurvaturesAndAbscissa(obj);
        computeDisplacements(obj);
        computeElongations(obj);
    end
end


%% Image selection
methods
    function n = frameNumber(obj)
        % Return the total number of images selected for processing.
        n = frameCount(obj.analysis.InputImages);
    end

    function img = getImage(obj, index)
        % Return the image corresponding to the given frame.
        img = getImage(obj.analysis.InputImages.ImageList, index);
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
            image = kymorod.core.image.adjustDynamic(image, 0.1);
        end
    end

    function loadImageData(obj)
        % Read image data.
        % Load images, or simply read file names depending on the value
        % of the "inputImagesLazyLoading" property

        updateImageData(obj.analysis.InputImages.ImageList);
    end

    function computeImageNames(obj)
        % Update list of image names from input directory and indices.

        disp('Read all image names');
        computeImageFileNameList(obj.analysis.InputImages.ImageList);
    end

    function nFiles = getFileNumber(obj)
        % Compute the number of files matching input dir and name pattern.

        nFiles = length(getFileList(obj.analysis.InputImages.ImageList));
    end

    function readAllImages(obj)
        % load all images based on settings.
        % refresh imageList and imageNameList

        updateImageData(obj.analysis.InputImages.ImageList);
        setProcessingStep(obj, ProcessingStep.Selection);
    end
end


%% Image segmentation

methods
    function seg = getSegmentedImage(obj, index)
        % Return the specified frame after smoothing and binarization.

        img = getSmoothedImage(obj, index);
        thresh = obj.analysis.ThresholdValues(index);
        seg = img > thresh;
    end

    function imgf = getSmoothedImage(obj, index)
        % Get the image after smoothing for use by threshold method.

        img = getSegmentableImage(obj, index);

        switch lower(obj.analysis.Parameters.ImageSmoothingMethodName)
            case lower('None')
                % no smoothing -> simply copy image
                imgf = img;

            case lower('BoxFilter')
                % smooth with flat box filter
                radius = obj.analysis.Parameters.ImageSmoothingRadius;
                diam = 2 * radius + 1;
                imgf = imfilter(img, ones(diam, diam) / diam^2, 'replicate');

            case lower('Gaussian')
                % smooth with gaussian filter
                radius = obj.analysis.Parameters.ImageSmoothingRadius;
                diam = 2 * radius + 1;
                h = fspecial('gaussian', [diam diam], radius);
                imgf = imfilter(img, h, 'replicate');

            otherwise
                error(['Can not handle smoothing method: ' ...
                    obj.analysis.Parameters.ImageSmoothingMethodName]);
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
        if isscalar(values)
            values = repmat(values, 1, frameNumber(obj));
        end
        if length(values) ~= frameNumber(obj)
            error('The number of values should match number of frames');
        end

        % update local variables
        values = values(:)';
        obj.analysis.InitialThresholdValues = values;
        obj.analysis.ThresholdValues = values;

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
        obj.analysis.InitialThresholdValues = zeros(nImages, 1);

        % Compute the threshold values
        disp('Segmentation');
        hDialog = msgbox(...
            {'Computing image thresholds,', 'please wait...'}, ...
            'Segmentation');

        % temporay array for storing result
        baseValues = zeros(1, nImages);

        % compute threshold values
        switch lower(obj.analysis.Parameters.AutoThresholdMethod)
            case lower('MaxEntropy')
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    baseValues(i) = kymorod.core.image.maxEntropyThreshold(img);
                end

            case lower('Otsu')
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    baseValues(i) = round(graythresh(img) * 255);
                end

            otherwise
                error(['Could not recognize threshold method: ' ...
                    obj.analysis.Parameters.AutoThresholdMethod]);
        end

        % setup threshold values
        obj.analysis.InitialThresholdValues = baseValues;
        obj.analysis.ThresholdValues = obj.analysis.InitialThresholdValues;

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
        contour = obj.analysis.Contours{index};
    end

    function contour = getSmoothedContour(obj, index)
        if obj.processingStep < ProcessingStep.Contour
            error('need to have contours computed');
        end
        contour = obj.analysis.Contours{index};
        smooth = obj.analysis.Parameters.ContourSmoothingSize;
        contour = kymorod.core.geom.smoothContour(contour, smooth);
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

        % allocate memory for contour array
        nFrames = frameNumber(obj);
        contours = cell(nFrames, 1);
        
        % iterate over images
        parfor i = 1:nFrames
            % add black border around each image, to ensure continuous contours
            img0 = getSegmentableImage(obj, i);

            % add one black pixel in each direction
            img = zeros(size(img0) + 2, class(img0));
            img(2:end-1, 2:end-1) = img0;

            % compute contour
            threshold = obj.analysis.ThresholdValues(i);
            contours{i} = kymorod.core.image.largestIsocontour(img, threshold);

            fprintf('.');
        end
        fprintf('\n');

        % obj.contourList = contours;
        obj.analysis.Contours = contours;

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
        skel = obj.analysis.Midlines{index};
    end

    function skel = getScaledkeleton(obj, index)
        if obj.processingStep < ProcessingStep.Skeleton
            error('need to have skeletons computed');
        end
        skel = obj.analysis.Midines{index};
        calib = obj.analysis.InputImages.Calibration;
        skel = calibrate(skel, calib);
    end

    function computeSkeletons(obj)
        % compute all skeletons from smoothed contours.

        obj.logger.info('KymoRodData.computeSkeletons', ...
            'Compute skeletons from contours');

        if obj.processingStep < ProcessingStep.Contour
            error('need to have contours computed');
        end

        % retrieve processing options
        smooth = obj.analysis.Parameters.ContourSmoothingSize;
        origin = lower(obj.analysis.Parameters.SkeletonOrigin);

        % allocate memory for results
        nFrames = frameNumber(obj);
        midlines = cell(nFrames, 1);

        disp('Skeletonization');

        t0 = tic;
        parfor i = 1:nFrames
            % extract current contour
            contour = getContour(obj, i);
            if smooth ~= 0
                contour = kymorod.core.geom.smoothContour(contour, smooth);
            end

            % compute the midline of current contour
            midlines{i} = kymorod.core.geom.contourMidline(contour, origin)

            fprintf('.');
        end
        fprintf('\n');
        
        % copy array of midlines within analysis instance 
        obj.analysis.Midlines = midlines;

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

        % TODO: split method into several processes

        % Compute curvilinear abscissa and align them
        computeSkeletonAlignedAbscissa(obj);

        % Compute vertical angle and curvatures
        computeAnglesAndCurvatures(obj);

        % Displacement (may require some time...)
        computeDisplacements(obj);
        computeFilteredDisplacements(obj);

        % Elongation
        computeElongations(obj);
    end

    function computeSkeletonAlignedAbscissa(obj)
        % Compute curvlinear abscissa on skeleton and align them.

        disp('Alignment of Midline abscissas');
        obj.logger.info('KymoRodData.computeSkeletonAlignedAbscissa', ...
            'Compute curvilinear abscissa of skeletons');

        % Alignment of all the curvilinear abscissas
        Sa = kymorod.core.alignMidlineAbscissas(obj.analysis);
        obj.analysis.AlignedAbscissas = Sa;
    end

    function computeAnglesAndCurvatures(obj)
        % Compute angle and curvature of all skeletons.

        disp('Compute angles and curvature');
        obj.logger.info('KymoRodData.computeAnglesAndCurvatures', ...
            'Compute vertical angles and curvatures');

        % get input data
        midlines = obj.analysis.Midlines;

        % size option for computing curvature
        ws = obj.analysis.Parameters.CurvatureWindowSize;

        % allocate memory for results
        n = length(midlines);
        A = cell(n, 1);

        % iterate over midlines in the list
        for i = 1:n
            midline = midlines{i};
            if size(midline.Coords, 1) > 2 * ws
                computeVertexCurvature(midline, ws);
                A{i} = vertexVerticalAngle(midline, ws);
            end
        end

        % keep within class
        obj.analysis.VerticalAngles = A;

        computeCurvaturesAndAbscissaImages(obj);
    end

    function computeCurvaturesAndAbscissaImages(obj)

        % retrieve parameters
        nFrames = frameCount(obj.analysis.InputImages);
        calib = obj.analysis.InputImages.Calibration;
        nPos = obj.analysis.Parameters.KymographAbscissaSize;

        % retrieve data
        Sa = obj.analysis.AlignedAbscissas;
        radiusValues = cell(1, nFrames);
        curvatureValues = cell(1, nFrames);
        for i = 1:nFrames
            midline = calibrate(obj.analysis.Midlines{i}, calib);
            radiusValues{i} = midline.Radiusses;
            curvatureValues{i} = midline.Curvatures;
        end
        verticalAngleValues = obj.analysis.VerticalAngles;

        inputImages = obj.analysis.InputImages;
        timeInterval = calib.TimeInterval;
        frameStep = inputImages.ImageList.IndexStep;

        % compute axis for time
        timeData = (0:(nFrames-1)) * timeInterval * frameStep;
        timeAxis = kymorod.core.PlotAxis(timeData, ...
            'Name', 'Time', ...
            'Unit', obj.settings.timeIntervalUnit);

        % compute axis for curvilinear abscissa
        Smax = max(cellfun(@max, Sa));
        Smin = min(cellfun(@min, Sa));
        positions = linspace(Smin, Smax, nPos);
        posAxis = kymorod.core.PlotAxis(positions, ...
            'Name', 'Curvilinear Abscissa', ...
            'Unit', 'mm');

        % compute images
        radiusImage = kymographFromValues(Sa, radiusValues, nPos);
        obj.analysis.RadiusKymograph = kymorod.core.Kymograph(radiusImage, ....
            'Name', 'Radius', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);

        verticalAngleImage = kymographFromValues(Sa, verticalAngleValues, nPos);
        obj.analysis.VerticalAngleKymograph = kymorod.core.Kymograph(verticalAngleImage, ...
            'Name', 'Vertical Angle', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);

        curvatureImage = kymographFromValues(Sa, curvatureValues, nPos);
        obj.analysis.CurvatureKymograph = kymorod.core.Kymograph(curvatureImage, ...
            'Name', 'Curvature', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
    end

    function computeDisplacements(obj)
        % Compute displacements between all couples of frames.

        disp('Displacement');
        obj.logger.info('KymoRodData.computeDisplacements', ...
            'Compute displacements');

        % retrieve settings
        step = obj.analysis.Parameters.DisplacementStep;

        % allocate memory for result
        nFrames = frameNumber(obj);
        displList = cell(nFrames-step, 1);

        parfor i = 1:(nFrames - step)
            % index of next skeleton
            i2 = i + step;

            % compute displacement between current couple of frames
            displ = computeFrameDisplacement(obj, i, i2);
            displList{i} = displ;

            fprintf('.');
        end
        fprintf('\n');

        obj.analysis.Displacements = displList;
    end

    function displ = computeFrameDisplacement(obj, i1, i2)
        % Compute displacement between two frames.
        %
        % Usage:
        % DISPL = computeFrameDisplacement(KYMO, IND1, IND2);
        %
        % Assumes the class field 'displacementList' is already
        % initialized to the required size.

        % retrieve midlines
        mid1 = obj.analysis.Midlines{i1};
        mid2 = obj.analysis.Midlines{i2};
        SK1 = mid1.Coords;
        SK2 = mid2.Coords;
        S1 = obj.analysis.AlignedAbscissas{i1};
        S2 = obj.analysis.AlignedAbscissas{i2};
        mid1 = kymorod.data.Midline(SK1, S1);
        mid2 = kymorod.data.Midline(SK2, S2);

        % local data
        img1 = getImageForDisplacement(obj, i1);
        img2 = getImageForDisplacement(obj, i2);

        % retrieve parameters
        ws = obj.analysis.Parameters.MatchingWindowRadius;
        calib = obj.analysis.InputImages.Calibration;
        maxDeltaS = 4 * ws * calib.PixelSize / 1000;

        % check if the two skeletons are large enough
        if length(SK1) <= 2*80 || length(SK2) <= 2*80
            % case of too small skeletons
            msg = sprintf('Skeletons %d or %d has not enough vertices', i1, i2);
            obj.logger.warn('KymoRodData.computeFrameDisplacement', msg);
            warning(msg); %#ok<SPWRN>
            displ = [1 0; 1 1];
            return;
        end

        % fprintf('frames: (%d,%d)\n', i1, i2);
        displ = kymorod.core.computeDisplacements(mid1, mid2, img1, img2, ws, maxDeltaS);
        % displ = computeDisplacement(SK1, SK2, S1, S2, img1, img2, ws, maxDeltaS);

        % check result is large enough
        if size(displ, 1) == 1
            msg = sprintf('Displacement from frame %d to frame %d resulted in small array', i1, i2);
            obj.logger.warn('KymoRodData.computeFrameDisplacement', msg);
            warning(msg); %#ok<SPWRN>
            displ = [1 0;1 1];
            return;
        end
    end

    function computeFilteredDisplacements(obj)
        % Apply filtering to all displacement signals.
        
        disp('Filter Displacements');
        obj.logger.info('KymoRodData.computeElongations', ...
            'Compute filtered displacements');

        % initialize results
        nFrames = length(obj.analysis.Displacements);
        displf = cell(nFrames, 1);

        % iterate over displacement curves
        parfor i = 1:nFrames
            displf{i} = computeFilteredDisplacement(obj, i);
        end

        % store results
        obj.analysis.FilteredDisplacements = displf;
    end

    function filtDispl = getFilteredDisplacement(obj, index)
        % Smooth the curve and remove errors using kernel smoothers.
        %
        % filtDispl = getFilteredDisplacement(KYMO, INDEX);
        %

        if isempty(obj.analysis.FilteredDisplacements)
            computeFilteredDisplacements(obj);
        end

        % get current array of displacement
        filtDispl = obj.analysis.FilteredDisplacements{index};
    end

    function filtDispl = computeFilteredDisplacement(obj, index)
        % Smooth the curve and remove errors using kernel smoothers.
        %
        % DISPLF = computeFilteredDisplacement(KYMO, INDEX);
        %

        % get current array of displacement
        displ = obj.analysis.Displacements{index};

        % check validity of size
        if length(displ) <= 20
            filtDispl = [0 0;1 0];
            return;
        end

        % extract computation options
        LX = obj.analysis.Parameters.DisplacementSpatialSmoothing;
        LY = obj.analysis.Parameters.DisplacementValueSmoothing;
        dx = obj.analysis.Parameters.DisplacementResampling;

        % apply curve smoothing
        [X, Y] = kymorod.core.filterDisplacements(displ, LX, LY, dx);

        % concatenate results
        filtDispl = [X Y];
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

        % check filtered displacements have been computed
        if isempty(obj.analysis.FilteredDisplacements)
            computeFilteredDisplacements(obj);
        end

        % initialize results
        nFrames = length(obj.analysis.Displacements);
        Elg = cell(nFrames, 1);

        % iterate over displacement curves
        parfor i = 1:nFrames
            Elg{i} = computeFrameElongation(obj, i);
        end

        % store results
        obj.analysis.Elongations = Elg;

        %  Space-time mapping
        obj.logger.info('KymoRodData.computeElongations', ...
            'Reconstruct elongation kymograph');
        nPos = obj.analysis.Parameters.KymographAbscissaSize;

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
        elongationImage = kymographFromValues(S, A, nPos);

        % retrieve axes from previous kymograph
        timeAxis = obj.analysis.RadiusKymograph.TimeAxis;
        posAxis = obj.analysis.RadiusKymograph.PositionAxis;

        obj.analysis.ElongationKymograph = kymorod.core.Kymograph(elongationImage, ....
            'Name', 'Elongation', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
        
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
        ws2     = obj.analysis.Parameters.ElongationDerivationRadius;
        t0      = obj.analysis.InputImages.Calibration.TimeInterval;
        step    = obj.analysis.Parameters.DisplacementStep;

        % time interval between frames
        deltaT = t0 * step / 60;

        % Compute elongation by spatial derivation of the displacement
        Elg = kymorod.core.computeElongations(E2, ws2, deltaT);
        % Elg = computeElongation(E2, t0, step, ws2);
    end

    function computeIntensityKymograph(obj)
        % Compute kymograph based on values within a list of images.

        % get number of frames
        nFrames = frameNumber(obj);

        % allocate memory for result
        S2List = cell(nFrames, 1);
        values = cell(nFrames, 1);

        % iterate over pairs image+midlines
        for i = 1:nFrames
            % get midline and its curvilinear abscissa
            S = obj.analysis.AlignedAbscissas{i};
            skel = obj.analysis.Midlines{i}.Coords;

            % reduce skeleton to snap on image pixels
            [S2, skel2] = snapCurveToPixels(S, skel);
            S2List{i} = S2;

            % compute values within image
            img = obj.getIntensityImage(i);
            values{i} = imEvaluate(img, skel2);
        end

        % Compute kymograph using specified kymograph size
        nPos = obj.analysis.Parameters.KymographAbscissaSize;
        intensityImage = kymographFromValues(S2List, values, nPos);

        % retrieve axes from previous kymograph
        timeAxis = obj.analysis.RadiusKymograph.TimeAxis;
        posAxis = obj.analysis.RadiusKymograph.PositionAxis;

        obj.analysis.IntensityKymograph = kymorod.core.Kymograph(intensityImage, ....
            'Name', 'Intensity', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
    end

    function image = getIntensityImage(obj, index)
        filePath = fullfile(obj.intensityImagesDir, obj.intensityImagesNameList{index});
        image = imread(filePath);

        if ndims(image) > 2 %#ok<ISMAT>
            switch lower(obj.settings.intensityImagesChannel)
                case 'red',     image = image(:,:,1);
                case 'green',   image = image(:,:,2);
                case 'blue',    image = image(:,:,3);
            end
        end
    end

    function img = getKymographMatrix(obj)
        % Return the array of values representing the current kymograph.
        % (defined by this.kymographDisplayType)

        kymo = getCurrentKymograph(obj);
        img = kymo.Data;
    end

    function kymo = getCurrentKymograph(obj)
        % Return the current kymograph.
        % (defined by this.kymographDisplayType)

        switch obj.analysis.KymographDisplayType
            case 'radius'
                kymo = obj.analysis.RadiusKymograph;
            case 'verticalAngle'
                kymo = obj.analysis.VerticalAngleKymograph;
            case 'curvature'
                kymo = obj.analysis.CurvatureKymograph;
            case 'elongation'
                kymo = obj.analysis.ElongationKymograph;
            case 'intensity'
                kymo = obj.analysis.IntensityKymograph;
        end
    end
end


%% Display methods

methods
    function varargout = showCurrentKymograph(obj)
        % Display the current kymograph on a new figure.

        % get floating-point image corresponding to kymograph
        kymo = getCurrentKymograph(obj);
        
        hImg = show(kymo);
        colormap jet;

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

        img = getKymographMatrix(obj);
        % switch type
        %     case 'elongation', img = obj.elongationKymograph.Data;
        %     case 'radius', img = obj.radiusKymograph.Data;
        %     case 'curvature', img = obj.curvatureKymograph.Data;
        %     case 'verticalAngle', img = obj.verticalAngleKymograph.Data;
        % end

        % compute display extent for elongation kymograph
        minCaxis = min(img(:));
        maxCaxis = max(img(:));

        % compute references for x and y axes
        calib = obj.analysis.InputImages.Calibration;
        timeInterval = calib.TimeInterval;
        frameStep = obj.analysis.InputImages.ImageList.IndexStep;
        xdata = (0:(size(img, 2)-1)) * timeInterval * frameStep;
        Sa = obj.analysis.AlignedAbscissas{end};
        nPos = obj.analysis.Parameters.KymographAbscissaSize;
        ydata = linspace(Sa(1), Sa(end), nPos);

        % display current kymograph
        hImg = imagesc(xdata, ydata, img);

        % setup display
        set(gca, 'YDir', 'normal');
        clim([minCaxis, maxCaxis]); colorbar;
        colormap jet;

        % annotate
        xlabel(sprintf('Time (%s)', calib.TimeIntervalUnit));
        ylabel(sprintf('Geodesic position (%s)', calib.PixelSizeUnit));
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

        updateLegacyProperties(obj);

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
        appStruct = toStruct(obj);

        appStruct = rmfield(appStruct, 'analysis');

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

    function str = toStruct(obj)
        % Convert this instance into a Matlab struct.
        %

        updateLegacyProperties(obj);
        warning('off', 'MATLAB:structOnObject');
        str = struct(obj);

        % also convert fields that are classes to structs or char
        str.settings = struct(obj.settings);
        str.processingStep = char(obj.processingStep);
        str.appliVersion = char(obj.appliVersion);
        str.serialVersion = char(obj.serialVersion);
        
        % convert fields that expose the "toStruct" method
        fields = [...
            "radiusKymograph", ...
            "verticalAngleKymograph", ...
            "curvatureKymograph", ...
            "elongationKymograph", ...
            "intensityKymograph", ...
            ];
        for fieldName = fields
            if ~isempty(obj.(fieldName))
                str.(fieldName) = toStruct(obj.(fieldName));
            end
        end
        
        % clear some unnecessary data
        str.logger = [];
    end

    function updateLegacyProperties(obj)
        % Update legacy properties from the 'analysis' property.
        imgList = obj.analysis.InputImages.ImageList;
        obj.imageNameList = imgList.ImageFileNameList;
        obj.inputImagesDir = imgList.Directory;
        obj.inputImagesFilePattern = imgList.FileNamePattern;
        obj.inputImagesLazyLoading = imgList.LazyLoading;
        obj.firstIndex = imgList.IndexFirst;
        obj.lastIndex = imgList.IndexLast;
        obj.indexStep = imgList.IndexStep;
        obj.frameImageSize = obj.analysis.InputImages.ImageSize;

        calib = obj.analysis.InputImages.Calibration;
        obj.settings.pixelSize = calib.PixelSize;
        obj.settings.pixelSizeUnit = calib.PixelSizeUnit;
        obj.settings.timeInterval = calib.TimeInterval;
        obj.settings.timeIntervalUnit = calib.TimeIntervalUnit;

        params = obj.analysis.Parameters;
        obj.settings.imageSmoothingMethod = params.ImageSmoothingMethodName;
        obj.settings.imageSmoothingRadius = params.ImageSmoothingRadius;
        obj.settings.thresholdStrategy = params.ThreshodStrategy;
        obj.settings.autoThresholdMethod = params.AutoThresholdMethod;
        obj.settings.manualThresholdValue = params.ManualThresholdValue;
        obj.settings.contourSmoothingSize = params.ContourSmoothingSize;

        obj.thresholdValues = obj.analysis.ThresholdValues;
        obj.baseThresholdValues = obj.analysis.InitialThresholdValues;
        obj.contourList = obj.analysis.ContourList;
    end

    function updateAnalyis(obj)
        % Update the 'analysis' property from the legacy properties.
        obj.analysis = kymorod.app.Analysis;
        imgList = obj.analysis.InputImages.ImageList;
        imgList.Directory = obj.inputImagesDir;
        imgList.FileNamePattern = obj.inputImagesFilePattern;
        imgList.LazyLoading = obj.inputImagesLazyLoading;
        imgList.IndexFirst = obj.firstIndex;
        imgList.IndexLast = obj.lastIndex;
        imgList.IndexStep = obj.indexStep;
        imgList.ImageFileNameList = obj.imageNameList;
        obj.analysis.InputImages = obj.frameImageSize;

        calib = obj.analysis.InputImages.Calibration;
        calib.PixelSize = obj.settings.pixelSize;
        calib.PixelSizeUnit = obj.settings.pixelSizeUnit;
        calib.TimeInterval = obj.settings.timeInterval;
        calib.TimeIntervalUnit = obj.settings.timeIntervalUnit;

        params = obj.analysis.Parameters;
        params.ImageSmoothingMethodName = obj.settings.imageSmoothingMethod;
        params.ImageSmoothingRadius = obj.settings.imageSmoothingRadius;
        params.ThreshodStrategy = obj.settings.thresholdStrategy;
        params.AutoThresholdMethod = obj.settings.autoThresholdMethod;
        params.ManualThresholdValue = obj.settings.manualThresholdValue;
        params.ContourSmoothingSize = obj.settings.contourSmoothingSize;

        obj.analysis.ThresholdValues = obj.thresholdValues;
        obj.analysis.InitialThresholdValues = obj.baseThresholdValues;
        obj.analysis.ContourList = obj.contourList;

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

        updateAnalyis(app);
    end

    function app = load(fileName)
        % Initialize a new KymoRodData instance from a saved binary file.
        %
        % Example
        %    save(app, 'savedKymo.mat');
        %    app2 = load('savedKymo.mat');
        %
        % See also
        %   read, save, fromStruct

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
        if version.major == 0 && ismember(version.minor, 13)
            % from V0.13, introduces Kymograph class
            app = KymoRodData.fromStruct(data);

        elseif version.major == 0 && ismember(version.minor, [11 12 13])
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

        updateAnalyis(app);
    end

    function app = fromStruct(data)
        % Convert a Matlab structure into a KymoRodData instance.
        %
        % Used by the "load" function.
        % (corresponds to KymoRod applications 0.13.x and upward)
        % Used by the "load" function.

        % creates a new empty instance
        app = KymoRodData();
        
        % iterate over struct fields to choose relevant processing
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

            elseif strcmpi(name, 'radiusKymograph')
                app.radiusKymograph = kymorod.core.Kymograph.fromStruct(value);
            elseif strcmpi(name, 'verticalAngleKymograph')
                app.verticalAngleKymograph = kymorod.core.Kymograph.fromStruct(value);
            elseif strcmpi(name, 'curvatureKymograph')
                app.curvatureKymograph = kymorod.core.Kymograph.fromStruct(value);
            elseif strcmpi(name, 'elongationKymograph')
                app.elongationKymograph = kymorod.core.Kymograph.fromStruct(value);
            elseif strcmpi(name, 'intensityKymograph')
                app.intensityKymograph = kymorod.core.Kymograph.fromStruct(value);
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

        updateAnalyis(app);
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