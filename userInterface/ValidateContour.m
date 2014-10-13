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

% Last Modified by GUIDE v2.5 22-Aug-2014 13:25:32

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

% Take the arguments from previous window
handles.output = hObject;
seuil   = varargin{1};
red     = varargin{2};
scale   = varargin{3};
size    = varargin{4};
debut   = varargin{5};
fin     = varargin{6};
step    = varargin{7};
direction = varargin{8};
dirInitial = varargin{9};
nbInit  = varargin{10};
N       = varargin{11};
folder_name = varargin{12};
CT2     = varargin{13};
thres   = varargin{14};

% Set the arguments to use it in the next window (Skeleton.m)
setappdata(0, 'red', red);
setappdata(0, 'scale', scale);
setappdata(0, 'Size', size);
setappdata(0, 'debut', debut);
setappdata(0, 'fin', fin);
setappdata(0, 'step', step);
setappdata(0, 'direction', direction);
setappdata(0, 'dirInitial', dirInitial);
setappdata(0, 'nbInit', nbInit);
setappdata(0, 'N', N);
setappdata(0, 'folder_name', folder_name);


% Show 3 images, begin middle and end of the red directory
axes(handles.AxFirst);
imshow(red{1} > thres(1));
hold on;
drawContour(CT2{1} * scale, 'r', 'LineWidth', 1.5);

% initialize middle image to the middle of the directory
indice = round(length(red) / 2); 
axes(handles.AxMiddle);
imshow(red{indice} > thres(indice));
hold on;
drawContour(CT2{indice} * scale, 'r', 'LineWidth', 1.5);

axes(handles.AxEnd);
imshow(red{end} > thres(end));
hold on;
drawContour(CT2{end} * scale, 'r', 'LineWidth', 1.5);

% To use it at the next window
setappdata(0, 'CT2', CT2); 
setappdata(0, 'indice', indice);
setappdata(0, 'thres', thres);
setappdata(0, 'seuil', seuil);

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
delete(gcf);
StartProgramm();

%% Widgets

% --- Executes on slider movement.
function smoothValueSlider_Callback(hObject, eventdata, handles)%#ok % To select the good smooth with a slidebar
% hObject    handle to smoothValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Take the value from the slide bar, rounded to have an integer
smooth = round(get(handles.smoothValueSlider, 'Value')); 

% disable slider to avoid multiple calls
set(handles.smoothValueSlider, 'Enable', 'Off');

% get global data
thres   = getappdata(0, 'seuil');
CT2     = getappdata(0, 'CT2');
indice  = getappdata(0, 'indice');
red     = getappdata(0, 'red');
scale   = getappdata(0, 'scale');

% create an array of contours
CT = cell(length(red), 1);

% Compute three images with the current smoothing value
CT{1}       = smoothContour(CT2{1}, smooth); 
CT{indice}  = smoothContour(CT2{indice}, smooth); 
CT{end}     = smoothContour(CT2{end}, smooth); 

 % Show three images with the smoothing
axes(handles.AxFirst);
imshow(red{1} > thres(1));
hold on;
drawContour(CT{1} * scale, 'r', 'Linewidth', 1.5);

axes(handles.AxMiddle);
imshow(red{indice} > thres(indice));
hold on;
drawContour(CT{indice} * scale, 'r', 'Linewidth', 1.5);

axes(handles.AxEnd);
imshow(red{end} > thres(end));
hold on;
drawContour(CT{end} * scale, 'r', 'Linewidth', 1.5);

% once processing is finished, re-enable smoothing
set(handles.smoothValueSlider, 'Enable', 'On');

% set the smooth
setappdata(0, 'smooth', smooth); 
set(handles.smoothValueLabel, 'String', num2str(smooth));

% --- Executes during object creation, after setting all properties.
function smoothValueSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to smoothValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% Validation and Comeback buttons

% --- Executes on button press in backToTresholdButton.
function backToTresholdButton_Callback(hObject, eventdata, handles)%#ok % To back at ValidateThres
% hObject    handle to backToTresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

red = getappdata(0, 'red');
delete(gcf);
ValidateThres(red);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles)%#ok % To go in the next window
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.validateContourButton, 'Enable', 'off')
set(handles.validateContourButton, 'String', 'Wait please...')
pause(0.01);

smooth  = getappdata(0, 'smooth');
CT2     = getappdata(0, 'CT2');
red     = getappdata(0, 'red');
indice  = getappdata(0, 'indice');
seuil   = getappdata(0, 'seuil');
thres   = getappdata(0, 'thres');
scale   = getappdata(0, 'scale');
size    = 0;
debut   = getappdata(0, 'debut');
fin     = getappdata(0, 'fin');
step    = getappdata(0, 'step');
direction   = getappdata(0, 'direction');
dirInitial  = getappdata(0, 'dirInitial');
nbInit  = getappdata(0, 'nbInit');
N       = getappdata(0, 'N');
folder_name = getappdata(0, 'folder_name');

dir = direction;
dirbegin = dirInitial;

CT      = cell(length(red),1);
SK      = cell(length(red),1);
shift   = cell(length(red),1);
rad     = cell(length(red),1);
CTVerif = cell(length(red),1);
SKVerif = cell(length(red),1);

disp('Skeletonization');
hDialog = msgbox(...
    {'Computing skeletons from contours,', 'please wait...'}, ...
    'Skeletonization');

parfor_progress(length(red));
for i = 1:length(red)
    % Smooth current contour
    if smooth ~= 0
        CT2{i} = smoothContour(CT2{i}, smooth);
    end
    
    % Skeleton of current contour
    [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(CT2{i}, dir, dirbegin);
    parfor_progress;
end

parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end
           
delete(gcf);

% Call the next window
ValidateSkeleton(red,smooth,CT2,indice,direction,dirInitial,thres,scale,size,...
    seuil,debut,fin,step,nbInit,N,folder_name,SK,CT,rad,SKVerif,CTVerif,shift); 