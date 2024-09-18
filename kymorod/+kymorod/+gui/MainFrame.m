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
    ZoomMode = 'adjust';

    % A dictionary of control panels, to retrieve them based on a key.
    ControlPanels = dictionary;

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

        % setup position large enough
        % pos = get(hFig, 'Position');
        pos = [300 200 1000 600];
        set(hFig, 'Position', pos);
        
        % create main figure menu
        setupFigureMenu(hFig);
        
        % creates the layout
        setupLayout(hFig);
        selectControlPanel(obj, 1);

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
            % (as a card panel ?)
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
            buttonRow1 = uix.HButtonBox('Parent', obj.Handles.ProcessingButtonsPanel);
            obj.Handles.UpdateProcessButton = uicontrol(...
                'Parent', buttonRow1, ...
                'Style','pushbutton', ...
                'String', 'Update');
            buttonRow2 = uix.HButtonBox('Parent', obj.Handles.ProcessingButtonsPanel);
            obj.Handles.PreviousProcessButton = uicontrol(...
                'Parent', buttonRow2, ...
                'Style','pushbutton', ...
                'String', 'Prev.', ...
                'Callback', @obj.onPreviousStepButton);
            obj.Handles.NextProcessButton = uicontrol(...
                'Parent', buttonRow2, ...
                'Style','pushbutton', ...
                'String', 'Next', ...
                'Callback', @obj.onNextStepButton);
            obj.Handles.ControlLayout.Heights = [-1 80];

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

            % % once each panel has been resized, setup image magnification
            % api = iptgetapi(obj.Handles.ScrollPanel);
            % mag = api.findFitMag();
            % api.setMagnification(mag);
            
            obj.Handles.KymographPanel = uix.BoxPanel(...
                'Parent', mainPanel, ...
                'Title', 'Kymograph');

            % creates an axis that fills the available space
            obj.Handles.KymographAxis = axes(...
                'Parent', obj.Handles.KymographPanel, ...
                'NextPlot', 'add');
            
            % initialize image display with default image. 
            obj.Handles.KymographImage = imshow(ones(10, 10), ...
                'parent', obj.Handles.KymographAxis);

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
        timeLapse = obj.Analysis.InputImages;

        % compute display data
        frameImage = getFrameImage(timeLapse, obj.Analysis.CurrentFrameIndex);
   
        % changes current display data
        api = iptgetapi(obj.Handles.ScrollPanel);
%         loc = api.getVisibleLocation();
        api.replaceImage(frameImage, 'PreserveView', true);
%         api.setVisibleLocation(loc);
               
        % remove all axis children that are not image
        children = get(obj.Handles.TimeLapseAxis, 'Children');
        for i = 1:length(children)
            child = children(i);
            if ~strcmpi(get(child, 'Type'), 'Image')
                delete(child);
            end
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


%% GUI Widgets listeners
methods
    function onPreviousStepButton(obj, src, ~)
        stepIndex = obj.Handles.SettingsPanel.Selection;
        if stepIndex > 1
            selectControlPanel(obj, stepIndex - 1);
        end
    end

    function onNextStepButton(obj, src, ~)
        stepIndex = obj.Handles.SettingsPanel.Selection;
        if stepIndex < length(obj.Handles.SettingsPanel.Children)
            selectControlPanel(obj, stepIndex + 1);
        end
    end

    function selectControlPanel(obj, index)
        % Select the panel given by its index, and call associated controler.

        % retrieve panel index in "SettingsPanel" CardPanel
        obj.Handles.SettingsPanel.Selection = index;

        % identify the panel corresponding to current step
        switch (index)
            case 1, panel = obj.ControlPanels("SelectInputImages");
            case 2, panel = obj.ControlPanels("SegmentImages");
            case 3, panel = obj.ControlPanels("SmoothContours");
            case 4, panel = obj.ControlPanels("ComputeMidlines");
            case 5, panel = obj.ControlPanels("CurvatureKymograph");
        end
        
        % retrieve controler instance and call the update method
        select(get(panel, 'UserData'));
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

