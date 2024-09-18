classdef MainFrame < kymorod.gui.KymoRodFrame
% Main frame of the application.
%
%   Displays three panels:
%   * one panel for setting up parameters
%   * one panel for the time-lapse image
%   * one panel for the kymogprah
%
%   Example
%   MainFrame
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inrae.fr
% Created: 2024-08-28,    using Matlab 24.1.0.2653294 (R2024a) Update 5
% Copyright 2024 INRAE - BIA-BIBS.


%% Properties
properties
    % A dictionary of control panels, to retrieve them based on a key.
    ControlPanels = dictionary;

    % The TimeLapse frame to display.
    % Can be one of {'None', 'Input', 'Smoothed', 'Segmented'}.
    ImageToDisplay = 'Input';

    DisplayContour = true;

    DisplayMidline = true;
    
    ZoomMode = 'adjust';

    % The Kymograph to display
    % Can be one of {'Radius', 'Curvature', 'VerticalAngle', 'Elongation'};
    KymographToDisplay = 'Curvature';

end % end properties


%% Constructor
methods
    function obj = MainFrame(gui, analysis, varargin)
        % Constructor for MainFrame class.
        obj = obj@kymorod.gui.KymoRodFrame(gui, analysis);

        % create the figure that will contains the display
        % hFig = kymorod.gui.KymoRodGui.findNewFigureHandle();
        hFig = figure(...
            'MenuBar', 'none', ...
            'NumberTitle', 'off', ...
            'NextPlot', 'new', ...
            'Name', 'KymoRod', ...
            'Visible', 'Off', ...
            'CloseRequestFcn', @obj.close);
        obj.Handles.Figure = hFig;

        % initialize empty handles for graphical items
        obj.Handles.Contour = [];
        obj.Handles.Midline = [];
        obj.Handles.TimeLapseCursor = [];

        % setup position large enough
        pos = [300 200 1000 600];
        set(hFig, 'Position', pos);
        
        % create main figure menu
        setupFigureMenu(hFig);
        
        % creates the layout
        setupLayout(hFig);
        currentPanel = obj.ControlPanels("SelectInputImages");
        select(get(currentPanel, 'UserData'));

        % updateFrameIndex(obj, 15);
        updateTimeLapseDisplay(obj);

        updateTitle(obj);
        
        % adjust zoom to view the full image
        api = iptgetapi(obj.Handles.ScrollPanel);
        mag = api.findFitMag();
        api.setMagnification(mag);
    
        set(hFig, 'Visible', 'On');
        
        function setupFigureMenu(hf)
            
            fileMenu = uimenu(hf, 'Label', 'Files');
            uimenu(fileMenu, 'Label', 'Close');
            
            helpMenu = uimenu(hf, 'Label', 'Help');
            uimenu(helpMenu, 'Label', 'About...');
            
        end
        
        function setupLayout(hf)
            
            % horizontal layout with three panels:
            % 1. control panel
            % 2. TimeLapse Panel
            % 3. Kymograph Panel
            mainPanel = uix.HBoxFlex('Parent', hf, ...
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);

            % -------------------------------------------
            % Control panel display
            % Uses a card panel to initialize all settings panels, and
            % display only the current one.
            % The bottom part is composed of two buttons to navigate
            % between the processing steps.
            obj.Handles.ControlPanel = uix.BoxPanel('Parent', mainPanel, ...
                'Title', 'Controls');
            obj.Handles.ControlLayout = uix.VBox('Parent', obj.Handles.ControlPanel, ...
                'BackgroundColor',[.5 .5 .5]);
            settingsPanel = uix.CardPanel(...
                'Parent', obj.Handles.ControlLayout);

            % add one panel per processing step
            addControlPanel(settingsPanel, 'SelectInputImages', kymorod.gui.panels.SelectInputImagesPanel(obj));
            addControlPanel(settingsPanel, 'SegmentImages', kymorod.gui.panels.SegmentImagesPanel(obj));
            addControlPanel(settingsPanel, 'SmoothContours', kymorod.gui.panels.SmoothContourPanel(obj));
            addControlPanel(settingsPanel, 'ComputeMidlines', kymorod.gui.panels.ComputeMidlinesPanel(obj));
            addControlPanel(settingsPanel, 'CurvatureKymograph', kymorod.gui.panels.CurvatureKymographPanel(obj));
            settingsPanel.Selection = 1;

            obj.Handles.SettingsPanel = settingsPanel;

            obj.Handles.ProcessingButtonsPanel = uix.VBox(...
                'Parent', obj.Handles.ControlLayout);
            buttonRow = uix.HButtonBox('Parent', obj.Handles.ProcessingButtonsPanel);
            obj.Handles.PreviousStepButton = uicontrol(...
                'Parent', buttonRow, ...
                'Style','pushbutton', ...
                'String', 'Prev.', ...
                'Callback', @obj.onPreviousStepButton);
            obj.Handles.NextStepButton = uicontrol(...
                'Parent', buttonRow, ...
                'Style','pushbutton', ...
                'String', 'Next', ...
                'Callback', @obj.onNextStepButton);
            obj.Handles.ControlLayout.Heights = [-1 40];

            % -------------------------------------------
            % Time-lapse display
            % three sub-components:
            % 1. status basr
            % 2. image within a scrollable panel, 
            % 3. frame index panel (text + index edit)
            % 4. frame index slider
            timeLapsePanel = uix.BoxPanel('Parent', mainPanel, ...
                'Title', 'Time-Lapse');
            timeLapseLayout = uix.VBox('Parent', timeLapsePanel);

            % info panel for cursor position and value
            obj.Handles.InfoPanel = uicontrol(...
                'Parent', timeLapseLayout, ...
                'Style', 'text', ...
                'String', ' x=    y=     I=', ...
                'HorizontalAlignment', 'left');
            
            % scrollable panel for image display
            scrollPanel = uipanel('Parent', timeLapseLayout, ...
                'resizeFcn', @obj.onScrollPanelResized);
          
            % creates an axis that fills the available space
            ax = axes('Parent', scrollPanel, ...
                'Units', 'Normalized', ...
                'NextPlot', 'add', ...
                'Position', [0 0 1 1]);
            
            % initialize image display with default image. 
            img = ones(10,10);
            if ~isempty(obj.Analysis.InputImages)
                img = getFrameImage(obj.Analysis.InputImages, 1);
            end
            hIm = imshow(img, 'parent', ax);
            obj.Handles.ScrollPanel = imscrollpanel(scrollPanel, hIm);

            % keep widgets handles
            obj.Handles.TimeLapseAxis = ax;
            obj.Handles.TimeLapseImage = hIm;

            % in case of empty doc, hides the axis
            if isempty(obj.Analysis.InputImages)
                set(ax, 'Visible', 'off');
                set(hIm, 'Visible', 'off');
            end

            % Initialize Widgets for frame index to default state 
            frameIndexPanel = uix.HBox('Parent', timeLapseLayout);
            uicontrol('Parent', frameIndexPanel, ...
                'Style', 'text', 'String', 'Frame Index: ');
            obj.Handles.FrameIndexEdit = uicontrol(...
                'Parent', frameIndexPanel, ...
                'Style', 'edit', ...
                'String', '1');
            obj.Handles.FrameCountLabel = uicontrol(...
                'Parent', frameIndexPanel, ...
                'Style', 'text', ...
                'String', '/ 1');
            uix.Empty('Parent', frameIndexPanel);
            frameIndexPanel.Widths = [90 30 20 -1];
            obj.Handles.FrameIndexSlider = uicontrol(...
                'Parent', timeLapseLayout, ...
                'Style', 'slider', ...
                'Min', 1, 'Max', 1, ...
                'SliderStep', [1 1], ...
                'Value', 1, ...
                'Enable', 'off', ...
                'Callback', @obj.onFrameSliderChanged, ...
                'BackgroundColor', [1 1 1]);
            % code for dragging the slider thumb
            % @see http://undocumentedmatlab.com/blog/continuous-slider-callback
            addlistener(obj.Handles.FrameIndexSlider, ...
                'ContinuousValueChange', @obj.onFrameSliderChanged);

            % If timelapse is valid, enable widgets
            if ~isempty(obj.Analysis.InputImages)
                set(obj.Handles.FrameIndexEdit, ...
                    'String', num2str(obj.Analysis.CurrentFrameIndex));
                set(obj.Handles.FrameCountLabel, ...
                    'String', ['/' num2str(frameCount(obj.Analysis))]);
                % slider for slice
                fmin = 1;
                fmax = frameCount(obj.Analysis.InputImages);
                fstep1 = 1/fmax;
                fstep2 = max(min(10/fmax, .5), fstep1);
                set(obj.Handles.FrameIndexSlider, ...
                    'Min', fmin, 'Max', fmax, ...
                    'SliderStep', [fstep1 fstep2], ...
                    'Value', obj.Analysis.CurrentFrameIndex, ...
                    'Enable', 'on');
            end

            timeLapseLayout.Heights = [20 -1 20 20];

            obj.Handles.KymographPanel = uix.BoxPanel(...
                'Parent', mainPanel, ...
                'Title', 'Kymograph');

            kymographLayout = uix.VBox('Parent', obj.Handles.KymographPanel);

            uix.Empty('Parent', kymographLayout);

            % creates an axis that fills the available space
            obj.Handles.KymographAxis = axes(...
                'Parent', kymographLayout, ...
                'NextPlot', 'add');
            
            % initialize image display with default image. 
            obj.Handles.KymographImage = imagesc(zeros(10, 10), ...
                'parent', obj.Handles.KymographAxis);
            set(obj.Handles.KymographAxis, ...
                'XLim', [1 10], 'YLim', [1 10], 'YTick', []);

            uix.Empty('Parent', kymographLayout);

            kymographLayout.Heights = [-0.5 -2 -0.5]; 

            mainPanel.Widths = [200 -1 -1];
        end

        function addControlPanel(parentPanel, panelKey, controlPanel)
            panel = uipanel('Parent', parentPanel);
            populatePanel(controlPanel, panel);
            set(panel, 'UserData', controlPanel);
            obj.ControlPanels(panelKey) = panel;
        end
    end

