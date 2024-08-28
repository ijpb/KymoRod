classdef (Sealed) KymoRodGui < handle
% KYMORODGUI GUI Manager for the KymoRod application.
%
%   This class provides several GUI utility methods, such as methods for
%   creating figure menus. 
%   
%   The KymoRodGui is a singleton, and can be shared by several
%   application instances. To get the unique instance:
%   GUI = KymoRodGui.getInstance();
%
%   See also
%   KymoRod
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-27,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Static methods
methods (Static)
    function singleObj = getInstance
        % Return the current instance if KymoRodGui, or create one.
        % (Singleton pattern)
        persistent localObj
        if isempty(localObj) || ~isvalid(localObj)
            localObj = kymorod.gui.KymoRodGui();
        end
        singleObj = localObj;
    end
   
    function hFigure = findParentFigure(hObject)
        % Return the figure object containing the hObject widget.
        while ~isempty(hObject) && ~strcmp(get(hObject, 'Type'), 'figure')
            hObject = get(hObject, 'Parent');
        end
        hFigure = hObject;
    end
end


%% Properties
properties
    % User Preferences
    UserPrefs;
end % end properties


%% Constructor
methods
    function obj = KymoRodGui(varargin)
        % Constructor for KymoRodGui class.

        % Initialisation of user preferences
        obj.UserPrefs = kymorod.app.UserPrefs();
        try
            obj.UserPrefs = kymorod.app.UserPrefs.load();
        catch
            warning('Unable to read default properties. If this is the first time KymoRod is run, this is normal.');
        end
    end

end % end constructors


%% General methods
methods
    function res = createNewAnalysis(obj)
        % Create a new analysis using current settings.
        
        % create new app dat awith current prefs
        params = kymorod.app.Parameters(obj.UserPrefs.Parameters);
        res = kymorod.app.Analysis();
        res.Parameters = params;
        
        % initialize with default directory
        imgList = res.InputImages.ImageList;
        imgList.Directory = obj.UserPrefs.LastOpenDir;
    end
end


end % end classdef

