classdef KymographDisplayFrame < handle
%KYMOGRAPHDISPLAYFRAME  Kymograph Display frame.
%
%   FIG = KymographDisplayFrame(APP)
%
%   Example
%   KymographDisplayDlg
%
%   See also
%
 
% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-03-16,    using Matlab 9.3.0.713579 (R2017b)
% Copyright 2018 INRA - Cepia Software Platform.

properties
    % the instance of KymoRodData
    AppData;
    
    % list of handles to the various gui items
    Handles;
    
end

methods
    function obj = KymographDisplayFrame(app, varargin)
        % Constructor.

        if ~isa(app, 'KymoRodData')
            error('Requies an insance of KymoRodData as first argument');
        end
        obj.AppData = app;
                
        % create the figure that will contains the display
        fig = figure();
        set(fig, ...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'NextPlot', 'new', ...
            'Name', 'Kymograph Display', ...
            'CloseRequestFcn', @obj.close);
        obj.Handles.figure = fig;
        
        % create main figure menu
        createFigureMenu(fig);

        % creates the layout
        setupLayout(fig);
        
        updateDisplay(obj);
        updateTitle(obj);

    
        function createFigureMenu(hf)
            fileMenu = uimenu(hf, 'Label', '&Files');
            uimenu(fileMenu, 'Label', 'Save As PNG...', ...
                    'MenuSelectedFcn', @(src, evt) obj.onSaveAsPng);
            uimenu(fileMenu, 'Label', 'Close', ...
                'Separator', 'On', ...
                'MenuSelectedFcn', @(src, evt) close(obj));
            viewMenu = uimenu(hf, 'Label', '&View');
            uimenu(viewMenu, 'Label', 'Select Kymograph...', ...
                    'MenuSelectedFcn', @(src, evt) obj.onSelectKymograph);
            uimenu(viewMenu, 'Label', 'Set Display Range...', ...
                    'MenuSelectedFcn', @(src, evt) obj.onSetDisplayRange);
        end
        
        function setupLayout(hf)
            % Seup the layout for the figure.

            % vertical layout: image display and status bar
            mainPanel = uix.VBox('Parent', hf, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            
            % creates an axis that fills the available space
            ax = axes('Parent', uicontainer('Parent', mainPanel), ...
                'YDir', 'normal');
            
            % intialize image display with default image.
            kymo = getCurrentKymograph(obj.AppData);
            hIm = imagesc(kymo.Data, 'parent', ax);
            
            % keep widgets handles
            obj.Handles.imageAxis = ax;
            obj.Handles.image = hIm;
            
            % info panel for cursor position and value
            obj.Handles.infoPanel = uicontrol(...
                'Parent', mainPanel, ...
                'Style', 'text', ...
                'String', ' x=    y=     I=', ...
                'HorizontalAlignment', 'left');
            
            % right panel fixed size, the remaining for left panel
            mainPanel.Heights = [-1 20];
        end
    end
end


%% Figure management
methods
    function updateDisplay(obj)
        % disp('Update title');
        kymo = getCurrentKymograph(obj.AppData);
        img = kymo.Data;

        % also retrieve display range
        validateDisplayRange(kymo);
        xdata = xData(kymo);
        ydata = yData(kymo);

        % update image display
        obj.Handles.image = imagesc(obj.Handles.imageAxis, ...
            img, 'xdata', xdata, 'ydata', ydata);
        set(obj.Handles.imageAxis, ...
            'DataAspectRatioMode', 'auto', ...
            'YDir', 'normal', ...
            'CLim', kymo.DisplayRange);

        % update graph annotations
        title(kymo.Name);
        xlabel(createLabel(kymo.TimeAxis));
        ylabel(createLabel(kymo.PositionAxis));
    end

    function updateTitle(obj, varargin) %#ok<INUSD>
        % disp('Update title');
    end

    function close(obj, varargin)
        delete(obj.Handles.figure);
    end
end

%% Menu callbacks
methods
    function onSaveAsPng(obj)

        gui = KymoRodGui.getInstance();
        defaultPath = gui.userPrefs.lastSaveDir;

        % open a dialog to select a PNG file
        [fileName, pathName] = uiputfile({'*.png'}, ...
            'Save as PNG', defaultPath);

        if fileName == 0
            return;
        end
        gui.userPrefs.lastSaveDir = pathName;

        app = obj.AppData;
        kymo = app.getCurrentKymograph;

        hf = figure;
        set(gca, 'fontsize', 14);
        show(kymo);
        print(hf, fullfile(pathName, fileName), '-dpng');
        close(hf);
    end

    function onSelectKymograph(obj)
        app = obj.AppData;

        listValues = {'Radius', 'VerticalAngle', 'Curvature', 'Elongation', 'Intensity'};
        switch app.kymographDisplayType
            case 'radius', current = 'Radius';
            case 'verticalAngle', current = 'VerticalAngle';
            case 'curvature', current = 'Curvature';
            case 'elongation', current = 'Elongation';
            case 'intensity', current = 'Intensity';
        end

        % create dialog
        gd = GenericDialog('Set Kymograph');
        addChoice(gd, 'Kymograph: ', listValues, current);
        showDialog(gd);

        % check if ok or cancel button was clicked
        if wasCanceled(gd)
            return;
        end

        typeList = {'radius', 'verticalAngle', 'curvature', 'elongation', 'intensity'};
        app.kymographDisplayType = typeList{getNextChoiceIndex(gd)};

        updateDisplay(obj);
    end

    function onSetDisplayRange(obj)

        app = obj.AppData;
        kymo = app.getCurrentKymograph;
        validateDisplayRange(kymo);
        vmin = kymo.DisplayRange(1);
        vmax = kymo.DisplayRange(2);

        % create dialog
        gd = GenericDialog('Set Display Range');
        addNumericField(gd, sprintf('Min Value (%0.2g): ', vmin), vmin, 2);
        addNumericField(gd, sprintf('Max Value (%0.2g): ', vmax), vmax, 2);
        showDialog(gd);

        % check if ok or cancel button was clicked
        if wasCanceled(gd)
            return;
        end

        vmin = getNextNumber(gd);
        vmax = getNextNumber(gd);
        kymo.DisplayRange = [vmin vmax];

        updateDisplay(obj);
    end
end

end