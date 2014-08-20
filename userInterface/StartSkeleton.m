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

% Last Modified by GUIDE v2.5 16-Jun-2014 15:00:15

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

% Choose default command line output for StartSkeleton
handles.output = hObject;
setappdata(0,'RepertoireImage','');
setappdata(0,'NomRep','');
if nargin == 6    col = varargin{1};
    N = varargin{2};
    folder_name = varargin{3};
    set(handles.slider1, 'Visible', 'on');
    set(handles.text2, 'Visible', 'on');
    set(handles.text3, 'Visible', 'on');
    set(handles.axes1, 'Visible', 'on');
    set(handles.axes2, 'Visible', 'on');
    set(handles.radiobutton1,'Visible','on');
    set(handles.radiobutton3,'Visible','on');
    
    nb = length(col);
    
    set(handles.slider1, 'Max', nb - 1);
    
    mini =cell(2,1);
    for i = 1:2
        
        mini{i} = col{i};
    end
    
    axes(handles.axes1);%#ok % To show the thumbnail
    imshow(mini{1});
    set(handles.text2, 'String', '1');
    
    axes(handles.axes2);%#ok
    imshow(mini{2});
    set(handles.text3, 'String', '2');
    
    
    setappdata(0,'Nbimages',nb);
    setappdata(0,'NomRep',N);
    setappdata(0,'RepertoireImage',folder_name);
    setappdata(0,'col',col);
    
    flag = 2;
    
    char = strcat('Select a range among  ',num2str(nb),' pictures');
    set(handles.radiobutton3, 'String', char);
else 
    flag = 1;
end

setappdata(0,'flag',flag);



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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok % To select the images from a directory

if get(handles.checkbox1,'Value') == 1
    
    folder_name = uigetdir(); % Open a dialog box
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
    for i = 1 : nb - 2 % 2 'for' to eliminate the first ad second index : '.' & '..'
        N(i) = N(i + 2);
    end
    for i = 1 : 2
        N(end) = [];
    end
    
elseif get(handles.checkbox2,'Value') == 1
    
    str = get(handles.edit11,'String');
    if isempty(str)
        warning('Text area is empty');%#ok
        return;
    end
    
    folder_name = uigetdir(); % Open a dialog box
    if folder_name == 0;
        warning('Select a floder please');%#ok
        return;
    end
    
    str = strcat(str,'*.*');
    rep = fullfile(folder_name,str);
    N = dir(rep); % To open the directory
    
    
else
    warning('Select an option please');%#ok
    return;
end


nb = length(N);
if nb == 0
    warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
    return;
end



set(handles.slider1, 'Visible', 'on');
set(handles.text2, 'Visible', 'on');
set(handles.text3, 'Visible', 'on');
set(handles.axes1, 'Visible', 'on');
set(handles.axes2, 'Visible', 'on');
set(handles.radiobutton1,'Visible','on');
set(handles.radiobutton3,'Visible','on');

set(handles.slider1, 'Max', nb - 1);

mini =cell(2,1);
for i = 1:2 

    mini{i} = imread(fullfile(folder_name,N(i).name));
end 

axes(handles.axes1);%#ok % To show the thumbnail
imshow(mini{1});
set(handles.text2, 'String', '1');

axes(handles.axes2);%#ok
imshow(mini{2});
set(handles.text3, 'String', '2');


setappdata(0,'Nbimages',nb);
setappdata(0,'NomRep',N); 
setappdata(0,'RepertoireImage',folder_name); 



char = strcat('Select a range among  ',num2str(nb),' pictures');
set(handles.radiobutton3, 'String', char);



guidata(hObject, handles);

 


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

flag = getappdata(0,'flag');
col = getappdata(0,'col');
folder_name = getappdata(0,'RepertoireImage');
N = getappdata(0,'NomRep');

valmax = get(handles.slider1,'Max');
if val == valmax + 1
    val = val - 1;
end

mini2=cell(2,1);
for i=val:val + 1
    if flag == 1
    mini2{i - val + 1}=imread(fullfile(folder_name,N(i).name)); %'+1' To start at the index n°1
    elseif flag == 2
    mini2{i - val + 1}=col{i}; %'+1' To start at the index n°1 
    end
end


axes(handles.axes1);%#ok
imshow(mini2{1});
set(handles.text2, 'String', val);

axes(handles.axes2);%#ok
imshow(mini2{2});
set(handles.text3, 'String', val + 1);


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


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.pushbutton5,'Visible','on');
set(handles.pushbutton6,'Visible','on');
set(handles.text8,'Visible','off');
set(handles.text10,'Visible','off');
set(handles.text11,'Visible','off');
set(handles.edit8,'Visible','off');
set(handles.edit9,'Visible','off');
set(handles.edit10,'Visible','off');
set(handles.radiobutton1,'Value',1);
set(handles.radiobutton3,'Value',0);
set(handles.edit11,'Visible','off');

guidata(hObject, handles);
% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


guidata(hObject, handles);
% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
set(handles.pushbutton5,'Visible','on');
set(handles.pushbutton6,'Visible','on');
set(handles.text8,'Visible','on');
set(handles.text10,'Visible','on');
set(handles.text11,'Visible','on');
set(handles.edit8,'Visible','on');
set(handles.edit9,'Visible','on');
set(handles.edit10,'Visible','on');
set(handles.radiobutton1,'Value',0);
set(handles.radiobutton3,'Value',1);
set(handles.edit11,'Visible','off');

