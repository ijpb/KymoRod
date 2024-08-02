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

    KymographTypes = {'Radius', 'Vertical Angle', 'Curvature', 'Elongation', 'Intensity'};

    ColormapNames = {'Jet', 'Parula', 'Blue-White-Red'};
    
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
        obj.Handles.Figure = fig;
        
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

            controlPanel = uix.HButtonBox('Parent', mainPanel);
            uicontrol('Parent', controlPanel, 'Style', 'text', ...
                'String', 'Kymograph:', ...
                'FontSize', 10);
            obj.Handles.KymographType = uicontrol(...
                'Parent', controlPanel, ...
                'Style', 'popupmenu', ...
                'String', obj.KymographTypes, ...
                'FontSize', 10, ...
                'Callback', @(src, evt) obj.onKymographDropdownChanged);
            uicontrol('Parent', controlPanel, 'Style', 'text', ...
                'String', 'Colormap:', ...
                'FontSize', 10);
            obj.Handles.ColormapName = uicontrol(...
                'Parent', controlPanel, ...
                'Style', 'popupmenu', ...
                'String', obj.ColormapNames, ...
                'FontSize', 10, ...
                'Callback', @(src, evt) obj.onColormapDropdownChanged);
            set(controlPanel, ...
                'ButtonSize', [130 35], ...
                'Spacing', 5);

            % creates an axis that fills the available space
            ax = axes('Parent', uicontainer('Parent', mainPanel), ...
                'YDir', 'normal');
            
            % intialize image display with default image.
            kymo = getCurrentKymograph(obj.AppData);
            hIm = imagesc(ax, kymo.Data);
            
            % keep widgets handles
            obj.Handles.ImageAxis = ax;
            obj.Handles.Image = hIm;
            
            % info panel for cursor position and value
            obj.Handles.StatusBar = uicontrol(...
                'Parent', mainPanel, ...
                'Style', 'text', ...
                'String', ' x=    y=     I=', ...
                'HorizontalAlignment', 'left');
            
            % right panel fixed size, the remaining for left panel
            mainPanel.Heights = [35 -1 20];
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
        set(obj.Handles.Image, ...
            'CData', img, ...
            'XData', xdata, ...
            'YData', ydata ...
            );
        set(obj.Handles.ImageAxis, ...
            'DataAspectRatioMode', 'auto', ...
            'XLim', xdata([1 end]), ...
            'YLim', ydata([1 end]), ...
            'YDir', 'normal', ...
            'CLim', kymo.DisplayRange);

        % update graph annotations
        title(obj.Handles.ImageAxis, kymo.Name);
        xlabel(obj.Handles.ImageAxis, createLabel(kymo.TimeAxis));
        ylabel(obj.Handles.ImageAxis, createLabel(kymo.PositionAxis));
    end

    function updateTitle(obj, varargin) %#ok<INUSD>
        % disp('Update title');
    end

    function close(obj, varargin)
        delete(obj.Handles.Figure);
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

%% Methods for widget callbacks
methods
    function onKymographDropdownChanged(obj)
        app = obj.AppData;
        index = obj.Handles.KymographType.Value;
        typeList = {'radius', 'verticalAngle', 'curvature', 'elongation', 'intensity'};
        app.kymographDisplayType = typeList{index};
        updateDisplay(obj);
    end

    function onColormapDropdownChanged(obj)
        index = obj.Handles.ColormapName.Value;
        switch index
            case 1, colormap(obj.Handles.ImageAxis, jet(256));
            case 2, colormap(obj.Handles.ImageAxis, 'parula');
            case 3, colormap(obj.Handles.ImageAxis, blue2White2Red);
        end
    end
end

end