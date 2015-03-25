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

% Last Modified by GUIDE v2.5 10-Feb-2015 13:00:01

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

if nargin == 4 && isa(varargin{1}, 'KymoRodAppData')
    % should be the canonical way of calling the program
    
    disp('validate threshold from app');
    app = varargin{1};    
    col = app.imageList;
    
else
    error('requires 4 input arguments, with a KymoRodAppDAta as fourth argument');
end

% update current process state
setappdata(0, 'app', app);

frameIndex = app.currentFrameIndex;

imageNumber = length(col);
string = sprintf('Current Frame: %d / %d', frameIndex, imageNumber);
set(handles.currentFrameIndexLabel, 'String', string);

set(handles.autoThresholdFinalEdit, 'String', num2str(imageNumber));

set(handles.automaticThresholdRadioButton, 'Value', 1);
set(handles.manualThresholdRadioButton, 'Value', 0);
set(handles.currentFrameThresholdLabel, 'String', '');
set(handles.manualThresholdSlider, 'Visible', 'off');
set(handles.manualThresholdSlider, 'SliderStep', [1/255 10/255]);
set(handles.manualThresholdValueLabel, 'Visible', 'off');
set(handles.autoThresholdValueLabel, 'Visible', 'on');
set(handles.autoThresholdStartLabel, 'Visible', 'on');
set(handles.autoThresholdFinalLabel, 'Visible', 'on');
set(handles.autoThresholdValueEdit, 'Visible', 'on');
set(handles.autoThresholdStartEdit, 'Visible', 'on');
set(handles.autoThresholdFinalEdit, 'Visible', 'on');
set(handles.updateAutomaticThresholdButton, 'Visible', 'on');
set(handles.manualThresholdSlider, 'Visible', 'off');

% pre-compute threshold values
computeThresholdValues(app);

% setup slider for display of current frame
set(handles.frameIndexSlider, 'Min', 1); 
set(handles.frameIndexSlider, 'Max', imageNumber); 
sliderStep = min(max([1 5] ./ (imageNumber - 1), 0.001), 1);
set(handles.frameIndexSlider, 'SliderStep', sliderStep); 

% get threshold of current frame
set(handles.currentFrameThresholdLabel, 'Visible', 'On');
currentThreshold = int16(app.thresholdValues(frameIndex));
string = sprintf('Threshold for frame %d is %d', frameIndex, currentThreshold);
set(handles.currentFrameThresholdLabel, 'String', string);

% compute binarised image
seg = app.imageList{frameIndex} > currentThreshold;
axis(handles.currentFrameAxes);
imshow(seg);

setappdata(0, 'app', app);

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


%% Menu

function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
HypoGrowthMenu(app);


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

% compute segmented image
currentFrame = app.imageList{frameIndex};
currentThreshold = app.thresholdValues(frameIndex);
bin = currentFrame > currentThreshold;

axes(handles.currentFrameAxes)
imshow(bin);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');
string = sprintf('Threshold for frame %d is %d', frameIndex, int16(currentThreshold));
set(handles.currentFrameThresholdLabel, 'String', string);

imageNumber = length(app.imageList);
string = sprintf('Current Frame: %d / %d', frameIndex, imageNumber);
set(handles.currentFrameIndexLabel, 'String', string);

app.currentFrameIndex = frameIndex;
setappdata(0, 'app', app);


% --- Executes during object creation, after setting all properties.
function frameIndexSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% Widgets for automated threshold

% --- Executes on button press in automaticThresholdRadioButton.
function automaticThresholdRadioButton_Callback(hObject, eventdata, handles)%#ok %Automatic
% hObject    handle to automaticThresholdRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of automaticThresholdRadioButton

app = getappdata(0, 'app');
frameIndex = app.currentFrameIndex;

set(handles.manualThresholdRadioButton, 'Value', 0);
set(handles.manualThresholdSlider, 'Visible', 'off');
set(handles.manualThresholdValueLabel, 'Visible', 'off');

