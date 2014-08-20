function varargout = ValidateThres(varargin)
% VALIDATETHRES MATLAB code for ValidateThres.fig
%      VALIDATETHRES, by itself, creates a new VALIDATETHRES or raises the existing
%      singleton*.
%
%      H = VALIDATETHRES returns the handle to a new VALIDATETHRES or the handle to
%      the existing singleton*.
%
%      VALIDATETHRES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VALIDATETHRES.M with the given input arguments.
%
%      VALIDATETHRES('Property','Value',...) creates a new VALIDATETHRES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ValidateThres_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ValidateThres_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ValidateThres

% Last Modified by GUIDE v2.5 18-Jun-2014 17:18:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ValidateThres_OpeningFcn, ...
                   'gui_OutputFcn',  @ValidateThres_OutputFcn, ...
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


% --- Executes just before ValidateThres is made visible.
function ValidateThres_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ValidateThres (see VARARGIN)

% Choose default command line output for ValidateThres
handles.output = hObject;

%default
flag = 0;
setappdata(0,'flag',flag);
n = 1;
setappdata(0,'NumImage',n);
setappdata(0,'ValeurSeuillage',0);

if nargin == 11 % if user come from StartSkeleton, normal way ..
    col = varargin{4};
    fin = varargin{2};
    debut = varargin{1};
    step = varargin{5};
    nbInit = varargin{6};
    N = varargin{7};
    folder_name = varargin{8};
    setappdata(0,'debut',debut);
    setappdata(0,'step',step);
    setappdata(0,'fin',fin);
    setappdata(0,'col',col);
    setappdata(0,'nbInit',nbInit);
    setappdata(0,'N',N);
    setappdata(0,'folder_name',folder_name);
    imshow(col{1});
end

if nargin == 4 % if user come from ValidateContour, back way
    col = varargin{1};
    imshow(col{1});
    setappdata(0,'col',col);
end



sizePixel = size(col{end},1); % To show in default settings the width of the picture

set(handles.radiobutton1,'Value',0);
set(handles.radiobutton2,'Value',0);
set(handles.text16,'String','');
set(handles.text15,'String',strcat('Picture n° : 1'));
set(handles.edit13,'String','');
set(handles.edit14,'String','');
set(handles.edit15,'String','');



maxSlide = length(col) - 1; % -1 to have the same number of images ex : for five : 0,1,2,3,4
set(handles.slider3,'Max',maxSlide); 

set(handles.slider1, 'Visible', 'off');

setappdata(0,'sizePixel',sizePixel);
guidata(hObject, handles);

% UIWAIT makes ValidateThres wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ValidateThres_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok % To go to ValidateContour
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

seuil = getappdata(0,'ValeurSeuillage');
debut = getappdata(0,'debut');
fin = getappdata(0,'fin');
step = getappdata(0,'step');
red = getappdata(0,'col');
nbInit = getappdata(0,'nbInit');
N = getappdata(0,'N');
folder_name = getappdata(0,'folder_name');
Size = 0;
scale = get(handles.EdScale,'String');


val = get(handles.popupmenu1,'Value'); % To take the first value
setappdata(0,'val',val);
direction = get(handles.popupmenu1,'String');

val2 = get(handles.popupmenu2,'Value'); % To take the second value
setappdata(0,'val2',val2);
dirInitial = get(handles.popupmenu2,'String');

direction = direction{val};
dirInitial = dirInitial{val2};

