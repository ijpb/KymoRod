function varargout = DisplayKymograph(varargin)
% DISPLAYKYMOGRAPH MATLAB code for DisplayKymograph.fig
%      DISPLAYKYMOGRAPH, by itself, creates a new DISPLAYKYMOGRAPH or raises the existing
%      singleton*.
%
%      H = DISPLAYKYMOGRAPH returns the handle to a new DISPLAYKYMOGRAPH or the handle to
%      the existing singleton*.
%
%      DISPLAYKYMOGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYKYMOGRAPH.M with the given input arguments.
%
%      DISPLAYKYMOGRAPH('Property','Value',...) creates a new DISPLAYKYMOGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DisplayKymograph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DisplayKymograph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DisplayKymograph

% Last Modified by GUIDE v2.5 12-Feb-2016 14:51:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DisplayKymograph_OpeningFcn, ...
                   'gui_OutputFcn',  @DisplayKymograph_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DisplayKymograph is made visible.
function DisplayKymograph_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DisplayKymograph (see VARARGIN)

% Choose default command line output for DisplayKymograph
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'KymoRod')
    app = varargin{1};
    setappdata(0, 'app', app);
else
    error('Run DisplayKymograph using deprecated call');
end

% setup figure menu
gui = KymoRodGui.getInstance();
buildFigureMenu(gui, hObject, app);

% compute number of frames that can be displayed
nFrames = frameNumber(app);
if strcmp(app.kymographDisplayType, 'elongation')
    % remove two frames for elongation kymographs
    nFrames = nFrames - 2; 
end

% get index of current frame, eventually corrected by max frame number
frameIndex = app.currentFrameIndex;
frameIndex = min(frameIndex, nFrames);

% Display current image
axes(handles.imageAxes); hold on;
% display grayscale image as RGB, to avoid colormap problems
img = getImage(app, frameIndex);
if ndims(img) == 2 %#ok<ISMAT>
    img = repmat(img, [1 1 3]);
end
handles.imageHandle = imshow(img);

% setup slider for display of current frame
set(handles.currentFrameSlider, 'Min', 1, 'Max', nFrames, 'Value', frameIndex); 
sliderStep = min(max([1 5] ./ (nFrames - 1), 0.001), 1);
set(handles.currentFrameSlider, 'SliderStep', sliderStep); 

% get geometric data for annotations
contour = getSmoothedContour(app, frameIndex);
skeleton = getSkeleton(app, frameIndex);

% create handles for geometric annotations
handles.contourHandle   = drawContour(contour, 'r');
handles.skeletonHandle  = drawSkeleton(skeleton, 'b');
handles.colorSkelHandle = scatter(skeleton(:, 1), skeleton(:, 2), ...
    [], 'b', 'filled', 'Visible', 'off');
handles.imageMarker     = drawMarker(skeleton(1, :), ...
    'd', 'Color', 'k', 'LineWidth', 1, 'MarkerFaceColor', 'w');

% update the widget for choosing the type of kymograph
switch lower(app.kymographDisplayType)
    case 'radius'
        set(handles.kymographTypePopup, 'Value', 1);
    case 'verticalangle'
        set(handles.kymographTypePopup, 'Value', 2);
    case 'curvature' 
        set(handles.kymographTypePopup, 'Value', 3);
    case 'elongation'
        set(handles.kymographTypePopup, 'Value', 4);
    otherwise
        warning(['Could not interpret kymograph type: ' app.kymographDisplayType]);
end

% compute display extent for elongation kymograph
img = getKymographMatrix(app);
minCaxis = min(img(:));
maxCaxis = max(img(:));

setappdata(0, 'minCaxis', minCaxis);
setappdata(0, 'maxCaxis', maxCaxis);

set(handles.slider1, 'Min', minCaxis);
set(handles.slider1, 'Max', maxCaxis);
set(handles.slider1, 'Value', minCaxis);

updateKymographDisplay(handles);
displayCurrentFrameIndex(handles);

handles.kymographMarker = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DisplayKymograph wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = DisplayKymograph_OutputFcn(hObject, eventdata, handles)%#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function updateCurrentFrameDisplay(handles)
% refresh display of current frame: image, and eventually colored skeleton

