classdef ComputeMidlinesPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class ComputeMidlinesPanel
%
%   Example
%   ComputeMidlinesPanel
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
    MidlineOriginNames = {'Bottom', 'Top', 'Left', 'Right'};
end % end properties


%% Constructor
methods
    function obj = ComputeMidlinesPanel(frame, varargin)
        % Constructor for ComputeMidlinesPanel class.

        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        midlinePanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Compute Midlines');
        midlineLayout = uix.VBox('Parent', midlinePanel);

        midlineOriginLine = uix.HBox(...
            'Parent', midlineLayout, 'Padding', obj.Padding);
        uicontrol('Parent', midlineOriginLine, ...
            'Style', 'text', ...
            'HorizontalAlignment', 'left', ...
            'String', 'Midline Origin: ');
        obj.Handles.MidlineOriginChoice = uicontrol(...
            'Parent', midlineOriginLine, ...
            'Style', 'popupmenu', ...
            'String', obj.MidlineOriginNames, ...
            'Value', 1, ...
            'Callback', @obj.onMidlineOriginChanged);
        midlineOriginLine.Widths = [-1 -1];

        uix.Empty('Parent', layout);

        buttonRow = uix.HButtonBox('Parent', layout);
        obj.Handles.UpdateButton = uicontrol(...
            'Parent', buttonRow, ...
            'Style','pushbutton', ...
            'String', 'Update', ...
            'Callback', @obj.onUpdateButton);
        layout.Heights = [85 -1 40];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        origin = obj.Frame.Analysis.Parameters.SkeletonOrigin;
        originIndex = find(strcmpi(origin, obj.MidlineOriginNames));
        set(obj.Handles.MidlineOriginChoice, 'Value', originIndex);

        set(obj.Handles.UpdateButton, 'Enable', 'on');
        if obj.Frame.Analysis.ProcessingStep < kymorod.app.ProcessingStep.Skeleton
            set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
        end

        % update time-lapse display
        obj.Frame.ImageToDisplay = 'Segmented';
        obj.Frame.DisplayMidline = true;
        updateTimeLapseDisplay(obj.Frame);
    end

    % To be called when the corresponding panel is selected.
    function validateProcess(obj) %#ok<MANU>
        % (nothing to do here)
    end

end % end methods


%% Callback methods
methods
    function onMidlineOriginChanged(obj, src, ~)

        index = get(src, 'Value');
        value = obj.MidlineOriginNames{index};

        obj.Frame.Analysis.Parameters.SkeletonOrigin = value;
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Contour);

        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onUpdateButton(obj, src, ~) %#ok<INUSD>

        set(obj.Handles.UpdateButton, 'Enable', 'off');
        pause(0.01);
        
        computeMidlines(obj.Frame.Analysis);
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Midline);
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'on');

        updateTimeLapseDisplay(obj.Frame);
    end
end

end % end classdef