if length(scale) ~= 0   %#ok isempty does'nt work i dont know why
    scale = str2num(scale);%#ok I want [] if it's a string and not NaN to test it
    
    if ~isempty(scale)
        
        if isnumeric(seuil);
            if seuil ~= 0
                set(handles.pushbutton1,'Enable','off')
                set(handles.pushbutton1,'String','Wait please...')
                pause(0.01);
                disp('Smoothing...');
                %thresholding
                parfor_progress(length(red));
                
                thres = zeros(length(red), 1);
                for k = 1:length(red) % To define the size of the picture and set the thres
                    if isnumeric(seuil);
                        thres(k) = seuil;
                    end
                    if iscell(seuil)
                        thres(k) = seuil{k};
                    end
                    
                    red{k}=[red{k}(:,1).*0 red{k} red{k}(:,1).*0];
                    red{k}=[red{k}(1,:).*0;red{k};red{k}(1,:).*0];
                    parfor_progress;
                end
                parfor_progress(0);
                
                % ValidateContour
                % Compute the contour and use the scale
                disp('Contour');
                CT2 = cell(length(red),1);
                parfor_progress(length(red));
                for i = 1:length(red)
                    CT2{i} = cont(red{i},thres(i));
                    CT2{i} = setsc(CT2{i},scale);
                    parfor_progress;
                end
                parfor_progress(0);
                delete(gcf);
                ValidateContour(seuil,red,scale,Size,debut,fin,step,direction,dirInitial,nbInit,N,folder_name,CT2,thres);
            else
                warning('Set a thres with the manual or automatic mode');
            end
        else
            set(handles.pushbutton1,'Enable','off')
            set(handles.pushbutton1,'String','Wait please...')
            pause(0.01);
            disp('Smoothing...');
            
            %thresholding
            parfor_progress(length(red));
            thres = zeros(length(red), 1);
            for k = 1:length(red) % To define the size of the picture and set the thres
                if isnumeric(seuil);
                    thres(k) = seuil;
                end
                if iscell(seuil)
                    thres(k) = seuil{k};
                end
                red{k}=[red{k}(:,1).*0 red{k} red{k}(:,1).*0];
                red{k}=[red{k}(1,:).*0;red{k};red{k}(1,:).*0];
                parfor_progress;
            end
            parfor_progress(0);
            
            % ValidateContour
            % Compute the contour and use the scale
            disp('Contour');
            CT2 = cell(length(red),1);
            parfor_progress(length(red));
            for i = 1:length(red)
                CT2{i} = cont(red{i},thres(i));
                CT2{i} = setsc(CT2{i},scale);
                parfor_progress;
            end
            parfor_progress(0);
            delete(gcf);
            ValidateContour(seuil,red,scale,Size,debut,fin,step,direction,dirInitial,nbInit,N,folder_name,CT2,thres);
        end
        
        
    else
        warning('Set a numeric value for scale');
    end
    
else
    warning('Set a value for scale');
end
% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)%#ok % To change the value of smooth
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

val = get(handles.slider1,'Value'); % Value of smooth between 0 and 100



n = getappdata(0,'NumImage');
col = getappdata(0,'col');

axes(handles.axes1);
imshow(col{end} > val);

flag = 1;

% if strcmp(class(seuil),'cell')%#ok
%     seuil = seuil{n};
% end
    

setappdata(0,'flag',flag);
setappdata(0,'ValeurSeuillage',val); 
set(handles.text13,'String',num2str(val)); % To show the value at the user
set(handles.text16,'Visible', 'on');
set(handles.text16,'String',strcat('Thres'' Value of picture n°   ',num2str(n),' is ',num2str(val)));

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function EdTime_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdTime as text
%        str2double(get(hObject,'String')) returns contents of EdTime as a double

% --- Executes during object creation, after setting all properties.
function EdTime_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdScale_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdScale as text
%        str2double(get(hObject,'String')) returns contents of EdScale as a double


% --- Executes during object creation, after setting all properties.
function EdScale_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdDirection_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdDirection as text
%        str2double(get(hObject,'String')) returns contents of EdDirection as a double


% --- Executes during object creation, after setting all properties.
function EdDirection_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdDirection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdDirInitial_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdDirInitial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdDirInitial as text
%        str2double(get(hObject,'String')) returns contents of EdDirInitial as a double


% --- Executes during object creation, after setting all properties.
function EdDirInitial_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdDirInitial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdSmoothing_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdSmoothing as text
%        str2double(get(hObject,'String')) returns contents of EdSmoothing as a double


% --- Executes during object creation, after setting all properties.
function EdSmoothing_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdSmoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdSize_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdSize as text
%        str2double(get(hObject,'String')) returns contents of EdSize as a double


% --- Executes during object creation, after setting all properties.
function EdSize_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdResample_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdResample as text
%        str2double(get(hObject,'String')) returns contents of EdResample as a double


% --- Executes during object creation, after setting all properties.
function EdResample_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdResample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdCorr1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdCorr1 as text
%        str2double(get(hObject,'String')) returns contents of EdCorr1 as a double


% --- Executes during object creation, after setting all properties.
function EdCorr1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdCorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdCorr2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdCorr2 as text
%        str2double(get(hObject,'String')) returns contents of EdCorr2 as a double


% --- Executes during object creation, after setting all properties.
function EdCorr2_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdCorr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdStep_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdStep as text
%        str2double(get(hObject,'String')) returns contents of EdStep as a double


