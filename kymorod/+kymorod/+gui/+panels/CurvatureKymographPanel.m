classdef CurvatureKymographPanel < kymorod.gui.ControlPanel
% One-line description here, please.
%
%   Class CurvatureKymographPanel
%
%   Example
%   CurvatureKymographPanel
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
    function obj = CurvatureKymographPanel(frame, varargin)
        % Constructor for CurvatureKymographPanel class.

        % call parent constructor
        obj = obj@kymorod.gui.ControlPanel(frame);
    end

end % end constructors


%% Methods
methods
    function populatePanel(obj, hPanel)
        % Populate the specified panel with control specific to this op.

        layout = uix.VBox('Parent', hPanel, 'Padding', obj.Padding);

        curvaturePanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Curvature');
        curvatureLayout = uix.VBox('Parent', curvaturePanel);

        windowSizeLine = uix.HBox(...
            'Parent', curvatureLayout, 'Padding', obj.Padding);
        obj.Handles.WindowSizeLabel = uicontrol(...
            'Parent', windowSizeLine, ...
            'Style', 'text', ...
            'String', 'Radius: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.WindowSizeEdit = uicontrol(...
            'Parent', windowSizeLine, ...
            'Style', 'edit', ...
            'String', 20, ...
            'Callback', @obj.onCurvatureWindowSizeChanged);
        windowSizeLine.Widths = [-1 -1];
        
        windowSizeSliderLine = uix.HBox(...
            'Parent', curvatureLayout, 'Padding', obj.Padding);
        obj.Handles.WindowSizeSlider = uicontrol(...
            'Parent', windowSizeSliderLine, ...
            'Style', 'slider', ...
            'Min', 1, 'Max', 100, ...
            'Value', 20, ...
            'Callback', @obj.onCurvatureWindowSizeChanged);
        windowSizeSliderLine.Widths = -1;

        abscissaPanel = uix.Panel(...
            'Parent', layout, ...
            'Title', 'Kymograph Abscissa Size');
        abscissaLayout = uix.VBox('Parent', abscissaPanel);

        abscissaSizeLine = uix.HBox(...
            'Parent', abscissaLayout, 'Padding', obj.Padding);
        obj.Handles.AbscissaSizeLabel = uicontrol(...
            'Parent', abscissaSizeLine, ...
            'Style', 'text', ...
            'String', 'Nb. Points: ', ...
            'HorizontalAlignment', 'left');
        obj.Handles.AbscissaSizeEdit = uicontrol(...
            'Parent', abscissaSizeLine, ...
            'Style', 'edit', ...
            'String', '500', ...
            'Callback', @obj.onAbscissaSizeChanged);
        abscissaSizeLine.Widths = [-1 -1];
        
        abscissaSliderLine = uix.HBox(...
            'Parent', abscissaLayout, 'Padding', obj.Padding);
        obj.Handles.AbscissaSizeSlider = uicontrol(...
            'Parent', abscissaSliderLine, ...
            'Style', 'slider', ...
            'Min', 1, 'Max', 1000, ...
            'Value', 500, ...
            'Callback', @obj.onAbscissaSizeChanged);
        abscissaSliderLine.Widths = -1;

        uix.Empty('Parent', layout);
        layout.Heights = [85 85 -1];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        windowSize = obj.Frame.Analysis.Parameters.CurvatureWindowSize;
        set(obj.Handles.WindowSizeEdit, 'String', num2str(windowSize));
        set(obj.Handles.WindowSizeSlider, 'Value', windowSize);
        
        nPoints = obj.Frame.Analysis.Parameters.KymographAbscissaSize;
        set(obj.Handles.AbscissaSizeEdit, 'String', num2str(nPoints));
        set(obj.Handles.AbscissaSizeSlider, 'Value', nPoints);

        % update time-lapse display
        obj.Frame.ImageToDisplay = 'Input';
        updateTimeLapseDisplay(obj.Frame);
   end
end % end methods


%% Callback methods
methods
    function onCurvatureWindowSizeChanged(obj, src, ~)

        if src == obj.Handles.WindowSizeEdit
            value = str2double(get(src, 'String'));
            if isnan(value)
                return;
            end
        elseif src == obj.Handles.WindowSizeSlider
            value = get(src, 'Value');
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.CurvatureWindowSize = value;

        set(obj.Handles.WindowSizeEdit, 'String', num2str(value));
        set(obj.Handles.WindowSizeSlider, 'Value', value);

    end

    function onAbscissaSizeChanged(obj, src, ~)

        if src == obj.Handles.AbscissaSizeEdit
            value = str2double(get(src, 'String'));
            if isnan(value)
                return;
            end
        elseif src == obj.Handles.AbscissaSizeSlider
            value = get(src, 'Value');
        end
        value = round(value);
        
        obj.Frame.Analysis.Parameters.KymographAbscissaSize = value;

        set(obj.Handles.AbscissaSizeEdit, 'String', num2str(value));
        set(obj.Handles.AbscissaSizeSlider, 'Value', value);

    end
end

end % end classdef