end % end constructors


%% Time-Lapse display
methods
    function updateFrameIndex(obj, newIndex)
        % Update widgets, but do not redisplay image.

        if isempty(obj.Analysis)
            return;
        end
        
        obj.Analysis.CurrentFrameIndex = newIndex;
        
        % update gui information for slider and textbox
        set(obj.Handles.FrameIndexSlider, 'Value', newIndex);
        set(obj.Handles.FrameIndexEdit, 'String', num2str(newIndex));
    end

    function updateFrameSliderBounds(obj)
        % To be called when image list is updated, and before display
        % update.

        indices = selectedFileIndices(obj.Analysis.InputImages.ImageList);
        frameCount = length(indices);

        frameIndex = min(obj.Analysis.CurrentFrameIndex, frameCount);
        step1 = 1 / max(frameCount, 1);
        step2 = max(min(10 / frameCount, .5), step1);
        set(obj.Handles.FrameIndexSlider, ...
            'Min', 1, 'Max', frameCount, ...
            'Value', frameIndex, ...
            'SliderStep', [step1 step2]);
    end

    function updateTimeLapseDisplay(obj)
        % Refresh image display of the current frame.

        % basic check up to avoid problems when display is already closed
        if ~ishandle(obj.Handles.ScrollPanel)
            return;
        end
        
        % check up doc validity
        if isempty(obj.Analysis.InputImages)
            return;
        end

        img = [];
        index = obj.Analysis.CurrentFrameIndex;
        switch obj.ImageToDisplay
            case 'None'
            case 'Input'
                if obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Selection
                    img = getSegmentableImage(obj.Analysis, index);
                end
            case 'Smoothed'
                if obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Selection
                    img = getSmoothedImage(obj.Analysis, index);
                end
            case 'Segmented'
                if obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Selection
                    img = getSegmentedImage(obj.Analysis, index);
                end
            otherwise
                warning('Could not interpret type of image to display: %s', obj.ImageToDisplay);
                return;
        end
        if isempty(img)
            dims = obj.Analysis.InputImages.ImageSize;
            if all(dims == [0 0])
                dims = [10 10];
            end
            img = 255 * ones(dims([2 1]));
        end
        if islogical(img)
            img = 255 * uint8(img);
        end

        % changes current display data
        api = iptgetapi(obj.Handles.ScrollPanel);
