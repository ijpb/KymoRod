function varargout = StartRGB(varargin)
% STARTRGB MATLAB code for StartRGB.fig
%      STARTRGB, by itself, creates a new STARTRGB or raises the existing
%      singleton*.
%
%      H = STARTRGB returns the handle to a new STARTRGB or the handle to
%      the existing singleton*.
%
%      STARTRGB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTRGB.M with the given input arguments.
%
%      STARTRGB('Property','Value',...) creates a new STARTRGB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StartRGB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StartRGB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StartRGB

% Last Modified by GUIDE v2.5 27-Jun-2014 13:01:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StartRGB_OpeningFcn, ...
                   'gui_OutputFcn',  @StartRGB_OutputFcn, ...
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


% --- Executes just before StartRGB is made visible.
function StartRGB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StartRGB (see VARARGIN)

% Choose default command line output for StartRGB
handles.output = hObject;


set(handles.radiobutton2,'Value',0);
set(handles.radiobutton3,'Value',0);


i = 0;
setappdata(0,'i',i);
val = 1;
setappdata(0,'val',val);
flag = 0;
setappdata(0,'flag',flag);

directory = {};
setappdata(0,'directory',directory);

pos = {};
setappdata(0,'pos',pos);
if nargin == 5
    NomRep = varargin{1};
    folder_name = varargin{2};
    pushbutton3_Callback(hObject, eventdata, handles,NomRep,folder_name);
end
    
    
    % Update handles structure
guidata(hObject, handles);

% UIWAIT makes StartRGB wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StartRGB_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)%#ok

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
set(handles.radiobutton2,'Value',1);
set(handles.radiobutton3,'Value',0);

set(handles.axes1,'Visible','off');

set(handles.text3,'Visible','on');
set(handles.pushbutton2,'Visible','on');
set(handles.pushbutton10,'Visible','on');
set(handles.edit4,'Visible','on');
set(handles.text4,'Visible','off');
set(handles.pushbutton3,'Visible','off');
set(handles.pushbutton9,'Visible','off');
set(handles.edit3,'Visible','off');
guidata(hObject, handles);
% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3


set(handles.radiobutton2,'Value',0);
set(handles.radiobutton3,'Value',1);





set(handles.text3,'Visible','off');
set(handles.pushbutton2,'Visible','off');
set(handles.pushbutton10,'Visible','off');
set(handles.edit4,'Visible','off');
set(handles.text4,'Visible','on');
set(handles.pushbutton3,'Visible','on');
set(handles.pushbutton9,'Visible','on');
set(handles.edit3,'Visible','on');
guidata(hObject, handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton2,'String','Wait please...');
pause(0.01);
folder_name = uigetdir();
if folder_name == 0;
    warning('Select a floder please');%#ok
    return;
end

N = dir(folder_name); % To open the directory
nb = length(N);

if nb == 0
    warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
    return;
end

directory = cell(nb,1);

a = 0;

disp('Opening data...');

parfor_progress(length(directory));

for i = 1 : nb  % To take just image of directory
    try
        directory{i - a} = imread(fullfile(folder_name,N(i).name));
        N(i - a).name = strcat(N(i).name);
    catch error%#ok
        a = a + 1;
    end
    parfor_progress;
end
parfor_progress(0);


directory = directory(~cellfun('isempty', directory));

for i = 1 : a
    N(end) = [];
end

nb = length(directory);

red = cell(nb,1);
green =cell(nb,1);
blue = cell(nb,1);

[FileName,PathName] = uiputfile('*.*','Enter a name for your new directory of pictures');


if PathName == 0;
    warning('Select a floder please');%#ok
    return;
end
path = fullfile(PathName,FileName);


mkdir(path);

pathRed = fullfile(path,'red');
mkdir(pathRed);

pathGreen = fullfile(path,'green');
mkdir(pathGreen);

pathBlue = fullfile(path,'blue');
mkdir(pathBlue);



disp('Saving data...');
parfor_progress(length(directory));
for i = 1 : nb
    red{i} = directory{i}(:,:,1);
    green{i} = directory{i}(:,:,2);
    blue{i} = directory{i}(:,:,3);
    imwrite(red{i},fullfile(pathRed,strcat('r',N(i).name)));
    imwrite(green{i},fullfile(pathGreen,strcat('g',N(i).name)));
    imwrite(blue{i},fullfile(pathBlue,strcat('b',N(i).name)));
    parfor_progress;
end
parfor_progress(0);


