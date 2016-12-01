function varargout = ChooseThresholdDialog(varargin)
% CHOOSETHRESHOLDDIALOG MATLAB code for ChooseThresholdDialog.fig
%      CHOOSETHRESHOLDDIALOG, by itself, creates a new CHOOSETHRESHOLDDIALOG or raises the existing
%      singleton*.
%
%      H = CHOOSETHRESHOLDDIALOG returns the handle to a new CHOOSETHRESHOLDDIALOG or the handle to
%      the existing singleton*.
%
%      CHOOSETHRESHOLDDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSETHRESHOLDDIALOG.M with the given input arguments.
%
%      CHOOSETHRESHOLDDIALOG('Property','Value',...) creates a new CHOOSETHRESHOLDDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseThresholdDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseThresholdDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseThresholdDialog

% Last Modified by GUIDE v2.5 01-Dec-2016 11:48:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseThresholdDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseThresholdDialog_OutputFcn, ...
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


% --- Executes just before ChooseThresholdDialog is made visible.
function ChooseThresholdDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseThresholdDialog (see VARARGIN)

% Choose default command line output for ChooseThresholdDialog
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'KymoRod')
    % should be the canonical way of calling the program
    app = varargin{1};    
else
    error('requires 4 input arguments, with a KymoRod instance as fourth argument');
end

app.logger.info('ChooseThresholdDialog.m', ...
    'Open the dialog: ChooseThresholdDialog');

% update current process state
setappdata(0, 'app', app);

% setup figure menu
gui = KymoRodGui.getInstance();
buildFigureMenu(gui, hObject, app);

% retrieve app data
frameIndex = app.currentFrameIndex;
nFrames = frameNumber(app);

switch app.settings.imageSmoothingMethod
    case 'none'
        set(handles.imageSmoothingMethodPopup, 'Value', 1);
    case 'boxFilter'
        set(handles.imageSmoothingMethodPopup, 'Value', 2);
    case 'gaussian'
        set(handles.imageSmoothingMethodPopup, 'Value', 3);
end
string = num2str(app.settings.imageSmoothingRadius);
set(handles.imageSmoothingRadiusEdit, 'String', string);

set(handles.autoThresholdFinalEdit, 'String', num2str(nFrames));

% setup slider steps for manual threshold slider
sliderStep = min(max([1 10] ./ 255, 0.001), 1);
set(handles.manualThresholdSlider, 'SliderStep', sliderStep); 

updateWidgetsVisibility(handles);


% setup slider for display of current frame
set(handles.frameIndexSlider, 'Min', 1); 
set(handles.frameIndexSlider, 'Max', nFrames); 
set(handles.frameIndexSlider, 'Value', frameIndex); 
sliderStep = min(max([1 5] ./ (nFrames - 1), 0.001), 1);
set(handles.frameIndexSlider, 'SliderStep', sliderStep); 

% eventually pre-compute threshold values
if getProcessingStep(app) < ProcessingStep.Threshold
    computeThresholdValues(app);
end

% update widgets
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameIndexLabel, 'String', string);

% display threshold of current frame
displayCurrentFrameThreshold(handles);

% display current binarised image
seg = getSegmentedImage(app, frameIndex);
axis(handles.currentFrameAxes);
handles.imageHandle = imshow(seg);

guidata(hObject, handles);

% UIWAIT makes ChooseThresholdDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ChooseThresholdDialog_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Utility functions

function displayCurrentFrameThreshold(handles)
% display threshold information of current frame

% get app data
app = getappdata(0, 'app');

frameIndex = app.currentFrameIndex;

currentThreshold = int16(app.thresholdValues(frameIndex));
baseThreshold = int16(app.baseThresholdValues(frameIndex));
diffThreshold = currentThreshold - baseThreshold;

if diffThreshold >= 0
    string = sprintf('Threshold = %d (%d + %d)', ...
        currentThreshold, baseThreshold, diffThreshold);
else
    string = sprintf('Threshold = %d (%d - %d)', ...
        currentThreshold, baseThreshold, -diffThreshold);
end

set(handles.currentFrameThresholdLabel, 'String', string);


function updateSegmentationDisplay(handles)
% display threshold information of current frame

% get app data
app = getappdata(0, 'app');

% compute/get current segmentation
frameIndex = app.currentFrameIndex;
seg = getSegmentedImage(app, frameIndex);

% update display
set(handles.imageHandle, 'CData', seg);


%% Menu

function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


%% Display of current frame

% --- Executes on slider movement.
function frameIndexSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');

frameIndex = round(get(handles.frameIndexSlider, 'Value'));
app.currentFrameIndex = frameIndex;
setappdata(0, 'app', app);

% compute and display segmented image
% bin = getSegmentedImage(app, frameIndex);
% axes(handles.currentFrameAxes)
% imshow(bin);
updateSegmentationDisplay(handles);

% display threshold level of current image
displayCurrentFrameThreshold(handles);

