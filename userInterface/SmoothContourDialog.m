function varargout = SmoothContourDialog(varargin)
% SMOOTHCONTOURDIALOG MATLAB code for SmoothContourDialog.fig
%      SMOOTHCONTOURDIALOG, by itself, creates a new SMOOTHCONTOURDIALOG or raises the existing
%      singleton*.
%
%      H = SMOOTHCONTOURDIALOG returns the handle to a new SMOOTHCONTOURDIALOG or the handle to
%      the existing singleton*.
%
%      SMOOTHCONTOURDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMOOTHCONTOURDIALOG.M with the given input arguments.
%
%      SMOOTHCONTOURDIALOG('Property','Value',...) creates a new SMOOTHCONTOURDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SmoothContourDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SmoothContourDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SmoothContourDialog

% Last Modified by GUIDE v2.5 09-Feb-2015 17:34:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SmoothContourDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @SmoothContourDialog_OutputFcn, ...
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


% --- Executes just before SmoothContourDialog is made visible.
function SmoothContourDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SmoothContourDialog (see VARARGIN)

% Choose default command line output for SmoothContourDialog

handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    app = varargin{1};

else
    % Take the arguments from previous window, in long list form
    error('deprecated way of calling SmoothContourDialog');
end

% update current process state
app.currentStep = 'contour';
setappdata(0, 'app', app);

% retrieve app data
nImages = length(app.imageList);
smooth  = app.contourSmoothingSize;
index   = app.currentFrameIndex;

% initialize smoothing value
set(handles.smoothValueSlider, 'Value', smooth);
set(handles.smoothValueEdit, 'String', num2str(smooth));


% initialize current frame index slider
set(handles.frameIndexSlider, 'Min', 1);
set(handles.frameIndexSlider, 'Max', nImages);
set(handles.frameIndexSlider, 'Value', index);
steps = min([1 10] ./ nImages, .5);
set(handles.frameIndexSlider, 'SliderStep', steps);
label = sprintf('Current Frame: %d / %d', index, nImages);
set(handles.currentFrameIndexLabel, 'String', label);

% Display current frame together with initial contour
updateContourDisplay(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SmoothContourDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%

% --- Outputs from this function are returned to the command line.
function varargout = SmoothContourDialog_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Menu

% --------------------------------------------------------------------
function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
HypoGrowthMenu(app);

%% Widgets

% --- Executes on slider movement.
function smoothValueSlider_Callback(hObject, eventdata, handles)%#ok % To select the good smooth with a slidebar
% hObject    handle to smoothValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% disable slider to avoid multiple calls
set(handles.smoothValueSlider, 'Enable', 'Off');

app  = getappdata(0, 'app');

% Take the value from the slide bar, rounded to have an integer
smooth = round(get(handles.smoothValueSlider, 'Value')); 

% set the smooth
set(handles.smoothValueEdit, 'String', num2str(smooth));

% update app data 
app.contourSmoothingSize = smooth;
setappdata(0, 'app', app);

% update display
updateContourDisplay(handles);

% once processing is finished, re-enable smoothing
set(handles.smoothValueSlider, 'Enable', 'On');


% --- Executes during object creation, after setting all properties.
function smoothValueSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to smoothValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function smoothValueEdit_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to smoothValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothValueEdit as text
%        str2double(get(hObject,'String')) returns contents of smoothValueEdit as a double

app  = getappdata(0, 'app');

% Take the value from the slide bar, rounded to have an integer
smooth = str2double(get(handles.smoothValueEdit, 'String')); 

% set the smooth
set(handles.smoothValueSlider, 'Value', smooth);

% update app data 
app.contourSmoothingSize = smooth;
setappdata(0, 'app', app);

% update display
updateContourDisplay(handles);

% --- Executes during object creation, after setting all properties.
function smoothValueEdit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to smoothValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frameIndexSlider_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');

index = round(get(hObject, 'Value'));

label = sprintf('Frame index: %d / %d', index, length(app.imageList));
set(handles.currentFrameIndexLabel, 'String', label);

app.currentFrameIndex = index;
setappdata(0, 'app', app);

updateContourDisplay(handles);


% --- Executes during object creation, after setting all properties.
function frameIndexSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateContourDisplay(handles)

% get global data
app     = getappdata(0, 'app');

% retrieve current contour
index   = app.currentFrameIndex;
contour = app.contourList{index};

% Smooth current contour
smooth  = app.contourSmoothingSize;
contour = smoothContour(contour, smooth); 

% update display
axes(handles.imageAxes);
threshold = app.thresholdValues(index);
imshow(app.imageList{index} > threshold);
hold on;
drawContour(contour, 'r', 'LineWidth', 1.5);


%% Validation and Comeback buttons

% --- Executes on button press in backToTresholdButton.
function backToTresholdButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to backToTresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ChooseThresholdDialog(app);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles)%#ok 
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ValidateSkeleton(app);
