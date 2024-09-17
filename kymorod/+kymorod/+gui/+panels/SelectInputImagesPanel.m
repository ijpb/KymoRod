classdef SelectInputImagesPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class SelectInputImagesPanel
%
%   Example
%   SelectInputImagesPanel
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-09-17,    using Matlab 24.2.0.2712019 (R2024b)
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
end % end properties


%% Constructor
methods
    function obj = SelectInputImagesPanel(frame, varargin)
        % Constructor for SelectInputImagesPanel class.

        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        inputImagesPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Input Images');
        inputImagesLayout = uix.VBox('Parent', inputImagesPanel);

        inputDir = obj.Frame.Analysis.InputImages.ImageList.Directory;
        pattern = obj.Frame.Analysis.InputImages.ImageList.FileNamePattern;
        inputDirLine = uix.HBox(...
            'Parent', inputImagesLayout, 'Padding', obj.Padding);
        uicontrol('Parent', inputDirLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Directory: ');
        obj.Handles.InputImagesDirButton = uicontrol(...
            'Parent', inputDirLine, ...
            'Style', 'pushbutton', ...
            'String', 'Change...', ...
            'Callback', @obj.onInputDirectoryChanged);
        inputDirLine.Widths = [-1 -1];

        obj.Handles.InputImagesDirLabel = uicontrol(...
            'Parent', inputImagesLayout, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', inputDir);

        filePatternLine = uix.HBox(...
            'Parent', inputImagesLayout, 'Padding', obj.Padding);
        obj.Handles.FilePatternLabel = uicontrol(...
            'Parent', filePatternLine, ...
            'Style', 'text', ...
            'String', 'Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.FilePatternEdit = uicontrol(...
            'Parent', filePatternLine, ...
            'Style', 'edit', ...
            'String', pattern, ...
            'Callback', @obj.onFilePatternChanged);
        filePatternLine.Widths = [-1 -1];

        calibrationPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Calibration');
        calibrationLayout = uix.VBox('Parent', calibrationPanel);

        pixelSize = obj.Frame.Analysis.InputImages.Calibration.PixelSize;
        pixelSizeUnit = obj.Frame.Analysis.InputImages.Calibration.PixelSizeUnit;
        pixelSizeLine = uix.HBox(...
            'Parent', calibrationLayout, 'Padding', obj.Padding);
        obj.Handles.PixelSizeLabel = uicontrol(...
            'Parent', pixelSizeLine, ...
            'Style', 'text', ...
            'String', 'Pixel Size: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.PixelSizeEdit = uicontrol(...
            'Parent', pixelSizeLine, ...
            'Style', 'edit', ...
            'String', num2str(pixelSize), ...
            'Callback', @obj.onPixelSizeChanged);
        uicontrol(...
            'Parent', pixelSizeLine, ...
            'Style', 'edit', ...
            'String', pixelSizeUnit, ...
            'Callback', @obj.onPixelSizeUnitChanged);
        pixelSizeLine.Widths = [-1 -0.5 -0.5];

        timeInterval = obj.Frame.Analysis.InputImages.Calibration.TimeInterval;
        timeIntervalUnit = obj.Frame.Analysis.InputImages.Calibration.TimeIntervalUnit;
        timeIntervalLine = uix.HBox(...
            'Parent', calibrationLayout, 'Padding', obj.Padding);
        obj.Handles.TimeIntervalLabel = uicontrol(...
            'Parent', timeIntervalLine, ...
            'Style', 'text', ...
            'String', 'Time Interval: ');
        obj.Handles.TimeIntervalEdit = uicontrol(...
            'Parent', timeIntervalLine, ...
            'Style', 'edit', ...
            'String', num2str(timeInterval), ...
            'Callback', @obj.onTimeIntervalChanged);
        uicontrol(...
            'Parent', timeIntervalLine, ...
            'Style', 'edit', ...
            'String', timeIntervalUnit, ...
            'Callback', @obj.onTimeIntervalUnitChanged);
        timeIntervalLine.Widths = [-1 -0.5 -0.5];


        imageIndicesPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Smooth Contour');
        imageIndicesLayout = uix.VBox('Parent', imageIndicesPanel);

        firstIndex = obj.Frame.Analysis.InputImages.ImageList.IndexFirst;
        firstIndexLine = uix.HBox(...
            'Parent', imageIndicesLayout, 'Padding', obj.Padding);
        obj.Handles.FirstIndexLabel = uicontrol(...
            'Parent', firstIndexLine, ...
            'Style', 'text', ...
            'String', 'First Index: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.FirstIndexEdit = uicontrol(...
            'Parent', firstIndexLine, ...
            'Style', 'edit', ...
            'String', num2str(firstIndex), ...
            'Callback', @obj.onFirstIndexChanged);
        firstIndexLine.Widths = [-1 -1];

        lastIndex = obj.Frame.Analysis.InputImages.ImageList.IndexLast;
        lastIndexLine = uix.HBox(...
            'Parent', imageIndicesLayout, 'Padding', obj.Padding);
        obj.Handles.LastIndexLabel = uicontrol(...
            'Parent', lastIndexLine, ...
            'Style', 'text', ...
            'String', 'Last Index: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.LastIndexEdit = uicontrol(...
            'Parent', lastIndexLine, ...
            'Style', 'edit', ...
            'String', num2str(lastIndex), ...
            'Callback', @obj.onLastIndexChanged);
        lastIndexLine.Widths = [-1 -1];

        
        uix.Empty('Parent', layout);
        layout.Heights = [115 85 85 -1];

    end
end % end methods

%% General methods
methods
    function updateImageList(obj)
        % Should be called after change of input directory, or file pattern

        hDialog = msgbox(...
            {'Reading Image File Infos,', 'Please wait...'}, ...
            'Read Images');

        % read new list of image names, used to compute frame number
        fprintf('Read image name list...');
        imageList = obj.Frame.Analysis.InputImages.ImageList;
        computeFileNameList(imageList);
        fprintf(' done\n');

        if ishandle(hDialog)
            close(hDialog);
        end

        if isempty(imageList.FileNameList)
            errordlg({'The chosen directory contains no file.', ...
                'Please choose another one'}, ...
                'Empty Directory Error', 'modal');
            return;
        end

        % update image selection indices
        frameNumber = length(imageList.FileNameList);
        imageList.IndexFirst = 1;
        imageList.IndexLast = frameNumber;
        imageList.IndexStep = 1;

        % update widgets of control panel
        set(obj.Handles.FirstIndexEdit, 'String', '1');
        set(obj.Handles.LastIndexEdit, 'String', num2str(frameNumber));
        
        updateFrameSliderBounds(obj.Frame);
        updateTimeLapseDisplay(obj.Frame);
    end
end


%% Callback methods
methods
    function onInputDirectoryChanged(obj, src, ~) %#ok<INUSD>
        % open a dialog to select input image folder, restricting type to images
        folderName = obj.Frame.Analysis.InputImages.ImageList.Directory;
        [fileName, folderName] = uigetfile(...
            {'*.tif;*.jpg;*.png;*.gif', 'All Image Files';...
            '*.tif;*.tiff;*.gif', 'Tagged Image Files (*.tif)';...
            '*.jpg;', 'JPEG images (*.jpg)';...
            '*.*','All Files' }, ...
            'Select Input Folder', ...
            fullfile(folderName, '*.*'));

        % check if cancel button was selected
        if fileName == 0
            return;
        end

        obj.Frame.Analysis.InputImages.ImageList.Directory = folderName;
        obj.Frame.Gui.UserPrefs.LastOpenDir = folderName;

        set(obj.Handles.InputImagesDirLabel, 'String', folderName);

        % recompute indices and update display
        updateImageList(obj);
    end

    function onFilePatternChanged(obj, src, ~)
        pattern = strtrim(get(src, 'String'));
        obj.Frame.Analysis.InputImages.ImageList.FileNamePattern = pattern;

        % recompute indices and update display
        updateImageList(obj);
    end

    function onPixelSizeChanged(obj, src, ~)
        size = str2double(get(src, 'String'));
        if isnan(size)
            return;
        end
        obj.Frame.Analysis.InputImages.Calibration.PixelSize = size;
    end

    function onPixelSizeUnitChanged(obj, src, ~)
        unit = strtrim(get(src, 'String'));
        obj.Frame.Analysis.InputImages.Calibration.PixelSizeUnit = unit;
    end

    function onTimeIntervalChanged(obj, src, ~)
        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        obj.Frame.Analysis.InputImages.Calibration.TimeInterval = value;
    end

    function onTimeIntervalUnitChanged(obj, src, ~)
        unit = strtrim(get(src, 'String'));
        obj.Frame.Analysis.InputImages.Calibration.TimeIntervalUnit = unit;
    end

    function onFirstIndexChanged(obj, src, ~)
        index = str2double(get(src, 'String'));
        if isnan(index) || index < 1
            return;
        end
        obj.Frame.Analysis.InputImages.ImageList.IndexFirst = index;
    end

    function onLastIndexChanged(obj, src, ~)
        index = str2double(get(src, 'String'));
        if isnan(index) || index < 1
            return;
        end
        obj.Frame.Analysis.InputImages.ImageList.IndexLast = index;
    end
end

end % end classdef