% show info on current frame
nFrames = frameNumber(app);
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameIndexLabel, 'String', string);


% --- Executes during object creation, after setting all properties.
function frameIndexSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



%% Widgets for image smoothing

% --- Executes on selection change in imageSmoothingMethodPopup.
function imageSmoothingMethodPopup_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to imageSmoothingMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageSmoothingMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageSmoothingMethodPopup

app = getappdata(0, 'app');
switch get(handles.imageSmoothingMethodPopup, 'Value')
    case 1
        app.settings.imageSmoothingMethod = 'none';
    case 2
        app.settings.imageSmoothingMethod = 'boxFilter';
    case 3
        app.settings.imageSmoothingMethod = 'gaussian';
end

updateSegmentationDisplay(handles);


% --- Executes during object creation, after setting all properties.
function imageSmoothingMethodPopup_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to imageSmoothingMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function imageSmoothingRadiusEdit_Callback(hObject, eventdata, handles)  %#ok<INUSL,DEFNU>
% hObject    handle to imageSmoothingRadiusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imageSmoothingRadiusEdit as text
%        str2double(get(hObject,'String')) returns contents of imageSmoothingRadiusEdit as a double

app = getappdata(0, 'app');

radius = str2double(get(hObject, 'String'));
if isnan(radius)
    return;
end
radius = round(radius);
set(hObject, 'String', num2str(radius));

app.settings.imageSmoothingRadius = radius;

updateSegmentationDisplay(handles);


