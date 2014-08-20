function varargout = FinalKymograph(varargin)
% FINALKYMOGRAPH MATLAB code for FinalKymograph.fig
%      FINALKYMOGRAPH, by itself, creates a new FINALKYMOGRAPH or raises the existing
%      singleton*.
%
%      H = FINALKYMOGRAPH returns the handle to a new FINALKYMOGRAPH or the handle to
%      the existing singleton*.
%
%      FINALKYMOGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINALKYMOGRAPH.M with the given input arguments.
%
%      FINALKYMOGRAPH('Property','Value',...) creates a new FINALKYMOGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FinalKymograph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FinalKymograph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FinalKymograph

% Last Modified by GUIDE v2.5 20-Jun-2014 11:08:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FinalKymograph_OpeningFcn, ...
                   'gui_OutputFcn',  @FinalKymograph_OutputFcn, ...
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


% --- Executes just before FinalKymograph is made visible.
function FinalKymograph_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FinalKymograph (see VARARGIN)

% Choose default command line output for FinalKymograph
handles.output = hObject;
flag = 0;
%set(handles.axes1, 'buttondownfcn', @axes1_ButtonDownFcn) % To detect clic on the axes
if nargin == 51
    
    ElgE1 = varargin{1};
    CE1 = varargin{2};
    AE1 = varargin{3};
    RE1 = varargin{4};
    red = varargin{5};
    seuil = varargin{6};
    CTVerif = varargin{7};
    SKVerif = varargin{8};
    scale = varargin{9};
    Elg = varargin{10};
    C = varargin{11};
    A = varargin{12};
    R = varargin{13};
    Sa = varargin{14};
    t0 = varargin{15};
    step = varargin{16};
    ws2 = varargin{17};
    ws = varargin{18};
    nx = varargin{19};
    iw = varargin{20};
    E2 = varargin{21};
    SK = varargin{22};
    shift = varargin{23};
    ElgE2 = varargin{24};
    CE2 = varargin{25};
    AE2 = varargin{26};
    RE2 = varargin{27};
    EnormE = varargin{28};
    ElgEh = varargin{29};
    ElgEr = varargin{30};
    EEh = varargin{31};
    EEr = varargin{32};
    ElgRE = varargin{33};
    anisE = varargin{34};
    Elg2 = varargin{35};
    Sa2 = varargin{36};
    Enorm2 = varargin{37};
    Elgh2 = varargin{38};
    Elgr = varargin{39};
    Eh2 = varargin{40};
    Er = varargin{41};
    ElgR = varargin{42};
    anis = varargin{43};
    debut = varargin{44};
    fin = varargin{45};
    stepPicture = varargin{46};
    N = varargin{47};
    folder_name = varargin{48};
    
    
    setappdata(0,'ElgE1',ElgE1);
    setappdata(0,'CE1',CE1);
    setappdata(0,'AE1',AE1);
    setappdata(0,'RE1',RE1);
    setappdata(0,'red',red);
    setappdata(0,'seuil',seuil);
    setappdata(0,'CTVerif',CTVerif);
    setappdata(0,'SKVerif',SKVerif);
    setappdata(0,'scale',scale);
    setappdata(0,'Elg',Elg);
    setappdata(0,'C',C);
    setappdata(0,'A',A);
    setappdata(0,'R',R);
    setappdata(0,'Sa',Sa);
    setappdata(0,'t0',t0);
    setappdata(0,'step',step);
    setappdata(0,'ws2',ws2);
    setappdata(0,'ws',ws);
    setappdata(0,'nx',nx);
    setappdata(0,'iw',iw);
    setappdata(0,'E2',E2);
    setappdata(0,'SK',SK);
    setappdata(0,'shift',shift);
    setappdata(0,'ElgE2',ElgE2);
    setappdata(0,'CE2',CE2);
    setappdata(0,'AE2',AE2);
    setappdata(0,'RE2',RE2);
    setappdata(0,'EnormE',EnormE);
    setappdata(0,'ElgEh',ElgEh);
    setappdata(0,'ElgEr',ElgEr);
    setappdata(0,'EEh',EEh);
    setappdata(0,'EEr',EEr);
    setappdata(0,'ElgRE',ElgRE);
    setappdata(0,'anisE',anisE);
    setappdata(0,'Elg2',Elg2);
    setappdata(0,'Sa2',Sa2);
    setappdata(0,'Enorm2',Enorm2);
    setappdata(0,'Elgh2',Elgh2);
    setappdata(0,'Elgr',Elgr);
    setappdata(0,'Eh2',Eh2);
    setappdata(0,'Er',Er);
    setappdata(0,'ElgR',ElgR);
    setappdata(0,'anis',anis);
    setappdata(0,'debut',debut);
    setappdata(0,'fin',fin);
    setappdata(0,'stepPicture',stepPicture);
    setappdata(0,'N',N);
    setappdata(0,'folder_name',folder_name);
    
    
   char = {'Simple Elongation'; 'Composed Elongation'; 'Simple Curvature'; 'Composed Curvature'; ...
                'Simple Angle'; 'Composed Angle'; 'Simple Radius'; 'Composed Radius'; 'Total Displacement';...
                'Hypocotyle''s Elongation'; 'Root''s Elongation';...
                'Hypocotyl''s Displacement'; 'Root''s Displacement'; 'Radial Elongation'; 'Anisotropy'};
    
    set(handles.PmChoix,'String',char);
    
    flag = 1;
    set(handles.pushbutton6,'Visible','off');
    