set(handles.pushbutton6,'Enable','on');
set(handles.pushbutton6,'String','Select all');
guidata(hObject, handles);  





% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles,varargin)%#ok
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if nargin == 3

folder_name = uigetdir();
if folder_name == 0;
    warning('Select a floder please');%#ok
    return;
end

N = dir(folder_name); % To open the directory
elseif nargin == 5
    N = varargin{1};
    folder_name = varargin{2};
end
nb = length(N);

if nb == 0
    warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
    return;
end

directory = cell(nb,1);
a = 0;

disp('Opening data...')
parfor_progress(length(directory));
for  i = 1 : nb % To take just image of directory
    try
        directory{i - a} = imread(fullfile(folder_name,N(i).name));
        N(i - a).name = strcat(N(i).name);
    catch error%#ok
        a = a + 1;
    end
    parfor_progress;
end

parfor_progress(0);
directory = directory(~cellfun('isempty', directory));

for i = 1 : a
    N(end) = [];
end

nb = length(directory);

setappdata(0,'directory',directory);
setappdata(0,'N',N);
setappdata(0,'folder_name',folder_name);

set(handles.axes1,'Visible','on');
set(handles.slider1,'Visible','on');
set(handles.text5,'Visible','on');
set(handles.text5,'String','1');
set(handles.slider1,'Max',nb-1);

im = imshow(directory{1});
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});


guidata(hObject, handles);
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

directory = getappdata(0,'directory');
pos = getappdata(0,'pos');
largeur = getappdata(0,'largeur');
hauteur = getappdata(0,'hauteur');
flag = getappdata(0,'flag');
i = getappdata(0,'i');

val = get(handles.slider1,'Value'); 
val = ceil(val);
val = val + 1;

im = imshow(directory{val});
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
set(handles.text5,'String',num2str(val));
setappdata(0,'val',val);

