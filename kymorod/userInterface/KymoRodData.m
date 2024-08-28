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

    % index of current frame for display
    currentFrameIndex = 1;

    % informations to retrieve intensity images
    % (for computing the intensity kymograph)
    intensityImagesNameList = {};
    intensityImagesDir = '';
    intensityImagesFilePattern = '*.*';
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

        image = getSegmentableImage(obj.analysis, index);
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

        seg = getSegmentedImage(obj.analysis, index);
    end

    function imgf = getSmoothedImage(obj, index)
        % Get the image after smoothing for use by threshold method.

        imgf = getSmoothedImage(obj.analysis, index);
    end

    function setThresholdValues(obj, values)
        % manually set up the values for threshold.
        %
        % setThresholdValues(KYMO, VALUES)
        %   VALUES should be an array with as many elements as the
        %   number of frames.
        % setThresholdValues(KYMO, VAL)
        %   VAL should be a scalar value.

        setThresholdValues(obj.analysis, values);
    end

    function computeThresholdValues(obj)
        % compute threshold values for all images.

        computeThresholdValues(obj.analysis);
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
        contour = getSmoothedContour(obj.analysis, index);
    end

    function computeContours(obj)
        % Compute the contour for each image.

        computeContours(obj.analysis);
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

        computeMidlines(obj.analysis);
        setProcessingStep(obj, ProcessingStep.Skeleton);
    end
end


%% Displacement and Elongation computation

methods
    function img = getImageForDisplacement(obj, index)
        % Return the image for computing displacement.

        img = getDisplacementImage(obj.analysis, index);
    end

    function computeCurvaturesDisplacementAndElongation(obj)

        if obj.processingStep < ProcessingStep.Skeleton
            error('need to have midlines computed');
        end

        % TODO: split method into several processes

        % align abscissas and compute geometric kymographs
        alignedMidlineAbscissas(obj.analysis);
        computeAnglesAndCurvatures(obj.analysis);
        computeGeometricKymographs(obj.analysis);

        % Computation of frame to frame displacements (may require some time...)
        computeDisplacements(obj.analysis);
        computeFilteredDisplacements(obj.analysis);

        % elongation
        computeElongations(obj.analysis);
    end

    function computeSkeletonAlignedAbscissa(obj)
        % Compute curvlinear abscissa on skeleton and align them.

        disp('Alignment of Midline abscissas');
        obj.logger.info('KymoRodData.computeSkeletonAlignedAbscissa', ...
            'Compute curvilinear abscissa of skeletons');

        alignedMidlineAbscissas(obj.analysis);
    end

    function computeAnglesAndCurvatures(obj)
        % Compute angle and curvature of all skeletons.

        % disp('Compute angles and curvature');
        obj.logger.info('KymoRodData.computeAnglesAndCurvatures', ...
            'Compute vertical angles and curvatures');

        computeAnglesAndCurvatures(obj.analysis);
        computeGeometricKymographs(obj.analysis);
    end

    function computeCurvaturesAndAbscissaImages(obj)
        computeGeometricKymographs(obj.analysis);
    end

    function computeDisplacements(obj)
        % Compute displacements between all couples of frames.

        % disp('Displacement');
        obj.logger.info('KymoRodData.computeDisplacements', ...
            'Compute displacements');

        computeDisplacements(obj.analysis);
    end

    function computeFilteredDisplacements(obj)
        % Apply filtering to all displacement signals.
        
        disp('Filter Displacements');
        obj.logger.info('KymoRodData.computeElongations', ...
            'Compute filtered displacements');

        computeFilteredDisplacements(obj.analysis);
    end


    function computeElongations(obj)
        % Compute elongation curves for all midlines.
        %
        %   computeElongations(KYMO)
        %

        computeElongations(obj.analysis);
        setProcessingStep(obj, ProcessingStep.Elongation);
    end

    function computeIntensityKymograph(obj)
        % Compute kymograph based on values within a list of images.

        obj.analysis.computeIntensityKymograph();
    end

    function image = getIntensityImage(obj, index)
        image = obj.analysis.IntensityImages.getFrameImage(index);

        if ndims(image) > 2 %#ok<ISMAT>
            switch lower(obj.analysis.Parameters.IntensityImageChannel)
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