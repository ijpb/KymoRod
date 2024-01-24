classdef (Sealed) KymoRodGui < handle
%KYMORODGUI GUI Manager for the KymoRod application
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

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-07-23,    using Matlab 8.5.0.197613 (R2015a)
% Copyright 2015 INRA - BIA-BIBS.


%% Properties
properties
    % the path to the last directory used for opening a file
    % (now included in userPrefs)
    lastOpenDir = pwd;

    % User Preferences
    userPrefs;
    
end % end properties


%% Constructor
methods (Access = private)
    function obj = KymoRodGui(varargin)
        % Constructor for KymoRodGui class
        %
        % Does not require any argument.
        %
    
        % Initialisation of user preferences
        obj.userPrefs = KymoRodUserPrefs();
        try
            obj.userPrefs = KymoRodUserPrefs.load();
        catch
            warning('Enable to read default properties. If this is the first time to run KymoRod, this is normal.');
        end
    end

end % end constructors


%% Static methods

methods (Static)
    function singleObj = getInstance
        % Return the current instance if KymoRodGui, or create one
        % (Singleton pattern)
        persistent localObj
        if isempty(localObj) || ~isvalid(localObj)
            localObj = KymoRodGui();
        end
        singleObj = localObj;
    end
   
    function hFigure = findParentFigure(hObject)
        % Return the figure object containing the hObject widget
        while ~isempty(hObject) && ~strcmp(get(hObject, 'Type'), 'figure')
            hObject = get(hObject, 'Parent');
        end
        hFigure = hObject;
    end
end

%% General methods
methods
    function data = createNewAnalysis(obj)
        % Create a new (empty) application data.
        
        % create new app dat awith current prefs
        settings = KymoRodSettings.fromPrefs(obj.userPrefs);
        data = KymoRodData(settings);
        
        % initialize with default directory
        data.inputImagesDir = obj.userPrefs.lastOpenDir;
        data.inputImagesFilePattern = obj.userPrefs.inputImagesFilePattern;
        data.inputImagesLazyLoading = obj.userPrefs.inputImagesLazyLoading;
    end

end

%% General GUI function

methods
    function app = loadKymoRodAppData(this)
        % Open File dialog to read KymoRod application data
        %
        % Returns a new instance, or empty if could not load.
        %
        
        % open a dialog to select input kymorod app file
        [fileName, folderName] = uigetfile(...
            {'*.mat', 'KymoRod Data Files';...
            '*.*','All Files' }, ...
            'Select KymoRod Analysis');
        
        % check if cancel button was selected
        if fileName == 0
            app = [];
            return;
        end
        
        % keep path to file for future opening
        this.lastOpenDir = folderName;

        % log file info
        logger = log4m.getLogger;
        logger.info(mfilename, ...
            ['Open analysis from file: ' fullfile(folderName, fileName)]);

        % read application data corresponding to selected file
        app = KymoRodData.load(fullfile(folderName, fileName));

        % ensure input directory is valid, otherwise, ask for a new one.
        while exist(app.inputImagesDir, 'dir') == 0
            disp(['Could not find input images dir: ' app.inputImagesDir]);
            
            msg = sprintf('Could not find input images directory:\n%s', app.inputImagesDir);
            h = errordlg(msg, 'Loading Error', 'modal');
            uiwait(h);
            
            % open a dialog to select input image folder, restricting type to images
            [fileName, folderName] = uigetfile(...
                {'*.tif;*.jpg;*.png;*.gif', 'All Image Files';...
                '*.tif;*.tiff;*.gif', 'Tagged Image Files (*.tif)';...
                '*.jpg;', 'JPEG images (*.jpg)';...
                '*.*','All Files' }, ...
                'Select Input Folder', ...
                fullfile(folderName, '*.*'));
            
            % check if cancel button was selected
            if fileName == 0
                app = [];
                return;
            end
            
            % let us try with the new folder...
            app.inputImagesDir = folderName;

            % keep it for future opening
            this.userPrefs.lastOpenDir = folderName;
        end
    end
    
    function displayProcessingDialog(this, app) %#ok<INUSL>
        % Opens the appropriate dialog to display result of kymorod appdata
        
        % switch dialog depending on processing step
        switch getProcessingStep(app)
            case {ProcessingStep.None, ProcessingStep.Selection}
                SelectInputImagesDialog(app);
                
            case ProcessingStep.Threshold
                ChooseThresholdDialog(app);
                
            case ProcessingStep.Contour
                SmoothContourDialog(app);
                
            case ProcessingStep.Skeleton
                ValidateSkeleton(app);
                
            case ProcessingStep.Kymograph
                DisplayKymograph(app);
                
            otherwise
                SelectInputImagesDialog(app);
        end
    end
end

