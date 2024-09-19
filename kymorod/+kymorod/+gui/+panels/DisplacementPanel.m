classdef DisplacementPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class DisplacementPanel
%
%   Example
%   DisplacementPanel
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-09-19,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    ChannelNames = {'Red', 'Green', 'Blue'};
end % end properties

%% Constructor
methods
    function obj = DisplacementPanel(frame, varargin)
        % Constructor for DisplacementPanel class.


        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        displPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Compute Displacements');
        displLayout = uix.VBox('Parent', displPanel);

        % 1. channel + step used for computing displacements
        displacementChannelLine = uix.HBox(...
            'Parent', displLayout, 'Padding', obj.Padding);
        uicontrol('Parent', displacementChannelLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Displacement Channel: ');
        obj.Handles.DisplacementChannelChoice = uicontrol(...
            'Parent', displacementChannelLine, ...
            'Style', 'popupmenu', ...
            'String', obj.ChannelNames, ...
            'Value', 1, ...
            'Callback', @obj.onDisplacementChannelChanged);
        displacementChannelLine.Widths = [-1 -1];

        % 2. text edit for choosing Displacement Step
        displacementStepLine = uix.HBox(...
            'Parent', displLayout, 'Padding', obj.Padding);
        obj.Handles.DisplacementStepLabel = uicontrol(...
            'Parent', displacementStepLine, ...
            'Style', 'text', ...
            'String', 'Frame Step: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.DisplacementStepEdit = uicontrol(...
            'Parent', displacementStepLine, ...
            'Style', 'edit', ...
            'String', 1, ...
            'Callback', @obj.onDisplacementStepChanged);
        displacementStepLine.Widths = [-1 -1];
        
        % 3. text edit for choosing Window Size
        windowSizePanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Local Frame Matching');
        windowSizeLayout = uix.VBox('Parent', windowSizePanel);

        windowSizeLine = uix.HBox(...
            'Parent', windowSizeLayout, 'Padding', obj.Padding);
        obj.Handles.WindowSizeLabel = uicontrol(...
            'Parent', windowSizeLine, ...
            'Style', 'text', ...
            'String', 'Window Size: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.WindowSizeEdit = uicontrol(...
            'Parent', windowSizeLine, ...
            'Style', 'edit', ...
            'String', '500', ...
            'Callback', @obj.onWindowSizeChanged);
        windowSizeLine.Widths = [-1 -1];
        
        windowSizeSliderLine = uix.HBox(...
            'Parent', windowSizeLayout, 'Padding', obj.Padding);
        obj.Handles.WindowSizeSlider = uicontrol(...
            'Parent', windowSizeSliderLine, ...
            'Style', 'slider', ...
            'Min', 1, 'Max', 100, ...
            'Value', 10, ...
            'Callback', @obj.onWindowSizeChanged);
        windowSizeSliderLine.Widths = -1;

        % 4. Empty space
        uix.Empty('Parent', layout);

        buttonRow = uix.HButtonBox('Parent', layout);
        obj.Handles.UpdateButton = uicontrol(...
            'Parent', buttonRow, ...
            'Style','pushbutton', ...
            'String', 'Update', ...
            'Callback', @obj.onUpdateButton);
        layout.Heights = [85 85 -1 40];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        channel = obj.Frame.Analysis.Parameters.DisplacementImageChannel;
        index = find(strcmpi(channel, obj.ChannelNames));
        set(obj.Handles.DisplacementChannelChoice, 'Value', index);

        step = obj.Frame.Analysis.Parameters.DisplacementStep;
        set(obj.Handles.DisplacementStepEdit, 'String', num2str(step));

        windowSize = obj.Frame.Analysis.Parameters.MatchingWindowRadius;
        set(obj.Handles.WindowSizeEdit, 'String', num2str(windowSize));
        set(obj.Handles.WindowSizeSlider, 'Value', windowSize);

        set(obj.Handles.UpdateButton, 'Enable', 'on');
        if obj.Frame.Analysis.ProcessingStep < kymorod.app.ProcessingStep.Displacement
            set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
        end
    end

    % To be called when the corresponding panel is selected.
    function validateProcess(obj) %#ok<MANU>
        % (nothing to do here)
    end
end


%% Callbacks to widgets
methods
    function onDisplacementChannelChanged(obj, src, ~)
        index = get(src, 'Value');
        value = obj.ChannelNames{index};

        obj.Frame.Analysis.Parameters.DisplacementImageChannel = value;
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Curvature);

        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onDisplacementStepChanged(obj, src, ~)
        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        value = round(value);

        obj.Frame.Analysis.Parameters.DisplacementStep = value;
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Curvature);
        
        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onWindowSizeChanged(obj, src, ~)

        if src == obj.Handles.WindowSizeEdit
            value = str2double(get(src, 'String'));
            if isnan(value)
                return;
            end
        elseif src == obj.Handles.WindowSizeSlider
            value = get(src, 'Value');
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.MatchingWindowRadius = value;
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Curvature);

        set(obj.Handles.WindowSizeEdit, 'String', num2str(value));
        set(obj.Handles.WindowSizeSlider, 'Value', value);

        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onUpdateButton(obj, src, ~) %#ok<INUSD>

        set(obj.Handles.UpdateButton, 'Enable', 'off');
        pause(0.01);
        
        computeDisplacements(obj.Frame.Analysis);
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Displacement);
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'on');
    end
end

end % end classdef