elseif nargin == 31
    
    ElgE1 = varargin{1};
    CE1 = varargin{2};
    AE1 = varargin{3};
    RE1 = varargin{4};
    red = varargin{5};
    seuil = varargin{6};
    CTVerif = varargin{7};
    SKVerif = varargin{8};
    scale = varargin{9};
    Elg = varargin{10};
    C = varargin{11};
    A = varargin{12};
    R = varargin{13};
    Sa = varargin{14};
    t0 = varargin{15};
    step = varargin{16};
    ws2 = varargin{17};
    ws = varargin{18};
    nx = varargin{19};
    iw = varargin{20};
    E2 = varargin{21};
    SK = varargin{22};
    shift = varargin{23};
    debut = varargin{24};
    fin = varargin{25};
    stepPicture = varargin{26};
    N = varargin{27};
    folder_name = varargin{28};
    
    setappdata(0,'ElgE1',ElgE1);
    setappdata(0,'CE1',CE1);
    setappdata(0,'AE1',AE1);
    setappdata(0,'RE1',RE1);
    setappdata(0,'red',red);
    setappdata(0,'seuil',seuil);
    setappdata(0,'CTVerif',CTVerif);
    setappdata(0,'SKVerif',SKVerif);
    setappdata(0,'scale',scale);
    setappdata(0,'Elg',Elg);
    setappdata(0,'C',C);
    setappdata(0,'A',A);
    setappdata(0,'R',R);
    setappdata(0,'Sa',Sa);
    setappdata(0,'t0',t0);
    setappdata(0,'step',step);
    setappdata(0,'ws2',ws2);
    setappdata(0,'ws',ws);
    setappdata(0,'nx',nx);
    setappdata(0,'iw',iw);
    setappdata(0,'E2',E2);
    setappdata(0,'SK',SK);
    setappdata(0,'shift',shift);
    setappdata(0,'debut',debut);
    setappdata(0,'fin',fin);
    setappdata(0,'stepPicture',stepPicture);
    setappdata(0,'N',N);
    setappdata(0,'folder_name',folder_name);
    
    flag = 2;
    