%% Menu Managment methods
methods
    function buildFigureMenu(this, hFigure, app)
        % creates standardized menu for a figure
        
        % remove default menu bar
        set(hFigure, 'MenuBar', 'none');
       
        % remove previously created menus, if any
        children = get(hFigure, 'children');
        inds = strcmp(get(children, 'type'), 'uimenu');
        delete(children(inds));
        
        % Populate the "File" menu entry
        fileMenu = uimenu('parent', hFigure, 'Label', 'Files');
        uimenu('parent', fileMenu, ...
            'Label', 'New Analysis', ...
            'UserData', app, ...
            'Callback', @this.newAnalysisMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Load...', ...
            'UserData', app, ...
            'Callback', @this.loadAppDataMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Save As...', ...
            'UserData', app, ...
            'Callback', @this.saveAppDataMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Quit', ...
            'Separator', 'On', ...
            'UserData', app, ...
            'Callback', @this.quitMenuCallback);
        
        % Populate the "Edit" menu entry
        editMenu = uimenu('parent', hFigure, 'Label', 'Edit');
        uimenu('parent', editMenu, ...
            'Label', 'Processing Step Menu...', ...
            'UserData', app, ...
            'Callback', @this.mainMenuCallback);
        uimenu('parent', editMenu, ...
            'Label', 'Print KymoRod Settings', ...
            'UserData', app, ...
            'Callback', @this.printSettingsCallback);
        
        % Populate the "Help" menu entry
        helpMenu = uimenu('parent', hFigure, 'Label', 'Help');
        uimenu('parent', helpMenu, ...
            'Label', 'Display Log File Path', ...
            'UserData', app, ...
            'Callback', @this.displayLogFilePathMenuCallback);
        uimenu('parent', helpMenu, ...
            'Label', 'Show Log File', ...
            'UserData', app, ...
            'Callback', @this.showLogFileMenuCallback);
        uimenu('parent', helpMenu, ...
            'Separator', 'On', ...
            'Label', 'About...', ...
            'UserData', app, ...
            'Callback', @this.aboutMenuCallback);
        
    end
    
    function newAnalysisMenuCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        % creates a new analysis 
        
        % create new empty application data structure, using same settings
        newApp = createNewAnalysis(obj);        

        % clear current figure
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
        
        % open first dialog of application
        SelectInputImagesDialog(newApp);
    end
    
    function loadAppDataMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        disp('loading...');
        
        try
            % try to load the data
            app = loadKymoRodAppData(this);
            
        catch ME
            logger = log4m.getLogger;
            logger.error(mfilename, ME.message);
            h = errordlg(ME.message, 'Loading Error', 'modal');
            uiwait(h);
            return;
        end
        
        if isempty(app)
            return;
        end
        
        % delete figure containing calling object
        hFigure = KymoRodGui.findParentFigure(hObject);
        close(hFigure);

        % display appropriate dialog for the application data
        displayProcessingDialog(this, app);
    end
    
    function saveAppDataMenuCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        disp('Saving...');
        
        % To open the directory who the user want to save the data
        [fileName, pathName] = uiputfile('*.mat', ...
            'Save KymoRod data');
        
        if pathName == 0
            return;
        end
        
        % filename of mat file
        [emptyPath, baseName, ext] = fileparts(fileName); %#ok<ASGLU>
        filePath = fullfile(pathName, [baseName '.mat']);
        
        % temporarily remove image list from app data
        app = get(hObject, 'UserData');
        imgTemp = app.imageList;
        app.imageList = {};

        % save full application data as mat file, without image data
        save(app, filePath);
        
        % replace image list within app data
        app.imageList = imgTemp;
        
        % save all informations of experiment, to retrieve them easily
        filePath = fullfile(pathName, [baseName '-kymorod.txt']);
        write(app, filePath);
    end
    
    function quitMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD,INUSL>
        % save user preferences and closes application.

        % save user prefs
        save(this.userPrefs);

        % closes graphical widgets
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
    end
    
    
    function mainMenuCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        app = get(hObject, 'UserData');
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
        KymoRodMenuDialog(app);
    end
    
    function printSettingsCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        app = get(hObject, 'UserData');
        disp('KymoRod Settings:');
        disp(app.settings);
    end
    
    function displayLogFilePathMenuCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        app = get(hObject, 'UserData');
        path = app.logger.fullpath;
        disp('Path to log file:');
        disp(path);
    end

    function showLogFileMenuCallback(this, hObject, eventdata, handles) %#ok<INUSL,INUSD>
        % Display the content of the log file in a new figure

        % try to open log file
        app = get(hObject, 'UserData');
        path = app.logger.fullpath;
        [f, errMsg] = fopen(path, 'rt');
        if f == -1
            errordlg(errMsg, 'Show Log File Error', 'modal');
            return;
        end
        
        % read all the lines of the log file
        lines = {};
        line = fgetl(f);
        while line ~= -1
            lines = [lines; {line}]; %#ok<AGROW>
            line = fgetl(f);
        end
        
        % Create new figure, and add the set of lines read from the file
        hf = figure('Name', 'KymoRod Log File', ...
            'Toolbar', 'none', 'menubar', 'none');
        uicontrol('Parent', hf, 'style', 'list', ...
            'unit', 'normalized', 'position', [0 0 1 1], ...
            'Min', 1, 'Max', Inf, ...
            'String', lines);
    end

    function aboutMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        KymoRodAboutDialog;
    end
end % end methods

end % end classdef

