function varargout = StartElongation(varargin)
% STARTELONGATION MATLAB code for StartElongation.fig
%      STARTELONGATION, by itself, creates a new STARTELONGATION or raises the existing
%      singleton*.
%
%      H = STARTELONGATION returns the handle to a new STARTELONGATION or the handle to
%      the existing singleton*.
%
%      STARTELONGATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTELONGATION.M with the given input arguments.
%
%      STARTELONGATION('Property','Value',...) creates a new STARTELONGATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StartElongation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StartElongation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StartElongation

% Last Modified by GUIDE v2.5 22-Aug-2014 16:14:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StartElongation_OpeningFcn, ...
                   'gui_OutputFcn',  @StartElongation_OutputFcn, ...
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


% --- Executes just before StartElongation is made visible.
function StartElongation_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StartElongation (see VARARGIN)


% Choose default command line output for StartElongation
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthApp')
    disp('init from HypoGrowthApp');
    
    app = varargin{1};
    app.currentStep = 'elongation';
    setappdata(0, 'app', app);
 
elseif nargin == 18 
    % if user come from ValidateSkeleton
    warning('old way of calling StartElongation');
    
elseif nargin == 3 
    % if user start the program. He must load the data
    [FileName, PathName] = uigetfile('*.mat', 'Select the MATLAB code file');
    if PathName == 0
        warning('Select a directory please');
        return;
    end
    
    file = fullfile(PathName,FileName);
    load(file);
    if step == 1 
        % For open all pictures
        nb = fin - debut + 1; 
        disp('Opening directory ...');
        red = cell(nb,1);
        parfor_progress(nb);
        for i = debut:fin
            try
                red{i - debut + 1} = imread(fullfile(folder_name,N(i).name)); 
            catch e%#ok
                disp('Pictures''s folder not found');
                delete(gcf);
                return;
            end
            parfor_progress;
        end
        parfor_progress(0);
        
    else
        nb = 0;
        disp('Opening directory ...');
        for i = debut : step : fin
            nb = nb + 1;
        end
        red = cell(nb,1);
        parfor_progress(nb);
        for i = 0:nb - 1
            try
                red{i+1} = imread(fullfile(folder_name,N(debut + step * i).name)); 
            catch ex %#ok<NASGU>
                disp('Pictures''s folder not found');
                delete(gcf);
                return;
            end
            parfor_progress;
        end
        parfor_progress(0);
        
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StartElongation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StartElongation_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function mainFrameMenuItem_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
HypoGrowthMenu(app);


function timeIntervalEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalEdit as a double


% --- Executes during object creation, after setting all properties.
function timeIntervalEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useDefaultSettingsRadioButton.
function useDefaultSettingsRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to useDefaultSettingsRadioButton (see GCBO)%#ok
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDefaultSettingsRadioButton
set(handles.changeSettingsRadioButton,'Value',0);
set(handles.useDefaultSettingsRadioButton,'Value',1);
set(handles.smoothingLengthEdit,'Visible','off');
set(handles.pointNumberEdit,'Visible','off');
set(handles.correlationWindowSize1Edit,'Visible','off');
set(handles.correlationWindowSize2Edit,'Visible','off');
set(handles.displacementStepEdit,'Visible','off');
set(handles.smoothingLengthLabel,'Visible','off');
set(handles.pointNumberLabel,'Visible','off');
set(handles.correlationWindowSize1Label,'Visible','off');
set(handles.correlationWindowSize2Label,'Visible','off');
set(handles.displacementStepLabel,'Visible','off');

set(handles.validateSettingsButton,'Visible','on');


% --- Executes on button press in changeSettingsRadioButton.
function changeSettingsRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to changeSettingsRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of changeSettingsRadioButton
set(handles.useDefaultSettingsRadioButton,'Value',0);
set(handles.changeSettingsRadioButton,'Value',1);
set(handles.smoothingLengthEdit,'Visible','on');
set(handles.pointNumberEdit,'Visible','on');
set(handles.correlationWindowSize1Edit,'Visible','on');
set(handles.correlationWindowSize2Edit,'Visible','on');
set(handles.displacementStepEdit,'Visible','on');
set(handles.smoothingLengthLabel,'Visible','on');
set(handles.pointNumberLabel,'Visible','on');
set(handles.correlationWindowSize1Label,'Visible','on');
set(handles.correlationWindowSize2Label,'Visible','on');
set(handles.displacementStepLabel,'Visible','on');