if flag == 1
axes(handles.axes1);%#ok
    if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        rectangle('Position',[pos{i - 1}(1) - largeur,pos{i - 1}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        rectangle('Position',[pos{i - 1}(1),pos{i - 1}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        rectangle('Position',[pos{i}(1),pos{i}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        rectangle('Position',[pos{i}(1) - largeur,pos{i}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    end
elseif flag == 0
    i = 0;
end


setappdata(0,'i',i);


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)%#ok
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = getappdata(0,'directory');
val = getappdata(0,'val');

set(handles.pushbutton4,'Visible','off');
set(handles.pushbutton5,'Visible','off');
set(handles.checkbox1,'Visible','off');
set(handles.checkbox2,'Visible','off');
set(handles.checkbox3,'Visible','off');
set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',0);
set(handles.checkbox3,'Value',0);
set(handles.edit1,'Visible','off');
set(handles.edit2,'Visible','off');
set(handles.text6,'Visible','off');
set(handles.text7,'Visible','off');


flag = 0;

i = getappdata(0,'i');
i = i + 1;
setappdata(0,'i',i);

if mod(i,2) == 1
    im = imshow(directory{val});
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
end

pos = getappdata(0,'pos');
pos{i} = round(get(handles.axes1,'CurrentPoint'));


if mod(i,2) == 0 && i > 1
    hauteur = abs(pos{i}(4) - pos{i - 1}(4));
    largeur = abs(pos{i}(1) - pos{i - 1}(1));
    axes(handles.axes1);%#ok
    if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        rectangle('Position',[pos{i - 1}(1) - largeur,pos{i - 1}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        rectangle('Position',[pos{i - 1}(1),pos{i - 1}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        rectangle('Position',[pos{i}(1),pos{i}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        rectangle('Position',[pos{i}(1) - largeur,pos{i}(4),largeur,hauteur],'LineWidth',3,'EdgeColor',[1,0,0]);
    end
    flag = 1;
end

if flag == 1
    setappdata(0,'hauteur',hauteur);
    setappdata(0,'largeur',largeur);
    set(handles.pushbutton4,'visible','on');
    set(handles.pushbutton5,'visible','on');
    set(handles.checkbox1,'visible','on');
    set(handles.checkbox2,'visible','on');
    set(handles.checkbox3,'visible','on');
    
end


setappdata(0,'pos',pos);
setappdata(0,'flag',flag);
   


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)%#ok % To crop the window%#ok
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton4,'String','Wait please...');
pause(0.01);
directory = getappdata(0,'directory');
val = getappdata(0,'val');
pos = getappdata(0,'pos');
largeur = getappdata(0,'largeur');
hauteur = getappdata(0,'hauteur');
i = getappdata(0,'i');



for b = 1:length(directory)
    if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        
        
        directory{b} = directory{b}(pos{i}(4) - hauteur:pos{i}(4),pos{i - 1}(1) - largeur:pos{i - 1}(1));
        
        
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        
      
        
        
        directory{b} = directory{b}(pos{i - 1}(4):pos{i - 1}(4) + hauteur,pos{i - 1}(1):pos{i - 1}(1) + largeur);
        
        
    elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        
        
        
        
        directory{b} = directory{b}(pos{i}(4):pos{i}(4) + hauteur,pos{i}(1):pos{i}(1) + largeur);
        
        
        
        
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
       
        
        directory{b} = directory{b}(pos{i - 1}(4) - hauteur:pos{i - 1}(4),pos{i}(1) - largeur:pos{i}(1));
        
        
        
        
    end
end
axes(handles.axes1);%#ok
im = imshow(directory{val});
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
flag = 0;

setappdata(0,'flag',flag);

setappdata(0,'directory',directory);

set(handles.edit1,'Visible','off');
set(handles.edit2,'Visible','off');
set(handles.text6,'Visible','off');
set(handles.text7,'Visible','off');
set(handles.checkbox1,'Visible','off');
set(handles.checkbox2,'Visible','off');
set(handles.checkbox3,'Visible','off');
set(handles.pushbutton4,'Visible','off');
set(handles.pushbutton5,'Visible','off');
set(handles.pushbutton6,'Visible','on');
set(handles.pushbutton4,'Enable','on');
set(handles.pushbutton4,'String','Crop window for all the pictures');
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)%#ok % To hide an element
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



directory = getappdata(0,'directory');
val = getappdata(0,'val');
pos = getappdata(0,'pos');
largeur = getappdata(0,'largeur');
hauteur = getappdata(0,'hauteur');
i = getappdata(0,'i');
nb = length(directory);

if get(handles.checkbox1,'Value') == 1 % For all pictures
    set(handles.pushbutton5,'Enable','off');
    set(handles.pushbutton5,'String','Wait please...');
    pause(0.01);
    parfor_progress(length(directory));
    for b = 1 : length(directory)
        
        if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
            
            start1 = pos{i}(4) - hauteur ;
            start2 = pos{i - 1}(1) - largeur ;
            
            for y = start1 : pos{i}(4)
                for x = start2 : pos{i - 1}(1)
                    directory{b}(y,x,1) = 0;
                end
            end
            
        elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
            
            start1 = pos{i - 1}(4);
            start2 = pos{i - 1}(1);
            
            for y = start1 : start1 + hauteur
                for x = start2 : pos{i - 1}(1) + largeur
                    directory{b}(y,x,1) = 0;
                end
            end
            
        elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
            
            start1 = pos{i}(4);
            start2 = pos{i}(1);
            
            for y = start1 : start1 + hauteur
                for x = start2 : start2 + largeur
                    directory{b}(y,x,1) = 0;
                end
            end
            
            
            
        elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
            
            start1 = pos{i - 1}(4) - hauteur ;
            start2 = pos{i}(1) - largeur ;
            
            for y = start1 : pos{i - 1}(4)
                for x = start2 : pos{i}(1)
                    directory{b}(y,x,1) = 0;
                end
            end
            
            
        end
        parfor_progress;
    end
    parfor_progress(0);
    
    axes(handles.axes1)%#ok
    im = imshow(directory{val});
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    
elseif get(handles.checkbox2,'Value') == 1 % For just the current pictures
    set(handles.pushbutton5,'Enable','off');
    set(handles.pushbutton5,'String','Wait please...');
    pause(0.01);
    if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        
        start1 = pos{i}(4) - hauteur ;
        start2 = pos{i - 1}(1) - largeur ;
        
        for y = start1 : pos{i}(4)
            for x = start2 : pos{i - 1}(1)
                directory{val}(y,x,1) = 0;
            end
        end
        
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
        
        start1 = pos{i - 1}(4);
        start2 = pos{i - 1}(1);
        
        for y = start1 : start1 + hauteur
            for x = start2 : pos{i - 1}(1) + largeur
                directory{val}(y,x,1) = 0;
            end
        end
        
    elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        
        start1 = pos{i}(4);
        start2 = pos{i}(1);
        
        for y = start1 : start1 + hauteur
            for x = start2 : start2 + largeur
                directory{val}(y,x,1) = 0;
            end
        end
        
        
        
    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
        
        start1 = pos{i - 1}(4) - hauteur ;
        start2 = pos{i}(1) - largeur ;
        
        for y = start1 : pos{i - 1}(4)
            for x = start2 : pos{i}(1)
                directory{val}(y,x,1) = 0;
            end
        end
        
        
    end
    axes(handles.axes1)%#ok
    im = imshow(directory{val});
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    
elseif get(handles.checkbox3,'Value') == 1
    set(handles.pushbutton5,'Enable','off');
    set(handles.pushbutton5,'String','Wait please...');
    pause(0.01);
    min = get(handles.edit1,'String');
    max = get(handles.edit2,'String');
    if length(max) ~= 0    %#ok isempty does'nt work i dont know why
        max = str2num(max);%#ok
    else
        max = nb;
    end
    if length(min) ~= 0    %#ok isempty does'nt work i dont know why
        min = str2num(min);%#ok
    else
        min = 1;
    end    
    if ~isempty(max) && ~isempty(min)
        
        if max  <= length(directory)
            
            if min >= 1
                parfor_progress(max - min);
                for b = min : max
                    
                    if pos{i}(1) < pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
                        
                        start1 = pos{i}(4) - hauteur ;
                        start2 = pos{i - 1}(1) - largeur ;
                        
                        
                        for y = start1 : pos{i}(4)
                            for x = start2 : pos{i - 1}(1)
                                directory{b}(y,x,1) = 0;
                            end
                            
                        end
                        
                        
                        
                    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) > pos{i - 1}(4)
                        
                        start1 = pos{i - 1}(4);
                        start2 = pos{i - 1}(1);
                        
                        for y = start1 : start1 + hauteur
                            for x = start2 : pos{i - 1}(1) + largeur
                                directory{b}(y,x,1) = 0;
                            end
                        end
                        
                    elseif pos{i}(1) < pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
                        
                        start1 = pos{i}(4);
                        start2 = pos{i}(1);
                        
                        for y = start1 : start1 + hauteur
                            for x = start2 : start2 + largeur
                                directory{b}(y,x,1) = 0;
                            end
                        end
                        
                        
                        
                    elseif pos{i}(1) > pos{i - 1}(1) && pos{i}(4) < pos{i - 1}(4)
                        
                        start1 = pos{i - 1}(4) - hauteur ;
                        start2 = pos{i}(1) - largeur ;
                        
                        for y = start1 : pos{i - 1}(4)
                            for x = start2 : pos{i}(1)
                                directory{b}(y,x,1) = 0;
                            end
                        end
                    end
                    parfor_progress;
                end
                parfor_progress(0);
                
                
            else
                warning('Set a min smaller to be in the directory');%#ok this a simple message no need warning identifier
            end
            
            
        else
            warning('Set a max smaller to be in the directory');%#ok this a simple message no need warning identifier
        end
        
    else
        warning('Set a numeric value for max and min');%#ok this a simple message no need warning identifier
    end
    
    axes(handles.axes1)%#ok
    im = imshow(directory{val});
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
else
    warning('Select a checkbox please');%#ok
    return;
end

setappdata(0,'directory',directory);
flag = 0;
setappdata(0,'flag',flag);


set(handles.edit1,'Visible','off');
set(handles.edit2,'Visible','off');
set(handles.text6,'Visible','off');
set(handles.text7,'Visible','off');
set(handles.checkbox1,'Visible','off');
set(handles.checkbox2,'Visible','off');
set(handles.checkbox3,'Visible','off');
set(handles.pushbutton4,'Visible','off');
set(handles.pushbutton5,'Visible','off');
set(handles.pushbutton6,'Visible','on');
set(handles.pushbutton5,'Enable','on');
set(handles.pushbutton5,'String','Hide the rectangle');
% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Value',0);
set(handles.checkbox3,'Value',0);
set(handles.edit1,'visible','off');
set(handles.edit2,'visible','off');
set(handles.text6,'visible','off');
set(handles.text7,'visible','off');

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',1);
set(handles.checkbox3,'Value',0);
set(handles.edit1,'visible','off');
set(handles.edit2,'visible','off');
set(handles.text6,'visible','off');
set(handles.text7,'visible','off');

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',0);
set(handles.checkbox3,'Value',1);
set(handles.edit1,'visible','on');
set(handles.edit2,'visible','on');
set(handles.text6,'visible','on');
set(handles.text7,'visible','on');


function edit1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit1 (see GCBO)%#ok
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)%#ok % TO save the data
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton6,'Enable','off');
set(handles.pushbutton6,'String','Wait please...');
pause(0.01);
directory = getappdata(0,'directory');
N = getappdata(0,'N');

[FileName,PathName] = uiputfile('*.*','Enter a name for your new directory of pictures');


if PathName == 0;
    warning('Select a floder please');%#ok
    set(handles.pushbutton6,'Enable','on');
    set(handles.pushbutton6,'String','Save new data');
    pause(0.01);
    return;
end
path = fullfile(PathName,FileName);


mkdir(path);

nb  = length(directory);


disp('Saving new data...');
parfor_progress(nb);
for i = 1 : nb
    
    imwrite(directory{i},fullfile(path,N(i).name));
    parfor_progress;
end

parfor_progress(0);

set(handles.pushbutton6,'Enable','on');
set(handles.pushbutton6,'String','Save new data');

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


directory = getappdata(0,'directory');
if isempty(directory)
    delete(gcf);
    StartSkeleton();
else
    N = getappdata(0,'N');
    folder_name = getappdata(0,'folder_name');
    
    delete(gcf);
    StartSkeleton(directory,N,folder_name);
end
% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.edit3,'String');
if isempty(str)
        warning('Text area is empty');%#ok
        return;
end


folder_name = uigetdir();
if folder_name == 0;
    warning('Select a floder please');%#ok
    return;
end

str = strcat(str,'*.*');
rep = fullfile(folder_name,str);
N = dir(rep); % To open the directory
nb = length(N);


if nb == 0
    warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
    return;
end

directory = cell(nb,1);
parfor_progress(nb);
disp('Opening data...')
for i = 1 : nb
    directory{i} = imread(fullfile(folder_name,N(i).name));
    parfor_progress;
end
parfor_progress(0);








nb = length(directory);

setappdata(0,'directory',directory);
setappdata(0,'N',N);
setappdata(0,'folder_name',folder_name);

set(handles.axes1,'Visible','on');
set(handles.slider1,'Visible','on');
set(handles.text5,'Visible','on');
set(handles.text5,'String','1');
set(handles.slider1,'Max',nb-1);

im = imshow(directory{1});
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});


guidata(hObject, handles);

function edit3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.edit4,'String');
if isempty(str)
        warning('Text area is empty');%#ok
        return;
end
set(handles.pushbutton10,'Enable','off');
set(handles.pushbutton10,'String','Wait please...');
pause(0.01);
folder_name = uigetdir();
if folder_name == 0;
    warning('Select a floder please');%#ok
    set(handles.pushbutton10,'Enable','on');
    set(handles.pushbutton10,'String','Take with prefix :');
    pause(0.01);
    return;
end

str = strcat(str,'*.*');
rep = fullfile(folder_name,str);
N = dir(rep); % To open the directory
nb = length(N);


if nb == 0
    warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
    set(handles.pushbutton6,'Enable','on');
    set(handles.pushbutton6,'String','Take with prefix :');
    return;
end

directory = cell(nb,1);
parfor_progress(nb);
disp('Opening data...')
for i = 1 : nb
    directory{i} = imread(fullfile(folder_name,'/',N(i).name));
    parfor_progress;
end
parfor_progress(0);








nb = length(directory);

setappdata(0,'directory',directory);
setappdata(0,'N',N);
setappdata(0,'folder_name',folder_name);

red = cell(nb,1);
green =cell(nb,1);
blue = cell(nb,1);

[FileName,PathName] = uiputfile('*.*','Enter a name for your new directory of pictures');


if PathName == 0;
    warning('Select a floder please');%#ok
    return;
end
path = fullfile(PathName,FileName);


mkdir(path);

pathRed = fullfile(path,'red');
mkdir(pathRed);

pathGreen = fullfile(path,'green');
mkdir(pathGreen);

pathBlue = fullfile(path,'blue');
mkdir(pathBlue);



disp('Saving data...');
parfor_progress(length(directory));
for i = 1 : nb
    red{i} = directory{i}(:,:,1);
    green{i} = directory{i}(:,:,2);
    blue{i} = directory{i}(:,:,3);
    imwrite(red{i},fullfile(pathRed,strcat('r',N(i).name)));
    imwrite(green{i},fullfile(pathGreen,strcat('g',N(i).name)));
    imwrite(blue{i},fullfile(pathBlue,strcat('b',N(i).name)));
    parfor_progress;
end
parfor_progress(0);


set(handles.pushbutton10,'Enable','on');
set(handles.pushbutton10,'String','Take with prefix :');
guidata(hObject, handles);


function edit4_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();
