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
        smoothingLayout = uix.VBox('Parent', smoothPanel);

        smoothingMethodLine = uix.HBox(...
            'Parent', smoothingLayout, 'Padding', obj.Padding);
        uicontrol('Parent', smoothingMethodLine, ...
            'Style', 'text', ...
            'String', 'Method: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SmoothingMethodChoice = uicontrol(...
            'Parent', smoothingMethodLine, ...
            'Style', 'popupmenu', ...
            'String', obj.SmoothingMethodNames, ...
            'Value', 1, ...
            'Callback', @obj.onSmoothingMethodChanged);
        smoothingMethodLine.Widths = [-1 -1];

        smoothingRadiusLine = uix.HBox(...
            'Parent', smoothingLayout, 'Padding', obj.Padding);
        obj.Handles.SmoothingRadiusLabel = uicontrol(...
            'Parent', smoothingRadiusLine, ...
            'Style', 'text', ...
            'String', 'Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SmoothingRadiusEdit = uicontrol(...
            'Parent', smoothingRadiusLine, ...
            'Style', 'edit', ...
            'String', '1', ...
            'Callback', @obj.onSmoothingRadiusChanged);
        smoothingRadiusLine.Widths = [-1 -1];
        smoothingLayout.Heights = [30 30];

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
            'Value', 1, ...
            'Callback', @obj.onThresholdStrategyChanged);
        segmentationStrategyLine.Widths = [-1 -1];
        
        autoThresholdMethodLine = uix.HBox(...
            'Parent', segmentLayout, 'Padding', obj.Padding);
        obj.Handles.AutoThresholdMethodLabel = uicontrol(...
            'Parent', autoThresholdMethodLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Method: ');
        obj.Handles.AutoThresholdMethodChoice = uicontrol(...
            'Parent', autoThresholdMethodLine, ...
            'Style', 'popupmenu', ...
            'String', obj.AutoThresholdMethodNames, ...
            'Value', 1, ...
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
        
        manualThresholdSliderLine = uix.HBox(...
            'Parent', segmentLayout, 'Padding', obj.Padding);
        obj.Handles.ManualThresholdSlider = uicontrol(...
            'Parent', manualThresholdSliderLine, ...
            'Style', 'slider', ...
            'Min', 1, 'Max', 255, ...
            'Value', 150, ...
            'SliderStep', [1 10] ./ 254, ...
            'Callback', @obj.onManualThresholdValueChanged);
        manualThresholdSliderLine.Widths = -1;

        segmentLayout.Heights = [30 30 30 30];

        uix.Empty('Parent', layout);
        layout.Heights = [85 145 -1];

        set(hPanel, 'UserData', obj);
    end

    function select(obj)

        params = obj.Frame.Analysis.Parameters;

        smoothingMethod = params.ImageSmoothingMethodName;
        smoothingIndex = find(strcmpi(smoothingMethod, {'None', 'BoxFilter', 'Gaussian'}));
        set(obj.Handles.SmoothingMethodChoice, 'Value', smoothingIndex);

        radius = params.ImageSmoothingRadius;
        set(obj.Handles.SmoothingRadiusEdit, 'String', num2str(radius));

        segmentationStrategy = params.ThresholdStrategy;
        strategyIndex = find(strcmpi(segmentationStrategy, {'Auto', 'Manual'}));
        set(obj.Handles.SegmentationStrategyChoice, 'Value', strategyIndex);

        thresholdMethod = params.AutoThresholdMethod;
        thresholdIndex = find(strcmpi(thresholdMethod, {'MaxEntropy', 'Otsu'}));
        set(obj.Handles.AutoThresholdMethodChoice, 'Value', thresholdIndex);

        manualThresholdValue = params.ManualThresholdValue;
        set(obj.Handles.ManualThresholdValueEdit, 'String', num2str(manualThresholdValue));
        set(obj.Handles.ManualThresholdSlider, 'Value', manualThresholdValue);

        updateWidgetSelection(obj);

        % ensure validity of segmentation
        if isempty(obj.Frame.Analysis.ThresholdValues)
            updateThresholdValues(obj.Frame.Analysis);
            setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        end

        % update time-lapse display
        obj.Frame.ImageToDisplay = 'Segmented';
        updateTimeLapseDisplay(obj.Frame);
    end

    function updateWidgetSelection(obj)
        params = obj.Frame.Analysis.Parameters;
        if strcmp(params.ThresholdStrategy, 'Auto')
            set([obj.Handles.AutoThresholdMethodLabel obj.Handles.AutoThresholdMethodChoice], 'Enable', 'on')
            set([obj.Handles.ManualThresholdValueLabel ...
                obj.Handles.ManualThresholdValueEdit ...
                obj.Handles.ManualThresholdSlider], 'Enable', 'off')
        else
            set([obj.Handles.AutoThresholdMethodLabel obj.Handles.AutoThresholdMethodChoice], 'Enable', 'off')
            set([obj.Handles.ManualThresholdValueLabel ...
                obj.Handles.ManualThresholdValueEdit ...
                obj.Handles.ManualThresholdSlider], 'Enable', 'on')
        end
    end

    % To be called when the corresponding panel is selected.
    function validateProcess(obj)
        % Ensure contours are computed.
        if isempty(obj.Frame.Analysis.Contours)
            set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
            computeContours(obj.Frame.Analysis);
            setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Contour);
            set(obj.Frame.Handles.NextStepButton, 'Enable', 'on');
        end
    end

end % end methods


%% Callback methods
methods
    function onSmoothingMethodChanged(obj, src, ~)
        index = get(src, 'Value');
        methodList =  {'None', 'BoxFilter', 'Gaussian'};
        methodName = methodList{index};
        obj.Frame.Analysis.Parameters.ImageSmoothingMethodName = methodName;

        % update auto threshold values if necessary
        if strcmpi(obj.Frame.Analysis.Parameters.ThresholdStrategy, 'Auto')
            computeAutoThresholdValues(obj.Frame.Analysis);
        end

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        updateTimeLapseDisplay(obj.Frame);
    end

    function onSmoothingRadiusChanged(obj, src, ~)
        radius = str2double(get(src, 'String'));
        if isnan(radius)
            return;
        end
        radius = round(radius);
        
        obj.Frame.Analysis.Parameters.ImageSmoothingRadius = radius;

        set(src, 'String', num2str(radius));

        % update auto threshold values if necessary
        if strcmpi(obj.Frame.Analysis.Parameters.ThresholdStrategy, 'Auto')
            computeAutoThresholdValues(obj.Frame.Analysis);
        end

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        updateTimeLapseDisplay(obj.Frame);
    end

    function onThresholdStrategyChanged(obj, src, ~)
        index = get(src, 'Value');
        strategyList = {'Auto', 'Manual'};
        strategyName = strategyList{index};
        obj.Frame.Analysis.Parameters.ThresholdStrategy = strategyName;

        updateWidgetSelection(obj);

        % update auto threshold values if necessary
        if strcmpi(strategyName, 'Auto')
            computeAutoThresholdValues(obj.Frame.Analysis);
        end

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        updateTimeLapseDisplay(obj.Frame);
    end

    function onAutoThresholdMethodChanged(obj, src, ~)
        index = get(src, 'Value');
        methodList = {'MaxEntropy', 'Otsu'};
        methodName = methodList{index};
        obj.Frame.Analysis.Parameters.AutoThresholdMethod = methodName;

        % update auto threshold values
        computeAutoThresholdValues(obj.Frame.Analysis);

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        updateTimeLapseDisplay(obj.Frame);
    end

    function onManualThresholdValueChanged(obj, src, ~)
        if src == obj.Handles.ManualThresholdValueEdit
            value = str2double(get(src, 'String'));
            if isnan(value)
                return;
            end
        elseif src == obj.Handles.ManualThresholdSlider
            value = get(src, 'Value');
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.ManualThresholdValue = value;

        set(obj.Handles.ManualThresholdValueEdit, 'String', num2str(value));
        set(obj.Handles.ManualThresholdSlider, 'Value', value);

        setThresholdValues(obj.Frame.Analysis, value);

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Segmentation);
        updateTimeLapseDisplay(obj.Frame);
    end
end

end % end classdef