%         loc = api.getVisibleLocation();
        api.replaceImage(repmat(img, [1 1 3]), 'PreserveView', true);
%         api.setVisibleLocation(loc);
               
        % remove all axis children that are not image
        children = get(obj.Handles.TimeLapseAxis, 'Children');
        for i = 1:length(children)
            child = children(i);
            if ~strcmpi(get(child, 'Type'), 'Image')
                delete(child);
            end
        end

        if obj.DisplayContour && obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Contour
            updateContourDisplay(obj);
        end

        if obj.DisplayMidline && obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Midline
            updateMidlineDisplay(obj);
        end

    end

    function updateContourDisplay(obj)

        if isempty(obj.Analysis.Contours)
            warning('Can not diplay contours if not computed');
        end

        % Remove previous display
        if ~isempty(obj.Handles.Contour) && ishandle(obj.Handles.Contour)
            delete(obj.Handles.Contour);
            obj.Handles.Contour = [];
        end

        % Display contour data if necessary      
        if obj.DisplayContour && obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Contour
            % retrieve current smooth contour
            index = obj.Analysis.CurrentFrameIndex;
            contour = getSmoothedContour(obj.Analysis, index);
            
            % draw contour from new data
            obj.Handles.Contour = drawPolygon(obj.Handles.TimeLapseAxis, contour, ...
                'LineWidth', 1, 'Color', 'r');
            % applyStyle(obj.Experiment.ContourStyle, obj.Handles.Contour);
        end
    end

    function updateMidlineDisplay(obj)
        if isempty(obj.Analysis.Midlines)
            warning('Can not diplay midlines if not computed');
        end

        % Remove previous display
        if ~isempty(obj.Handles.Midline) && ishandle(obj.Handles.Midline)
            delete(obj.Handles.Midline);
            obj.Handles.Midline = [];
        end

        % Display contour data if necessary      
        if obj.DisplayMidline && obj.Analysis.ProcessingStep >= kymorod.app.ProcessingStep.Midline
            % retrieve current midline
            index = obj.Analysis.CurrentFrameIndex;
            midline = obj.Analysis.Midlines{index};
            
            % draw contour from new data
            obj.Handles.Midline = draw(obj.Handles.TimeLapseAxis, midline, ...
                'LineWidth', 1, 'Color', 'b');
            % applyStyle(obj.Experiment.MidlineStyle, obj.Handles.Contour);
        end
    end
