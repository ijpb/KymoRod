function varargout = StartSkeleton(varargin)
% STARTSKELETON MATLAB code for StartSkeleton.fig
%      STARTSKELETON, by itself, creates a new STARTSKELETON or raises the existing
%      singleton*.
%
%      H = STARTSKELETON returns the handle to a new STARTSKELETON or the handle to
%      the existing singleton*.
%
%      STARTSKELETON('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTSKELETON.M with the given input arguments.
%
%      STARTSKELETON('Property','Value',...) creates a new STARTSKELETON or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StartSkeleton_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StartSkeleton_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StartSkeleton

% Last Modified by GUIDE v2.5 20-Aug-2014 18:07:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StartSkeleton_OpeningFcn, ...
                   'gui_OutputFcn',  @StartSkeleton_OutputFcn, ...
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


% --- Executes just before StartSkeleton is made visible.
function StartSkeleton_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StartSkeleton (see VARARGIN)

% initialize some global variables
setappdata(0, 'RepertoireImage', '');
setappdata(0, 'NomRep', '');

set(handles.channelSelectionPanel, 'SelectionChangeFcn', ...
    @channelSelectionPanel_SelectionChangeFcn);

if nargin == 6 
    col = varargin{1};
    N = varargin{2};
    folderName = varargin{3};
    set(handles.slider1, 'Visible', 'on');
    set(handles.axis1Label, 'Visible', 'on');
    set(handles.axis2Label, 'Visible', 'on');
    set(handles.axes1, 'Visible', 'on');
    set(handles.axes2, 'Visible', 'on');
    set(handles.keepAllFramesRadioButton, 'Visible', 'on');
    set(handles.selectFramesIndicesRadioButton, 'Visible', 'on');
    
    nb = length(col);
    
    set(handles.slider1, 'Max', nb - 1);
    
    % demo images
    mini = cell(2,1);
    for i = 1:2
        mini{i} = col{i};
    end
    
    % display first image
    axes(handles.axes1);
    imshow(mini{1});
    set(handles.axis1Label, 'String', '1');
    
    % display second image
    axes(handles.axes2);
    imshow(mini{2});
    set(handles.axis2Label, 'String', '2');
    
    % update globale variables
    setappdata(0, 'Nbimages', nb);
    setappdata(0, 'NomRep', N);
    setappdata(0, 'RepertoireImage', folderName);
    setappdata(0, 'col', col);
    
    flag = 2;
    
    string = sprintf('Select a range among the %d frames', nb);
    set(handles.selectFramesIndicesRadioButton, 'String', string);
else 
    flag = 1;
end

setappdata(0, 'flag', flag);

% Choose default command line output for StartSkeleton
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StartSkeleton wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StartSkeleton_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function mainFrameMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();


% --- Executes on button press in chooseInputImagesButton.
function chooseInputImagesButton_Callback(hObject, eventdata, handles)%#ok 
% To select the images from a directory

% Open a dialog box
folderName = getappdata(0, 'RepertoireImage');
folderName = uigetdir(folderName);

% check if cancel button was selected
if folderName == 0;
    return;
end

set(handles.directoryNameEdit, 'String', folderName);
setappdata(0, 'RepertoireImage', folderName);

% list files in chosen directory
fileList = dir(fullfile(folderName, '*.*'));
fileList = fileList(~[fileList.isdir]);

if isempty(fileList)
    errordlg({'The chosen directory contains no file.', ...
        'Please choose another one'}, ...
        'Empty Directory Error', 'modal')
    return;
end

selectedRadioButton = get(handles.channelSelectionPanel, 'SelectedObject');
if selectedRadioButton == handles.allImagesRadioButton
    % All images selected
    % Requires two 'for'-loops to eliminate the first and second index: '.' & '..'
    for i = 1 : length(fileList) - 2 
        fileList(i) = fileList(i + 2);
    end
    for i = 1 : 2
        fileList(end) = [];
    end
    
elseif selectedRadioButton == handles.selectChannelRadioButton
    % keep only images starting with a given letter
    str = get(handles.channelPrefixEdit,'String');
    if isempty(str)
        warning('Text area is empty');
        return;
    end
   
    str = strcat(str, '*.*');
    rep = fullfile(folderName, str);
    fileList = dir(rep);
    fileList = fileList(~[fileList.isdir]);

    if isempty(fileList)
        errordlg({'The chosen directory contains no file.', ...
            'Please choose another one'}, ...
            'Empty Directory Error', 'modal')
        return;
    end
end

imageNumber = length(fileList);

set(handles.channelSelectionPanel, 'Visible', 'on');
set(handles.calibrationPanel, 'Visible', 'on');
set(handles.frameSelectionPanel, 'Visible', 'on');

set(handles.slider1, 'Visible', 'on');
set(handles.axis1Label, 'Visible', 'on');
set(handles.axis2Label, 'Visible', 'on');
set(handles.axes1, 'Visible', 'on');
set(handles.axes2, 'Visible', 'on');

set(handles.slider1, 'Max', imageNumber - 1);

mini = cell(2,1);
for i = 1:2 
    mini{i} = imread(fullfile(folderName, fileList(i).name));
end 

axes(handles.axes1);
imshow(mini{1});
set(handles.axis1Label, 'String', sprintf('frame %d (%s)', 1, fileList(1).name));

axes(handles.axes2);
imshow(mini{2});
% set(handles.axis2Label, 'String', '2');
set(handles.axis2Label, 'String', sprintf('frame %d (%s)', 2, fileList(2).name));

setappdata(0, 'Nbimages', imageNumber);
setappdata(0, 'NomRep', fileList); 
setappdata(0, 'RepertoireImage', folderName); 

string = sprintf('Keep All Frames (%d)', imageNumber);
set(handles.keepAllFramesRadioButton, 'String', string);
string = sprintf('Select a range among the %d frames', imageNumber);
set(handles.selectFramesIndicesRadioButton, 'String', string);

guidata(hObject, handles);


% --- Executes on button change in channelSelectionPanel
function channelSelectionPanel_SelectionChangeFcn(hObject, eventdata)
% channelSelectionPanel

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles) % To select all the pictures
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)  
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(handles.slider1,'Value'); %Take the value between 0 and 255
val = floor(val);
val = val + 1; %'+1' To start at the index n°1