elseif nargin == 3 %  A voir pour charger les autres kymographes
    [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
    if PathName == 0
        warning('Select a directory please'); %#ok
    else
        file = fullfile(PathName,FileName);
        load(file);
        if flag == 2
            setappdata(0,'Elg',Elongation);
            setappdata(0,'C',Curvature);
            setappdata(0,'A',Angle);
            setappdata(0,'R',Radius);
            setappdata(0,'scale',scale);%#ok
            setappdata(0,'seuil',thres);
            setappdata(0,'Sa',curvilinearAbscissa);
            setappdata(0,'t0',timeBetween2Pictures);
            setappdata(0,'step',stepBetween2Displacement);
            setappdata(0,'ws2',sizeOfCorrelatingWindow2);
            setappdata(0,'ws',sizeOfCorrelatingWindow1);
            setappdata(0,'nx',numberPointsForResample);
            setappdata(0,'iw',lengthOfTheSmoothing );
            setappdata(0,'SKVerif',SKVerif);%#ok
            setappdata(0,'CTVerif',CTVerif);%#ok
            setappdata(0,'E2',E2);%#ok
            setappdata(0,'SK',SK);%#ok
            setappdata(0,'shift',shift);%#ok
            setappdata(0,'debut',debut);%#ok
            setappdata(0,'fin',fin);%#ok
            setappdata(0,'stepPicture',stepPicture);%#ok
            setappdata(0,'N',N);%#ok
            setappdata(0,'folder_name',folder_name);%#ok
            
            ElgE1 = reconstruct_Elg2(numberPointsForResample,Elongation);
            
            CE1 = reconstruct_Elg2(numberPointsForResample,Curvature,curvilinearAbscissa);
            
            AE1 = reconstruct_Elg2(numberPointsForResample,Angle,curvilinearAbscissa);
            
            RE1 = reconstruct_Elg2(numberPointsForResample,Radius,curvilinearAbscissa);
            
            setappdata(0,'ElgE1',ElgE1);
            setappdata(0,'CE1',CE1);
            setappdata(0,'AE1',AE1);
            setappdata(0,'RE1',RE1);
            
            
            
            
            if stepPicture == 1 % For open all pictures
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
                for i = debut : stepPicture : fin
                    nb = nb + 1;
                end
                red = cell(nb,1);
                parfor_progress(nb);
                for i=0:nb - 1
                    try
                        red{i+1} = imread(fullfile(folder_name,N(debut + stepPicture * i).name));
                    catch e%#ok
                        disp('Pictures''s folder not found');
                        delete(gcf);
                        return;
                    end
                    parfor_progress;
                end
                parfor_progress(0);
                
            end
            
            setappdata(0,'red',red);
            t0 = timeBetween2Pictures;
            
            
        elseif flag == 1
            setappdata(0,'Elg',Elongation);
            setappdata(0,'C',Curvature);
            setappdata(0,'A',Angle);
            setappdata(0,'R',Radius);
            setappdata(0,'scale',scale);%#ok
            setappdata(0,'seuil',thres);
            setappdata(0,'Sa',curvilinearAbscissa);
            setappdata(0,'t0',timeBetween2Pictures);
            setappdata(0,'step',stepBetween2Displacement);
            setappdata(0,'ws2',sizeOfCorrelatingWindow2);
            setappdata(0,'ws',sizeOfCorrelatingWindow1);
            setappdata(0,'nx',numberPointsForResample);
            setappdata(0,'iw',lengthOfTheSmoothing );
            setappdata(0,'SKVerif',SKVerif);%#ok
            setappdata(0,'CTVerif',CTVerif);%#ok
            setappdata(0,'E2',E2);%#ok
            setappdata(0,'SK',SK);%#ok
            setappdata(0,'shift',shift);%#ok
            setappdata(0,'Elg2',Elg2);%#ok
            setappdata(0,'Sa2',Sa2);%#ok
            setappdata(0,'Enorm2',Enorm2);%#ok
            setappdata(0,'Elgh2',Elgh2);%#ok
            setappdata(0,'Elgr',Elgr);%#ok
            setappdata(0,'Eh2',Eh2);%#ok
            setappdata(0,'Er',Er);%#ok
            setappdata(0,'ElgR',ElgR);%#ok
            setappdata(0,'anis',anis);%#ok
            setappdata(0,'debut',debut);%#ok
            setappdata(0,'fin',fin);%#ok
            setappdata(0,'stepPicture',stepPicture);%#ok
            setappdata(0,'N',N);%#ok
            setappdata(0,'folder_name',folder_name);%#ok
            
            char = {'Simple Elongation'; 'Composed Elongation'; 'Simple Curvature'; 'Composed Curvature'; ...
                'Simple Angle'; 'Composed Angle'; 'Simple Radius'; 'Composed Radius'; 'Total Displacement';...
                'Hypocotyle''s Elongation'; 'Root''s Elongation';...
                'Hypocotyl''s Displacement'; 'Root''s Displacement'; 'Radial Elongation'; 'Anisotropy'};
            
            set(handles.PmChoix,'String',char);
            nx = numberPointsForResample;
            
            ElgE1 = reconstruct_Elg2(numberPointsForResample,Elongation);
            
            CE1 = reconstruct_Elg2(numberPointsForResample,Curvature,curvilinearAbscissa);
            
            AE1 = reconstruct_Elg2(numberPointsForResample,Angle,curvilinearAbscissa);
            
            RE1 = reconstruct_Elg2(numberPointsForResample,Radius,curvilinearAbscissa);
            
            ElgE2=reconstruct_Elg2(nx,Elg2);
            CE2=reconstruct_Elg2(nx,Curvature,Sa2);
            AE2=reconstruct_Elg2(nx,Angle,Sa2);
            RE2=reconstruct_Elg2(nx,Radius,Sa2);
            EnormE=reconstruct_Elg2(nx,Enorm2);
            ElgEh=reconstruct_Elg2(nx,Elgh2);
            ElgEr=reconstruct_Elg2(nx,Elgr);
            EEh=reconstruct_Elg2(nx,Eh2);
            EEr=reconstruct_Elg2(nx,Er);
            ElgRE=reconstruct_Elg2(nx,ElgR);
            anisE=reconstruct_Elg2(nx,anis);
            setappdata(0,'ElgE1',ElgE1);
            setappdata(0,'CE1',CE1);
            setappdata(0,'AE1',AE1);
            setappdata(0,'RE1',RE1);
            setappdata(0,'ElgE2',ElgE2);
            setappdata(0,'CE2',CE2);
            setappdata(0,'AE2',AE2);
            setappdata(0,'RE2',RE2);
            setappdata(0,'EnormE',EnormE);
            setappdata(0,'ElgEh',ElgEh);
            setappdata(0,'ElgEr',ElgEr);
            setappdata(0,'EEh',EEh);
            setappdata(0,'EEr',EEr);
            setappdata(0,'ElgRE',ElgRE);
            setappdata(0,'anisE',anisE);
            t0 = timeBetween2Pictures;
            set(handles.pushbutton6,'Visible','off');
            if stepPicture == 1 % For open all pictures
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
                for i = debut : stepPicture : fin
                    nb = nb + 1;
                end
                red = cell(nb,1);
                parfor_progress(nb);
                for i=0:nb - 1
                    try
                        red{i+1} = imread(fullfile(folder_name,N(debut + stepPicture * i).name));
                    catch e%#ok
                        disp('Pictures''s folder not found');
                        delete(gcf);
                        return;
                    end
                    parfor_progress;
                end
                parfor_progress(0);
                
            end
            
            setappdata(0,'red',red);
            
        end
    end
    
    
end
axes(handles.axes1);%#ok % To load the first kymograph, elongation
im = imagesc(ElgE1);colorbar;
set(gca, 'YDir', 'normal')
val = caxis;
minCaxis = val(1);
maxCaxis = val(2);
set(handles.slider1,'Max',maxCaxis);
set(handles.slider1,'Min',minCaxis);
set(handles.slider1,'Value',minCaxis);
colormap jet;
freezeColors;
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles}) % To detect clics on the pictures
str = (strcat('one equals ',num2str(t0),'minutes'));
xlabel(str);
setappdata(0,'flag',flag);
setappdata(0,'maxCaxis',maxCaxis);
setappdata(0,'minCaxis',minCaxis);
%Update handles structure
guidata(hObject, handles);

