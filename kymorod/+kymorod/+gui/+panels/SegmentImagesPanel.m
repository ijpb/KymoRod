classdef SegmentImagesPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class SegmentImagesPanel
%
%   Example
%   SegmentImagesPanel
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

    SmoothingMethodNames = {'None', 'Box Filter', 'Gaussian Filter'};
    SegmentationStrategyNames = {'Auto.', 'Manual'};
    AutoThresholdMethodNames = {'MaxEntropy', 'Otsu'};

    Padding = 5;

end % end properties


%% Constructor
methods
    function obj = SegmentImagesPanel(frame, varargin)
        % Constructor for SegmentImagesPanel class.

        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        smoothPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Smoothing');
        smoothLayout = uix.VBox('Parent', smoothPanel);

        smoothMethodLine = uix.HBox(...
            'Parent', smoothLayout, 'Padding', obj.Padding);
        uicontrol('Parent', smoothMethodLine, ...
            'Style', 'text', ...
            'String', 'Method: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SmoothMethodChoice = uicontrol(...
            'Parent', smoothMethodLine, ...
            'Style', 'popupmenu', ...
            'String', obj.SmoothingMethodNames, ...
            'Callback', @obj.onSmoothingMethodChanged);
        smoothMethodLine.Widths = [-1 -1];

        smoothRadiusLine = uix.HBox(...
            'Parent', smoothLayout, 'Padding', obj.Padding);
        obj.Handles.SmoothMethodLabel = uicontrol(...
            'Parent', smoothRadiusLine, ...
            'Style', 'text', ...
            'String', 'Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SmoothMethodChoice = uicontrol(...
            'Parent', smoothRadiusLine, ...
            'Style', 'edit', ...
            'String', '1', ...
            'Callback', @obj.onSmoothingRadiusChanged);
        smoothRadiusLine.Widths = [-1 -1];
        smoothLayout.Heights = [30 30];

        segmentPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Segmentation');
        segmentLayout = uix.VBox('Parent', segmentPanel);

        segmentationStrategyLine = uix.HBox(...
            'Parent', segmentLayout, 'Padding', obj.Padding);
        uicontrol('Parent', segmentationStrategyLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Strategy: ');
        obj.Handles.SegmentationStrategyChoice = uicontrol(...
            'Parent', segmentationStrategyLine, ...
            'Style', 'popupmenu', ...
            'String', obj.SegmentationStrategyNames, ...
            'Callback', @obj.onThresholdStrategyChanged);
        segmentationStrategyLine.Widths = [-1 -1];
        
        autoThresholdMethodLine = uix.HBox(...
            'Parent', segmentLayout, 'Padding', obj.Padding);
        uicontrol('Parent', autoThresholdMethodLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Strategy: ');
        obj.Handles.AutoThresholdMethodChoice = uicontrol(...
            'Parent', autoThresholdMethodLine, ...
            'Style', 'popupmenu', ...
            'String', obj.AutoThresholdMethodNames, ...
            'Callback', @obj.onAutoThresholdMethodChanged);
        autoThresholdMethodLine.Widths = [-1 -1];
        
        manualThresholdLine = uix.HBox(...
            'Parent', segmentLayout, 'Padding', obj.Padding);
        obj.Handles.ManualThresholdValueLabel = uicontrol(...
            'Parent', manualThresholdLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Threshold Value: ');
        obj.Handles.ManualThresholdValueEdit = uicontrol(...
            'Parent', manualThresholdLine, ...
            'Style', 'edit', ...
            'String', '1', ...
            'Callback', @obj.onManualThresholdValueChanged);
        manualThresholdLine.Widths = [-1 -1];
        
        segmentLayout.Heights = [30 30 30];

        uix.Empty('Parent', layout);
        layout.Heights = [85 110 -1];
    end
end % end methods

methods
    function onSmoothingMethodChanged(obj, src, ~)
        index = get(src, 'Value');
        methodList =  {'None', 'BoxFilter', 'Gaussian'};
        methodName = methodList{index};
        obj.Frame.Analysis.Parameters.AutoThresholdMethod = methodName;
    end

    function onSmoothingRadiusChanged(obj, src, ~)
        radius = str2double(get(src, 'String'));
        if isnan(radius)
            return;
        end
        radius = round(radius);
        
        obj.Frame.Analysis.Parameters.ImageSmoothingRadius = radius;

        set(src, 'String', num2str(radius));
    end

    function onThresholdStrategyChanged(obj, src, ~)
        index = get(src, 'Value');
        strategyList = {'Auto', 'Manual'};
        strategyName = strategyList{index};
        obj.Frame.Analysis.Parameters.ThresholdStrategy = strategyName;
    end

    function onManualThresholdValueChanged(obj, src, ~)
        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.ManualThresholdValue = value;

        set(src, 'String', num2str(value));
    end

    function onAutoThresholdMethodChanged(obj, src, ~)
        index = get(src, 'Value');
        methodList = {'MaxEntropy', 'Otsu'};
        methodName = methodList{index};
        obj.Frame.Analysis.Parameters.AutoThresholdMethod = methodName;

    end
end

end % end classdef