set(handles.validateSettingsButton,'Visible','on');


function smoothingLengthEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to smoothingLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothingLengthEdit as text
%        str2double(get(hObject,'String')) returns contents of smoothingLengthEdit as a double


% --- Executes during object creation, after setting all properties.
function smoothingLengthEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to smoothingLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pointNumberEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pointNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pointNumberEdit as text
%        str2double(get(hObject,'String')) returns contents of pointNumberEdit as a double


% --- Executes during object creation, after setting all properties.
function pointNumberEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to pointNumberEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function correlationWindowSize1Edit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to correlationWindowSize1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of correlationWindowSize1Edit as text
%        str2double(get(hObject,'String')) returns contents of correlationWindowSize1Edit as a double


% --- Executes during object creation, after setting all properties.
function correlationWindowSize1Edit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to correlationWindowSize1Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function correlationWindowSize2Edit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to correlationWindowSize2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of correlationWindowSize2Edit as text
%        str2double(get(hObject,'String')) returns contents of correlationWindowSize2Edit as a double


% --- Executes during object creation, after setting all properties.
function correlationWindowSize2Edit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to correlationWindowSize2Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function displacementStepEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to displacementStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of displacementStepEdit as text
%        str2double(get(hObject,'String')) returns contents of displacementStepEdit as a double


% --- Executes during object creation, after setting all properties.
function displacementStepEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to displacementStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

        
% --- Executes on button press in changeDirectoryCheckBox.
function changeDirectoryCheckBox_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to changeDirectoryCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of changeDirectoryCheckBox
if get(handles.changeDirectoryCheckBox,'Value') == 1
    set(handles.keepAllFramesCheckBox,'Visible','on');
    set(handles.choosePrefixRadioButton,'Visible','on');
    set(handles.fileNamePrefixEdit,'Visible','on');
    set(handles.changeInputDirectoryButton,'Visible','on');
    set(handles.changeDirectoryCheckBox,'Value',1);
    
elseif get(handles.changeDirectoryCheckBox,'Value') == 0
    set(handles.keepAllFramesCheckBox,'Visible','off');
    set(handles.choosePrefixRadioButton,'Visible','off');
    set(handles.fileNamePrefixEdit,'Visible','off');
    set(handles.changeInputDirectoryButton,'Visible','off');
    set(handles.changeDirectoryCheckBox,'Value',0);
    
end

% --- Executes on button press in keepAllFramesCheckBox.
function keepAllFramesCheckBox_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to keepAllFramesCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepAllFramesCheckBox

set(handles.keepAllFramesCheckBox,'Value',1);
set(handles.choosePrefixRadioButton,'Value',0);


% --- Executes on button press in choosePrefixRadioButton.
function choosePrefixRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to choosePrefixRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of choosePrefixRadioButton

set(handles.keepAllFramesCheckBox,'Value',0);
set(handles.choosePrefixRadioButton,'Value',1);

function fileNamePrefixEdit_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to fileNamePrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNamePrefixEdit as text
%        str2double(get(hObject,'String')) returns contents of fileNamePrefixEdit as a double


% --- Executes during object creation, after setting all properties.
function fileNamePrefixEdit_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to fileNamePrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in changeInputDirectoryButton.
function changeInputDirectoryButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to changeInputDirectoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% TODO: was not modified. Proposal is to remove it.

debut   = getappdata(0, 'debut');
fin     = getappdata(0, 'fin');
step    = getappdata(0, 'step');
nbInit  = getappdata(0, 'nbInit');

if get(handles.keepAllFramesCheckBox,'Value') == 1
    
    folder_name = uigetdir(); % Open a dialog box
    if folder_name == 0;
        warning('Select a floder please');
        return;
    end
    N = dir(folder_name); % To open the directory
    nb = length(N);
    for i = 1 : nb - 2 % 2 for to eliminate the first and second index : '.' & '..'
        N(i) = N(i + 2);
    end
    for i = 1 : 2
        N(end) = [];
    end
    nb = length(N);
    if nb == 0
        warning('Not good pictures in the directory. Take an other');
        return;
    end
    if(nb ~= nbInit)
        error('The two directory must have the same number of picture'); 
    end
    
