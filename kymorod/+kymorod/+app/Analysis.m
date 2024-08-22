classdef Analysis < handle
% Container for data of a Kymorod analysis.
%
%   Class Analysis
%
%   Example
%   Analysis
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-04,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    % The set of parameters that specifies the analysis, as an instance of
    % the Parameters class.
    Parameters;

    % The input images for segmentation, as an instance of TimeLapseImage.
    InputImages;

    % The list of threshold values used to segment images.
    ThresholdValues;
    
    % the list of threshold values computed automatically, without
    % manual correction.
    InitialThresholdValues = [];

    % The list of contours, one polygon by cell, in pixel units.
    Contours = {};

    % The longest path in skeleton for each image, as a cell array of
    % kymorod.data.Midline instances, in pixel coordinates.
    Midlines = {};

    % The curvilinear abscissa after alignment procedure, as a cell array.
    % Aligned abscissas are in calibrated units (mm).
    AlignedAbscissas = {};

    VerticalAngles = {};

    % The displacement of each point to the next similar point.
    % Given as a cell array, each cell containing a N-by-2 numeric array,
    % the first column coresponding to the curvilinear abscissa.
    Displacements;

    % The displacement after smoothing and resampling
    % Given as a cell array, each cell containing a N-by-2 numeric array.
    FilteredDisplacements = {};
    
    % Elongation, computed by derivation of filtered displacement.
    Elongations;

    % reconstructed Kymograph of skeleton radius in absissa and time
    RadiusKymograph;

    % reconstructed Kymograph of angle with vertical in absissa and time
    VerticalAngleKymograph;

    % reconstructed Kymograph of curvature in absissa and time
    CurvatureKymograph;

    % final result: elongation as a function of position and time
    ElongationKymograph;

    % intensity kymograph, computed by evaluating the intensity of
    % another image on the positions of the skeletons
    IntensityKymograph;


    % index of current frame for display.
    CurrentFrameIndex = 1;

    % the type of kymograph used for display
    % should be one of 'radius' (default), 'verticalAngle',
    % 'curvature', 'elongation', 'intensity'
    KymographDisplayType = 'radius';

    % the relative abscissa of the graphical cursor, between 0 and 1.
    % Default value is .5, corresponding to the middle of the skeleton.
    CursorRelativeAbscissa = 0.5;

end % end properties


%% Constructor
methods
    function obj = Analysis(varargin)
        % Constructor for Analysis class.
        obj.Parameters = kymorod.app.Parameters;
        obj.InputImages = kymorod.data.TimeLapseImage;
    end

end % end constructors