% UIWAIT makes FinalKymograph wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FinalKymograph_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure




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


% --- Executes on selection change in PmChoix.
function PmChoix_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to PmChoix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PmChoix contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PmChoix

% To select the kymograph with a popupmenu

flag = getappdata(0,'flag');
t = getappdata(0,'t0');
if flag == 2
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    
    
    valPopUp = get(handles.PmChoix,'Value'); % Take the value of popupmenu
    
    if(valPopUp==1)
        axes(handles.axes1);%#ok
        im = imagesc(ElgE1);colorbar;freezeColors;
        set(gca, 'YDir', 'normal')
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
       
        
    end
    
    if(valPopUp==2)
        axes(handles.axes1);%#ok
        im = imagesc(RE1);colorbar;freezeColors;
        set(gca, 'YDir', 'normal')
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end
    
    if(valPopUp==3)
        axes(handles.axes1);%#ok
        im = imagesc(CE1);colorbar;freezeColors;
        set(gca, 'YDir', 'normal')
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end
    
    if(valPopUp==4)
        axes(handles.axes1);%#ok
        im = imagesc(AE1);colorbar;freezeColors;
        set(gca, 'YDir', 'normal')
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end

elseif flag == 1
    ElgE2 = getappdata(0,'ElgE2');
    CE2 = getappdata(0,'CE2');
    AE2 = getappdata(0,'AE2');
    RE2 = getappdata(0,'RE2');
    EnormE = getappdata(0,'EnormE');
    ElgEh = getappdata(0,'ElgEh');
    ElgEr = getappdata(0,'ElgEr');
    EEh = getappdata(0,'EEh');
    EEr = getappdata(0,'EEr');
    ElgRE = getappdata(0,'ElgRE');
    anisE = getappdata(0,'anisE');
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    
    cell = {ElgE1; ElgE2; CE1; CE2; AE1; AE2; RE1; RE2; EnormE; ElgEh; ElgEr; EEh; EEr; ElgRE; anisE};
    
     valPopUp = get(handles.PmChoix,'Value'); % Take the value of popupmenu
    
    for i = 1 : 15
        if valPopUp == i
             axes(handles.axes1);%#ok
             im = imagesc(cell{i});
             set(gca, 'YDir', 'normal')
             set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
             colormap jet;
             colorbar;freezeColors;
             str = (strcat('one equals ',num2str(t),'minutes'));
             xlabel(str);
             freezeColors;
        end
    end
    
    
    
    
    
    
    
    
    
    
end
% --- Executes during object creation, after setting all properties.
function PmChoix_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to PmChoix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)%#ok
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% To show a picture with contour and skeleton corresponding at kymograph
% clic

handles = guidata(hObject);
pos = get(handles.axes1,'CurrentPoint');

%disp(['You clicked X:',num2str(pos(1)),', Y:',num2str(pos(4))]);

flag = getappdata(0,'flag');
red = getappdata(0,'red');
CTVerif = getappdata(0,'CTVerif');
SKVerif = getappdata(0,'SKVerif');
scale = getappdata(0,'scale');
nx = getappdata(0,'nx');


posX = pos(1);
posY = pos(3);
valPopUp = get(handles.PmChoix,'Value'); % Take the value of pop up menu

P = get(handles.axes1,'XLim');
max = P(2); % Maximum value of axes
min = P(1); % Minimum value of axes