flag = getappdata(0, 'flag');
col = getappdata(0, 'col');
folderName = getappdata(0, 'RepertoireImage');
fileList = getappdata(0, 'NomRep');

valmax = get(handles.slider1, 'Max');
if val == valmax + 1
    val = val - 1;
end

mini2 = cell(2,1);
for i = val:val + 1
    if flag == 1
        % '+1' To start at the index 1
        mini2{i - val + 1} = imread(fullfile(folderName, fileList(i).name)); 
    elseif flag == 2
        % '+1' To start at the index 1
        mini2{i - val + 1} = col{i};
    end
end


axes(handles.axes1);
imshow(mini2{1});
set(handles.axis1Label, 'String', val);
string = sprintf('frame %d (%s)', val, fileList(val).name);
set(handles.axis1Label, 'String', string);

axes(handles.axes2);
imshow(mini2{2});
string = sprintf('frame %d (%s)', val + 1, fileList(val + 1).name);
set(handles.axis2Label, 'String', string);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in keepAllFramesRadioButton.
function keepAllFramesRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to keepAllFramesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepAllFramesRadioButton
set(handles.pushbutton5,'Visible','on');
set(handles.saveSelectedImagesButton,'Visible','on');
set(handles.text8,'Visible','off');
set(handles.text10,'Visible','off');
set(handles.text11,'Visible','off');
set(handles.edit8,'Visible','off');
set(handles.edit9,'Visible','off');
set(handles.edit10,'Visible','off');
set(handles.keepAllFramesRadioButton,'Value',1);
set(handles.selectFramesIndicesRadioButton,'Value',0);
set(handles.channelPrefixEdit,'Visible','off');

guidata(hObject, handles);
% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


guidata(hObject, handles);
% --- Executes on button press in selectFramesIndicesRadioButton.


function selectFramesIndicesRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to selectFramesIndicesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectFramesIndicesRadioButton
set(handles.pushbutton5,'Visible','on');
set(handles.saveSelectedImagesButton,'Visible','on');
set(handles.text8, 'Visible', 'on');
set(handles.text10, 'Visible', 'on');
set(handles.text11, 'Visible', 'on');
set(handles.edit8, 'Visible', 'on');
set(handles.edit9, 'Visible', 'on');
set(handles.edit10, 'Visible', 'on');
set(handles.keepAllFramesRadioButton,'Value', 0);
set(handles.selectFramesIndicesRadioButton, 'Value', 1);
set(handles.channelPrefixEdit, 'Visible', 'off');

guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nbInit = getappdata(0, 'Nbimages');
N = getappdata(0, 'NomRep');
folderName = getappdata(0, 'RepertoireImage');
nb = nbInit;
flag = getappdata(0, 'flag');
colN = getappdata(0, 'col');

if get(handles.keepAllFramesRadioButton, 'Value') == 1 
   % For all pictures
    set(handles.pushbutton5, 'Enable', 'off')
    set(handles.pushbutton5, 'String', 'Wait please...')
    pause(0.01);
    debut = 1;
    fin = nb;
    
    setappdata(0, 'debut', debut);
    setappdata(0, 'fin', fin);
    
    disp('Opening directory ...');
    col = cell(nb,1);
    
    parfor_progress(length(N));
    for i = 1:nb
        if flag == 1
            col{i} = imread(fullfile(folderName, N(i).name));
        elseif flag == 2
            col{i} = colN{i};
        end
        parfor_progress;
    end
    parfor_progress(0); 
    
    step = 1;
    delete (gcf);
    ValidateThres(debut, fin, nb, col, step, nbInit, N, folderName);

else
    % For pictures by step
    firstPicture = get(handles.edit8, 'String');% To take the range of pictures
    lastPicture = get(handles.edit9, 'String');
    stepPicture = get(handles.edit10, 'String');
    set(handles.pushbutton5,'Enable','off')
    set(handles.pushbutton5,'String','Wait please...')
    pause(0.01);
    
    if length(firstPicture) ~= 0   %#ok isempty does'nt work i dont know why
        firstPicture = str2num(firstPicture);%#ok I want [] if it's a string and not NaN to test it
    elseif length(firstPicture) == 0%#ok
        firstPicture = 1;
    end
    if length(lastPicture) ~= 0%#ok
        lastPicture = str2num(lastPicture);%#ok
    elseif length(lastPicture) == 0%#ok
        lastPicture = nb;
    end
    if  length(stepPicture) ~=0%#ok
        stepPicture = str2num(stepPicture);%#ok
    elseif length(stepPicture) == 0%#ok
        stepPicture = 1;
    end
    
    % check input validity
    if isempty(firstPicture) || isempty(lastPicture) || isempty(stepPicture)
        errordlg({'Please set a numeric value for the first, the last,', ...
            'and the step indices'}, ...
            'Wrong indices', 'modal')
        return;
    end
    
    disp('Opening directory ...');
    col = cell(nbstep,1);
    parfor_progress(nbstep);
    for i = 0:nbstep-1
        if flag == 1
            col{i+1} = imread(fullfile(folderName, N(firstPicture + stepPicture * i).name));
        elseif flag == 2
            col{i+1} = colN{firstPicture + stepPicture * i};
        end
        parfor_progress;
    end
    parfor_progress(0);
    debut = firstPicture;
    fin = lastPicture;
    
    delete (gcf);
    
    ValidateThres(debut, fin, nb, col, stepPicture, nbInit, N, folderName);
end