%% General methods for analysis
methods
    function nf = frameCount(obj)
        % Return the number of frames within this analysis.
        nf = 0;
        if ~isempty(obj.InputImages)
            nf = frameCount(obj.InputImages);
        end
    end

    function img = getSegmentableImage(obj, index)
        % Return the image that can be used for computing segmentation.
        % (without smoothing)
        % get the image

        img = getFrameImage(obj.InputImages, index);

        % extract the channel used for segmentation
        if ndims(img) > 2 %#ok<ISMAT>
            switch lower(obj.Parameters.MidlineImageChannel)
                case 'red',     img = img(:,:,1);
                case 'green',   img = img(:,:,2);
                case 'blue',    img = img(:,:,3);
            end
        end

        % eventually converts to uint8
        if isa(img, 'uint16') && ndims(img) == 2 %#ok<ISMAT>
            img = kymorod.core.image.adjustDynamic(img, 0.1);
        end
    end

    function imgf = getSmoothedImage(obj, index)
        % Get the image after smoothing for use by threshold method.

        img = getSegmentableImage(obj, index);

        switch obj.Parameters.ImageSmoothingMethodName
            case 'None'
                % no smoothing -> simply copy image
                imgf = img;

            case 'BoxFilter'
                % smooth with flat box filter
                radius = obj.Parameters.ImageSmoothingRadius;
                diam = 2 * radius + 1;
                imgf = imfilter(img, ones(diam, diam) / diam^2, 'replicate');

            case 'Gaussian'
                % smooth with gaussian filter
                radius = obj.Parameters.ImageSmoothingRadius;
                diam = 2 * radius + 1;
                h = fspecial('gaussian', [diam diam], radius);
                imgf = imfilter(img, h, 'replicate');

            otherwise
                error(['Can not handle smoothing method: ' ...
                    obj.Parameters.ImageSmoothingMethodName]);
        end
    end

    function computeThresholdValues(obj)
        % Compute threshold values for all images.

        % Compute the threshold values
        disp('Segmentation');

        % allocate memory for result
        nImages = frameCount(obj);
        values = zeros(1, nImages);

        % compute threshold values
        switch obj.Parameters.AutoThresholdMethod
            case 'MaxEntropy'
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    values(i) = kymorod.core.image.maxEntropyThreshold(img);
                end

            case 'Otsu'
                parfor i = 1 : nImages
                    img = getSegmentableImage(obj, i);
                    values(i) = round(graythresh(img) * 255);
                end

            otherwise
                error(['Could not recognize threshold method: ' ...
                    obj.Parameters.AutoThresholdMethod]);
        end

        % setup threshold values
        obj.InitialThresholdValues = values;
        obj.ThresholdValues = obj.InitialThresholdValues;
    end

    function setThresholdValues(obj, values)
        % Manually set up the values for threshold.
        %
        % setThresholdValues(KYMO, VALUES)
        %   VALUES should be an array with as many elements as the
        %   number of frames.
        % setThresholdValues(KYMO, VAL)
        %   VAL should be a scalar value.

        if isscalar(values)
            values = values * ones(1, frameCount(obj));
        end

        % update local variables
        values = values(:)';
        obj.InitialThresholdValues = values;
        obj.ThresholdValues = values;
    end

    function seg = getSegmentedImage(obj, index)
        % Return the specified frame after smoothing and binarization.

        img = getSmoothedImage(obj, index);
        thresh = obj.ThresholdValues(index);
        seg = img > thresh;
    end

    function computeContours(obj)
        % Compute the contour for each image.

        disp('Contour extraction...');
        % allocate memory for contour array
        nFrames = frameCount(obj);
        contours = cell(nFrames, 1);
        
        % iterate over images
        parfor i = 1:nFrames
            % add black border around each image, to ensure continuous contours
            img0 = getSegmentableImage(obj, i);

            % add one black pixel in each direction
            img = zeros(size(img0) + 2, class(img0));
            img(2:end-1, 2:end-1) = img0;

            % compute contour
            threshold = obj.ThresholdValues(i);
            contours{i} = kymorod.core.image.largestIsocontour(img, threshold);

            fprintf('.');
        end
        fprintf('\n');

        % obj.contourList = contours;
        obj.Contours = contours;
    end

    function contour = getSmoothedContour(obj, index)
        contour = obj.Contours{index};
        smooth = obj.Parameters.ContourSmoothingSize;
        contour = kymorod.core.geom.smoothContour(contour, smooth);
    end

    function computeMidlines(obj)
        % Compute all midlines from smoothed contours.

        disp('Computation of midlines');

        % retrieve processing options
        smooth = obj.Parameters.ContourSmoothingSize;
        origin = lower(obj.Parameters.SkeletonOrigin);

        % allocate memory for results
        nFrames = frameCount(obj);
        midlines = cell(nFrames, 1);
        
        contours = obj.Contours;

        t0 = tic;
        parfor i = 1:nFrames
            % extract current contour
            contour = contours{i};
            if smooth ~= 0
                contour = kymorod.core.geom.smoothContour(contour, smooth);
            end

            % compute the midline of current contour
            midlines{i} = kymorod.core.geom.contourMidline(contour, origin)

            fprintf('.');
        end
        fprintf('\n');
        
        % copy array of midlines within analysis instance 
        obj.Midlines = midlines;

        t1 = toc(t0);
        disp(sprintf('elapsed time: %6.2f mn', t1 / 60)); %#ok<DSPS>
    end

    function alignedMidlineAbscissas(obj)
        % Align the curvlinear abscissas of the different midlines.

        disp('Alignment of Midline abscissas');
        % Alignment of all the curvilinear abscissas
        Sa = kymorod.core.alignMidlineAbscissas(obj);
        obj.AlignedAbscissas = Sa;
    end

    function computeAnglesAndCurvatures(obj)
        % Compute angle and curvature of all skeletons.

        disp('Compute angles and curvature');

        % get input data
        midlines = obj.Midlines;

        % size option for computing curvature
        ws = obj.Parameters.CurvatureWindowSize;

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
        obj.VerticalAngles = A;

        computeGeometricKymographs(obj);
    end

    function computeGeometricKymographs(obj)

        % retrieve parameters
        nFrames = frameCount(obj.InputImages);
        calib = obj.InputImages.Calibration;
        nPos = obj.Parameters.KymographAbscissaSize;

        % retrieve data
        Sa = obj.AlignedAbscissas;
        radiusValues = cell(1, nFrames);
        curvatureValues = cell(1, nFrames);
        for i = 1:nFrames
            midline = calibrate(obj.Midlines{i}, calib);
            radiusValues{i} = midline.Radiusses;
            curvatureValues{i} = midline.Curvatures;
        end
        verticalAngleValues = obj.VerticalAngles;

        inputImages = obj.InputImages;
        timeInterval = calib.TimeInterval;
        frameStep = inputImages.ImageList.IndexStep;

        % compute axis for time
        timeData = (0:(nFrames-1)) * timeInterval * frameStep;
        timeAxis = kymorod.core.PlotAxis(timeData, ...
            'Name', 'Time', ...
            'Unit', calib.TimeIntervalUnit);

        % compute axis for curvilinear abscissa
        Smax = max(cellfun(@max, Sa));
        Smin = min(cellfun(@min, Sa));
        positions = linspace(Smin, Smax, nPos);
        posAxis = kymorod.core.PlotAxis(positions, ...
            'Name', 'Curvilinear Abscissa', ...
            'Unit', 'mm');

        % compute kymographs
        obj.RadiusKymograph = kymorod.core.Kymograph.fromValues(...
            Sa, radiusValues, nPos, ....
            'Name', 'Radius', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
        obj.VerticalAngleKymograph = kymorod.core.Kymograph.fromValues(...
            Sa, verticalAngleValues, nPos, ...
            'Name', 'Vertical Angle', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
        obj.CurvatureKymograph = kymorod.core.Kymograph.fromValues(...
            Sa, curvatureValues, nPos, ...
            'Name', 'Curvature', ...
            'TimeAxis', timeAxis, 'PositionAxis', posAxis);
    end

    function img = getDisplacementImage(obj, index)
        % Return the image for computing displacement.

        img = getFrameImage(obj.InputImages, index);

        if ndims(img) > 2 %#ok<ISMAT>
            switch lower(obj.Parameters.DisplacementImageChannel)
                case 'red',     img = img(:,:,1);
                case 'green',   img = img(:,:,2);
                case 'blue',    img = img(:,:,3);
            end
        end

        % eventually converts to uint8
        if isa(img, 'uint16') && ndims(img) == 2 %#ok<ISMAT>
            img = kymorod.core.image.adjustDynamic(img, 0.1);
        end
    end

    function computeDisplacements(obj)
        % Compute displacements between all couples of frames.

        disp('Displacement');

        % retrieve settings
        step = obj.Parameters.DisplacementStep;

        % allocate memory for result
        nFrames = frameCount(obj);
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

        obj.Displacements = displList;
    end

    function displ = computeFrameDisplacement(obj, i1, i2)
        % Compute displacement between two frames.
        %
        % Usage:
        % DISPL = computeFrameDisplacement(ANL, IND1, IND2);
        %
        % Assumes the class field 'Displacements' was alread initialized to
        % the required size.

        % retrieve midlines
        mid1 = obj.Midlines{i1};
        mid2 = obj.Midlines{i2};
        S1 = obj.AlignedAbscissas{i1};
        S2 = obj.AlignedAbscissas{i2};
        % create new midlines using aligned abscissas
        mid1 = kymorod.data.Midline(mid1.Coords, S1);
        mid2 = kymorod.data.Midline(mid2.Coords, S2);

        % local data
        img1 = getDisplacementImage(obj, i1);
        img2 = getDisplacementImage(obj, i2);

        % retrieve parameters
        ws = obj.Parameters.MatchingWindowRadius;
        calib = obj.InputImages.Calibration;
        maxDeltaS = 4 * ws * calib.PixelSize / 1000;

        % check that the two midlines are large enough
        if length(S1) <= 2*80 || length(S2) <= 2*80
            % case of too small skeletons
            msg = sprintf('Midline %d or %d has not enough vertices', i1, i2);
            warning(msg); %#ok<SPWRN>
            displ = [1 0; 1 1];
            return;
        end

        % perform computation of displacement
        displ = kymorod.core.computeDisplacements(mid1, mid2, img1, img2, ws, maxDeltaS);

        % check result is large enough
        if size(displ, 1) == 1
            msg = sprintf('Displacement from frame %d to frame %d resulted in small array', i1, i2);
            warning(msg); %#ok<SPWRN>
            displ = [1 0;1 1];
            return;
        end
    end

    function computeFilteredDisplacements(obj)
        % Apply filtering to all displacement signals.
        
        disp('Filter Displacements');

        % retrieve computation options
        displ = obj.Displacements;
        LX = obj.Parameters.DisplacementSpatialSmoothing;
        LY = obj.Parameters.DisplacementValueSmoothing;
        dx = obj.Parameters.DisplacementResampling;

        % initialize results
        nFrames = length(displ);
        displf = cell(nFrames, 1);

        % iterate over displacement curves
        parfor i = 1:nFrames
            displf{i} = kymorod.core.filterDisplacements(displ{i}, LX, LY, dx);
        end

        % store results
        obj.FilteredDisplacements = displf;
    end

    function computeElongations(obj)
        % Compute elongation curves for all skeleton curves.
        %
        %   computeElongations(KYMO)
        %

        % Elongation
        disp('Elongation');

        % check filtered displacements have been computed
        if isempty(obj.FilteredDisplacements)
            computeFilteredDisplacements(obj);
        end

        % initialize results
        nFrames = length(obj.Displacements);
        Elg = cell(nFrames, 1);

        % iterate over displacement curves
        parfor i = 1:nFrames
            Elg{i} = computeFrameElongation(obj, i);
        end

        % store results
        obj.Elongations = Elg;

        computeElongationKymograph(obj);
    end

    function elong = computeFrameElongation(obj, index)
        % Compute elongation curve for a specific frame.
        %
        % ELG = computeFrameElongation(KYMO, INDEX)
        %   ELG: array of elongation
        
        % get current array of displacement
        displ = obj.FilteredDisplacements{index};

        % check validity of size
        if length(displ) <= 20
            elong = [0 0;1 0];
            return;
        end

        % get some settings
        ws      = obj.Parameters.ElongationDerivationRadius;
        t0      = obj.InputImages.Calibration.TimeInterval;
        step    = obj.Parameters.DisplacementStep;

        % time interval between frames
        deltaT = t0 * step / 60;

        % Compute elongation by spatial derivation of the displacement
        elong = kymorod.core.computeElongations(displ, ws, deltaT);
    end

    function computeElongationKymograph(obj)
        % Compute elongation kymograph.
        %
        %   computeElongationKymograph(KYMO)
        %

        % retrieve results
        Elg = obj.Elongations;

        %  Space-time mapping
        nPos = obj.Parameters.KymographAbscissaSize;

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

        % create kymograph
        obj.ElongationKymograph = kymorod.core.Kymograph.fromValues(S, A, nPos, ...
            'Name', 'Elongation');

        % retrieve axes from previous kymograph
        obj.ElongationKymograph.TimeAxis = obj.RadiusKymograph.TimeAxis;
        obj.ElongationKymograph.PositionAxis = obj.RadiusKymograph.PositionAxis;
    end
    
end


%% Serialization methods
methods
    function write(obj, fileName, varargin)
        % WRITE Write object instance into a JSON file.
        % Requires implementation of the "toStruct" method.
        if exist('savejson', 'file') == 0
            error('Requires the jsonlab library');
        end
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end
    
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization.
        
        str = struct('Type', 'kymorod.app.Analysis');
        propNames = properties(obj);
        for i = 1:length(propNames)
            name = propNames{i};
            
            if strcmpi(name, 'Parameters')
                str.Parameters = toStruct(obj.Parameters);
            elseif strcmpi(name, 'InputImages')
                str.InputImages = toStruct(obj.InputImages);
            % elseif strcmpi(name, 'DisplacementImages') && ~isempty(obj.(name))
            %     str.DisplacementImages = toStruct(obj.DisplacementImages);
            % elseif strcmpi(name, 'ProcessingStep')
            %     str.ProcessingStep = char(obj.ProcessingStep);
            % elseif isa(obj.(name), 'kr.app.DisplayStyle')
            %     str.(name) = toStruct(obj.(name));
            else
                str.(name) = obj.(name);
            end
        end
    end
end

methods (Static)
    function style = read(fileName)
        % Reads information from a file in JSON format.
        if exist('loadjson', 'file') == 0
            error('Requires the jsonlab library');
        end
        style = kymorod.app.Analysis.fromStruct(loadjson(fileName));
    end
    
    function obj = fromStruct(str)
        % Create a new instance from a structure.
        
        obj = kymorod.app.Analysis();
        fieldNames = fields(str);
        for i = 1:length(fieldNames)
            name = fieldNames{i};
            if strcmpi(name, 'Type')
                continue;
            elseif strcmpi(name, 'Parameters')
                obj.Parameters = kymorod.app.Parameters.fromStruct(str.Parameters);
            elseif strcmpi(name, 'InputImages')
                obj.InputImages = kymorod.data.TimeLapseImage.fromStruct(str.InputImages);
            % elseif strcmpi(name, 'DisplacementImages')
            %     if ~isempty(str.DisplacementImages)
            %         obj.DisplacementImages = kr.app.TimeLapseImage.fromStruct(str.DisplacementImages);
            %     end
            % elseif strcmpi(name, 'ProcessingStep')
            %     obj.ProcessingStep = kr.app.ProcessingStep.parse(str.ProcessingStep);
            % elseif isstruct(str.(name))
            %     field = str.(name);
            %     if ~isfield(field, 'Type')
            %         error('Can not parse structures without "Type" field');
            %     end
            %     if strcmp(field.Type, 'kr.app.DisplayStyle')
            %         obj.(name) = kr.app.DisplayStyle.fromStruct(field);
            %     else
            %         error('Uanble to parse structure with type: %s', field.Type);
            %     end
            else
                obj.(name) = str.(name);
            end
        end
    end
end

end % end classdef