% --- Executes during object creation, after setting all properties.
function imageSmoothingRadiusEdit_CreateFcn(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to imageSmoothingRadiusEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% Widgets for automated threshold

% --- Executes on button press in automaticThresholdRadioButton.
function automaticThresholdRadioButton_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to automaticThresholdRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of automaticThresholdRadioButton

app = getappdata(0, 'app');
app.settings.thresholdStrategy = 'auto';

app.logger.info('ChooseThresholdDialog.m', ...
    'Choose automatic threshold');

updateWidgetsVisibility(handles);

% compute new threshold values
computeThresholdValues(app);

% update inner state of appli
setappdata(0, 'app', app);

% update display with current info
updateSegmentationDisplay(handles);
displayCurrentFrameThreshold(handles);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

frameIndexSlider_Callback(hObject, eventdata, handles);


% --- Executes on selection change in autoThresholdMethodPopup.
function autoThresholdMethodPopup_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to autoThresholdMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns autoThresholdMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from autoThresholdMethodPopup

app = getappdata(0, 'app');

% choose new method for threshold
ind = get(handles.autoThresholdMethodPopup, 'Value');
methodList = {'maxEntropy', 'Otsu'};
methodName = methodList{ind};

app.logger.info('ChooseThresholdDialog.m', ...
    ['Set automatic threshold method: ' methodName]);

% update threshold information of application
app.settings.thresholdMethod = methodList{ind};
computeThresholdValues(app);

updateSegmentationDisplay(handles);

% display threshold of current frame
displayCurrentFrameThreshold(handles);


% --- Executes during object creation, after setting all properties.
function autoThresholdMethodPopup_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to autoThresholdMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autoThresholdValueEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoThresholdValueEdit as text
%        str2double(get(hObject,'String')) returns contents of autoThresholdValueEdit as a double


% --- Executes during object creation, after setting all properties.
function autoThresholdValueEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autoThresholdStartEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoThresholdStartEdit as text
%        str2double(get(hObject,'String')) returns contents of autoThresholdStartEdit as a double


% --- Executes during object creation, after setting all properties.
function autoThresholdStartEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function autoThresholdFinalEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdFinalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of autoThresholdFinalEdit as text
%        str2double(get(hObject,'String')) returns contents of autoThresholdFinalEdit as a double


% --- Executes during object creation, after setting all properties.
function autoThresholdFinalEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to autoThresholdFinalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateAutomaticThresholdButton.
function updateAutomaticThresholdButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to updateAutomaticThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extract application data
app     = getappdata(0, 'app');

addThres = strtrim(get(handles.autoThresholdValueEdit, 'String'));
start   = strtrim(get(handles.autoThresholdStartEdit, 'String'));
fin     = strtrim(get(handles.autoThresholdFinalEdit, 'String'));

% check input validity
if isempty(start) || isempty(fin)
    return;
end
if addThres == 0
    warning('Select a value to add to the current threshold');
    return;
end

% print info into log file
app.logger.info('ChooseThresholdDialog.m', ...
    sprintf('add threshold value %s to frames %s to %s', ...
    addThres, start, fin));

% convert to numeric values
start   = str2double(start);
fin     = str2double(fin);
addThres = str2double(addThres);

% check input validity
if isempty(start) || isempty(fin) || isempty(addThres)
    warning('Set a numeric value for the edit text');
    return;
end
if start > fin
    warning('The first value must be smaller than the second value');
    return;
end

% disable widgets to avoid double-clicks
set(handles.updateAutomaticThresholdButton, 'Enable', 'off');
set(handles.updateAutomaticThresholdButton, 'String', 'Wait please...');
pause(0.01);

% update modified threshold values
for i = start : fin
    app.thresholdValues(i) = app.baseThresholdValues(i) + addThres;
end

% update widgets with new values
displayCurrentFrameThreshold(handles);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

% Update display of binarized image
updateSegmentationDisplay(handles);

% re-enable widgets
set(handles.updateAutomaticThresholdButton, 'Enable', 'on');
set(handles.updateAutomaticThresholdButton, 'String', 'Update threshold');

setProcessingStep(app, ProcessingStep.Threshold);


%% Widgets for manual threshold

% --- Executes on button press in manualThresholdRadioButton.
function manualThresholdRadioButton_Callback(hObject, eventdata, handles)%#ok %Manual
% hObject    handle to manualThresholdRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualThresholdRadioButton

% extract application data
app     = getappdata(0, 'app');
app.settings.thresholdStrategy = 'manual';

app.logger.info('ChooseThresholdDialog.m', ...
    'Choose manual threshold method');

val = round(get(handles.manualThresholdSlider, 'Value'));
set(handles.manualThresholdValueEdit2, 'String', num2str(val));

updateWidgetsVisibility(handles);


function manualThresholdValueEdit2_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to manualThresholdValueEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of manualThresholdValueEdit2 as text
%        str2double(get(hObject,'String')) returns contents of manualThresholdValueEdit2 as a double

% get threshold value between 0 and 255
val = str2double(get(handles.manualThresholdValueEdit2, 'String'));
if isnan(val)
    return;
end
updateManualThresholdValue(handles, val);


% --- Executes during object creation, after setting all properties.
function manualThresholdValueEdit2_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to manualThresholdValueEdit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function manualThresholdSlider_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to manualThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% get threshold value between 0 and 255
val = round(get(handles.manualThresholdSlider, 'Value'));

updateManualThresholdValue(handles, val);


% --- Executes during object creation, after setting all properties.
function manualThresholdSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to manualThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor',[.9 .9 .9]);
end

function updateManualThresholdValue(handles, value)

app = getappdata(0, 'app');
setThresholdValues(app, value)
setappdata(0, 'app', app);

% update widgets
updateSegmentationDisplay(handles);
set(handles.manualThresholdValueEdit2, 'String', num2str(value));
set(handles.manualThresholdSlider, 'Value', value);

displayCurrentFrameThreshold(handles);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');


function updateWidgetsVisibility(handles)


app = getappdata(0, 'app');

autoThreshold = strcmp(app.settings.thresholdStrategy, 'auto');
if autoThreshold
    keyAuto = 'on';
    keyManual = 'off';
else
    keyAuto = 'off';
    keyManual = 'on';
end

set(handles.automaticThresholdRadioButton, 'Value', autoThreshold);
set(handles.autoThresholdMethodLabel, 'Visible', keyAuto);
set(handles.autoThresholdMethodPopup, 'Visible', keyAuto);
set(handles.autoThresholdValueLabel, 'Visible', keyAuto);
set(handles.autoThresholdStartLabel, 'Visible', keyAuto);
set(handles.autoThresholdFinalLabel, 'Visible', keyAuto);
set(handles.autoThresholdValueEdit, 'Visible', keyAuto);
set(handles.autoThresholdStartEdit, 'Visible', keyAuto);
set(handles.autoThresholdFinalEdit, 'Visible', keyAuto);
set(handles.adjustAutoThresholdLabel, 'Visible', keyAuto);
set(handles.updateAutomaticThresholdButton, 'Visible', keyAuto);

set(handles.manualThresholdRadioButton, 'Value', ~autoThreshold);
set(handles.manualThresholdSlider, 'Visible', keyManual);
set(handles.manualThresholdValueEdit2, 'Visible', keyManual);


%% General settings widgets

% --- Executes on button press in backToSelectionButton.
function backToSelectionButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to backToSelectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');

app.logger.info('ChooseThresholdDialog.m', ...
    'Back to image selection');

delete(gcf);
SelectInputImagesDialog(app);


% --- Executes on button press in validateTresholdButton.
function validateTresholdButton_Callback(hObject, eventdata, handles)%#ok
% To go to ValidateContour
%
% Extract input argments from dialog, compute contours, and opens the 
% 'validateContour' dialog.
%
% hObject    handle to validateTresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.validateTresholdButton, 'Enable', 'Off')
set(handles.validateTresholdButton, 'String', 'Please wait...')
pause(0.01);

% retrieve application data
app = getappdata(0, 'app');
app.logger.info('ChooseThresholdDialog.m', ...
    'Validate threshold');

% update processing step if necessary
if getProcessingStep(app) < ProcessingStep.Contour
    computeContours(app);
end

% switch the visible dialog to Smooth Contour
delete(gcf);
SmoothContourDialog(app);
