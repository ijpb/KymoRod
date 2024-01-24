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
    inputImagesFilePattern = '*.*';

    inputImagesLazyLoading = true;

    % Settings for an analysis.
    settings;
end % end properties


%% Constructor
methods
    function obj = KymoRodUserPrefs(varargin)
        % Constructor for KymoRodUserPrefs class.

        % initialize default settings
        obj.settings = KymoRodSettings;
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

        fileName = fullfile(path, 'kymorod_prefs.txt');

        % open in text mode, erasing content if it exists
        f = fopen(fileName, 'w+t');
        if f == -1
            errordlg(['Could not open file for writing: ' fileName]);
            return;
        end

        % spatial calibration of input images
        fprintf(f, 'lastOpenDir = %s\n', obj.lastOpenDir);
        fprintf(f, 'inputImagesFilePattern = %s\n', obj.inputImagesFilePattern);
        fprintf(f, 'inputImagesLazyLoading = %s\n', booleanToString(obj.inputImagesLazyLoading));
        fprintf(f, '\n');

        writeSettings(obj.settings, f);

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
            elseif strcmpi(key, 'inputImagesFilePattern')
                prefs.inputImagesFilePattern = value;
            elseif strcmpi(key, 'inputImagesLazyLoading')
                prefs.inputImagesLazyLoading = strcmp(value, 'true');

            elseif strcmpi(key, 'pixelSize')
                prefs.settings.pixelSize = str2double(value);
            elseif strcmpi(key, 'pixelSizeUnit')
                prefs.settings.pixelSizeUnit = value;
            elseif strcmpi(key, 'timeInterval')
                prefs.settings.timeInterval = str2double(value);
            elseif strcmpi(key, 'timeIntervalUnit')
                prefs.settings.timeIntervalUnit = value;

            elseif strcmpi(key, 'imageSmoothingMethod')
                prefs.settings.imageSmoothingMethod = value;
            elseif strcmpi(key, 'imageSmoothingRadius')
                prefs.settings.imageSmoothingRadius = str2double(value);
            elseif strcmpi(key, 'imageSegmentationChannel')
                prefs.settings.imageSegmentationChannel = value;
            elseif strcmpi(key, 'thresholdStrategy')
                prefs.settings.thresholdStrategy = value;
            elseif strcmpi(key, 'thresholdMethod')
                prefs.settings.thresholdMethod = value;

            elseif strcmpi(key, 'contourSmoothingSize')
                prefs.settings.contourSmoothingSize = str2double(value);
            elseif strcmpi(key, 'firstPointLocation')
                prefs.settings.firstPointLocation = value;

            elseif strcmpi(key, 'curvatureSmoothingSize')
                prefs.settings.curvatureSmoothingSize = str2double(value);
            elseif strcmpi(key, 'finalResultLength')
                prefs.settings.finalResultLength = value;

            elseif strcmpi(key, 'displacementChannel')
                prefs.settings.displacementChannel = value;
            elseif strcmpi(key, 'displacementStep')
                prefs.settings.displacementStep = str2double(value);
            elseif strcmpi(key, 'windowSize1')
                prefs.settings.windowSize1 = str2double(value);

            elseif strcmpi(key, 'displacementSpatialSmoothing')
                prefs.settings.displacementSpatialSmoothing = str2double(value);
            elseif strcmpi(key, 'displacementValueSmoothing')
                prefs.settings.displacementValueSmoothing = str2double(value);
            elseif strcmpi(key, 'displacementResamplingDistance')
                prefs.settings.displacementResamplingDistance = str2double(value);
            elseif strcmpi(key, 'windowSize2')
                prefs.settings.windowSize2 = str2double(value);

            elseif strcmpi(key, 'intensityImagesChannel')
                prefs.settings.intensityImagesChannel = value;

            else
                warning(['Unrecognized preference parameter: ' key]);
            end
        end

        % close file
        fclose(f);
    end
end

end % end classdef

%% some utility methods
function string = booleanToString(bool)
if bool
    string = 'true';
else
    string = 'false';
end
end
    