elseif get(handles.choosePrefixRadioButton,'Value') == 1
    
    str = get(handles.fileNamePrefixEdit,'String');
    if isempty(str)
        warning('Text area is empty');
        return;
    end
    
    % chose another folder
    folder_name = uigetdir();
    if folder_name == 0;
        warning('Select a floder please');
        return;
    end
    
    str = strcat(str,'*.*');
    rep = fullfile(folder_name,str);
    N = dir(rep); % To open the directory
    nb = length(N);
    if nb == 0
        warning('Not good pictures in the directory. Take an other');
        return;
    end
    if nb ~= nbInit
         error('The two directory must have the same number of picture'); 
    end
    
else
    warning('Select an option please');
    return;
end


plage = fin - debut;
if step == 1
    col = cell(plage,1);
    for i = debut:fin
        col{i - debut + 1} = imread(fullfile(folder_name,N(i).name)); % Same thing for the '+1'
    end
else
    col = cell(plage,1);
    for i = 0:plage-1
        col{i} = imread(fullfile(folder_name, N(debut + step * i).name));
    end
end

setappdata(0, 'red', col);
disp('Directory changed');


% --- Executes on button press in validateSettingsButton.
function validateSettingsButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validateSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% To start the programm
set(handles.validateSettingsButton, 'Enable', 'Off')
set(handles.validateSettingsButton, 'String', 'Wait please...')
pause(0.01);

% get global data
app = getappdata(0, 'app');
red     = app.imageList;
SK      = app.scaledSkeletonList;
R       = app.radiusList;
shift   = app.originPosition;
scale   = 1000 ./ app.pixelSize;
t0      = app.timeInterval;

tic;

% default values
iw  = 10;
nx  = 500;
ws  = 15;
ws2 = 30;
step = 2;

if get(handles.changeSettingsRadioButton, 'Value') == 1
    % Take the parameters given by the user
    iw  = get(handles.smoothingLengthEdit, 'String'); 
    nx  = get(handles.pointNumberEdit, 'String');
    ws  = get(handles.correlationWindowSize1Edit, 'String');
    ws2 = get(handles.correlationWindowSize2Edit, 'String');
    step = get(handles.displacementStepEdit, 'String');
    
    if length(iw) == 0 || length(nx) ==0 || length(ws) == 0 || length(ws2) ==0 || length(step) ==0  %#ok
        warning('Edit must not be empty');
        return;
    end
    
    iw  = str2num(iw);%#ok
    nx  = str2num(nx);%#ok
    ws  = str2num(ws);%#ok
    ws2 = str2num(ws2);%#ok
    step = str2num(step);%#ok
    
    if isempty(nx) || isempty(iw) || isempty(ws) || isempty(ws2) || isempty(step)
        warning('Value must be a number');
        return;
    end
    
    if iw < 0 || nx < 0 || ws < 0 || ws2 < 0 || step < 0
        warning('Value must be positive');
        return;
    end
end



% store new settings in Application Data
app.curvatureSmoothingSize = iw;
app.windowSize1 = ws;
app.windowSize2 = ws2;
app.displacementStep = step;
app.finalResultLength = nx;


% Start the program

% Curvature
disp('Curvature');
[S, A, C] = curvall(SK, iw);

% Alignment of all the results
disp('Alignment of curves');
Sa = aligncurv(S, R);

% Displacement
disp('Displacement');
% variable not used
we = 1; 
E = displall(SK, Sa, red, scale, shift, ws, we, step);

% Elongation
disp('Elongation');
[Elg, E2] = elgall(E, t0, step, ws2);

%  Space-time mapping
ElgE1 = reconstruct_Elg2(nx, Elg);
CE1 = reconstruct_Elg2(nx, C, Sa);
AE1 = reconstruct_Elg2(nx, A, Sa);
RE1 = reconstruct_Elg2(nx, R, Sa);

toc;

% store results in Application Data
app.abscissaList        = Sa;
app.verticalAngleList   = A;
app.curvatureList       = C;
app.displacementList    = E;
app.smoothedDisplacementList = E2;
app.elongationList      = Elg;

app.elongationImage     = ElgE1;
app.curvatureImage      = CE1;
app.verticalAngleImage  = AE1;
app.radiusImage         = RE1;

setappdata(0, 'app', app);

delete(gcf);

disp('Display Kymographs');
DisplayKymograph(app);
