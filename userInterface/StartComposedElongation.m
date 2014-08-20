function varargout = StartComposedElongation(varargin)
% STARTCOMPOSEDELONGATION MATLAB code for StartComposedElongation.fig
%      STARTCOMPOSEDELONGATION, by itself, creates a new STARTCOMPOSEDELONGATION or raises the existing
%      singleton*.
%
%      H = STARTCOMPOSEDELONGATION returns the handle to a new STARTCOMPOSEDELONGATION or the handle to
%      the existing singleton*.
%
%      STARTCOMPOSEDELONGATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTCOMPOSEDELONGATION.M with the given input arguments.
%
%      STARTCOMPOSEDELONGATION('Property','Value',...) creates a new STARTCOMPOSEDELONGATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StartComposedElongation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StartComposedElongation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StartComposedElongation

% Last Modified by GUIDE v2.5 20-Jun-2014 09:58:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StartComposedElongation_OpeningFcn, ...
                   'gui_OutputFcn',  @StartComposedElongation_OutputFcn, ...
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


% --- Executes just before StartComposedElongation is made visible.
function StartComposedElongation_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StartComposedElongation (see VARARGIN)

% Choose default command line output for StartComposedElongation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StartComposedElongation wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if nargin == 3
    [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
    if PathName == 0
        warning('Select a directory please'); %#ok
    else
        file = fullfile(PathName,FileName);
        load(file);
        
        setappdata(0,'Elg',Elongation);
        setappdata(0,'C',Curvature);
        setappdata(0,'A',Angle);
        setappdata(0,'R',Radius);
        setappdata(0,'scale',scale);%#ok
        setappdata(0,'seuil',thres);%#ok
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
elseif nargin == 31
    
    ElgE1 = varargin{1};
    CE1 = varargin{2};
    AE1 = varargin{3};
    RE1 = varargin{4};
    red = varargin{5};
    thres = varargin{6};
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
    setappdata(0,'seuil',thres);
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
    
end 

     
axes(handles.axes1);%#ok
imshow(red{end});

% --- Outputs from this function are returned to the command line.
function varargout = StartComposedElongation_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton2,'Enable','off')
set(handles.pushbutton2,'String','Wait please...')
pause(0.01);
disp('Composed elongation ...')
Sa = getappdata(0,'Sa');
R = getappdata(0,'R');
Elg = getappdata(0,'Elg');
scale = getappdata(0,'scale');
red = getappdata(0,'red');
C = getappdata(0,'C');
A = getappdata(0,'A');
t0 = getappdata(0,'t0');
nx = getappdata(0,'nx');
E2 = getappdata(0,'E2');
SK = getappdata(0,'SK');
shift = getappdata(0,'shift');
seuil = getappdata(0,'seuil');%#ok
CTVerif = getappdata(0,'CTVerif');
SKVerif = getappdata(0,'SKVerif');
ws2 = getappdata(0,'ws2');
ws = getappdata(0,'ws');
iw = getappdata(0,'iw');
seuil = getappdata(0,'seuil');
step = getappdata(0,'step');
debut = getappdata(0,'debut');
fin = getappdata(0,'fin');
N = getappdata(0,'N');
folder_name = getappdata(0,'folder_name');
stepPicture = getappdata(0,'stepPicture');

 %% Detection of the transition between root and hypoctyl
    %
    Smax = 4;
    Phr=hyproot(R,Sa,Smax);
    
    
    %decay of the functions
    [Sa1 Sa2]=deccurv(Sa,Phr);
    [E21 E22]=deccurv(E2,Phr);
    [Elg1 Elg2]=deccurv(Elg,Phr);
    [Enorm1 Enorm2]=displnorm(E22,E21);
    
    %Phh=hyphook(C,Sa1);
    %[Elg3 Elg4]=deccurv2(Phh,Elg1);
    %[R3 R4]=deccurv2(Phh,Sa1,R);
    %[A3 A4]=deccurv2(Phh,Sa1,A);    
    %[C3 C4]=deccurv2(Phh,Sa1,C); 
%% Separate hypocotyl and Root
    
    %[tdecr tdech Elgr Elgh]=hyprootdec(Elg1,SK,shift,scale,red);
    
    %Separation of hypoctyl and roots
    [Elgr Elgh tdecr tdech]=hyprootdec2(SK,shift,scale,red,Elg1);%#ok
    [Er Eh tdecr tdech]=hyprootdec2(SK,shift,scale,red,Enorm1);%#ok
    [Cr Ch]=hyprootdec2(SK,shift,scale,red,Sa1,C);%#ok
    
    %Detection of the top of the hook (maxima of curvature)
    Phh=hyphook2(Ch);      
    
    %Hypocotyl: From the apex to the base
    [Elgh1 Elgh2]=deccurv2(Phh,Elgh);
    [Eh1 Eh2]=deccurv2(Phh,Eh);    %#ok
    
    %Ltot total length of the organ
    %Lgz length of the growth zone
    %Emoy averaged elongation in the growth zone
    
    [Ltotr Lgzr Emoyr]=growthlength(Elgr);%#ok % a quoi ca sert?
    [Ltoth Lgzh Emoyh]=growthlength(Elgh1);%#ok


%% radial Elongation
    [ElgR anis]=elongrad(Elg2,Sa2,Elg2{end}(1,1)-Elg1{end}(1,1),R,t0);
    %[ElgR anis]=elongrad(Elg,Sa,0,R,t0);


%%  Space-time mapping
% Subsampling size

    
    ElgE1=reconstruct_Elg2(nx,Elg);     
    ElgE2=reconstruct_Elg2(nx,Elg2);    
    %ElgE3=reconstruct_Elg2(nx,Elg4);

    CE1=reconstruct_Elg2(nx,C,Sa);
    CE2=reconstruct_Elg2(nx,C,Sa2);
    %CE3=reconstruct_Elg2(nx,C4);
    AE1=reconstruct_Elg2(nx,A,Sa);
    AE2=reconstruct_Elg2(nx,A,Sa2);
    %AE3=reconstruct_Elg2(nx,A4);   
    RE1=reconstruct_Elg2(nx,R,Sa);
    RE2=reconstruct_Elg2(nx,R,Sa2);
    %RE3=reconstruct_Elg2(nx,R4);
    EnormE=reconstruct_Elg2(nx,Enorm2);

    ElgEh=reconstruct_Elg2(nx,Elgh2);
    ElgEr=reconstruct_Elg2(nx,Elgr);
    EEh=reconstruct_Elg2(nx,Eh2);
    EEr=reconstruct_Elg2(nx,Er);    
    ElgRE=reconstruct_Elg2(nx,ElgR);
    anisE=reconstruct_Elg2(nx,anis);

    delete(gcf);
    FinalKymograph(ElgE1,CE1,AE1,RE1,red,seuil,CTVerif,SKVerif,scale,Elg,C,A,R,Sa...
    ,t0,step,ws2,ws,nx,iw,E2,SK,shift,ElgE2,CE2,AE2,RE2,EnormE...
        ,ElgEh,ElgEr,EEh,EEr,ElgRE,anisE,Elg2,Sa2,Enorm2,Elgh2,Elgr,Eh2,Er,ElgR,anis...
        ,debut,fin,stepPicture,N,folder_name);
    


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(gcf);
StartProgramm();


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)%#ok
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