% --- Executes during object creation, after setting all properties.
function EdStep_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EdColor_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to EdColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EdColor as text
%        str2double(get(hObject,'String')) returns contents of EdColor as a double


% --- Executes during object creation, after setting all properties.
function EdColor_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to EdColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)%#ok %Automatic
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1

red = getappdata(0,'col');
n = getappdata(0,'NumImage');

set(handles.radiobutton2,'Value',0);
set(handles.slider1, 'Visible', 'off');
set(handles.text13, 'Visible', 'off');
set(handles.text20,'Visible','on');
set(handles.text21,'Visible','on');
set(handles.text22,'Visible','on');
set(handles.edit13,'Visible','on');
set(handles.edit14,'Visible','on');
set(handles.edit15,'Visible','on');
set(handles.pushbutton4,'Visible','on');

flag = 2;

seuil = cell(length(red),1);
parfor_progress(length(red));
for i = 1 : length(red)
    seuil{i} = graythresh(red{i})*255;
    parfor_progress;
end
parfor_progress(0);


set(handles.text16, 'Visible', 'on');
set(handles.text16,'String',strcat('Thres'' Value of picture n° ',num2str(n),'is ',num2str(seuil{n})));

setappdata(0,'ValeurSeuillage',seuil);
setappdata(0,'flag',flag);

slider3_Callback(hObject, eventdata, handles);

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)%#ok %Manual
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2


set(handles.radiobutton1,'Value',0);
set(handles.slider1, 'Visible', 'on');
set(handles.text13, 'Visible', 'on');
set(handles.text20,'Visible','off');
set(handles.text21,'Visible','off');
set(handles.text22,'Visible','off');
set(handles.edit13,'Visible','off');
set(handles.edit14,'Visible','off');
set(handles.pushbutton4,'Visible','off');
set(handles.edit15,'Visible','off');


flag = 1;
setappdata(0,'flag',flag);

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

seuil = getappdata(0,'ValeurSeuillage');
flag = getappdata(0,'flag');

red = getappdata(0,'col');
val = get(handles.slider3,'Value');
val = int64(val);

val = val + 1; %'+1' To start at the index n°1
if flag == 2
    imshow(red{val} > seuil{val});
    set(handles.text16, 'Visible', 'on');
    set(handles.text16,'String',strcat('Thres'' Value of picture n°  ',num2str(val),' is ',num2str(seuil{val})));
    
elseif flag == 1
    imshow(red{val} > seuil);
    set(handles.text16,'String',strcat('Thres'' Value of picture n°  ',num2str(val),' is ',num2str(seuil)));
else
    imshow(red{val});
end
set(handles.text15,'String',strcat('Picture n° :',num2str(val)));
setappdata(0,'NumImage',val);


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(gcf);
StartSkeleton();



function edit13_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
red = getappdata(0,'col');
n = getappdata(0, 'NumImage');
seuil = getappdata(0, 'ValeurSeuillage');
nb = length(red);

addThres = get(handles.edit13, 'String');
start   = get(handles.edit14, 'String');
fin     = get(handles.edit15, 'String');

if length(start) ~= 0    %#ok isempty does'nt work i dont know why
    start = str2num(start);%#ok
else
    start = 1;
end
if length(fin) ~= 0    %#ok isempty does'nt work i dont know why
    fin = str2num(fin);%#ok
else
    fin = nb;
end

if addThres == 0
    warning('Select a value to add at the current threshold');
    return;
end

addThres = str2num(addThres);%#ok

if isempty(fin) || isempty(start) || isempty(addThres)
    warning('Set a numeric value for the edit text');
    return;
end

if start > fin
    warning('The first value must be smaller than the second value');
    return;
end

set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton4,'String','Wait please...');
pause(0.01);
flag = 2;
parfor_progress(length(red));
for i = start : fin
    if graythresh(red{i}) * 255 <= 255
        seuil{i} = (graythresh(red{i}) * 255) + addThres;
    else
        warning('New thres is bigger than 255. Select a smaller value at add to thres');
        return;
    end
    parfor_progress;
end

parfor_progress(0);

set(handles.text16, 'Visible', 'on');
set(handles.text16,'String',strcat('Thres'' Value of picture n° ',num2str(n),'is ',num2str(seuil{n})));

setappdata(0, 'ValeurSeuillage', seuil);
setappdata(0, 'flag', flag);
slider3_Callback(hObject, eventdata, handles);

set(handles.pushbutton4, 'Enable', 'on');
set(handles.pushbutton4, 'String', 'Compute new automatical threshold');

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();