% % --- Executes on button press in allImagesCheckBox.
% function allImagesCheckBox_Callback(hObject, eventdata, handles)%#ok
% % hObject    handle to allImagesCheckBox (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of allImagesCheckBox
% set(handles.allImagesCheckBox,'Value',1);
% set(handles.SelectImagesFromLetterCheckBox,'Value',0);
% set(handles.channelPrefixEdit,'Visible','off');
% 
% % --- Executes on button press in SelectImagesFromLetterCheckBox.
% function SelectImagesFromLetterCheckBox_Callback(hObject, eventdata, handles)%#ok
% % hObject    handle to SelectImagesFromLetterCheckBox (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: get(hObject,'Value') returns toggle state of SelectImagesFromLetterCheckBox
% set(handles.allImagesCheckBox,'Value',0);
% set(handles.SelectImagesFromLetterCheckBox,'Value',1);
% set(handles.channelPrefixEdit,'Visible','on');


function channelPrefixEdit_Callback(hObject, eventdata, handles)
% hObject    handle to channelPrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelPrefixEdit as text
%        str2double(get(hObject,'String')) returns contents of channelPrefixEdit as a double


% --- Executes during object creation, after setting all properties.
function channelPrefixEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelPrefixEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveSelectedImagesButton.
function saveSelectedImagesButton_Callback(hObject, eventdata, handles)%#ok % To save the new pictures
% hObject    handle to saveSelectedImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.saveSelectedImagesButton, 'Enable', 'off');
set(handles.saveSelectedImagesButton, 'String', 'Wait please...');

pause(0.01);
nbInit = getappdata(0, 'Nbimages');
N = getappdata(0, 'NomRep');
folderName = getappdata(0, 'RepertoireImage');
nb = nbInit;

[FileName, PathName] = uiputfile('*.*', 'Enter a name for your new directory of pictures');

if PathName == 0;
    set(handles.saveSelectedImagesButton, 'Enable', 'on');
    set(handles.saveSelectedImagesButton, 'String', 'Save new pictures');
    return;
end

path = fullfile(PathName, FileName); 
mkdir(path);

if get(handles.keepAllFramesRadioButton,'Value') == 1 
    % For all pictures  
    debut = 1;
    fin = nb;
    
    setappdata(0,'debut',debut);
    setappdata(0,'fin',fin);
    
    disp('Opening directory ...');
    col = cell(nb,1);
    for i = 1:nb
        col{i} = imread(fullfile(folderName,N(i).name));
    end
   
else
    % For pictures by step
    firstPicture = get(handles.edit8, 'String');% To take the range of pictures
    lastPicture = get(handles.edit9, 'String');
    stepPicture = get(handles.edit10, 'String');
    
    if length(firstPicture) ~= 0 && length(lastPicture) ~= 0 &&  length(stepPicture)  %#ok isempty does'nt work i dont know why
        firstPicture = str2num(firstPicture);%#ok
        lastPicture = str2num(lastPicture);%#ok
        stepPicture = str2num(stepPicture);%#ok
        
        if ~isempty(firstPicture) && ~isempty(lastPicture) && ~isempty(stepPicture)
            
            nbstep = 0;
            for i = firstPicture:stepPicture:lastPicture
                nbstep = nbstep + 1;
            end
            if nbstep <= nb
                disp('Opening directory ...');
                col = cell(nbstep,1);
                for i = 0:nbstep-1
                    col{i+1} = imread(fullfile(folderName,N(firstPicture + stepPicture * i).name));
                end
                
                disp('Saving new data...');
                nb = length(col);
                for i = 0 : nb - 1
                    imwrite(col{i + 1},fullfile(path,'/',N(firstPicture + stepPicture * i).name));
                end
            else
                warning('Length of your range must be smaller than length of picture');
            end
        else
            warning('Set a numeric value for the begin, the step and the length');
        end
    else
        warning('Set 3 values not empty for the begin, the step and the length');
    end
end

set(handles.saveSelectedImagesButton, 'Enable', 'on');
set(handles.saveSelectedImagesButton, 'String', 'Save new pictures');

guidata(hObject, handles);


% --- Executes on button press in editImagesButton.
function editImagesButton_Callback(hObject, eventdata, handles)
% hObject    handle to editImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = getappdata(0, 'NomRep');
if isempty(N)
    delete(gcf);
    StartRGB();
else
    folderName = getappdata(0, 'RepertoireImage');
    delete(gcf);
    StartRGB(N, folderName);
end


function spatialResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionEdit as a double


% --- Executes during object creation, after setting all properties.
function spatialResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeIntervalEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalEdit as a double


% --- Executes during object creation, after setting all properties.
function timeIntervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
