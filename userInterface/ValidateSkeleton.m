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

% Last Modified by GUIDE v2.5 21-Aug-2014 20:01:03

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
function ValidateSkeleton_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Skeleton (see VARARGIN)

% Choose default command line output for Skeleton
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthApp')
    % should be the canonical way of calling the program
    
    app = varargin{1};
    setappdata(0, 'app', app);
    
    red     = app.imageList;
    thres   = app.thresholdValues;
    CTVerif = app.contourList;
    SKVerif = app.skeletonList;
    indice  = app.currentFrameIndex;
    dirInitial = app.firstPointLocation;
    
else
    warning('Deprecated way of calling ValidateSkeleton');
    % extract input arguments
    red = varargin{1};
    indice = varargin{4};
    dirInitial = varargin{6};
    thres = varargin{7};
    SKVerif = varargin{20};
    CTVerif = varargin{21};
    
    app = HypoGrowthApp();
end

app.currentStep = 'skeleton';

set(handles.middleImageIndexSlider, 'Min', 1);
set(handles.middleImageIndexSlider, 'Max', length(red));
set(handles.middleImageIndexSlider, 'Value', 1);

% Compute 3 skeletons that should be validated by the user


% Show the three skeletons
axes(handles.AxFirst2);
imshow(red{1} > thres(1));
hold on;
% plot(CTVerif{1}(:,1) * scale, CTVerif{1}(:,2) * scale, 'r');
% plot(SKVerif{1}(:,1) * scale, SKVerif{1}(:,2) * scale, 'b');
plot(CTVerif{1}(:,1), CTVerif{1}(:,2), 'r');
% plot(SKVerif{1}(:,1), SKVerif{1}(:,2), 'b');
skeleton = SKVerif{1} * 1000 / app.pixelSize;
plot(skeleton(:,1), skeleton(:,2), 'b');
set(handles.text5, 'String', 'Frame n° 1');

axes(handles.AxMiddle2);
imshow(red{indice} > thres(indice));
hold on;
% plot(CTVerif{indice}(:,1)*scale, CTVerif{indice}(:,2)*scale, 'r');
% plot(SKVerif{indice}(:,1)*scale, SKVerif{indice}(:,2)*scale, 'b');
plot(CTVerif{indice}(:,1), CTVerif{indice}(:,2), 'r');
% plot(SKVerif{indice}(:,1), SKVerif{indice}(:,2), 'b');
skeleton = SKVerif{indice} * 1000 / app.pixelSize;
plot(skeleton(:,1), skeleton(:,2), 'b');
set(handles.text6, 'String', strcat('Frame n°', num2str(indice)));

axes(handles.AxEnd2);
imshow(red{end} > thres(end));
hold on;
% plot(CTVerif{end}(:,1)*scale,CTVerif{end}(:,2)*scale,'r');
% plot(SKVerif{end}(:,1)*scale,SKVerif{end}(:,2)*scale,'b');
plot(CTVerif{end}(:,1), CTVerif{end}(:,2), 'r');
% plot(SKVerif{end}(:,1), SKVerif{end}(:,2), 'b');
skeleton = SKVerif{end} * 1000 / app.pixelSize;
plot(skeleton(:,1), skeleton(:,2), 'b');
set(handles.text7, 'String', strcat('Frame n°', num2str(length(red))));

direction = 'boucle';
switch direction
    case 'boucle'
        set(handles.filterDirectionPopup,'Value',1);
    case 'droit'
        set(handles.filterDirectionPopup,'Value',2);
    case 'droit2'
        set(handles.filterDirectionPopup,'Value',3);
    case 'penche'
        set(handles.filterDirectionPopup,'Value',4);
    case 'penche2'
        set(handles.filterDirectionPopup,'Value',5);
    case 'dep'
        set(handles.filterDirectionPopup,'Value',6);
    case 'rien'
        set(handles.filterDirectionPopup,'Value',7);
end


switch dirInitial
    case 'bottom'
        set(handles.firstSkeletonPointPopup,'Value',1);
    case 'left'
        set(handles.firstSkeletonPointPopup,'Value',2);
    case 'right'
        set(handles.firstSkeletonPointPopup,'Value',3);
    case 'top'
        set(handles.firstSkeletonPointPopup,'Value',4);
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

delete(gcf);
StartProgramm();


% --- Executes on slider movement.
function middleImageIndexSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to middleImageIndexSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') retkurns position osf slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');
red     = app.imageList;
seuil   = app.thresholdValues;
SKVerif = app.skeletonList;
CTVerif = app.contourList;

val = get(handles.middleImageIndexSlider, 'Value');
val = ceil(val);

set(handles.middleImageIndexSlider, 'Enable', 'Off');

if val == 0
    val = 1;
end

seuil = seuil(val);

axes(handles.AxMiddle2);
imshow(red{val} > seuil);
hold on;
% plot(CTVerif{val}(:,1)*scale, CTVerif{val}(:,2)*scale, 'r');
% plot(SKVerif{val}(:,1)*scale, SKVerif{val}(:,2)*scale, 'b');
plot(CTVerif{val}(:,1), CTVerif{val}(:,2), 'r');
% plot(SKVerif{val}(:,1), SKVerif{val}(:,2), 'b');
skeleton = SKVerif{val} * 1000 / app.pixelSize;
plot(skeleton(:,1), skeleton(:,2), 'b');

