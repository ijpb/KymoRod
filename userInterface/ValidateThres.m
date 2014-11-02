function varargout = ValidateThres(varargin)
% VALIDATETHRES MATLAB code for ValidateThres.fig
%      VALIDATETHRES, by itself, creates a new VALIDATETHRES or raises the existing
%      singleton*.
%
%      H = VALIDATETHRES returns the handle to a new VALIDATETHRES or the handle to
%      the existing singleton*.
%
%      VALIDATETHRES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VALIDATETHRES.M with the given input arguments.
%
%      VALIDATETHRES('Property','Value',...) creates a new VALIDATETHRES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ValidateThres_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ValidateThres_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ValidateThres

% Last Modified by GUIDE v2.5 29-Oct-2014 10:29:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ValidateThres_OpeningFcn, ...
                   'gui_OutputFcn',  @ValidateThres_OutputFcn, ...
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


% --- Executes just before ValidateThres is made visible.
function ValidateThres_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ValidateThres (see VARARGIN)

% Choose default command line output for ValidateThres
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    % should be the canonical way of calling the program
    
    disp('validate threshold from app');
    app = varargin{1};    
    col = app.imageList;
    
elseif nargin == 11 
    % if user come from StartSkeleton
    warning('deprecated way of calling ValidateThresh');
    
    col = varargin{4};
    fin = varargin{2};
    debut = varargin{1};
    step = varargin{5};
    nbInit = varargin{6};
    N = varargin{7};
    folder_name = varargin{8};
    setappdata(0, 'debut', debut);
    setappdata(0, 'step', step);
    setappdata(0, 'fin', fin);
    setappdata(0, 'col', col);
    setappdata(0, 'nbInit', nbInit);
    setappdata(0, 'N', N);
    setappdata(0, 'folder_name', folder_name);
    
elseif nargin == 4 
    % if user come from ValidateContour, back way
    col = varargin{1};
    app = HypoGrowthApp();
    app.imageList = col;
    
else
    error('requires 11 or 4 input arguments');
end

% update current process state
app.currentStep = 'threshold';
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
thresholdValues = zeros(length(col), 1);
for i = 1 : length(col)
    thresholdValues(i) = round(graythresh(col{i}) * 255);
end
app.thresholdValues = thresholdValues;

% setup slider for display of current frame
set(handles.frameIndexSlider, 'Min', 1); 
set(handles.frameIndexSlider, 'Max', imageNumber); 
sliderStep = min(max([1 5] ./ (imageNumber - 1), 0.001), 1);
set(handles.frameIndexSlider, 'SliderStep', sliderStep); 

% get threshold of current frame
set(handles.currentFrameThresholdLabel, 'Visible', 'on');
currentThreshold = int16(thresholdValues(frameIndex));
string = sprintf('Threshold for frame %d is %d', frameIndex, currentThreshold);
set(handles.currentFrameThresholdLabel, 'String', string);
app.currentFrameIndex = frameIndex;

% compute binarised image
seg = col{1} > currentThreshold;
axis(handles.currentFrameAxes);
imshow(seg);

setappdata(0, 'app', app);

guidata(hObject, handles);

% UIWAIT makes ValidateThres wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ValidateThres_OutputFcn(hObject, eventdata, handles) %#ok
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
thresholdValues = app.thresholdValues;

frameIndex = round(get(handles.frameIndexSlider, 'Value'));

% compute segmented image
currentFrame = app.imageList{frameIndex};
currentThreshold = thresholdValues(frameIndex);
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
red = app.imageList;
n = app.currentFrameIndex;

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

nImages = length(red);

% compute thresholded images
thresholdValues = zeros(nImages, 1);
for i = 1 : nImages
    thresholdValues(i) = round(graythresh(red{i}) * 255);
end
app.thresholdValues = thresholdValues;

string = sprintf('Threshold for frame %d is %d', n, round(thresholdValues(n)));
set(handles.currentFrameThresholdLabel, 'String', string);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

setappdata(0, 'app', app);

% update display
frameIndexSlider_Callback(hObject, eventdata, handles);


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
n       = app.currentFrameIndex;
seuil   = app.thresholdValues;
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

set(handles.updateAutomaticThresholdButton, 'Enable', 'off');
set(handles.updateAutomaticThresholdButton, 'String', 'Wait please...');
pause(0.01);
for i = start : fin
    if graythresh(red{i}) * 255 <= 255
        seuil(i) = round(graythresh(red{i}) * 255) + addThres;
    else
        warndlg(...
            {'New threshold is bigger than 255.', ...
            'Please select a smaller value to add', ...
            'to the auto threshold.'}, ...
        'Wrong threshold', 'modal');
        return;
    end
end

string = sprintf('Threshold for frame %d is %d', n, seuil(n));
set(handles.currentFrameThresholdLabel, 'String', string);
set(handles.currentFrameThresholdLabel, 'Visible', 'on');

app.thresholdValues = seuil;
setappdata(0, 'app', app);
frameIndexSlider_Callback(hObject, eventdata, handles);

set(handles.updateAutomaticThresholdButton, 'Enable', 'on');
set(handles.updateAutomaticThresholdButton, 'String', 'Compute new automatical threshold');


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
col = app.imageList;
n   = app.currentFrameIndex;

imshow(handles.currentFrameAxes, col{n} > val);

nImages = length(col);
thresholdValues = ones(nImages, 1) * val;

app.thresholdValues = thresholdValues;
setappdata(0, 'app', app);

% update widgets
set(handles.manualThresholdValueLabel, 'String', num2str(thresholdValues(n)));
set(handles.currentFrameThresholdLabel, 'Visible', 'on');
string = sprintf('Threshold for frame %d is %d', n, round(thresholdValues(n)));
set(handles.currentFrameThresholdLabel, 'String', string);


% --- Executes during object creation, after setting all properties.
function manualThresholdSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to manualThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject, 'BackgroundColor',[.9 .9 .9]);
end


%% General settings widgets


function pixelScaleEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pixelScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pixelScaleEdit as text
%        str2double(get(hObject,'String')) returns contents of pixelScaleEdit as a double

% --- Executes during object creation, after setting all properties.
function pixelScaleEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to pixelScaleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in directionFilterPopup.
function directionFilterPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to directionFilterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns directionFilterPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from directionFilterPopup


% --- Executes during object creation, after setting all properties.
function directionFilterPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to directionFilterPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in firstPointSkeletonPopup.
function firstPointSkeletonPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to firstPointSkeletonPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns firstPointSkeletonPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from firstPointSkeletonPopup


% --- Executes during object creation, after setting all properties.
function firstPointSkeletonPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to firstPointSkeletonPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in backToSelectionButton.
function backToSelectionButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to backToSelectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
StartSkeleton(app);


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
seuil   = app.thresholdValues;
images  = app.imageList;

disp('Binarisation...');
hDialog = msgbox(...
    {'Performing Binarisation,', 'please wait...'}, ...
    'Binarisation');

thres = seuil;

nImages = length(images);

% add black border around each image
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
    contours{i} = cont(images{i}, thres(i));
    parfor_progress;
end

parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end

app.contourList = contours;

delete(gcf);

ValidateContour(app);