if flag == 2
    if valPopUp == 1 % 1 for elongation
        if posX < min + 0.05 % For the first image (not showing in kimograph)
            axes(handles.axes2);%#ok
            imshow(red{1} );
            hold on;
            plot(CTVerif{1}(:,1)*scale,CTVerif{1}(:,2)*scale,'r');
            hold on;
            plot(SKVerif{1}(:,1)*scale,SKVerif{1}(:,2)*scale,'b');
            colormap gray;
            freezeColors;
            nbPoints = length(SKVerif{1});
            point = (nbPoints * posY) / nx ;
            point = round(point);
            plot(SKVerif{1}(point,1)*253,SKVerif{1}(point,2)*253,'d','Color','c','LineWidth',3);
            
        elseif posX > max - 0.05 % For the last image (not showing in kimograph)
            axes(handles.axes2);%#ok
            imshow(red{end} );
            hold on;
            plot(CTVerif{end}(:,1)*scale,CTVerif{end}(:,2)*scale,'r');
            hold on;
            plot(SKVerif{end}(:,1)*scale,SKVerif{end}(:,2)*scale,'b');
            colormap gray;
            freezeColors;
            nbPoints = length(SKVerif{end});
            point = (nbPoints * posY) / nx ;
            point = round(point);
            plot(SKVerif{end}(point,1)*253,SKVerif{end}(point,2)*253,'d','Color','c','LineWidth',3);
            
        else
            for i=min - 0.5: max - 0.5 % For all the others image, showing in the kymograph
                if posX > i-0.5 && posX < i+0.5
                    axes(handles.axes2);%#ok
                    imshow(red{i+1} );
                    hold on;
                    plot(CTVerif{i+1}(:,1)*scale,CTVerif{i+1}(:,2)*scale,'r');
                    hold on;
                    plot(SKVerif{i+1}(:,1)*scale,SKVerif{i+1}(:,2)*scale,'b');
                    colormap gray;
                    freezeColors;
                    nbPoints = length(SKVerif{1 + i});
                    point = (nbPoints * posY) / nx ;
                    point = round(point);
                    plot(SKVerif{1 + i}(point,1)*253,SKVerif{1 + i}(point,2)*253,'d','Color','c','LineWidth',3);
                    
                end
            end
        end
    end
    if valPopUp == 2 || valPopUp == 3 || valPopUp == 4 % For angle curvature and Radius
        for i=min - 0.5: max - 0.5
            if posX > i-0.5 && posX < i+0.5
                axes(handles.axes2);%#ok
                imshow(red{i} );
                hold on;
                plot(CTVerif{i}(:,1)*scale,CTVerif{i}(:,2)*scale,'r');
                hold on;
                plot(SKVerif{i}(:,1)*scale,SKVerif{i}(:,2)*scale,'b');
                colormap gray;
                freezeColors;
                nbPoints = length(SKVerif{i});
                point = (nbPoints * posY) / nx ;
                point = round(point);
                plot(SKVerif{i}(point,1)*253,SKVerif{i}(point,2)*253,'d','Color','c','LineWidth',3);
            end
        end
    end
elseif flag == 1
    if valPopUp == 1 || valPopUp == 2 || valPopUp == 9 || valPopUp == 10 || valPopUp == 11 ||...
            valPopUp == 12 ||valPopUp == 13 ||valPopUp == 14 ||valPopUp == 15  % 1 for elongation
        if posX < min + 0.05 % For the first image (not showing in kimograph)
            axes(handles.axes2);%#ok
            imshow(red{1} );
            hold on;
            plot(CTVerif{1}(:,1)*scale,CTVerif{1}(:,2)*scale,'r');
            hold on;
            plot(SKVerif{1}(:,1)*scale,SKVerif{1}(:,2)*scale,'b');
            colormap gray;
            freezeColors;
            nbPoints = length(SKVerif{1});
            point = (nbPoints * posY) / nx ;
            point = round(point);
            plot(SKVerif{1}(point,1)*253,SKVerif{1}(point,2)*253,'d','Color','c','LineWidth',3);
            
        elseif posX > max - 0.05 % For the last image (not showing in kimograph)
            axes(handles.axes2);%#ok
            imshow(red{end} );
            hold on;
            plot(CTVerif{end}(:,1)*scale,CTVerif{end}(:,2)*scale,'r');
            hold on;
            plot(SKVerif{end}(:,1)*scale,SKVerif{end}(:,2)*scale,'b');
            colormap gray;
            freezeColors;
            nbPoints = length(SKVerif{end});
            point = (nbPoints * posY) / nx ;
            point = round(point);
            plot(SKVerif{end}(point,1)*253,SKVerif{end}(point,2)*253,'d','Color','c','LineWidth',3);
            
        else
            for i=min - 0.5: max - 0.5 % For all the others image, showing in the kymograph
                if posX > i-0.5 && posX < i+0.5
                    axes(handles.axes2);%#ok
                    imshow(red{i+1} );
                    hold on;
                    plot(CTVerif{i+1}(:,1)*scale,CTVerif{i+1}(:,2)*scale,'r');
                    hold on;
                    plot(SKVerif{i+1}(:,1)*scale,SKVerif{i+1}(:,2)*scale,'b');
                    colormap gray;
                    freezeColors;
                    nbPoints = length(SKVerif{i+1});
                    point = (nbPoints * posY) / nx ;
                    point = round(point);
                    plot(SKVerif{i + 1}(point,1)*253,SKVerif{i + 1}(point,2)*253,'d','Color','c','LineWidth',3);
                    
                end
            end
        end
    end
    if valPopUp == 3 || valPopUp == 4 || valPopUp == 5 ||valPopUp == 6 ||valPopUp == 7 || valPopUp == 8    % For angle curvature and Radius
        for i=min - 0.5: max - 0.5
            if posX > i-0.5 && posX < i+0.5
                axes(handles.axes2);%#ok
                imshow(red{i} );
                hold on;
                plot(CTVerif{i}(:,1)*scale,CTVerif{i}(:,2)*scale,'r');
                hold on;
                plot(SKVerif{i}(:,1)*scale,SKVerif{i}(:,2)*scale,'b');
                colormap gray;
                freezeColors;
                nbPoints = length(SKVerif{i});
                point = (nbPoints * posY) / nx ;
                point = round(point);
                plot(SKVerif{i}(point,1)*253,SKVerif{i}(point,2)*253,'d','Color','c','LineWidth',3);
            end
        end
    end
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [FileName,PathName] = uiputfile({'*.tif'});%ouvre la boite et liste les fichiers .tif
    f = getframe(handles.axes1);%selectione la totalité de la figure courante
    im = frame2im(f);
    imwrite(im,fullfile(PathName, FileName),'tif')%enregistre l'image dans le fichier sélectionné
