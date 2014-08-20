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

% Last Modified by GUIDE v2.5 19-Jun-2014 12:56:23

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
if nargin == 18 % if user come from ValidateSkeleton, normal way
    red = varargin{1};
    CT = varargin{2};
    SK = varargin{3};
    R = varargin{4};
    shift = varargin{5};
    CTVerif = varargin{6};
    SKVerif = varargin{7};
    seuil = varargin{8};
    scale = varargin{9};
    debut = varargin{10};
    fin = varargin{11};
    step = varargin{12};
    nbInit = varargin{13};
    N = varargin{14};
    folder_name = varargin{15};
end
if nargin == 3 % if user start the program. He must to load the data
    
    [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
    if PathName == 0
        warning('Select a directory please'); %#ok
    else
        file = fullfile(PathName,FileName);
        load(file);
        
        
        
        
        if step == 1 % For open all pictures
            nb = fin - debut + 1;
            disp('Opening directory ...');
            red=cell(nb,1);
            parfor_progress(nb);
            for i=debut:fin
                try
                red{i - debut + 1}=imread(fullfile(folder_name,N(i).name));
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
            for i=0:nb - 1
                try
                red{i+1} = imread(fullfile(folder_name,N(debut + step * i).name));
                catch e%#ok
                    disp('Pictures''s folder not found');
                    delete(gcf);
                    return;
                end
                parfor_progress;
            end
            parfor_progress(0);
            
        end
        
    end
end

setappdata(0,'red',red);
setappdata(0,'CT',CT);
setappdata(0,'SK',SK);
setappdata(0,'R',R);
setappdata(0,'CTVerif',CTVerif);
setappdata(0,'SKVerif',SKVerif);
setappdata(0,'seuil',seuil);
setappdata(0,'scale',scale);
setappdata(0,'shift',shift);
setappdata(0,'debut',debut);
setappdata(0,'fin',fin);
setappdata(0,'step',step);
setappdata(0,'nbInit',nbInit);
setappdata(0,'N',N);
setappdata(0,'folder_name',folder_name);
guidata(hObject, handles);


% Update handles structure


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



function edit1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit1 (see GCBO)
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



function edit5_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% To start the programm
set(handles.pushbutton1,'Enable','off')
set(handles.pushbutton1,'String','Wait please...')
pause(0.01);

SK = getappdata(0,'SK');
CT = getappdata(0,'CT');%#ok
red = getappdata(0,'red');
R = getappdata(0,'R');
SKVerif = getappdata(0,'SKVerif');
CTVerif = getappdata(0,'CTVerif');
seuil = getappdata(0,'seuil');
scale = getappdata(0,'scale');
shift = getappdata(0,'shift');
debut = getappdata(0,'debut');
fin = getappdata(0,'fin');
N = getappdata(0,'N');
folder_name = getappdata(0,'folder_name');
stepPicture = getappdata(0,'step');

tic;
t0 = get(handles.edit6,'String');

if get(handles.radiobutton1,'Value') == 1
    iw = '10';
    nx = '500';
    ws = '15';
    ws2 = '30';
    step = '2';
    
elseif get(handles.radiobutton3,'Value') == 1
    iw = get(handles.edit1,'String'); % Take the parameters gave by the user
    
    
    nx = get(handles.edit2,'String');
    
    
    ws = get(handles.edit3,'String');
    
    
    ws2 = get(handles.edit4,'String');
    
    
    step = get(handles.edit5,'String');
    
    
    
end

if length(iw) ~=0 && length(nx) ~=0 && length(ws) ~= 0 && length(ws2) ~=0 && length(step) ~=0 && length(t0) ~= 0 %#ok
    iw = str2num(iw);%#ok
    nx = str2num(nx);%#ok
    ws = str2num(ws);%#ok
    ws2 = str2num(ws2);%#ok
    step = str2num(step);%#ok
    t0 = str2num(t0);%#ok
    if ~isempty(nx) && ~isempty(iw) && ~isempty(ws) && ~isempty(ws2) && ~isempty(step) && ~isempty(t0)
        if iw >= 0 && nx >= 0 && ws >= 0 && ws2 >= 0 && step >= 0 && t0 >=0
            
            we = 1; % Doesn't work
            
            
            % Start the program
            %% Curvature
            
            disp('Curvature');
            [S A C] = curvall(SK,iw);
            %% Alignment of all the results
            
            disp('Aligncurv');
            Sa = aligncurv(S,R);
            
            
            %% Displacement
            
            disp('Displacement');
            E = displall(SK,Sa,red,scale,shift,ws,we,step);
            
            %% Elongation
            
            disp('Elongation');
            [Elg E2] = elgall(E,t0,step,ws2);
            
            %%  Space-time mapping
            % Subsampling size
            
            
            ElgE1 = reconstruct_Elg2(nx,Elg);
            
            CE1 = reconstruct_Elg2(nx,C,Sa);
            
            AE1 = reconstruct_Elg2(nx,A,Sa);
            
            RE1 = reconstruct_Elg2(nx,R,Sa);
            
           
            
            disp('Programm done');
            toc;
            delete(gcf);
            FinalKymograph(ElgE1,CE1,AE1,RE1,red,seuil,CTVerif,SKVerif,...
            scale,Elg,C,A,R,Sa,t0,step,ws2,ws,nx,iw,E2,SK,shift,debut,fin,stepPicture,N,folder_name);
            
        else
            warning('Value must be positive');%#ok
        end
    else
        warning('Value must be a number');%#ok
    end
else warning('Edit must be not empty');%#ok
end
        
function edit6_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit6 (see GCBO)
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

debut = getappdata(0,'debut');
fin = getappdata(0,'fin');
step = getappdata(0,'step');
%red = setappdata(0,'red');
nbInit = getappdata(0,'nbInit');

if get(handles.checkbox1,'Value') == 1
    
    folder_name = uigetdir(); % Open a dialog box
    if folder_name == 0;
        warning('Select a floder please');%#ok
        return;
    end
    N = dir(folder_name); % To open the directory
    nb = length(N);
    for i = 1 : nb - 2 % 2 for to eliminate the first ad second index : '.' & '..'
        N(i) = N(i + 2);
    end
    for i = 1 : 2
        N(end) = [];
    end
    nb = length(N);
    if nb == 0
        warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
        return;
    end
    if(nb ~= nbInit)
        error('The two directory must have the same number of picture'); 
    end
   
    
elseif get(handles.checkbox2,'Value') == 1
    
    str = get(handles.edit7,'String');
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
    nb = length(N);
    if nb == 0
        warning('Not good pictures in the directory. Take an other');%#ok just a message no need identifier
        return;
    end
    if nb ~= nbInit
         error('The two directory must have the same number of picture'); 
    end
    
else
    warning('Select an option please');%#ok
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
    for i=0:plage-1
        col{i} = imread(fullfile(folder_name,N(debut + step * i).name));
    end
end


setappdata(0,'red',col);
disp('Directory changed');



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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

set(handles.checkbox1,'Value',1);
set(handles.checkbox2,'Value',0);


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

set(handles.checkbox1,'Value',0);
set(handles.checkbox2,'Value',1);

function edit7_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to edit7 (see GCBO)
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


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton1 (see GCBO)%#ok
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
set(handles.radiobutton3,'Value',0);
set(handles.radiobutton1,'Value',1);
set(handles.edit1,'Visible','off');
set(handles.edit2,'Visible','off');
set(handles.edit3,'Visible','off');
set(handles.edit4,'Visible','off');
set(handles.edit5,'Visible','off');
set(handles.text1,'Visible','off');
set(handles.text2,'Visible','off');
set(handles.text3,'Visible','off');
set(handles.text4,'Visible','off');
set(handles.text5,'Visible','off');

set(handles.pushbutton1,'Visible','on');
% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
set(handles.radiobutton1,'Value',0);
set(handles.radiobutton3,'Value',1);
set(handles.edit1,'Visible','on');
set(handles.edit2,'Visible','on');
set(handles.edit3,'Visible','on');
set(handles.edit4,'Visible','on');
set(handles.edit5,'Visible','on');
set(handles.text1,'Visible','on');
set(handles.text2,'Visible','on');
set(handles.text3,'Visible','on');
set(handles.text4,'Visible','on');
set(handles.text5,'Visible','on');

set(handles.pushbutton1,'Visible','on');

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
if get(handles.radiobutton5,'Value') == 1
set(handles.checkbox1,'Visible','on');
set(handles.checkbox2,'Visible','on');
set(handles.edit7,'Visible','on');
set(handles.pushbutton2,'Visible','on');
set(handles.radiobutton5,'Value',1);

elseif get(handles.radiobutton5,'Value') == 0
set(handles.checkbox1,'Visible','off');
set(handles.checkbox2,'Visible','off');
set(handles.edit7,'Visible','off');
set(handles.pushbutton2,'Visible','off');    
set(handles.radiobutton5,'Value',0); 

end