% extract data for current frame
app = getappdata(0, 'app');
frameIndex = app.currentFrameIndex;

% create RGB image from app data
img = app.getImage(frameIndex);
if ndims(img) == 2 %#ok<ISMAT>
    img = repmat(img, [1 1 3]);
end

% extract geometric annotations
contour = getSmoothedContour(app, frameIndex);
skeleton = getSkeleton(app, frameIndex);

% update display
axes(handles.imageAxes);
set(handles.imageHandle, 'CData', img);
set(handles.contourHandle, 'XData', contour(:,1), 'YData', contour(:,2));
set(handles.skeletonHandle, 'XData', skeleton(:,1), 'YData', skeleton(:,2));


function displayCurrentFrameIndex(handles)
% Updates the content of the "currentFrameIndex" label
% Typically after slider update, or after click on kymograph

% get current frame index and number
app = getappdata(0, 'app');
frameIndex = app.currentFrameIndex;
nFrames = frameNumber(app);

% update label display
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameLabel, 'String', string);


% --------------------------------------------------------------------
function mainMenuMenuItem_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to mainMenuMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


% --- Executes on slider movement.
function currentFrameSlider_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% compute new value for frame index
app = getappdata(0, 'app');
frameIndex = round(get(handles.currentFrameSlider, 'Value'));

app.currentFrameIndex = frameIndex;
setappdata(0, 'app', app);

displayCurrentFrameIndex(handles);

updateCurrentFrameDisplay(handles);
if strcmpi(get(handles.colorSkelHandle, 'Visible'), 'On')
    updateColoredSkeleton(handles);
end


% --- Executes during object creation, after setting all properties.
function currentFrameSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in showColoredSkeletonCheckBox.
function showColoredSkeletonCheckBox_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to showColoredSkeletonCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showColoredSkeletonCheckBox

if get(handles.showColoredSkeletonCheckBox, 'Value')
    updateColoredSkeleton(handles);
    set(handles.colorSkelHandle, 'Visible', 'On');
else
    set(handles.colorSkelHandle, 'Visible', 'Off');
end


% --- Executes on selection change in kymographTypePopup.
function kymographTypePopup_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to kymographTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns kymographTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from kymographTypePopup
% To select the kymograph with a popupmenu

app = getappdata(0, 'app');

% Choose the kymograph to display
valPopUp = get(handles.kymographTypePopup, 'Value');
switch valPopUp
    case 1
        app.kymographDisplayType = 'radius';
        img = app.radiusImage;
    case 2
        app.kymographDisplayType = 'verticalAngle';
        img = app.verticalAngleImage;
    case 3
        app.kymographDisplayType = 'curvature';
        img = app.curvatureImage;
    case 4
        app.kymographDisplayType = 'elongation';
        img = app.elongationImage;
end
minCaxis = min(img(:));
maxCaxis = max(img(:));

setappdata(0, 'minCaxis', minCaxis);
setappdata(0, 'maxCaxis', maxCaxis);

set(handles.slider1, 'Min', minCaxis);
set(handles.slider1, 'Max', maxCaxis);
set(handles.slider1, 'Value', minCaxis);

updateKymographDisplay(handles);
if strcmpi(get(handles.colorSkelHandle, 'Visible'), 'On')
    updateColoredSkeleton(handles);
end
   
handles.kymographMarker = [];
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function kymographTypePopup_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU,INUSD>
% hObject    handle to kymographTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function updateColoredSkeleton(handles)

app = getappdata(0, 'app');

% coordinates of current skeleton
frameIndex = app.currentFrameIndex;
skeleton = getSkeleton(app, frameIndex);
xdata = skeleton(:, 1);
ydata = skeleton(:, 2);

% switch depending on value to display
valPopUp = get(handles.kymographTypePopup, 'Value');
switch valPopUp
    case 1, values = app.radiusList{frameIndex};
    case 2, values = app.verticalAngleList{frameIndex};
    case 3, values = app.curvatureList{frameIndex};
    case 4
        % make sure frame index is valid for elongation data
        frameIndex = min(frameIndex, length(app.elongationList));
        skeleton = getSkeleton(app, frameIndex);
        
        % extract the values of elongation
        elg = app.elongationList{frameIndex};
        values = elg(:, 2);
        
        % need to re-compute x and y data, as they are computed on a pixel
        % approximation of the skeleton
        abscissa = app.abscissaList{frameIndex};
        inds = zeros(size(elg, 1), 1);
        for i = 1:length(inds)
            inds(i) = find(abscissa > elg(i,1), 1, 'first');
        end
        xdata = skeleton(inds, 1);
        ydata = skeleton(inds, 2);

