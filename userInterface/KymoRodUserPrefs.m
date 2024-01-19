classdef KymoRodUserPrefs < handle
% KymoRodUserPrefs Keep global settings and user preferences of KymoRod App. 
%
%   Class KymoRodUserPrefs
%
%   Example
%   KymoRodUserPrefs
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-01-18,    using Matlab 23.2.0.2459199 (R2023b) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    lastOpenDir = '';

    % spatial calibration of input images
    pixelSize = 1000 / 253;

    % The unit name for spatial calibration. Default value is 'µm'
    pixelSizeUnit = 'µm';

    % time interval between two frames. Default value is 10.
    timeInterval = 10;
    % The unit name for time interval. Default value is 'min'
    timeIntervalUnit = 'min';

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
    
    % length of window for smoothing coutours. Default value is 20.
    contourSmoothingSize = 20;

    % location of the first point of the skeleton.
    % Can be one of 'bottom' (default), 'top', 'left', 'right'.
    firstPointLocation = 'bottom';

    % smoothing window size for computation of curvature.
    % Default value is 10.
    curvatureSmoothingSize = 10;

    % the number of points used to discretize signal on each skeleton.
    % Default value is 500.
    finalResultLength = 500;

    % in case of color images, specify the channel used for computing
    % displacement
    displacementChannel = 'red';

    % length of displacement (in pixels). Default value is 2.
    displacementStep = 2;

    % size of first correlation window (in pixels). Default value is 5.
    windowSize1 = 5;

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

    intensityImagesChannel = 'red';


end % end properties


%% Constructor
methods
    function obj = KymoRodUserPrefs(varargin)
        % Constructor for KymoRodUserPrefs class.

    end

end % end constructors



%% input / output methods
methods
    function save(obj)
        % Save save user preferences into user config file.
        %
        % usage:
        %   save()
        %
        % See also
        %   load

        % determines file name
        try
            % use 'getuserdir' function in lib directory
            path = fullfile(getuserdir, '.kymorod');
        catch ME
            error('Error using the getuserdir function, please check it is on the path');
        end

        if ~exist(path, 'dir')
            status = mkdir(path);
            if status == 0
                error('Unable to create directory foir user preferences');
            end
        end

        fileName = fullfile(path, 'kymorod_prefs.txt');

        % open in text mode, erasing content if it exists
        f = fopen(fileName, 'w+t');
        if f == -1
            errordlg(['Could not open file for writing: ' fileName]);
            return;
        end

        % spatial calibration of input images
        fprintf(f, 'lastOpenDir = %s\n', obj.lastOpenDir);
        fprintf(f, '\n');

        % spatial calibration of input images
        fprintf(f, 'pixelSize = %g\n', obj.pixelSize);
        fprintf(f, 'pixelSizeUnit = %s\n', obj.pixelSizeUnit);
        
        % time interval between two frames
        fprintf(f, 'timeInterval = %g\n', obj.timeInterval);
        fprintf(f, 'timeIntervalUnit = %s\n', obj.timeIntervalUnit);
        fprintf(f, '\n');

        % smoothing of images before threshold
        fprintf(f, 'imageSmoothingMethod = %s\n', obj.imageSmoothingMethod);
        fprintf(f, 'imageSmoothingRadius = %d\n', obj.imageSmoothingRadius);

        % the method used for computing thresholds
        fprintf(f, 'imageSegmentationChannel = %s\n', obj.imageSegmentationChannel);
        fprintf(f, 'thresholdStrategy = %s\n', obj.thresholdStrategy);
        fprintf(f, 'thresholdMethod = %s\n', obj.thresholdMethod);

        % length of window for smoothing coutours
        fprintf(f, 'contourSmoothingSize = %d\n', obj.contourSmoothingSize);
        fprintf(f, '\n');

        % information for computation of skeletons
        fprintf(f, 'firstPointLocation = %s\n', obj.firstPointLocation);
        fprintf(f, '\n');

        % smoothing window size for computation of curvature
        fprintf(f, 'curvatureSmoothingSize = %d\n', obj.curvatureSmoothingSize);
        fprintf(f, 'finalResultLength = %d\n', obj.finalResultLength);
        fprintf(f, '\n');

        % info for computation of displacement
        fprintf(f, 'displacementChannel = %s\n', obj.displacementChannel);
        fprintf(f, 'displacementStep = %d\n', obj.displacementStep);
        fprintf(f, 'windowSize1 = %d\n', obj.windowSize1);

        % info for filtering displacement curves
        fprintf(f, 'displacementSpatialSmoothing = %f\n', obj.displacementSpatialSmoothing);
        fprintf(f, 'displacementValueSmoothing = %f\n', obj.displacementValueSmoothing);
        fprintf(f, 'displacementResamplingDistance = %f\n', obj.displacementResamplingDistance);
        fprintf(f, 'windowSize2 = %d\n', obj.windowSize2);
        fprintf(f, '\n');

        % info for computing intensity kymograph
        fprintf(f, 'intensityImagesChannel = %s\n', obj.intensityImagesChannel);

        % close the file
        fclose(f);
    end