catch error%#ok
    warning('Select a folder to save picture please');%#ok
    return;
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    [FileName,PathName] = uiputfile({'*.png'});%ouvre la boite et liste les fichiers .png
    f = getframe(handles.axes1);%selectione la totalité de la figure courante
    im = frame2im(f);
    imwrite(im,fullfile(PathName, FileName),'png')%enregistre l'image dans le fichier sélectionné
catch error%#ok
    warning('Select a folder to save picture please');%#ok
    return;
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton5,'Enable','off')
set(handles.pushbutton5,'String','Wait please...')
pause(0.01);
flag = getappdata(0,'flag');

if flag == 2
    
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    
    Elongation = getappdata(0,'Elg');%#ok
    Curvature = getappdata(0,'C');%#ok
    Angle = getappdata(0,'A');%#ok
    Radius = getappdata(0,'R');%#ok
    dirPicture = getappdata(0,'red');
    scale = getappdata(0,'scale');%#ok
    thres = getappdata(0,'seuil');%#ok
    curvilinearAbscissa  = getappdata(0,'Sa');%#ok
    timeBetween2Pictures = getappdata(0,'t0');%#ok
    stepBetween2Displacement = getappdata(0,'step');%#ok
    sizeOfCorrelatingWindow2 = getappdata(0,'ws2');%#ok
    sizeOfCorrelatingWindow1 = getappdata(0,'ws');%#ok
    numberPointsForResample = getappdata(0,'nx');%#ok
    lengthOfTheSmoothing = getappdata(0,'iw');%#ok
    CTVerif = getappdata(0,'CTVerif');%#ok
    SKVerif = getappdata(0,'SKVerif');%#ok
    E2 = getappdata(0,'E2');%#ok
    SK = getappdata(0,'SK');%#ok
    shift = getappdata(0,'shift');%#ok
    debut = getappdata(0,'debut');%#ok
    fin = getappdata(0,'fin');%#ok
    N = getappdata(0,'N');%#ok
    folder_name = getappdata(0,'folder_name');%#ok
    stepPicture = getappdata(0,'stepPicture');%#ok
    
    [FileName,PathName] = uiputfile('*.*','Create a directory for save your data'); % To open the directory who the user want to save the data
    nameDir = fullfile(PathName,FileName);
    
    if PathName == 0
        warning('Select a file please');%#ok
        return;
    end
    
    disp('Saving...');
    
    mkdir(nameDir);
    
    FileData = 'data.mat';
    nameData = fullfile(nameDir,FileData);
    
    save(nameData,'Elongation','Curvature','Angle','Radius','scale','thres',... % J'ai enlvé dirPicture
        'curvilinearAbscissa','timeBetween2Pictures','stepBetween2Displacement','sizeOfCorrelatingWindow2',...
        'sizeOfCorrelatingWindow1','numberPointsForResample','lengthOfTheSmoothing','CTVerif','SKVerif','E2','SK','shift','flag'...
        ,'debut','fin','stepPicture','N','folder_name');
    
    n = length(dirPicture);
    
    pathElongation = fullfile(nameDir,'dataElongation.csv');
    pathAngle = fullfile(nameDir,'dataAngle.csv');
    pathCurvature = fullfile(nameDir,'dataCurvature.csv');
    pathRadius = fullfile(nameDir,'dataRadius.csv');
    
    cols = cell(n,1);
    for i = 1 : n
        cols{i} = strcat('picture',num2str(i));
    end
    
    colsElongation = cell(n-2,1);
    for i = 2 : n-1
        colsElongation{i - 1} = strcat('picture',num2str(i));
    end
    
    % Strtrim pour supprimer les espaces!
    cols = strtrim(cols);
    colsElongation = strtrim(colsElongation);
    
    
    tabElongation = Table(ElgE1,'colNames',colsElongation);
    write(tabElongation,pathElongation);
    
    tabAngle = Table(AE1,'colNames',cols);
    write(tabAngle,pathAngle);
    
    tabCurvature = Table(CE1,'colNames',cols);
    write(tabCurvature,pathCurvature);
    
    tabRadius = Table(RE1,'colNames',cols);
    write(tabRadius,pathRadius);
    
    disp('Saving done');
    
