classdef UserPrefs < handle
% USERPREFS Keep global settings and user preferences of KymoRod App.
%
%   Class UserPrefs
%
%   Example
%   UserPrefs
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-27,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    LastOpenDir = '';

    LastSaveDir = '';

    % The parameters for an analysis.
    Parameters;

end % end properties


%% Constructor
methods
    function obj = UserPrefs(varargin)
        % Constructor for UserPrefs class.

        % initialize default analysis parameters
        obj.Parameters = kymorod.app.Parameters;
    end

end % end constructors


%% input / output methods
methods
    function save(obj)
        % SAVE Save user preferences into user config file.
        %
        % usage:
        %   save(prefs)
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

        fileName = fullfile(path, 'userPrefs.txt');

        % open in text mode, erasing content if it exists
        f = fopen(fileName, 'w+t');
        if f == -1
            errordlg(['Could not open file for writing: ' fileName]);
            return;
        end

        % spatial calibration of input images
        fprintf(f, 'LastOpenDir = %s\n', obj.LastOpenDir);
        fprintf(f, 'LastSaveDir = %s\n', obj.LastSaveDir);
        fprintf(f, '\n');

        % writeToFile(obj.Parameters, f);
        fprintf(f, 'MidlineImageChannel = %s\n', obj.Parameters.MidlineImageChannel);

        % smoothing of images before threshold
        fprintf(f, 'ImageSmoothingMethodName = %s\n', obj.Parameters.ImageSmoothingMethodName);
        fprintf(f, 'ImageSmoothingRadius = %d\n', obj.Parameters.ImageSmoothingRadius);

        fprintf(f, 'ThresholdStrategy = %s\n', obj.Parameters.ThresholdStrategy);
        fprintf(f, 'AutoThresholdMethod = %s\n', obj.Parameters.AutoThresholdMethod);
        fprintf(f, 'ManualThresholdValue = %d\n', obj.Parameters.ManualThresholdValue);

        % length of window for smoothing coutours and computing midlines
        fprintf(f, 'ContourSmoothingSize = %d\n', obj.Parameters.ContourSmoothingSize);
        fprintf(f, 'SkeletonOrigin = %s\n', obj.Parameters.SkeletonOrigin);
        fprintf(f, '\n');

        % smoothing window size for computation of curvature
        fprintf(f, 'CurvatureWindowSize = %d\n', obj.Parameters.CurvatureWindowSize);
        fprintf(f, 'KymographAbscissaSize = %d\n', obj.Parameters.KymographAbscissaSize);
        fprintf(f, '\n');

        % info for computation of displacement
        fprintf(f, 'DisplacementImageChannel = %s\n', obj.Parameters.DisplacementImageChannel);
        fprintf(f, 'DisplacementStep = %d\n', obj.Parameters.DisplacementStep);
        fprintf(f, 'MatchingWindowRadius = %d\n', obj.Parameters.MatchingWindowRadius);

        % info for filtering displacement curves
        fprintf(f, 'DisplacementSpatialSmoothing = %f\n', obj.Parameters.DisplacementSpatialSmoothing);
        fprintf(f, 'DisplacementValueSmoothing = %f\n', obj.Parameters.DisplacementValueSmoothing);
        fprintf(f, 'DisplacementResampling = %f\n', obj.Parameters.DisplacementResampling);
        fprintf(f, 'ElongationDerivationRadius = %d\n', obj.Parameters.ElongationDerivationRadius);
        fprintf(f, '\n');

        % info for computing intensity kymograph
        fprintf(f, 'IntensityImageChannel = %s\n', obj.Parameters.IntensityImageChannel);

        % close the file
        fclose(f);
    end
end % end of I/O non static methods

% Static methods
methods (Static)
    function prefs = load()
        % Initialize a new instance of "UserPrefs" from saved file.
        %
        % usage:
        % prefs = KymoRodUserPrefs.load();
        % parentDir = prefs.lastOpenDir;
        %
        % See also
        %   save

        % create new empty class
        prefs = kymorod.app.UserPrefs();

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

        fileName = fullfile(path, 'userPrefs.txt');

        % open in text reading mode
        f = fopen(fileName, 'rt');
        if f == -1
            error('enable to open user preference file');
        end

        params = prefs.Parameters;

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
            if strcmpi(key, 'LastOpenDir')
                prefs.LastOpenDir = value;
            elseif strcmpi(key, 'LastSaveDir')
                prefs.LastSaveDir = value;

            elseif strcmpi(key, 'MidlineImageChannel')
                params.MidlineImageChannel = value;

            elseif strcmpi(key, 'ImageSmoothingMethodName')
                params.ImageSmoothingMethodName = value;
            elseif strcmpi(key, 'ImageSmoothingRadius')
                params.ImageSmoothingRadius = str2double(value);

            elseif strcmpi(key, 'ThresholdStrategy')
                params.ThresholdStrategy = value;
            elseif strcmpi(key, 'AutoThresholdMethod')
                params.AutoThresholdMethod = value;
            elseif strcmpi(key, 'ManualThresholdValue')
                params.ManualThresholdValue = str2double(value);

            elseif strcmpi(key, 'ContourSmoothingSize')
                params.ContourSmoothingSize = str2double(value);
            elseif strcmpi(key, 'SkeletonOrigin')
                params.SkeletonOrigin = value;

            elseif strcmpi(key, 'CurvatureWindowSize')
                params.CurvatureWindowSize = str2double(value);
            elseif strcmpi(key, 'KymographAbscissaSize')
                params.KymographAbscissaSize = str2double(value);

            elseif strcmpi(key, 'DisplacementImageChannel')
                params.DisplacementImageChannel = value;
            elseif strcmpi(key, 'DisplacementStep')
                params.DisplacementStep = str2double(value);
            elseif strcmpi(key, 'MatchingWindowRadius')
                params.MatchingWindowRadius = str2double(value);

            elseif strcmpi(key, 'DisplacementSpatialSmoothing')
                params.DisplacementSpatialSmoothing = str2double(value);
            elseif strcmpi(key, 'DisplacementValueSmoothing')
                params.DisplacementValueSmoothing = str2double(value);
            elseif strcmpi(key, 'DisplacementResampling')
                params.DisplacementResampling = str2double(value);
            elseif strcmpi(key, 'ElongationDerivationRadius')
                params.ElongationDerivationRadius = str2double(value);

            elseif strcmpi(key, 'IntensityImageChannel')
                params.IntensityImageChannel = value;

            else
                warning(['Unrecognized preference parameter: ' key]);
            end
        end

        % close file
        fclose(f);
    end
end

end % end classdef
