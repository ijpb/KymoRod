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
        
        % Populate the "File" menu entry
        fileMenu = uimenu('parent', hFigure, 'Label', 'Files');
        uimenu('parent', fileMenu, ...
            'Label', 'New Analysis', ...
            'Callback', @this.newAnalysisMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Load...', ...
            'Callback', @this.loadAppDataMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Save As...', ...
            'Callback', @this.saveAppDataMenuCallback);
        uimenu('parent', fileMenu, ...
            'Label', 'Quit', ...
            'Separator', 'On', ...
            'Callback', @this.quitMenuCallback);
        
        % Populate the "Edit" menu entry
        editMenu = uimenu('parent', hFigure, 'Label', 'Edit');
        uimenu('parent', editMenu, ...
            'Label', 'Processing Step Menu', ...
            'Callback', @this.mainMenuCallback);
        
        % Populate the "Help" menu entry
        helpMenu = uimenu('parent', hFigure, 'Label', 'Help');
        uimenu('parent', helpMenu, ...
            'Label', 'Display Log File Path', ...
            'Callback', @this.displayLogFilePathMenuCallback);
        uimenu('parent', helpMenu, ...
            'Label', 'Show Log File', ...
            'Callback', @this.showLogFileMenuCallback);
        uimenu('parent', helpMenu, ...
            'Separator', 'On', ...
            'Label', 'About...', ...
            'Callback', @this.aboutMenuCallback);
        
    end
    
    function newAnalysisMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        % creates a new analysis 
        
        % clear current figure
        hFig = KymoRodGui.findParentFigure(hObject);
        delete(hFig);
        
        % create new empty application data structure, using same settings
        settings = this.app.settings;
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
        if fileName == 0;
            return;
        end
        
        this.app.logger.info('KymoRodGUI.loadAppDataMenuCallback', ...
            ['Open saved analysis from file ' fullfile(folderName, fileName)]);
        
        % depending in file format, either use binary reading, or read parameters
        % from a text file
        [path, name, ext] = fileparts(fileName); %#ok<ASGLU>
        if strcmp(ext, '.mat')
            warning('off', 'MATLAB:load:cannotInstantiateLoadedVariable');
            try
                newApp = KymoRod.load(fullfile(folderName, fileName));
            catch ME
                h = errordlg(ME.message, 'Loading Error', 'modal');
                uiwait(h);
                return;
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
            DisplayKymograph(newApp);
            
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
    
    function saveAppDataMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
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
        imgTemp = this.app.imageList;
        this.app.imageList = {};

        % save full application data as mat file, without image data
        save(this.app, filePath);
        
        % replace image list within app data
        this.app.imageList = imgTemp;
        
        % save all informations of experiment, to retrieve them easily
        filePath = fullfile(pathName, [baseName '-kymorod.txt']);
        write(this.app, filePath);
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

    function displayLogFilePathMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        path = this.app.logger.fullpath;
        disp('Path to log file:');
        disp(path);
    end

    function showLogFileMenuCallback(this, hObject, eventdata, handles) %#ok<INUSD>
        % Display the content of the log file in a new figure

        % try to open log file
        path = this.app.logger.fullpath;
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