end % end of I/O non static methods

% Static methods
methods (Static)
    function prefs = load()
        % Initialize a new instance of "KymoRodUserPrefs" from saved file.
        %
        % usage:
        % prefs = KymoRodUserPrefs.load();
        % parentDir = prefs.lastOpenDir;
        %
        % See also
        %   save

        % create new empty class
        prefs = KymoRodUserPrefs();

        % determines file name
        try
            % use 'getuserdir' function in lib directory
            path = fullfile(getuserdir, '.kymorod');
        catch ME
            error('Error using the getuserdir function');
        end

        if ~exist(path, 'dir')
            return;
        end

        fileName = fullfile(path, 'kymorod_prefs.txt');

        % open in text reading mode
        f = fopen(fileName, 'rt');
        if f == -1
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
            if strcmpi(key, 'lastOpenDir')
                prefs.lastOpenDir = value;

            elseif strcmpi(key, 'pixelSize')
                prefs.pixelSize = str2double(value);
            elseif strcmpi(key, 'pixelSizeUnit')
                prefs.pixelSizeUnit = value;
            elseif strcmpi(key, 'timeInterval')
                prefs.timeInterval = str2double(value);
            elseif strcmpi(key, 'timeIntervalUnit')
                prefs.timeIntervalUnit = value;

            elseif strcmpi(key, 'imageSmoothingMethod')
                prefs.imageSmoothingMethod = value;
            elseif strcmpi(key, 'imageSmoothingRadius')
                prefs.imageSmoothingRadius = str2double(value);
            elseif strcmpi(key, 'imageSegmentationChannel')
                prefs.imageSegmentationChannel = value;
            elseif strcmpi(key, 'thresholdStrategy')
                prefs.thresholdStrategy = value;
            elseif strcmpi(key, 'thresholdMethod')
                prefs.thresholdMethod = value;

            elseif strcmpi(key, 'contourSmoothingSize')
                prefs.contourSmoothingSize = str2double(value);
            elseif strcmpi(key, 'firstPointLocation')
                prefs.firstPointLocation = value;

            elseif strcmpi(key, 'curvatureSmoothingSize')
                prefs.curvatureSmoothingSize = str2double(value);
            elseif strcmpi(key, 'finalResultLength')
                prefs.finalResultLength = value;

            elseif strcmpi(key, 'displacementChannel')
                prefs.displacementChannel = value;
            elseif strcmpi(key, 'displacementStep')
                prefs.displacementStep = str2double(value);
            elseif strcmpi(key, 'windowSize1')
                prefs.windowSize1 = str2double(value);

            elseif strcmpi(key, 'displacementSpatialSmoothing')
                prefs.displacementSpatialSmoothing = str2double(value);
            elseif strcmpi(key, 'displacementValueSmoothing')
                prefs.displacementValueSmoothing = str2double(value);
            elseif strcmpi(key, 'displacementResamplingDistance')
                prefs.displacementResamplingDistance = str2double(value);
            elseif strcmpi(key, 'windowSize2')
                prefs.windowSize2 = str2double(value);

            elseif strcmpi(key, 'intensityImagesChannel')
                prefs.intensityImagesChannel = value;

            else
                warning(['Unrecognized preference parameter: ' key]);
            end
        end

        % close file
        fclose(f);
    end
end

end % end classdef

