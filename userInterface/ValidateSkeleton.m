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
%     smooth = varargin{2};
%     CT2 = varargin{3};
    indice = varargin{4};
%     direction = varargin{5};
    dirInitial = varargin{6};
    thres = varargin{7};
%     scale = varargin{8};
%     size = varargin{9};
%     seuil = varargin{10};
%     debut = varargin{11};
%     fin = varargin{12};
%     step = varargin{13};
%     nbInit = varargin{14};
%     N = varargin{15};
%     folder_name = varargin{16};
%     SK = varargin{17};
%     CT = varargin{18};
%     rad = varargin{19};
    SKVerif = varargin{20};
    CTVerif = varargin{21};
%     shift = varargin{22};
    
    app = HypoGrowthApp();
end

app.currentStep = 'skeleton';

% Compute 3 skeletons that should be validated by the user

set(handles.middleImageIndexSlider, 'Max', length(red));


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



% setappdata(0, 'red', red);
% setappdata(0, 'Direction', direction);
% setappdata(0, 'DirInitial', dirInitial);
% setappdata(0, 'SK', SK);
% setappdata(0, 'CT', CT);
% setappdata(0, 'shift', shift);
% setappdata(0, 'rad', rad);
% setappdata(0, 'SKVerif', SKVerif);
% setappdata(0, 'CTVerif', CTVerif);
% setappdata(0, 'smooth', smooth);
% setappdata(0, 'thres', thres);
% setappdata(0, 'scale', scale);
% setappdata(0, 'size', size);
% setappdata(0, 'seuil', seuil);
% setappdata(0, 'debut', debut);
% setappdata(0, 'fin', fin);
% setappdata(0, 'step', step);
% setappdata(0, 'nbInit', nbInit);
% setappdata(0, 'N', N);
% setappdata(0, 'folder_name', folder_name);
% setappdata(0, 'CT2', CT2);

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
% scale   = app.pixelSize;
% red     = getappdata(0, 'red');
% seuil   = getappdata(0, 'seuil');
% SKVerif = getappdata(0, 'SKVerif');
% CTVerif = getappdata(0, 'CTVerif');
% scale   = getappdata(0, 'scale');

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

% indice  = app.currentFrameIndex;
% scale   = app.pixelSize;
% size    = 0;
% thres   = app.thresholdValues;
% debut   = app.firstIndex;
% fin     = app.lastIndex;
% step    = app.indexStep;
% nbInit  = length(red);
% N       = length(red);
% folderName = app.inputImageDirectory;

% red     = getappdata(0, 'red');
% smooth  = getappdata(0, 'smooth');
% CT2     = getappdata(0, 'CT2');
% indice  = getappdata(0, 'indice');
% scale   = getappdata(0, 'scale');
% size    = getappdata(0, 'size');
% thres   = getappdata(0, 'thres');
% debut   = getappdata(0, 'debut');
% fin     = getappdata(0, 'fin');
% step    = getappdata(0, 'step');
% nbInit  = getappdata(0, 'nbInit');
% N       = getappdata(0, 'N');
% folder_name = getappdata(0, 'folder_name');

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
%     % Smoothing
%     if smooth ~= 0
%         CT2{i} = smoothContour(CT2{i}, smooth);
%     end
%     
%     % Skeletonization
%     [SK{i}, CT{i}, shift{i}, rad{i}, SKVerif{i}, CTVerif{i}] = skel55(CT2{i},dir,dirbegin);

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

% red = getappdata(0,'red');%#ok
% CT = getappdata(0,'CT');%#ok
% SK = getappdata(0,'SK');%#ok
% R = getappdata(0,'rad');%#ok
% shift = getappdata(0,'shift');%#ok
% CTVerif = getappdata(0,'CTVerif');%#ok
% SKVerif = getappdata(0,'SKVerif');%#ok
% seuil = getappdata(0,'seuil');%#ok
% scale = getappdata(0,'scale');%#ok
% debut = getappdata(0,'debut');%#ok
% fin = getappdata(0,'fin');%#ok
% step = getappdata(0,'step');%#ok
% nbInit = getappdata(0,'nbInit');%#ok
% N = getappdata(0,'N');%#ok
% folder_name = getappdata(0,'folder_name');%#ok

% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile(); 

if pathName == 0
    warning('Select a file please');
    return;
end

name = fullfile(pathName, fileName);
% save(name,'CT','SK','R','shift','CTVerif','SKVerif',...
%     'seuil','scale','debut','fin','step','nbInit','N','folderName');
save(name,'CT','SK','R','shift','CTVerif','SKVerif',...
    'seuil','scale','debut','fin','step','nbInit','N','folderName');

set(handles.saveSkeletonDataButton, 'Enable', 'on');
set(handles.saveSkeletonDataButton, 'String', 'Save data of skeleton');


% --- Executes on button press in BackToContourButton.
function BackToContourButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to BackToContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
% red=getappdata(0,'red');
% seuil = getappdata(0,'seuil');
% scale = getappdata(0,'scale');
% size = getappdata(0,'size');
% debut = getappdata(0,'debut');
% fin = getappdata(0,'fin');
% step = getappdata(0,'step');
% direction = getappdata(0,'direction');
% dirInitial = getappdata(0,'dirInitial');
% nbInit = getappdata(0,'nbInit');
% N = getappdata(0,'N');
% folder_name = getappdata(0,'folder_name');
% thres = getappdata(0,'thres');
% CT2 = getappdata(0,'CT2');
delete (gcf);
ValidateContour(app);
% ValidateContour(seuil,red,scale,size,debut,fin,step,direction,dirInitial,nbInit,N,folder_name,CT2,thres);

% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');

red     = app.imageList;
CT      = app.scaledContourList;
SK      = app.scaledSkeletonList;
R       = app.radiusList;
shift   = app.originPosition;
CTVerif = app.contourList;
SKVerif = app.skeletonList;
seuil   = app.thresholdValues;
scale   = 1000 ./ app.pixelSize;
debut   = app.firstIndex;
fin     = app.lastIndex;
step    = app.indexStep;
nbInit  = length(R);
N       = length(R);
folderName = app.inputImagesDir;

% red = getappdata(0,'red');
% CT = getappdata(0,'CT');
% SK = getappdata(0,'SK');
% R = getappdata(0,'rad');
% shift = getappdata(0,'shift');
% CTVerif = getappdata(0,'CTVerif');
% SKVerif = getappdata(0,'SKVerif');
% seuil = getappdata(0,'thres');
% scale = getappdata(0,'scale');
% debut = getappdata(0,'debut');
% fin = getappdata(0,'fin');
% step = getappdata(0,'step');
% nbInit = getappdata(0,'nbInit');
% N = getappdata(0,'N');
% folder_name = getappdata(0,'folder_name');

delete(gcf);

StartElongation(red,CT,SK,R,shift,CTVerif,SKVerif,seuil,scale,debut,fin,step,nbInit,N,folderName);