set(handles.adjustAutoThresholdLabel, 'Visible', 'on');
set(handles.autoThresholdValueLabel, 'Visible', 'on');
set(handles.autoThresholdStartLabel, 'Visible', 'on');
set(handles.autoThresholdFinalLabel, 'Visible', 'on');
set(handles.autoThresholdValueEdit, 'Visible', 'on');
set(handles.autoThresholdStartEdit, 'Visible', 'on');
set(handles.autoThresholdFinalEdit, 'Visible', 'on');
set(handles.updateAutomaticThresholdButton, 'Visible', 'on');

% compute thresholded images
computeThresholdValues(app);

currentThreshold = round(app.thresholdValues(frameIndex));
string = sprintf('Threshold for frame %d is %d', frameIndex, currentThreshold);
set(handles.currentFrameThresholdLabel, 'String', string);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

setappdata(0, 'app', app);

% update display
frameIndexSlider_Callback(hObject, eventdata, handles);


% --- Executes on selection change in thresholdMethodPopup.
function thresholdMethodPopup_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to thresholdMethodPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns thresholdMethodPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thresholdMethodPopup

app = getappdata(0, 'app');
frameIndex = app.currentFrameIndex;

ind = get(handles.thresholdMethodPopup, 'Value');
methodList = {'maxEntropy', 'Otsu'};
app.thresholdMethod = methodList{ind};

computeThresholdValues(app);

% display threshold of current frame
currentThreshold = int16(app.thresholdValues(frameIndex));
string = sprintf('Threshold for frame %d is %d', frameIndex, currentThreshold);
set(handles.currentFrameThresholdLabel, 'String', string);

% compute binarised image
seg = app.imageList{frameIndex} > currentThreshold;
axis(handles.currentFrameAxes);
imshow(seg);


% --- Executes during object creation, after setting all properties.
function thresholdMethodPopup_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to thresholdMethodPopup (see GCBO)
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
function updateAutomaticThresholdButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to updateAutomaticThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extract application data
app     = getappdata(0, 'app');
red     = app.imageList;
nb      = length(red);

addThres = get(handles.autoThresholdValueEdit, 'String');
start   = get(handles.autoThresholdStartEdit, 'String');
fin     = get(handles.autoThresholdFinalEdit, 'String');

if length(start) ~= 0    %#ok isempty does'nt work i dont know why
    start = str2num(start);%#ok
else
    start = 1;
end
if length(fin) ~= 0    %#ok isempty does'nt work i dont know why
    fin = str2num(fin);%#ok
else
    fin = nb;
end

if addThres == 0
    warning('Select a value to add at the current threshold');
    return;
end

addThres = str2num(addThres);%#ok

if isempty(fin) || isempty(start) || isempty(addThres)
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
frameIndex = app.currentFrameIndex;
currentThreshold = app.thresholdValues(frameIndex);
string = sprintf('Threshold for frame %d is %d', frameIndex, currentThreshold);
set(handles.currentFrameThresholdLabel, 'String', string);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

% compute binarised image
seg = app.imageList{frameIndex} > currentThreshold;
axis(handles.currentFrameAxes);
imshow(seg);

% re-enable widgets
set(handles.updateAutomaticThresholdButton, 'Enable', 'on');
set(handles.updateAutomaticThresholdButton, 'String', 'Update threshold');

setProcessingStep(app, 'threshold');


%% Widgets for manual threshold

% --- Executes on button press in manualThresholdRadioButton.
function manualThresholdRadioButton_Callback(hObject, eventdata, handles)%#ok %Manual
% hObject    handle to manualThresholdRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manualThresholdRadioButton

set(handles.automaticThresholdRadioButton, 'Value', 0);
set(handles.manualThresholdSlider, 'Visible', 'on');
set(handles.manualThresholdValueLabel, 'Visible', 'on');