guidata(hObject, handles);
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


nbInit = getappdata(0,'Nbimages');
N = getappdata(0,'NomRep');
folder_name=getappdata(0,'RepertoireImage');
nb = nbInit;
flag = getappdata(0,'flag');
colN = getappdata(0,'col');

if get(handles.radiobutton1,'Value') == 1 % For all pictures
   
    set(handles.pushbutton5,'Enable','off')
    set(handles.pushbutton5,'String','Wait please...')
    pause(0.01);
    debut = 1;
    fin = nb;
    
    setappdata(0,'debut',debut);
    setappdata(0,'fin',fin);
    
   
    disp('Opening directory ...');
    col=cell(nb,1);
    
    parfor_progress(length(N));
    for i=1:nb
        if flag == 1
            col{i}=imread(fullfile(folder_name,N(i).name));
        elseif flag == 2
            col{i}=colN{i};
        end
        parfor_progress;
    end
    parfor_progress(0); 
    
    step = 1;
    delete (gcf);
    ValidateThres(debut,fin,nb,col,step,nbInit,N,folder_name)


else  % For pictures by step
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
        if ~isempty(firstPicture) && ~isempty(lastPicture) && ~isempty(stepPicture)
            
            nbstep = 0;
            for i = firstPicture :stepPicture : lastPicture
                nbstep = nbstep + 1;                
            end
            if nbstep <= nb
                
                disp('Opening directory ...');
                col = cell(nbstep,1);
                parfor_progress(nbstep);
                for i=0:nbstep-1
                    if flag == 1
                    col{i+1} = imread(fullfile(folder_name,N(firstPicture + stepPicture * i).name));
                    elseif flag == 2
                        col{i+1} = colN{firstPicture + stepPicture * i};
                    end
                    parfor_progress;
                end
                parfor_progress(0);
                debut = firstPicture;
                fin = lastPicture;
                
                delete (gcf);
                
                ValidateThres(debut,fin,nb,col,stepPicture,nbInit,N,folder_name)
                
            else
                warning('Length of your range must be smaller than length of picture');%#ok this a simple message no need warning identifier
            end
            
        else
            warning('Set a numeric value for the begin, the last and the end');%#ok this a simple message no need warning identifier
        end
        
end

%guidata(hObject, handles);
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Value',0);
set(handles.edit11,'Visible','off');

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',1);
set(handles.edit11,'Visible','on');


function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)%#ok % To save the new pictures
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton6,'Enable','off');
set(handles.pushbutton6,'String','Wait please...');
pause(0.01);
nbInit = getappdata(0,'Nbimages');
N = getappdata(0,'NomRep');
folder_name=getappdata(0,'RepertoireImage');
nb = nbInit;


[FileName,PathName] = uiputfile('*.*','Enter a name for your new directory of pictures');


if PathName == 0;
    warning('Select a floder please');%#ok
    return;
end
path = fullfile(PathName,FileName);

mkdir(path);



if get(handles.radiobutton1,'Value') == 1 % For all pictures
   
    
    debut = 1;
    fin = nb;
    
    setappdata(0,'debut',debut);
    setappdata(0,'fin',fin);
    
   
    disp('Opening directory ...');
    col=cell(nb,1);
    for i=1:nb
        col{i}=imread(fullfile(folder_name,N(i).name));
    end
    
   

    


else  % For pictures by step
    firstPicture = get(handles.edit8, 'String');% To take the range of pictures
    lastPicture = get(handles.edit9, 'String');
    stepPicture = get(handles.edit10, 'String');
    
    if length(firstPicture) ~= 0 && length(lastPicture) ~= 0 &&  length(stepPicture)  %#ok isempty does'nt work i dont know why
        firstPicture = str2num(firstPicture);%#ok
        lastPicture = str2num(lastPicture);%#ok
        stepPicture = str2num(stepPicture);%#ok
        
        
        if ~isempty(firstPicture) && ~isempty(lastPicture) && ~isempty(stepPicture)
            
            nbstep = 0;
            for i = firstPicture :stepPicture : lastPicture
                nbstep = nbstep + 1;
            end
            if nbstep <= nb
                disp('Opening directory ...');
                col = cell(nbstep,1);
                for i=0:nbstep-1
                    col{i+1} = imread(fullfile(folder_name,N(firstPicture + stepPicture * i).name));
                end
                
                disp('Saving new data...');
                nb = length(col);
                for i = 0 : nb - 1
                    
                    imwrite(col{i + 1},fullfile(path,'/',N(firstPicture + stepPicture * i).name));
                    
                end
                
                
            else
                warning('Length of your range must be smaller than length of picture');%#ok this a simple message no need warning identifier
            end
            
        else
            warning('Set a numeric value for the begin, the step and the length');%#ok this a simple message no need warning identifier
        end
        
    else
        warning('Set 3 values not empty for the begin, the step and the length');%#ok this a simple message no need warning identifier
    end
end

set(handles.pushbutton6,'Enable','on');
set(handles.pushbutton6,'String','Save new pictures');

guidata(hObject, handles);
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
N = getappdata(0,'NomRep');
if isempty(N)
    delete(gcf);
    StartRGB();
else
    folder_name = getappdata(0,'RepertoireImage');
    delete(gcf);
    StartRGB(N,folder_name);
end

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();
