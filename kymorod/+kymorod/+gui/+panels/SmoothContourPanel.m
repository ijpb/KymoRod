classdef SmoothContourPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class SmoothContourPanel
%
%   Example
%   SmoothContourPanel
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
    function obj = SmoothContourPanel(frame, varargin)
        % Constructor for SmoothContourPanel class.

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
            'Title', 'Smooth Contour');
        smoothLayout = uix.VBox('Parent', smoothPanel);

        smoothValueLine = uix.HBox(...
            'Parent', smoothLayout, 'Padding', obj.Padding);
        obj.Handles.SmoothMethodLabel = uicontrol(...
            'Parent', smoothValueLine, ...
            'Style', 'text', ...
            'String', 'Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SmoothValueEdit = uicontrol(...
            'Parent', smoothValueLine, ...
            'Style', 'edit', ...
            'String', 10, ...
            'Callback', @obj.onSmoothingValueChanged);
        smoothValueLine.Widths = [-1 -1];
        
        smoothSliderLine = uix.HBox(...
            'Parent', smoothLayout, 'Padding', obj.Padding);
        obj.Handles.SmoothSlider = uicontrol(...
            'Parent', smoothSliderLine, ...
            'Style', 'slider', ...
            'Min', 1, 'Max', 100, ...
            'Value', 10, ...
            'Callback', @obj.onSmoothingValueChanged);
        smoothSliderLine.Widths = -1;

        uix.Empty('Parent', layout);
        layout.Heights = [85 -1];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        value = obj.Frame.Analysis.Parameters.ContourSmoothingSize;
        set(obj.Handles.SmoothValueEdit, 'String', num2str(value));
        set(obj.Handles.SmoothSlider, 'Value', value);

        % ensure contours are computed
        if isempty(obj.Frame.Analysis.Contours)
            computeContours(obj.Frame.Analysis);
            setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Contour);
        end

        % update time-lapse display
        obj.Frame.ImageToDisplay = 'Segmented';
        obj.Frame.DisplayContour = true;
        updateTimeLapseDisplay(obj.Frame);
    end

    % To be called when the corresponding panel is selected.
    function validateProcess(obj) %#ok<MANU>
        % (nothing to do here)
    end

end % end methods


%% Callback methods
methods
    function onSmoothingValueChanged(obj, src, ~)

        if src == obj.Handles.SmoothValueEdit
            value = str2double(get(src, 'String'));
            if isnan(value)
                return;
            end
        elseif src == obj.Handles.SmoothSlider
            value = get(src, 'Value');
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.ContourSmoothingSize = value;

        set(obj.Handles.SmoothValueEdit, 'String', num2str(value));
        set(obj.Handles.SmoothSlider, 'Value', value);

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Contour);
        updateTimeLapseDisplay(obj.Frame);
    end
end

end % end classdef

