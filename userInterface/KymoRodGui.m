classdef KymoRodGui < handle
%KYMORODGUI GUI Manager for the KymoRod application
%
%   The goal of this class is to provide several facility methods, such as
%   methods for creating figure menus.
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@nantes.inra.fr
% Created: 2015-07-23,    using Matlab 8.5.0.197613 (R2015a)
% Copyright 2015 INRA - BIA-BIBS.


%% Properties
properties
    app;
end % end properties


%% Constructor
methods
    function this = KymoRodGui(varargin)
    % Constructor for KymoRodGui class
    
        if nargin ~= 1 || ~isa(varargin{1}, 'KymoRod')
            error('Requires an object of class KymoRod as input');
        end
        
        this.app = varargin{1};
    end

end % end constructors

methods (Static)
    function hFigure = findParentFigure(hObject)
        while ~isempty(hObject) && ~strcmp(get(hObject, 'Type'), 'figure')
            hObject = get(hObject, 'Parent');
        end
        hFigure = hObject;
    end
end

%% Menu Managment methods
methods
    function buildFigureMenu(this, hFigure)
        % creates standardized menu for a figure
        
        % remove default menu bar
        set(hFigure, 'MenuBar', 'none');
       
        % remove previously created menus
        children = get(hFigure, 'children');
        inds = strcmp(get(children, 'type'), 'uimenu');
        delete(children(inds));
        
        % create standard menu hierarchy
        fileMenu = uimenu('parent', hFigure, 'Label', 'Files');
        uimenu('parent', fileMenu, ...
            'Label', 'Process Step Menu', ...
            'Callback', @this.mainMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Quit', ...
            'Separator', 'On', ...
            'Callback', @this.quitMenuCallback);
        
%         editMenu = uimenu('parent', hFigure, 'Label', 'Edit');
        
        helpMenu = uimenu('parent', hFigure, 'Label', 'Help');
        uimenu('parent', helpMenu, ...
            'Label', 'About...', ...
            'Callback', @this.aboutMenuCallback);
        
    end
    
    function mainMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
        KymoRodMenuDialog(this.app);
    end
    
    function quitMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD,INUSL>
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
    end
    
    function aboutMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        KymoRodAboutDialog;
    end
end % end methods

end % end classdef