elseif flag == 1
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    Elongation = getappdata(0,'Elg');%#ok
    Curvature = getappdata(0,'C');%#ok
    Angle = getappdata(0,'A');%#ok
    Radius = getappdata(0,'R');%#ok
    dirPicture = getappdata(0,'red');
    scale = getappdata(0,'scale');%#ok
    thres = getappdata(0,'seuil');%#ok
    curvilinearAbscissa  = getappdata(0,'Sa');%#ok
    timeBetween2Pictures = getappdata(0,'t0');%#ok
    stepBetween2Displacement = getappdata(0,'step');%#ok
    sizeOfCorrelatingWindow2 = getappdata(0,'ws2');%#ok
    sizeOfCorrelatingWindow1 = getappdata(0,'ws');%#ok
    numberPointsForResample = getappdata(0,'nx');%#ok
    lengthOfTheSmoothing = getappdata(0,'iw');%#ok
    CTVerif = getappdata(0,'CTVerif');%#ok
    SKVerif = getappdata(0,'SKVerif');%#ok
    E2 = getappdata(0,'E2');%#ok
    SK = getappdata(0,'SK');%#ok
    shift = getappdata(0,'shift');%#ok
    ElgE2 = getappdata(0,'ElgE2');
    CE2 = getappdata(0,'CE2');
    AE2 = getappdata(0,'AE2');
    RE2 = getappdata(0,'RE2');
    EnormE = getappdata(0,'EnormE');
    ElgEh = getappdata(0,'ElgEh');
    ElgEr = getappdata(0,'ElgEr');
    EEh = getappdata(0,'EEh');
    EEr = getappdata(0,'EEr');
    ElgRE = getappdata(0,'ElgRE');
    anisE = getappdata(0,'anisE');
    Elg2 = getappdata(0,'Elg2');%#ok
    Sa2 = getappdata(0,'Sa2');%#ok
    Enorm2 = getappdata(0,'Enorm2');%#ok
    Elgh2 = getappdata(0,'Elgh2');%#ok
    Elgr = getappdata(0,'Elgr');%#ok
    Eh2 = getappdata(0,'Eh2');%#ok
    Er = getappdata(0,'Er');%#ok
    ElgR = getappdata(0,'Elgr');%#ok
    anis = getappdata(0,'anis');%#ok
    debut = getappdata(0,'debut');%#ok
    fin = getappdata(0,'fin');%#ok
    N = getappdata(0,'N');%#ok
    folder_name = getappdata(0,'folder_name');%#ok
    stepPicture = getappdata(0,'stepPicture');%#ok
    
    
    
    [FileName,PathName] = uiputfile('*.*','Create a directory for save your data'); % To open the directory who the user want to save the data
    nameDir = fullfile(PathName,FileName);
    
    if PathName == 0
        warning('Select a file please');%#ok
        return;
    end
    
    disp('Saving...');
    
    mkdir(nameDir);
    
    FileData = 'data.mat';
    nameData = fullfile(nameDir,FileData);
    
    save(nameData,'Elongation','Curvature','Angle','Radius',...
        'scale','thres',...
        'curvilinearAbscissa','timeBetween2Pictures','stepBetween2Displacement',...
        'sizeOfCorrelatingWindow2','sizeOfCorrelatingWindow1','numberPointsForResample',...
        'lengthOfTheSmoothing','CTVerif','SKVerif','E2','SK','shift','flag','Elg2','Sa2',...
        'Enorm2','Elgh2','Elgr','Eh2','Er','ElgR','anis','debut','fin','stepPicture','N','folder_name');
    n = length(dirPicture);
    
    pathElongationSimple = fullfile(nameDir,'dataElongationSimple.csv');
    pathAngleSimple = fullfile(nameDir,'dataAngleSimple.csv');
    pathCurvatureSimple = fullfile(nameDir,'dataCurvatureSimple.csv');
    pathRadiusSimple = fullfile(nameDir,'dataRadiusSimple.csv');
    pathElongationComposed = fullfile(nameDir,'dataElongationComposed.csv');
    pathAngleComposed = fullfile(nameDir,'dataAngleComposed.csv');
    pathCurvatureComposed = fullfile(nameDir,'dataCurvatureComposed.csv');
    pathRadiusComposed = fullfile(nameDir,'dataRadiusComposed.csv');
    pathElongationHypocotyle = fullfile(nameDir,'dataElongationHypocotyle.csv');
    pathElongationRoot = fullfile(nameDir,'dataElongationRoot.csv');
    pathDisplacementHypocotyle = fullfile(nameDir,'dataDisplacementHypocotyle.csv');
    pathDisplacementRoot = fullfile(nameDir,'dataDisplacementRoot.csv');
    pathElongationRadial = fullfile(nameDir,'dataElongationRadial.csv');
    pathAnisotropie = fullfile(nameDir,'dataAnisotropie.csv');
    pathEnormE = fullfile(nameDir,'dataEnormE.csv');
     
    
    cols = cell(n,1);
    for i = 1 : n
        cols{i} = strcat('picture',num2str(i));
    end
    
    colsElongation = cell(n-2,1);
    for i = 2 : n-1
        colsElongation{i - 1} = strcat('picture',num2str(i));
    end
    
    % Strtrim pour supprimer les espaces!
    cols = strtrim(cols);
    colsElongation = strtrim(colsElongation);
    
     
    tabElongation = Table(ElgE1,'colNames',colsElongation);
    write(tabElongation,pathElongationSimple);
    
    tabAngle = Table(AE1,'colNames',cols);
    write(tabAngle,pathAngleSimple);
    
    tabCurvature = Table(CE1,'colNames',cols);
    write(tabCurvature,pathCurvatureSimple);
    
    tabRadius = Table(RE1,'colNames',cols);
    write(tabRadius,pathRadiusSimple);
    
    tabElongation2 = Table(ElgE2,'colNames',colsElongation);
    write(tabElongation2,pathElongationComposed);
    
    tabAngle2 = Table(AE2,'colNames',cols);
    write(tabAngle2,pathAngleComposed);
    
    tabCurvature2 = Table(CE2,'colNames',cols);
    write(tabCurvature2,pathCurvatureComposed);
    
    tabRadius2 = Table(RE2,'colNames',cols);
    write(tabRadius2,pathRadiusComposed);
    
    tabElongationH = Table(ElgEh,'colNames',colsElongation);
    write(tabElongationH,pathElongationHypocotyle);
    
    tabElongationR = Table(ElgEr,'colNames',colsElongation);
    write(tabElongationR,pathElongationRoot);
    
    tabDisplacementH = Table(EEh,'colNames',colsElongation);
    write(tabDisplacementH, pathDisplacementHypocotyle);
    
    tabDisplacementR = Table(EEr,'colNames',colsElongation);
    write(tabDisplacementR,pathDisplacementRoot);
    
    tabElongationRadial = Table(ElgRE,'colNames',colsElongation);
    write(tabElongationRadial, pathElongationRadial);
    
    tabAnisotropie = Table(anisE,'colNames',colsElongation);
    write(tabAnisotropie,pathAnisotropie);
    
    tabEnormE = Table(EnormE,'colNames',colsElongation);
    write(tabEnormE,pathEnormE);
    
    disp('Saving done..');