% setup slider for display of current frame
maxSlide = length(red);
set(handles.middleImageIndexSlider, 'Max', maxSlide); 
sliderStep = min(max([1 5] ./ (maxSlide - 1), 0.001), 1);
set(handles.middleImageIndexSlider, 'SliderStep', sliderStep); 
set(handles.middleImageIndexSlider, 'Enable', 'On');

set(handles.text6, 'String', strcat('Frame n°',num2str(val)));


% --- Executes during object creation, after setting all properties.
function middleImageIndexSlider_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to middleImageIndexSlider (see GCBO)
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
set(handles.updateSkeletonButton, 'Enable', 'off')
set(handles.updateSkeletonButton, 'String', 'Wait please...')
pause(0.01);

app = getappdata(0, 'app');
red     = app.imageList;
smooth  = app.contourSmoothingSize;
CT2     = app.contourList;

% To take the first values
val = get(handles.filterDirectionPopup, 'Value'); 
setappdata(0, 'val', val);
direction = get(handles.filterDirectionPopup, 'String');

% To take the second value
val2 = get(handles.firstSkeletonPointPopup, 'Value');
setappdata(0, 'val2' ,val2);
dirInitial = get(handles.firstSkeletonPointPopup, 'String');

direction   = direction{val};
dirInitial  = dirInitial{val2};

dir = direction;
dirbegin = dirInitial;

% initialize result arrays
CT      = cell(length(red), 1);
SK      = cell(length(red), 1);
shift   = cell(length(red), 1);
rad     = cell(length(red), 1);
CTVerif = cell(length(red), 1);
SKVerif = cell(length(red), 1);

disp('Skeletonization');
hDialog = msgbox(...
    {'Computing skeletons from contours,', 'please wait...'}, ...
    'Skeletonization');

parfor_progress(length(red));
for i = 1:length(red)
    % Smooth current contour
    contour = CT2{i};
    if smooth ~= 0
        contour = smoothContour(contour, smooth);
    end
    
    % scale contour in user unit
    contour = contour * app.pixelSize / 1000;
    
    % Skeleton of current contour
%     [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(CT2{i}, dir, dirbegin);
    [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(contour, dir, dirbegin);
%     CTVerif{i} = contour;
%     [SKVerif{i}, rad{i}] = skel55b(contour, dir, dirbegin);
%     [SK{i}, CT{i}, shift{i}] = shiftSkeleton(SK{i}, CT{i});

    parfor_progress;
end

parfor_progress(0);
if ishandle(hDialog)
    close(hDialog);
end

app.skeletonList = SKVerif;
app.radiusList = rad;

app.scaledContourList = CT;
app.scaledSkeletonList = SK;
app.originPosition = shift;

setappdata(0, 'app', app); 

% close the window and open again with the new settings
delete(gcf);

ValidateSkeleton(app);
% seuil = thres;
% ValidateSkeleton(red,smooth,CT2,indice,direction,dirInitial,thres,...
%     scale,size,seuil,debut,fin,step,nbInit,N,folderName,SK,CT,rad,SKVerif,CTVerif,shift);


% --- Executes on button press in saveSkeletonDataButton.
function saveSkeletonDataButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to saveSkeletonDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.saveSkeletonDataButton, 'Enable', 'off');
set(handles.saveSkeletonDataButton, 'String', 'Wait please...');
pause(0.01);

app = getappdata(0, 'app');
red     = app.imageList;
smooth  = app.contourSmoothingSize; %#ok<NASGU>
CTVerif = app.contourList; %#ok<NASGU>
SKVerif = app.skeletonList; %#ok<NASGU>
R       = app.radiusList; %#ok<NASGU>
CT      = app.scaledContourList; %#ok<NASGU>
SK      = app.scaledSkeletonList; %#ok<NASGU>
shift   = app.originPosition; %#ok<NASGU> 
seuil   = app.thresholdValues; %#ok<NASGU> 
% scale   = app.pixelSize; %#ok<NASGU> 
scale   = 1000 ./ app.pixelSize; %#ok<NASGU> 
debut   = app.firstIndex; %#ok<NASGU> 
fin     = app.lastIndex; %#ok<NASGU> 
step    = app.indexStep; %#ok<NASGU> 
nbInit  = length(red); %#ok<NASGU> 
N       = length(red); %#ok<NASGU> 
folderName = app.inputImageDirectory; %#ok<NASGU> 

% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile(); 

if pathName == 0
    warning('Select a file please');
    return;
end

name = fullfile(pathName, fileName);
save(name, 'app');
% % save(name,'CT','SK','R','shift','CTVerif','SKVerif',...
% %     'seuil','scale','debut','fin','step','nbInit','N','folderName');
% save(name,'CT','SK','R','shift','CTVerif','SKVerif',...
%     'seuil','scale','debut','fin','step','nbInit','N','folderName');

set(handles.saveSkeletonDataButton, 'Enable', 'On');
set(handles.saveSkeletonDataButton, 'String', 'Save data of skeleton');


% --- Executes on button press in BackToContourButton.
function BackToContourButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to BackToContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete (gcf);
ValidateContour(app);

% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
StartElongation(app);
