function varargout = ValidateContour(varargin)
% VALIDATECONTOUR MATLAB code for ValidateContour.fig
%      VALIDATECONTOUR, by itself, creates a new VALIDATECONTOUR or raises the existing
%      singleton*.
%
%      H = VALIDATECONTOUR returns the handle to a new VALIDATECONTOUR or the handle to
%      the existing singleton*.
%
%      VALIDATECONTOUR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VALIDATECONTOUR.M with the given input arguments.
%
%      VALIDATECONTOUR('Property','Value',...) creates a new VALIDATECONTOUR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ValidateContour_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ValidateContour_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ValidateContour

% Last Modified by GUIDE v2.5 27-Oct-2014 12:50:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ValidateContour_OpeningFcn, ...
                   'gui_OutputFcn',  @ValidateContour_OutputFcn, ...
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


% --- Executes just before ValidateContour is made visible.
function ValidateContour_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ValidateContour (see VARARGIN)

% Choose default command line output for ValidateContour

handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    disp('init from HypoGrowthAppData');
    app = varargin{1};

else
    % Take the arguments from previous window, in long list form
    error('deprecated way of calling ValidateContour');
end

% update current process state
app.currentStep = 'contour';
setappdata(0, 'app', app);

% retrieve app data
red     = app.imageList;
thresh  = app.thresholdValues;
CT2     = app.contourList;

% initialize smoothing value
smooth = app.contourSmoothingSize;
set(handles.smoothValueSlider, 'Value', smooth);
set(handles.smoothValueEdit, 'String', num2str(smooth));

index = app.currentFrameIndex;

% initialize current frame index slider
set(handles.frameIndexSlider, 'Min', 1);
set(handles.frameIndexSlider, 'Max', length(red));
set(handles.frameIndexSlider, 'Value', index);
steps = min([1 10] ./ length(red), .5);
set(handles.frameIndexSlider, 'SliderStep', steps);
label = sprintf('Current Frame: %d / %d', index, length(red));
set(handles.currentFrameIndexLabel, 'String', label);

% Display current frame together with initial contour
updateContourDisplay(handles);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ValidateContour wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%

% --- Outputs from this function are returned to the command line.
function varargout = ValidateContour_OutputFcn(hObject, eventdata, handles) %#ok
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
label = sprintf('Frame index: %d/%d', index, length(app.imageList));
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
function backToTresholdButton_Callback(hObject, eventdata, handles)%#ok % To back at ValidateThres
% hObject    handle to backToTresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ValidateThres(app);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles)%#ok % To go in the next window
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ValidateSkeleton(app);
