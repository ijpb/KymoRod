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

% Last Modified by GUIDE v2.5 19-Jun-2014 17:07:53

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

% Take the arguments from test.m
handles.output = hObject;
seuil = varargin{1};
red = varargin{2};
scale = varargin{3};
size = varargin{4};
debut = varargin{5};
fin = varargin{6};
step = varargin{7};
direction = varargin{8};
dirInitial = varargin{9};
nbInit = varargin{10};
N = varargin{11};
folder_name = varargin{12};
CT2 = varargin{13};
thres = varargin{14};

% Set the arguments to use it in the next window (Skeleton.m)
setappdata(0,'red',red);

setappdata(0,'scale',scale);
setappdata(0,'Size',size);
setappdata(0,'debut',debut);
setappdata(0,'fin',fin);
setappdata(0,'step',step);
setappdata(0,'direction',direction);
setappdata(0,'dirInitial',dirInitial);
setappdata(0,'nbInit',nbInit);
setappdata(0,'N',N);
setappdata(0,'folder_name',folder_name);


% definition of the intial parameters 


% Show 3 images, begin middle and end of the red directory
axes(handles.AxFirst);
imshow(red{1} > thres(1));
hold on;
plot(CT2{1}(:,1)*scale,CT2{1}(:,2)*scale,'r','Linewidth',1.5);

indice=round(length(red)/2); % to have the midle of the directory

axes(handles.AxMiddle);
imshow(red{indice} > thres(indice));
hold on;
plot(CT2{indice}(:,1)*scale,CT2{indice}(:,2)*scale,'r','Linewidth',1.5);

axes(handles.AxEnd);
imshow(red{end} > thres(end));
hold on;
plot(CT2{end}(:,1)*scale,CT2{end}(:,2)*scale,'r','Linewidth',1.5);

setappdata(0,'CT2',CT2); % To use it at the next window
setappdata(0,'indice',indice);
setappdata(0,'thres',thres);
setappdata(0,'seuil',seuil);
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
function Untitled_1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();

%% Widgets

% --- Executes on slider movement.
function SdSmoothing_Callback(hObject, eventdata, handles)%#ok % To select the good smooth with a slidebar
% hObject    handle to SdSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

smooth = get(handles.SdSmoothing, 'Value'); % Take the value from the slide bar
smooth = round(smooth); % round to have an integer

% get global data
seuil   = getappdata(0, 'seuil');
CT2     = getappdata(0, 'CT2');
indice  = getappdata(0, 'indice');
red     = getappdata(0, 'red');
scale   = getappdata(0, 'scale');

% get threshold value as a double
for k = 1:length(red)
    if isdouble(seuil)
        thres(k) = seuil;%#ok
    end
    if iscell(seuil)
        thres(k) = seuil{k};%#ok
    end
end

% create an array of contours
CT = cell(length(red),1);

% Compute three images with the smoothing
CT{1}(:,1) = moving_average(CT2{1}(:,1), smooth); 
CT{1}(:,2) = moving_average(CT2{1}(:,2), smooth);

CT{indice}(:,1) = moving_average(CT2{indice}(:,1),smooth);
CT{indice}(:,2) = moving_average(CT2{indice}(:,2),smooth);

CT{end}(:,1) = moving_average(CT2{end}(:,1),smooth);
CT{end}(:,2) = moving_average(CT2{end}(:,2),smooth);

 % Show three images with the smoothing
axes(handles.AxFirst);
imshow(red{1} > thres(1));
hold on;
contour = [CT{1}(:,1)*scale,CT{1}(:,2)*scale];
plot(contour(:,1), contour(:,2), 'r', 'Linewidth', 1.5);

axes(handles.AxMiddle);
imshow(red{indice} > thres(indice));
hold on;
plot(CT{indice}(:,1)*scale,CT{indice}(:,2)*scale,'r','Linewidth',1.5);

axes(handles.AxEnd);
imshow(red{end} > thres(end));
hold on;
plot(CT{end}(:,1)*scale,CT{end}(:,2)*scale,'r','Linewidth',1.5);

% set the smooth
setappdata(0, 'smooth', smooth); 
set(handles.text4, 'String', num2str(smooth));

% --- Executes during object creation, after setting all properties.
function SdSmoothing_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to SdSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%% Validation and Comeback buttons

% --- Executes on button press in PbBack.
function PbBack_Callback(hObject, eventdata, handles)%#ok % To back at ValidateThres
% hObject    handle to PbBack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
red=getappdata(0,'red');
delete(gcf);
ValidateThres(red);


% --- Executes on button press in PbValidate.
function PbValidate_Callback(hObject, eventdata, handles)%#ok % To go in the next window
% hObject    handle to PbValidate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.PbValidate,'Enable','off')
set(handles.PbValidate,'String','Wait please...')
pause(0.01);
smooth = getappdata(0,'smooth');
CT2 = getappdata(0,'CT2');
red = getappdata(0,'red');
indice = getappdata(0,'indice');
seuil = getappdata(0,'seuil');
thres = getappdata(0,'thres');
scale = getappdata(0,'scale');
size = 0;
debut  = getappdata(0,'debut');
fin = getappdata(0,'fin');
step = getappdata(0,'step');
direction = getappdata(0,'direction');
dirInitial = getappdata(0,'dirInitial');
nbInit  = getappdata(0,'nbInit');
N = getappdata(0,'N');
folder_name = getappdata(0,'folder_name');

dir = direction;
dirbegin = dirInitial;

CT=cell(length(red),1);
SK=cell(length(red),1);
shift=cell(length(red),1);
rad=cell(length(red),1);
CTVerif=cell(length(red),1);
SKVerif=cell(length(red),1);

disp('Skeletonisation');

parfor_progress(length(red));
for i=1:length(red)
    %Smoothing
    if smooth ~= 0
        CT2{i}(:,1) = moving_average(CT2{i}(:,1), smooth);
        CT2{i}(:,2) = moving_average(CT2{i}(:,2), smooth);
    end
    
    %Skeletonization
    [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(CT2{i},dir,dirbegin);
    parfor_progress;
   
end
parfor_progress(0);

delete(gcf);
ValidateSkeleton(red,smooth,CT2,indice,direction,dirInitial,thres,scale,size,...
    seuil,debut,fin,step,nbInit,N,folder_name,SK,CT,rad,SKVerif,CTVerif,shift); % Call the next window