end
set(handles.pushbutton5,'Enable','on')
set(handles.pushbutton5,'String','Save all data')


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ElgE1 = getappdata(0,'ElgE1');
CE1 = getappdata(0,'CE1');
AE1 = getappdata(0,'AE1');
RE1 = getappdata(0,'RE1');
Elg = getappdata(0,'Elg');
C = getappdata(0,'C');
A = getappdata(0,'A');
R = getappdata(0,'R');
red= getappdata(0,'red'); 
scale = getappdata(0,'scale');
seuil = getappdata(0,'seuil');
Sa  = getappdata(0,'Sa');
t0 = getappdata(0,'t0');
step = getappdata(0,'step');
ws2 = getappdata(0,'ws2');
ws = getappdata(0,'ws');
nx = getappdata(0,'nx');
iw = getappdata(0,'iw');
CTVerif = getappdata(0,'CTVerif');
SKVerif = getappdata(0,'SKVerif');
E2 = getappdata(0,'E2');
SK = getappdata(0,'SK');
shift = getappdata(0,'shift');
debut = getappdata(0,'debut');
fin = getappdata(0,'fin');
N = getappdata(0,'N');
folder_name = getappdata(0,'folder_name');
stepPicture = getappdata(0,'stepPicture');

delete(gcf);
StartComposedElongation(ElgE1,CE1,AE1,RE1,red,seuil,CTVerif,SKVerif,scale...
    ,Elg,C,A,R,Sa,t0,step,ws2,ws,nx,iw,E2,SK,shift,debut,fin,stepPicture,N,folder_name);


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

minCaxis = getappdata(0,'minCaxis');
maxCaxis = getappdata(0,'maxCaxis');


val = get(handles.slider1,'Value');



flag = getappdata(0,'flag');
t = getappdata(0,'t0');
if flag == 2
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    
    
    valPopUp = get(handles.PmChoix,'Value'); % Take the value of popupmenu
    
    if(valPopUp==1)
        axes(handles.axes1);%#ok
        im = imagesc(ElgE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
       
        
    end
    
    if(valPopUp==2)
        axes(handles.axes1);%#ok
        im = imagesc(RE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end
    
    if(valPopUp==3)
        axes(handles.axes1);%#ok
        im = imagesc(CE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end
    
    if(valPopUp==4)
        axes(handles.axes1);%#ok
        im = imagesc(AE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
    end

elseif flag == 1
    ElgE2 = getappdata(0,'ElgE2');
    CE2 = getappdata(0,'CE2');
    AE2 = getappdata(0,'AE2');
    RE2 = getappdata(0,'RE2');
    EnormE = getappdata(0,'EnormE');
    ElgEh = getappdata(0,'ElgEh');
    ElgEr = getappdata(0,'ElgEr');
    EEh = getappdata(0,'EEh');
    EEr = getappdata(0,'EEr');
    ElgRE = getappdata(0,'ElgRE');
    anisE = getappdata(0,'anisE');
    ElgE1 = getappdata(0,'ElgE1');
    CE1 = getappdata(0,'CE1');
    AE1 = getappdata(0,'AE1');
    RE1 = getappdata(0,'RE1');
    
    cell = {ElgE1; ElgE2; CE1; CE2; AE1; AE2; RE1; RE2; EnormE; ElgEh; ElgEr; EEh; EEr; ElgRE; anisE};
    
     valPopUp = get(handles.PmChoix,'Value'); % Take the value of popupmenu
    
    for i = 1 : 15
        if valPopUp == i
             axes(handles.axes1);%#ok
             im = imagesc(cell{i});
             set(gca, 'YDir', 'normal')
             set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
             colormap jet;
             caxis([minCaxis,maxCaxis - val]);colorbar;
             str = (strcat('one equals ',num2str(t),'minutes'));
             xlabel(str);
             freezeColors;
        end
    end
       
end
% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)%#ok
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
