classdef (Sealed) KymoRodGui < handle
%KYMORODGUI GUI Manager for the KymoRod application
%
%   The goal of this class is to provide several facility methods, such as
%   methods for creating figure menus.
%   
%   The KymoRodGui is a singleton, and can be shared byu several
%   application instances. To get the unique instance:
%   GUI = KymoRodGui.getInstance();
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2015-07-23,    using Matlab 8.5.0.197613 (R2015a)
% Copyright 2015 INRA - BIA-BIBS.


%% Properties
properties

end % end properties


%% Constructor
methods (Access = private)
    function this = KymoRodGui(varargin)
    % Constructor for KymoRodGui class
    % 
    % Does not require any argument.
    %
  
    end

end % end constructors

methods (Static)
    function singleObj = getInstance
        % Return the current instance if KymoRodGui, or create one
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
        
        % clear current figure
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
        
        % create new empty application data structure, using same settings
        app = get(hObject, 'UserData');
        settings = app.settings;
        newApp = KymoRod(settings);
        
        % initialize with default directory
        path = fileparts(mfilename('fullpath'));
        newApp.inputImagesDir = fullfile(path, '..', '..', '..', 'sampleImages', '01');
        
        % open first dialog of application
        SelectInputImagesDialog(newApp);
    end
    
    function loadAppDataMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        disp('Loading...');
        
        % open a dialog to select input image folder, restricting type to images
        [fileName, folderName] = uigetfile(...
            {'*.mat', 'KymoRod Data Files';...
            '*-kymo.txt', 'KymoRod Info Files';...
            '*.*','All Files' }, ...
            'Select KymoRod Analysis');
        
        % check if cancel button was selected
        if fileName == 0
            return;
        end
        
        app = get(hObject, 'UserData');
        app.logger.info('KymoRodGUI.loadAppDataMenuCallback', ...
            ['Open saved analysis from file ' fullfile(folderName, fileName)]);
        
        % depending in file format, either use binary reading, or read parameters
        % from a text file
        [path, name, ext] = fileparts(fileName); %#ok<ASGLU>
        if strcmp(ext, '.mat')
            readAppData_mat(this, fullfile(folderName, fileName));
            
        elseif strcmp(ext, '.txt')
            newApp = KymoRod.read(fullfile(folderName, fileName));
            setProcessingStep(newApp, ProcessingStep.Selection);
            
            % in case of reading from a text, binary data are not saved and need to
            % be recomputed
            SelectInputImagesDialog(newApp);
            
        else
            msg = sprintf('Can not manage file with extension %s', ext);
            h = errordlg(msg, 'Loading Error', 'modal');
            uiwait(h);
        end
    end
    
    function readAppData_mat(this, filePath) %#ok<INUSL>
        % read KymoRod data from a mat file
        
        % try to read the app from selected file
        warning('off', 'MATLAB:load:cannotInstantiateLoadedVariable');
        try
            newApp = KymoRod.load(filePath);
        catch ME
            h = errordlg(ME.message, 'Loading Error', 'modal');
            uiwait(h);
            return;
        end
        
        % ensure input directory is valid, otherwise, ask for a new one.
        if exist(newApp.inputImagesDir, 'dir') == 0
            disp(['Could not find input dir: ' newApp.inputImagesDir]);
            
            msg = sprintf('Could not find input directory:\n%s', newApp.inputImagesDir);
            h = errordlg(msg, 'Loading Error', 'modal');
            uiwait(h);
            
            % open a dialog to select input image folder, restricting type to images
            [fileName, folderName] = uigetfile(...
                {'*.tif;*.jpg;*.png;*.gif', 'All Image Files';...
                '*.tif;*.tiff;*.gif', 'Tagged Image Files (*.tif)';...
                '*.jpg;', 'JPEG images (*.jpg)';...
                '*.*','All Files' }, ...
                'Select Input Folder', '*.*');
            
            % check if cancel button was selected
            if fileName == 0
                return;
            end
            
            % let us try with the new folder...
            newApp.inputImagesDir = folderName;
        end
        
        % assumes only 'complete' analyses can be saved, and call the dialog for
        % showing results
        switch getProcessingStep(newApp)
            case {ProcessingStep.None, ProcessingStep.Selection}
                SelectInputImagesDialog(newApp);
                
            case ProcessingStep.Threshold
                ChooseThresholdDialog(newApp);
                
            case ProcessingStep.Contour
                SmoothContourDialog(newApp);
                
            case ProcessingStep.Skeleton
                ValidateSkeleton(newApp);
                
            case ProcessingStep.Kymograph
                DisplayKymograph(newApp);
                
            otherwise
                SelectInputImagesDialog(newApp);
        end
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

