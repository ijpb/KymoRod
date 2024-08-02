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

if nargin == 4 && isa(varargin{1}, 'KymoRodData')
    app = varargin{1};

else
    % Take the arguments from previous window, in long list form
    error('deprecated way of calling SmoothContourDialog');
end

% update current process state
setappdata(0, 'app', app);

app.logger.info('SmoothContourDialog.m', ...
    'Open dialog: SmoothContourDialog');

% setup figure menu
gui = KymoRodGui.getInstance();
buildFigureMenu(gui, hObject, app);

% retrieve app data
nFrames = frameNumber(app);
index   = app.currentFrameIndex;

% compute the max value for smoothing 
smoothMaxValue = 500;

% initialize slider for smoothing value
smooth  = app.settings.contourSmoothingSize;
set(handles.smoothValueSlider, 'Min', 0);
set(handles.smoothValueSlider, 'Max', smoothMaxValue);
set(handles.smoothValueSlider, 'Value', smooth);
steps = min([1 10] ./ smoothMaxValue, .5);
set(handles.smoothValueSlider, 'SliderStep', steps);
set(handles.smoothValueEdit, 'String', num2str(smooth));

% initialize current frame index slider
set(handles.frameIndexSlider, 'Min', 1);
set(handles.frameIndexSlider, 'Max', nFrames);
set(handles.frameIndexSlider, 'Value', index);
steps = min([1 10] ./ nFrames, .5);
set(handles.frameIndexSlider, 'SliderStep', steps);
label = sprintf('Current Frame: %d / %d', index, nFrames);
set(handles.currentFrameIndexLabel, 'String', label);

% compute data to display for current frame
segmentedImage = app.getSegmentedImage(index);
contour = app.getContour(index);
contour = smoothContour(contour, smooth); 

% display current frame (image and contour)
axes(handles.imageAxes);
handles.imageHandle     = imshow(segmentedImage);
hold on;
handles.contourHandle   = drawContour(contour, 'color', 'r', 'linewidth', 1.5);

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
KymoRodMenuDialog(app);

%% Widgets

% --- Executes on slider movement.
function smoothValueSlider_Callback(hObject, eventdata, handles)%#ok 
% hObject    handle to smoothValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% disable slider to avoid multiple calls
set(handles.smoothValueSlider, 'Enable', 'Off');

app  = getappdata(0, 'app');

% Take the value from the slide bar, rounded to have an integer
smoothingSize = round(get(handles.smoothValueSlider, 'Value')); 

smoothString = num2str(smoothingSize);
app.logger.info('SmoothContourDialog.m', ...
    ['Set smoothing value to ' smoothString]);

% set the smooth
set(handles.smoothValueEdit, 'String', num2str(smoothingSize));

% update app data 
app.settings.contourSmoothingSize = smoothingSize;
gui = KymoRodGui.getInstance();
gui.userPrefs.settings.contourSmoothingSize = smoothingSize;
setProcessingStep(app, ProcessingStep.Contour);

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


function smoothValueEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to smoothValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothValueEdit as text
%        str2double(get(hObject,'String')) returns contents of smoothValueEdit as a double

app  = getappdata(0, 'app');
smoothString = get(handles.smoothValueEdit, 'String');

app.logger.info('SmoothContourDialog.m', ...
    ['Set smoothing value to ' smoothString]);

% Take the value from the slider, rounded to have an integer
smoothingSize = round(str2double(smoothString));

% set the smooth
set(handles.smoothValueSlider, 'Value', smoothingSize);

% update app data 
app.settings.contourSmoothingSize = smoothingSize;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.contourSmoothingSize = smoothingSize;

setProcessingStep(app, ProcessingStep.Contour);

setappdata(0, 'app', app);

% update display
updateContourDisplay(handles);

% --- Executes during object creation, after setting all properties.
function smoothValueEdit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to smoothValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frameIndexSlider_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to frameIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');

index = round(get(hObject, 'Value'));

label = sprintf('Frame index: %d / %d', index, frameNumber(app));
set(handles.currentFrameIndexLabel, 'String', label);

app.currentFrameIndex = index;
setappdata(0, 'app', app);

updateContourDisplay(handles);


% --- Executes during object creation, after setting all properties.
function frameIndexSlider_CreateFcn(hObject, eventdata, handles) %#ok<INUSD>
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
index   = app.currentFrameIndex;

% compute current segmented image
segmentedImage = app.getSegmentedImage(index);

% retrieve current contour and smooth it
contour = app.getContour(index);
smooth  = app.settings.contourSmoothingSize;
contour = smoothContour(contour, smooth); 

% display current frame image and contour
set(handles.imageHandle, 'CData', segmentedImage);
set(handles.contourHandle, 'XData', contour(:,1), 'YData', contour(:,2));


%% Validation and Comeback buttons

% --- Executes on button press in backToTresholdButton.
function backToTresholdButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to backToTresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');

app.logger.info('SmoothContourDialog.m', ...
    'Back to threshold dialog');

delete(gcf);
ChooseThresholdDialog(app);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');

app.logger.info('SmoothContourDialog.m', ...
    'Validate contour smoothing');

delete(gcf);
ValidateSkeletonDialog(app);