set(handles.adjustAutoThresholdLabel, 'Visible', 'off');
set(handles.autoThresholdValueLabel, 'Visible', 'off');
set(handles.autoThresholdStartLabel, 'Visible', 'off');
set(handles.autoThresholdFinalLabel, 'Visible', 'off');
set(handles.autoThresholdValueEdit, 'Visible', 'off');
set(handles.autoThresholdStartEdit, 'Visible', 'off');
set(handles.autoThresholdFinalEdit, 'Visible', 'off');
set(handles.updateAutomaticThresholdButton, 'Visible', 'off');

% --- Executes on slider movement.
function manualThresholdSlider_Callback(hObject, eventdata, handles)%#ok % To change the value of smooth
% hObject    handle to manualThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% get threshold value between 0 and 255
val = round(get(handles.manualThresholdSlider, 'Value'));

app = getappdata(0, 'app');
frameIndex   = app.currentFrameIndex;

imshow(handles.currentFrameAxes, app.imageList{frameIndex} > val);

nImages = length(app.imageList);
thresholdValues = ones(nImages, 1) * val;

app.thresholdValues = thresholdValues;
setappdata(0, 'app', app);

% update widgets
set(handles.manualThresholdValueLabel, 'String', ...
    num2str(thresholdValues(frameIndex)));
set(handles.currentFrameThresholdLabel, 'Visible', 'on');
string = sprintf('Threshold for frame %d is %d', frameIndex, ...
    round(thresholdValues(frameIndex)));
set(handles.currentFrameThresholdLabel, 'String', string);

setProcessingStep(app, 'threshold');


% --- Executes during object creation, after setting all properties.
function manualThresholdSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to manualThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor',[.9 .9 .9]);
end

function computeThresholdValues(app)

nImages = length(app.imageList);
thresholdValues = zeros(nImages, 1);

% Compute the contour
disp('Segmentation');
hDialog = msgbox(...
    {'Computing image thresholds,', 'please wait...'}, ...
    'Segmentation');

% compute thresholded images
switch app.thresholdMethod
    case 'maxEntropy'
        parfor_progress(nImages);
        for i = 1 : nImages
            thresholdValues(i) = maxEntropyThreshold(app.imageList{i});
            parfor_progress;
        end
        parfor_progress(0);
        
    case 'Otsu'
        parfor_progress(nImages);
        for i = 1 : nImages
            thresholdValues(i) = round(graythresh(app.imageList{i}) * 255);
            parfor_progress;
        end
        parfor_progress(0);
        
    otherwise
        error(['Could not recognize threshold method: ' app.thresholdMethod]);        
end


if ishandle(hDialog)
    close(hDialog);
end

app.baseThresholdValues = thresholdValues;
app.thresholdValues = thresholdValues;

setProcessingStep(app, 'threshold');


%% General settings widgets

% --- Executes on button press in backToSelectionButton.
function backToSelectionButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to backToSelectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
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
app     = getappdata(0, 'app');
thres   = app.thresholdValues;
images  = app.imageList;

disp('Binarisation...');
hDialog = msgbox(...
    {'Performing Binarisation,', 'please wait...'}, ...
    'Binarisation');

nImages = length(images);

% add black border around each image, to ensure continuous contours
parfor_progress(nImages);
for k = 1:nImages
    images{k} = imAddBlackBorder(images{k});
    parfor_progress;
end
parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end

% Compute the contour
disp('Contour');
hDialog = msgbox(...
    {'Computing contours,', 'please wait...'}, ...
    'Contour');

% allocate memory for contour array
contours = cell(nImages, 1);

% compute contours from gray scale images
parfor_progress(nImages);
for i = 1:nImages
    contours{i} = segmentContour(images{i}, thres(i));
    parfor_progress;
end

parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end

app.contourList = contours;

delete(gcf);

SmoothContourDialog(app);