end

% extract bounds
vmin = getappdata(0, 'minCaxis');
val = get(handles.slider1, 'Value');
vmax = getappdata(0, 'maxCaxis') - val;

% create 256-by-3 array of colors
cmap = jet(256);
inds = floor((values - vmin) * 255 / (vmax - vmin)) + 1;
inds = max(min(inds, 256), 1);
colors = cmap(inds, :);

if isfield(handles, 'colorSkelHandle')
    set(handles.colorSkelHandle, ...
        'XData', xdata, 'YData', ydata, 'CData', colors);
end

% --- Executes on mouse press over axes background.
function kymographAxes_ButtonDownFcn(hObject, eventdata, handles)%#ok
% hObject    handle to kymographAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% To show a picture with contour and skeleton corresponding at kymograph
% clic

handles = guidata(hObject);

app     = getappdata(0, 'app');
nx      = app.settings.finalResultLength;

% extract last clicked position, x = index of frame
pos = get(handles.kymographAxes, 'CurrentPoint');
posX = pos(1);
posY = pos(3);

% Display marker on kymograph image
if isempty(handles.kymographMarker)
    % create new marker
    axes(handles.kymographAxes); hold on;
    handles.kymographMarker = plot(posX, posY, ...
        'd', 'LineWidth', 1, 'color', 'k', 'MarkerFaceColor', 'w');
else
    % update position of current marker
    set(handles.kymographMarker, 'XData', posX, 'YData', posY);
end

% determine index of frame corresponding to clicked point
frameIndex = round(posX / (app.settings.timeInterval * app.indexStep)) + 1;
app.currentFrameIndex = frameIndex;

% extract data for current frame
img = app.getImage(frameIndex);
if ndims(img) == 2 %#ok<ISMAT>
    img = repmat(img, [1 1 3]);
end
contour = getSmoothedContour(app, frameIndex);
skeleton = getSkeleton(app, frameIndex);

% update display
axes(handles.imageAxes);
set(handles.imageHandle, 'CData', img);
set(handles.contourHandle, 'XData', contour(:,1), 'YData', contour(:,2));
set(handles.skeletonHandle, 'XData', skeleton(:,1), 'YData', skeleton(:,2));

% convert y-coordinate to curvilinear abscissa
Smax = app.abscissaList{end}(end);
Smin = 0;
Smarker = (posY - Smin) * (Smax - Smin) / nx;

S = app.abscissaList{frameIndex};
ind = find(Smarker <= S, 1, 'first');
ind = max(ind, 1);
if isempty(ind)
    ind = size(skeleton, 1);
end
set(handles.imageMarker, 'xdata', skeleton(ind, 1), 'ydata', skeleton(ind, 2));

if strcmpi(get(handles.colorSkelHandle, 'Visible'), 'On')
    updateColoredSkeleton(handles);
end    

% update display of frame info
setappdata(0, 'app', app);
updateCurrentFrameDisplay(handles);
displayCurrentFrameIndex(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateKymographDisplay(handles);
if strcmpi(get(handles.colorSkelHandle, 'Visible'), 'On')
    updateColoredSkeleton(handles);
end


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)%#ok<INUSD>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function updateKymographDisplay(handles)

app = getappdata(0, 'app');

minCaxis = getappdata(0, 'minCaxis');
maxCaxis = getappdata(0, 'maxCaxis');

img = getKymographMatrix(app);

% display current kymograph
timeInterval = app.settings.timeInterval;
xdata = (0:(size(img, 2)-1)) * timeInterval * app.indexStep;
ydata = 1:size(img, 1);
axes(handles.kymographAxes);
hImg = imagesc(xdata, ydata, img);

% a value to adjust kymograph contrast
val = get(handles.slider1, 'Value');
  
% setup display
set(gca, 'YDir', 'normal', 'YTick', []);
if minCaxis < maxCaxis - val
    caxis([minCaxis, maxCaxis - val]); 
