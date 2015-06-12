function varargout = ValidateSkeleton(varargin)
% VALIDATESKELETON MATLAB code for ValidateSkeleton.fig
%      VALIDATESKELETON, by itself, creates a new VALIDATESKELETON or raises the existing
%      singleton*.
%
%      H = VALIDATESKELETON returns the handle to a new VALIDATESKELETON or the handle to
%      the existing singleton*.
%
%      VALIDATESKELETON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VALIDATESKELETON.M with the given input arguments.
%
%      VALIDATESKELETON('Property','Value',...) creates a new VALIDATESKELETON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ValidateSkeleton_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ValidateSkeleton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ValidateSkeleton

% Last Modified by GUIDE v2.5 12-Nov-2014 13:53:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ValidateSkeleton_OpeningFcn, ...
                   'gui_OutputFcn',  @ValidateSkeleton_OutputFcn, ...
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


% --- Executes just before ValidateSkeleton is made visible.
function ValidateSkeleton_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Skeleton (see VARARGIN)

% Choose default command line output for Skeleton
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'KymoRod')
    app = varargin{1};
    setappdata(0, 'app', app);
    
else
    error('Deprecated way of calling ValidateSkeleton');
end

frameIndex  = app.currentFrameIndex;
nFrames     = frameNumber(app);

% setup widgets
set(handles.currentFrameSlider, 'Min', 1);
set(handles.currentFrameSlider, 'Max', nFrames);
set(handles.currentFrameSlider, 'Value', frameIndex);
sliderStep = min(max([1 5] ./ (nFrames - 1), 0.001), 1);
set(handles.currentFrameSlider, 'SliderStep', sliderStep); 

% compute current segmented image
seuil = app.thresholdValues(frameIndex);
segmentedImage = app.getImage(frameIndex) > seuil;
contour = app.contourList{frameIndex};

% apply smoothing on current contour
smooth  = app.settings.contourSmoothingSize;
contour = smoothContour(contour, smooth);

% display current frame (image and contour)
axes(handles.currentFrameAxes);
handles.imageHandle     = imshow(segmentedImage);
hold on;
handles.contourHandle   = drawContour(contour, 'color', 'r', 'linewidth', 2);

% eventually display skeleton
if ~isempty(app.skeletonList)
    skeleton = app.skeletonList{frameIndex};
else
    skeleton = zeros(1, 2);
end
handles.skeletonHandle  = drawSkeleton(skeleton, 'b');
handles.markerHandle    = drawMarker(skeleton(1,:), 'bo');
if isempty(app.skeletonList)
    set([handles.skeletonHandle, handles.markerHandle], 'Visible', 'Off');  
end

% display some info on current frame
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameLabel, 'String', string);

%TODO: check if used ?
direction = 'boucle';
switch direction
    case 'boucle'
        set(handles.filterDirectionPopup, 'Value', 1);
    case 'droit'
        set(handles.filterDirectionPopup, 'Value', 2);
    case 'droit2'
        set(handles.filterDirectionPopup, 'Value', 3);
    case 'penche'
        set(handles.filterDirectionPopup, 'Value', 4);
    case 'penche2'
        set(handles.filterDirectionPopup, 'Value', 5);
    case 'dep'
        set(handles.filterDirectionPopup, 'Value', 6);
    case 'rien'
        set(handles.filterDirectionPopup, 'Value', 7);
end

dirInitial  = app.settings.firstPointLocation;
switch dirInitial
    case 'bottom'
        set(handles.firstSkeletonPointPopup, 'Value', 1);
    case 'left'
        set(handles.firstSkeletonPointPopup, 'Value', 2);
    case 'right'
        set(handles.firstSkeletonPointPopup, 'Value', 3);
    case 'top'
        set(handles.firstSkeletonPointPopup, 'Value', 4);
end

% disable some widgets in case skeletons are not computed
if isempty(app.skeletonList)
    set(handles.validateSkeletonButton, 'Enable', 'Off');
    set(handles.saveSkeletonDataButton, 'Enable', 'Off');
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Skeleton wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ValidateSkeleton_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok % To save the 
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


% --- Executes on slider movement.
function currentFrameSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') retkurns position osf slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% disable slider to avoid multiple calls
set(handles.currentFrameSlider, 'Enable', 'Off');

app = getappdata(0, 'app');

% update frame index value
frameIndex = get(handles.currentFrameSlider, 'Value');
frameIndex = max(ceil(frameIndex), 1);