end

%% Zoom Management
methods
    function zoom = getCurrentZoomLevel(obj)
        api = iptgetapi(obj.Handles.ScrollPanel);
        zoom = api.getMagnification();
    end
    
    function setCurrentZoomLevel(obj, newZoom)
        api = iptgetapi(obj.Handles.ScrollPanel);
        api.setMagnification(newZoom);
    end
    
    function zoom = findBestZoom(obj)
        api = iptgetapi(obj.Handles.ScrollPanel);
        zoom = api.findFitMag();
    end
    
    function mode = getZoomMode(obj)
        mode = obj.ZoomMode;
    end
    
    function setZoomMode(obj, mode)
        switch lower(mode)
            case 'adjust'
                obj.ZoomMode = 'adjust';
            case 'fixed'
                obj.ZoomMode = 'fixed';
            otherwise
                error(['Unrecognized zoom mode option: ' mode]);
        end
    end
end


%% Kymograph display methods
methods
    function updateKymographDisplay(obj)
        % Refresh kymograph display.
        disp('update kymograph display');

        kymo = getKymograph(obj.Analysis, obj.KymographToDisplay);
        img = kymo.Data;

        timeStep = obj.Analysis.InputImages.Calibration.TimeInterval;
        xdata = (0:(size(img, 2)-1)) * timeStep;
        ydata = 1:size(img, 1);

        set(obj.Handles.KymographImage, ...
            'xdata', xdata, ...
            'ydata', ydata, ...
            'cdata', img);
        set(obj.Handles.KymographAxis, 'XLim', ([0 size(img,2)] - .5) * timeStep);
        set(obj.Handles.KymographAxis, ...
            'YDir', 'normal', ...
            'YLim', [1 size(img, 1)], ...
            'YTick', []);

        validateDisplayRange(kymo);
        clim(obj.Handles.KymographAxis, kymo.DisplayRange);

        colormap('parula');
    end
