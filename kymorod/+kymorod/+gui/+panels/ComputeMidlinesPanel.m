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
        layout.Heights = [85 -1];

        set(hPanel, 'UserData', obj);
    end
    
    function select(obj)
        origin = obj.Frame.Analysis.Parameters.SkeletonOrigin;
        originIndex = find(strcmpi(origin, obj.MidlineOriginNames));
        set(obj.Handles.MidlineOriginChoice, 'Value', originIndex);

        % update time-lapse display
        obj.Frame.ImageToDisplay = 'Segmented';
        updateTimeLapseDisplay(obj.Frame);
    end
end % end methods


%% Callback methods
methods
    function onMidlineOriginChanged(obj, src, ~)

        index = get(src, 'Value');
        value = obj.MidlineOriginNames{index};

        obj.Frame.Analysis.Parameters.SkeletonOrigin = value;
    end
end

end % end classdef