app.currentFrameIndex = frameIndex;

% update display
updateCurrentDisplay(handles);

% update display of current frame index
nFrames = frameNumber(app);
string = sprintf('Current Frame: %d / %d', frameIndex, nFrames);
set(handles.currentFrameLabel, 'String', string);

% re-enable slider
set(handles.currentFrameSlider, 'Enable', 'On');


% --- Executes during object creation, after setting all properties.
function currentFrameSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to currentFrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on selection change in filterDirectionPopup.
function filterDirectionPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to filterDirectionPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filterDirectionPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filterDirectionPopup


% --- Executes during object creation, after setting all properties.
function filterDirectionPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to filterDirectionPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in firstSkeletonPointPopup.
function firstSkeletonPointPopup_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to firstSkeletonPointPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns firstSkeletonPointPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from firstSkeletonPointPopup

% determine origin of skeleton
val2 = get(handles.firstSkeletonPointPopup, 'Value');
stringList = get(handles.firstSkeletonPointPopup, 'String');
originDirection = stringList{val2};

% store in app settings
app = getappdata(0, 'app');
app.settings.firstPointLocation = originDirection;

% --- Executes during object creation, after setting all properties.
function firstSkeletonPointPopup_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to firstSkeletonPointPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updateSkeletonButton.
function updateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to updateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the skeleton with the new settings in popupmenu
set(handles.updateSkeletonButton, 'Enable', 'Off');
set(handles.updateSkeletonButton, 'String', 'Wait please...');
pause(0.01);

app = getappdata(0, 'app');

% parse popup containing info for starting skeleton
val2 = get(handles.firstSkeletonPointPopup, 'Value');
dirInitial = get(handles.firstSkeletonPointPopup, 'String');
dirInitial  = dirInitial{val2};

app.settings.firstPointLocation = dirInitial;

computeAllSkeletons(handles);
updateCurrentDisplay(handles);

set(handles.updateSkeletonButton, 'Enable', 'On');
set(handles.updateSkeletonButton, 'String', 'Update All Skeletons');


function updateCurrentDisplay(handles)
% refresh the content of graphical elements: image, contour, skeleton...

app = getappdata(0, 'app');
frameIndex = app.currentFrameIndex;

% compute current segmented image
seuil = app.thresholdValues(frameIndex);
segmentedImage = getImage(app, frameIndex) > seuil;

% apply smoothing on current contour
contour = app.contourList{frameIndex};
smooth  = app.settings.contourSmoothingSize;
contour = smoothContour(contour, smooth);

% display current frame image and contour
set(handles.imageHandle, 'CData', segmentedImage);
set(handles.contourHandle, 'XData', contour(:,1), 'YData', contour(:,2));

% display current skeleton if already computed
if ~isempty(app.skeletonList)
    skeleton = app.skeletonList{frameIndex};
    set(handles.skeletonHandle, 'XData', skeleton(:,1), 'YData', skeleton(:,2));
    set(handles.markerHandle, 'XData', skeleton(1,1), 'YData', skeleton(2,2));
    set([handles.skeletonHandle handles.markerHandle], 'Visible', 'On');
else
    set([handles.skeletonHandle handles.markerHandle], 'Visible', 'Off');
end


function computeAllSkeletons(handles)
% compute skeletons from contours, and update widgets

% get current application data
app = getappdata(0, 'app');

computeSkeletons(app);

set(handles.validateSkeletonButton, 'Enable', 'On');
set(handles.saveSkeletonDataButton, 'Enable', 'On');


% --- Executes on button press in saveSkeletonDataButton.
function saveSkeletonDataButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to saveSkeletonDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.saveSkeletonDataButton, 'Enable', 'Off');
set(handles.saveSkeletonDataButton, 'String', 'Wait please...');
pause(0.01);

app = getappdata(0, 'app'); %#ok<NASGU>

% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile('*.mat', 'Save App Data', 'appData.mat'); 

if pathName == 0
    warning('Select a file please');
    return;
end

% save app data as .mat file
name = fullfile(pathName, fileName);
save(name, 'app');

set(handles.saveSkeletonDataButton, 'Enable', 'On');
set(handles.saveSkeletonDataButton, 'String', 'Save Skeleton Data');


% --- Executes on button press in BackToContourButton.
function BackToContourButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to BackToContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete (gcf);
SmoothContourDialog(app);


% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
ChooseElongationSettingsDialog(app);
