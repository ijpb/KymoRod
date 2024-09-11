classdef KymoRodFrame < handle
% Parent class for all KymoRod frames.
%
%   Class KymoRodFrame
%
%   Example
%   KymoRodFrame
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-14,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    % A reference to the current GUI (kymorod.gui.KymoRodGui).
    Gui;

    % A reference to the current analysis (kymorod.app.Analysis).
    Analysis;
    
    % A list of refernces to the widgets within this frame, as a struct.
    Handles;
    
    % % The set of mouse listeners, stored as a cell array.
    % MouseListeners = [];
    % 
    % % The currently selected tool.
    % CurrentTool = [];
 
end % end properties


%% Static methods
methods (Static)
    function hFig = createNewFigure()
        % Create a new figure.
        %
        %   Usage:
        %   hFig = kr.gui.KymoRodFrame.createNewFigure();
        %
       
        while true
            hFig = 22000 + randi(10000);
            if ~ishandle(hFig)
                break;
            end
        end
        hFig = figure(hFig);
    end
    
    function hFig = findNewFigureHandle()
        % Compute a new handle index for figure.
        %
        %   Usage:
        %   hFig = kr.gui.KymoRodFrame.findNewFigureHandle();
        %   fig = figure(kr.gui.KymoRodFrame.findNewFigureHandle());
        %
        %   Choose it large enough not to collide with common figure
        %   handles.
        %
        
        while true
            hFig = 22000 + randi(10000);
            if ~ishandle(hFig)
                break;
            end
        end
    end
end


%% Constructor
methods
    function obj = KymoRodFrame(gui, analysis, varargin)
        % Constructor for KymoRodFrame class.

        % check input validity
        if ~isa(gui, 'kymorod.gui.KymoRodGui')
            error('First argument must be an instance of KymoRodGui.')
        end
        if ~isa(analysis, 'kymorod.app.Analysis')
            error('Second argument must be an instance of Analysis.')
        end

        % store references
        obj.Gui = gui;
        obj.Analysis = analysis;
    end

end % end constructors


%% Methods
methods
end % end methods

end % end classdef