end
colorbar; colormap jet;

% add the function handle to capture mouse clicks
set(hImg, 'buttondownfcn', {@kymographAxes_ButtonDownFcn, handles});

% annotate
xlabel(sprintf('Time (%s)', app.settings.timeIntervalUnit));


% --- Executes on button press in saveAsPngButton.
function saveAsPngButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to saveAsPngButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open a dialog to select a PNG file
[fileName, pathName] = uiputfile({'*.png'});

% check dialog was canceled
if fileName == 0
    return;
end

app = getappdata(0, 'app');

hf = figure; 
set(gca, 'fontsize', 14);
showCurrentKymograph(app);
print(hf, fullfile(pathName, fileName), '-dpng');
close(hf);


% --- Executes on button press in saveAsTiffButton.
function saveAsTiffButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to saveAsTiffButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open a dialog to select a PNG file
[fileName, pathName] = uiputfile({'*.tif'});

% check dialog was canceled
if fileName == 0
    return;
end

app = getappdata(0, 'app');

hf = figure; 
set(gca, 'fontsize', 14);
showCurrentKymograph(app);
print(hf, fullfile(pathName, fileName), '-dtiff');
close(hf);


% --- Executes on button press in saveAllDataButton.
function saveAllDataButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to saveAllDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% disable save button to avoid multiple clicks
set(handles.saveAllDataButton, 'Enable', 'Off')
set(handles.saveAllDataButton, 'String', 'Wait please...')
pause(0.01);

% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile('*.mat', ...
    'Save Kymographs');

if pathName == 0
    return;
end

disp('Saving...');

% retrieve application data
app = getappdata(0, 'app');

% filename of mat file
[emptyPath, baseName, ext] = fileparts(fileName); %#ok<ASGLU>
filePath = fullfile(pathName, [baseName '.mat']);

% save full application data as mat file, without image data
imgTemp = app.imageList;
app.imageList = {};
save(app, filePath);
app.imageList = imgTemp;

% save all informations of experiment, to retrieve them easily
filePath = fullfile(pathName, [baseName '-kymo.txt']);
write(app, filePath);

% save settings of experiment, to apply them to another experiment
filePath = fullfile(pathName, [baseName '-settings.txt']);
write(app.settings, filePath);

% initialize row names
nFrames = frameNumber(app);
rowNames = cell(nFrames, 1);
if isstruct(app.imageNameList)
	for i = 1:nFrames
		rowNames{i} = app.imageNameList(i).name;
	end
elseif iscell(app.imageNameList)
	for i = 1:nFrames
		rowNames{i} = app.imageNameList{i};
	end
else
	for i = 1:nFrames
		rowNames{i} = sprintf('frame%03d', i);
	end
end

% save individual image arrays
RE1     = app.radiusImage;
AE1     = app.verticalAngleImage;
CE1     = app.curvatureImage;
ElgE1   = app.elongationImage;

% initialize col names: a list of values
nPositions = app.settings.finalResultLength;
colNames = strtrim(cellstr(num2str((1:nPositions)', '%d'))');

% Save each data file as tab separated values
filePath = fullfile(pathName, [baseName '-radius.csv']);
writeTable(RE1', colNames, rowNames, filePath);

filePath = fullfile(pathName, [baseName '-angle.csv']);
writeTable(AE1', colNames, rowNames, filePath);

filePath = fullfile(pathName, [baseName '-curvature.csv']);
writeTable(CE1', colNames, rowNames, filePath);

filePath = fullfile(pathName, [baseName '-elongation.csv']);
writeTable(ElgE1', colNames, rowNames(2:end-1), filePath);

disp('Saving done');

% re-enable save button
set(handles.saveAllDataButton, 'Enable', 'On')
set(handles.saveAllDataButton, 'String', 'Save all data')


% --- Executes on button press in backToElongationButton.
function backToElongationButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to backToElongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ChooseElongationSettingsDialog(app);


% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

button = questdlg({'This will quit the program', 'Are you sure ?'}, ...
    'Quit Confirmation', ... 
    'Yes', 'No', 'No');

if strcmp(button, 'Yes')
    delete(gcf);
end