end


%% GUI Widgets listeners
methods
    function onPreviousStepButton(obj, src, ~)
        index = obj.Handles.SettingsPanel.Selection;
        if index > 1
            % switch to next panel
            index = index - 1;
            obj.Handles.SettingsPanel.Selection = index;
            panel = retrieveControlPanel(obj, index);
            select(get(panel, 'UserData'));
        end
    end

    function onNextStepButton(obj, src, ~)
        index = obj.Handles.SettingsPanel.Selection;
        if index < length(obj.Handles.SettingsPanel.Children)
            % deselect controls of old panel
            panel = retrieveControlPanel(obj, index);
            validateProcess(get(panel, 'UserData'));

            % switch to next panel
            index = index + 1;
            obj.Handles.SettingsPanel.Selection = index;
            panel = retrieveControlPanel(obj, index);
            select(get(panel, 'UserData'));
        end
    end

    function panel = retrieveControlPanel(obj, index)
        % Identify the panel corresponding to current step.
        % The associated controller is stored in 'UserData' field.
        switch (index)
            case 1, panel = obj.ControlPanels("SelectInputImages");
            case 2, panel = obj.ControlPanels("SegmentImages");
            case 3, panel = obj.ControlPanels("SmoothContours");
            case 4, panel = obj.ControlPanels("ComputeMidlines");
            case 5, panel = obj.ControlPanels("CurvatureKymograph");
        end
    end

    function onFrameSliderChanged(obj, hObject, eventdata) %#ok<*INUSD>
        % Callback to widgets that change index of current frame.

        if isempty(obj.Analysis)
            return;
        end
        nFrames = frameCount(obj.Analysis);
        if nFrames == 0
            return;
        end

        frameIndex = round(get(hObject, 'Value'));
        % ensure valide value
        frameIndex = max(1, min(nFrames, frameIndex));

        updateFrameIndex(obj, frameIndex);
        updateTimeLapseDisplay(obj);
    end
end


%% Figure management
methods
    function close(obj, varargin)
        delete(obj.Handles.Figure);
    end
    
    function updateTitle(obj)

        % small checkup, because function can be called before figure was
        % initialised
        if ~isfield(obj.Handles, 'Figure')
            return;
        end
        
        if isempty(obj.Analysis.InputImages)
            return;
        end
        
        % compute image zoom
        zoom = getCurrentZoomLevel(obj);
        
        % compute new title string
        imgName = 'Time-Lapse';
        sizeString = sprintf('%d x %d', obj.Analysis.InputImages.ImageSize);
        nf = frameCount(obj.Analysis.InputImages);
        sizeString = sprintf('%s (x%d)', sizeString, nf);
        zoomString = sprintf('%g:%g', max(1, zoom), max(1, 1/zoom));
        titlePattern = '%s [%s %s] - KymoRod';
        titleString = sprintf(titlePattern, imgName, sizeString, zoomString);
        
        % display new title
        set(obj.Handles.Figure, 'Name', titleString);
    end

    function onScrollPanelResized(obj, varargin)
        % function called when the Scroll panel has been resized

       if strcmp(obj.ZoomMode, 'adjust')
            if ~isfield(obj.Handles, 'ScrollPanel')
                return;
            end
            scroll = obj.Handles.ScrollPanel;
            api = iptgetapi(scroll);
            mag = api.findFitMag();
            api.setMagnification(mag);
            updateTitle(obj);
        end
    end
    
end

end % end classdef

