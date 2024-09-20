classdef ElongationsPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class ElongationsPanel
%
%   Example
%   ElongationsPanel
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-09-20,    using Matlab 24.2.0.2712019 (R2024b)
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
end % end properties


%% Constructor
methods
    function obj = ElongationsPanel(frame, varargin)
        % Constructor for ElongationsPanel class.

        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        % 1. Apply signal filtering to displacement curves
        filteringPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Filtering Displacements');
        filteringLayout = uix.VBox('Parent', filteringPanel);

        spatialSmoothingLine = uix.HBox(...
            'Parent', filteringLayout, 'Padding', obj.Padding);
        obj.Handles.SpatialSmoothingLabel = uicontrol(...
            'Parent', spatialSmoothingLine, ...
            'Style', 'text', ...
            'String', 'Spatial Smoothing: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.SpatialSmoothingEdit = uicontrol(...
            'Parent', spatialSmoothingLine, ...
            'Style', 'edit', ...
            'String', 10, ...
            'Callback', @obj.onSpatialSmoothingValueChanged);
        spatialSmoothingLine.Widths = [-1 -1];
        
        valueSmoothingLine = uix.HBox(...
            'Parent', filteringLayout, 'Padding', obj.Padding);
        obj.Handles.ValueSmoothingLabel = uicontrol(...
            'Parent', valueSmoothingLine, ...
            'Style', 'text', ...
            'String', 'Value Smoothing: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.ValueSmoothingEdit = uicontrol(...
            'Parent', valueSmoothingLine, ...
            'Style', 'edit', ...
            'String', 10, ...
            'Callback', @obj.onValueSmoothingValueChanged);
        valueSmoothingLine.Widths = [-1 -1];
        
        resamplingStepLine = uix.HBox(...
            'Parent', filteringLayout, 'Padding', obj.Padding);
        obj.Handles.ResamplingStepLabel = uicontrol(...
            'Parent', resamplingStepLine, ...
            'Style', 'text', ...
            'String', 'Resampling Step: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.ResamplingStepEdit = uicontrol(...
            'Parent', resamplingStepLine, ...
            'Style', 'edit', ...
            'String', 10, ...
            'Callback', @obj.onResamplingStepValueChanged);
        resamplingStepLine.Widths = [-1 -1];
        
        filteringLayout.Heights = [40 40 40];

        % 2. Elongation computation
        elongPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Elongation');
        elongLayout = uix.VBox('Parent', elongPanel);

        derivationRadiusLine = uix.HBox(...
            'Parent', elongLayout, 'Padding', obj.Padding);
        obj.Handles.DerivationRadiusLabel = uicontrol(...
            'Parent', derivationRadiusLine, ...
            'Style', 'text', ...
            'String', 'Derivation Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.DerivationRadiusEdit = uicontrol(...
            'Parent', derivationRadiusLine, ...
            'Style', 'edit', ...
            'String', 10, ...
            'Callback', @obj.onDerivationRadiusValueChanged);
        derivationRadiusLine.Widths = [-1 -1];
        elongLayout.Heights = 40;


        % 3. Empty space
        uix.Empty('Parent', layout);

        buttonRow = uix.HButtonBox('Parent', layout);
        obj.Handles.UpdateButton = uicontrol(...
            'Parent', buttonRow, ...
            'Style','pushbutton', ...
            'String', 'Update', ...
            'Callback', @obj.onUpdateButton);

        layout.Heights = [135 55 -1 40];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        spatialSmoothing = obj.Frame.Analysis.Parameters.DisplacementSpatialSmoothing;
        set(obj.Handles.SpatialSmoothingEdit, 'String', num2str(spatialSmoothing));

        valueSmoothing = obj.Frame.Analysis.Parameters.DisplacementValueSmoothing;
        set(obj.Handles.ValueSmoothingEdit, 'String', num2str(valueSmoothing));

        resampling = obj.Frame.Analysis.Parameters.DisplacementResampling;
        set(obj.Handles.ResamplingStepEdit, 'String', num2str(resampling));

        derivRadius = obj.Frame.Analysis.Parameters.ElongationDerivationRadius;
        set(obj.Handles.DerivationRadiusEdit, 'String', num2str(derivRadius));

        set(obj.Handles.UpdateButton, 'Enable', 'on');
    end

    % To be called when the corresponding panel is selected.
    function validateProcess(obj) %#ok<MANU>
        % (nothing to do here)
    end

end % end methods


%% Callback methods
methods
    function onSpatialSmoothingValueChanged(obj, src, ~)

        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        
        obj.Frame.Analysis.Parameters.DisplacementSpatialSmoothing = value;

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Displacement);
        
        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onValueSmoothingValueChanged(obj, src, ~)

        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        
        obj.Frame.Analysis.Parameters.DisplacementValueSmoothing = value;

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Displacement);
        
        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onResamplingStepValueChanged(obj, src, ~)

        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        
        obj.Frame.Analysis.Parameters.DisplacementResampling = value;

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Displacement);
        
        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onDerivationRadiusValueChanged(obj, src, ~)

        value = str2double(get(src, 'String'));
        if isnan(value)
            return;
        end
        value = round(value);

        obj.Frame.Analysis.Parameters.ElongationDerivationRadius = value;

        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Displacement);
        
        set(obj.Handles.UpdateButton, 'Enable', 'on');
        set(obj.Frame.Handles.NextStepButton, 'Enable', 'off');
    end

    function onUpdateButton(obj, src, ~) %#ok<INUSD>

        set(obj.Handles.UpdateButton, 'Enable', 'off');
        pause(0.01);
        
        computeElongations(obj.Frame.Analysis);
        setProcessingStep(obj.Frame.Analysis, kymorod.app.ProcessingStep.Elongation);

        set(obj.Frame.Handles.NextStepButton, 'Enable', 'on');

        obj.Frame.KymographToDisplay = 'Elongation';
        updateKymographDisplay(obj.Frame);
    end
end

end % end classdef

