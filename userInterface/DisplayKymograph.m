function varargout = DisplayKymograph(varargin)
% DISPLAYKYMOGRAPH MATLAB code for DisplayKymograph.fig
%      DISPLAYKYMOGRAPH, by itself, creates a new DISPLAYKYMOGRAPH or raises the existing
%      singleton*.
%
%      H = DISPLAYKYMOGRAPH returns the handle to a new DISPLAYKYMOGRAPH or the handle to
%      the existing singleton*.
%
%      DISPLAYKYMOGRAPH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAYKYMOGRAPH.M with the given input arguments.
%
%      DISPLAYKYMOGRAPH('Property','Value',...) creates a new DISPLAYKYMOGRAPH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DisplayKymograph_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DisplayKymograph_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DisplayKymograph

% Last Modified by GUIDE v2.5 22-Aug-2014 16:40:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DisplayKymograph_OpeningFcn, ...
                   'gui_OutputFcn',  @DisplayKymograph_OutputFcn, ...
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


% --- Executes just before DisplayKymograph is made visible.
function DisplayKymograph_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DisplayKymograph (see VARARGIN)

% Choose default command line output for DisplayKymograph
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    disp('Run DisplayKymograph using HypoGrowthAppData class');
    
    app = varargin{1};
    app.currentStep = 'kymograph';
    setappdata(0, 'app', app);
    
    t0      = app.timeInterval;
    ElgE1   = app.elongationImage;
    
elseif nargin == 31
    warning('Run DisplayKymograph using deprecated call');
    
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
    
elseif nargin == 3 %  A voir pour charger les autres kymographes
    [FileName,PathName] = uigetfile('*.mat','Select the MATLAB code file');
    if PathName == 0
        warning('Select a directory please');
    else
        file = fullfile(PathName,FileName);
        data = load(file);
        
        app = data.app;
        setappdata(0, 'app', app);
        
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
    end
end


% To load the first kymograph, elongation
axes(handles.axes1); 
im = imagesc(ElgE1); 
colorbar;
set(gca, 'YDir', 'normal')
val = caxis;
minCaxis = val(1);
maxCaxis = val(2);
set(handles.slider1, 'Max', maxCaxis);
set(handles.slider1, 'Min', minCaxis);
set(handles.slider1, 'Value', minCaxis);
colormap jet;

freezeColors;

% To detect clics on the pictures
set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles}) 
str = (strcat('one equals ', num2str(t0), 'minutes'));
xlabel(str);
% setappdata(0, 'flag', flag);
setappdata(0, 'maxCaxis', maxCaxis);
setappdata(0, 'minCaxis', minCaxis);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DisplayKymograph wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DisplayKymograph_OutputFcn(hObject, eventdata, handles)%#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in kymographTypePopup.
function kymographTypePopup_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to kymographTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns kymographTypePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from kymographTypePopup
% To select the kymograph with a popupmenu

app = getappdata(0, 'app');
t = app.timeInterval;

ElgE1   = app.elongationImage;
CE1     = app.curvatureImage;
AE1     = app.verticalAngleImage;
RE1     = app.radiusImage;

% Take the value of popupmenu
valPopUp = get(handles.kymographTypePopup, 'Value');

if(valPopUp==1)
    axes(handles.axes1);
    im = imagesc(ElgE1);colorbar;freezeColors;
    set(gca, 'YDir', 'normal')
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    str = (strcat('one equals ',num2str(t),'minutes'));
    xlabel(str);
    colormap jet;
    freezeColors;
end

if(valPopUp==2)
    axes(handles.axes1);
    im = imagesc(RE1);colorbar;freezeColors;
    set(gca, 'YDir', 'normal')
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    str = (strcat('one equals ',num2str(t),'minutes'));
    xlabel(str);
    colormap jet;
    freezeColors;
end

if(valPopUp==3)
    axes(handles.axes1);
    im = imagesc(CE1);colorbar;freezeColors;
    set(gca, 'YDir', 'normal')
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    str = (strcat('one equals ',num2str(t),'minutes'));
    xlabel(str);
    colormap jet;
    freezeColors;
end

if(valPopUp==4)
    axes(handles.axes1);
    im = imagesc(AE1);colorbar;freezeColors;
    set(gca, 'YDir', 'normal')
    set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
    str = (strcat('one equals ',num2str(t),'minutes'));
    xlabel(str);
    colormap jet;
    freezeColors;
end

% --- Executes during object creation, after setting all properties.
function kymographTypePopup_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU,INUSD>
% hObject    handle to kymographTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)%#ok
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% To show a picture with contour and skeleton corresponding at kymograph
% clic

handles = guidata(hObject);

app     = getappdata(0, 'app');
red     = app.imageList;
CTVerif = app.contourList;
SKVerif = app.skeletonList;
scale   = 1000 / app.pixelSize;
nx      = app.finalResultLength;

% extract last clicked position
pos = get(handles.axes1, 'CurrentPoint');
posX = pos(1);
posY = pos(3);

% extract min/max values of axes
P = get(handles.axes1, 'XLim');
min = P(1); 
max = P(2); 

% Take the value of pop up menu
valPopUp = get(handles.kymographTypePopup, 'Value'); 

if valPopUp == 1 % 1 for elongation
    if posX < min + 0.05 % For the first image (not showing in kimograph)
        axes(handles.axes2);
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
        axes(handles.axes2);
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



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


app = getappdata(0, 'app');

minCaxis = getappdata(0, 'minCaxis');
maxCaxis = getappdata(0, 'maxCaxis');
val = get(handles.slider1, 'Value');

t = app.timeInterval;
   
ElgE1   = app.elongationImage;
CE1     = app.curvatureImage;
AE1     = app.verticalAngleImage;
RE1     = app.radiusImage;

% Take the value of popupmenu
valPopUp = get(handles.kymographTypePopup, 'Value');

switch valPopUp
    case 1
        axes(handles.axes1);
        im = imagesc(ElgE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
        
    case 2
        axes(handles.axes1);
        im = imagesc(RE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
        
    case 3
        axes(handles.axes1);
        im = imagesc(CE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
        
    case 4
        axes(handles.axes1);
        im = imagesc(AE1);
        set(gca, 'YDir', 'normal')
        caxis([minCaxis,maxCaxis - val]);colorbar;
        set(im, 'buttondownfcn', {@axes1_ButtonDownFcn,handles});
        str = (strcat('one equals ',num2str(t),'minutes'));
        xlabel(str);
        colormap jet;
        freezeColors;
end



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)%#ok<INUSD>
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in saveAsPngButton.
function saveAsPngButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to saveAsPngButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [FileName,PathName] = uiputfile({'*.png'});%ouvre la boite et liste les fichiers .png
    f = getframe(handles.axes1);%selectione la totalité de la figure courante
    im = frame2im(f);
    imwrite(im,fullfile(PathName, FileName),'png')%enregistre l'image dans le fichier sélectionné
    
catch error %#ok
    warning('Select a folder to save picture please');
    return;
end


% --- Executes on button press in saveAsTiffButton.
function saveAsTiffButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to saveAsTiffButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [FileName,PathName] = uiputfile({'*.tif'});%ouvre la boite et liste les fichiers .tif
    f = getframe(handles.axes1);%selectione la totalité de la figure courante
    im = frame2im(f);
    imwrite(im,fullfile(PathName, FileName),'tif')%enregistre l'image dans le fichier sélectionné
catch error%#ok
    warning('Select a folder to save picture please');
    return;
end

% --- Executes on button press in saveAllDataButton.
function saveAllDataButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to saveAllDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.saveAllDataButton,'Enable','off')
set(handles.saveAllDataButton,'String','Wait please...')
pause(0.01);
   
app = getappdata(0, 'app');

ElgE1   = app.elongationImage;
CE1     = app.curvatureImage;
AE1     = app.verticalAngleImage;
RE1     = app.radiusImage;

    
% To open the directory who the user want to save the data
[fileName, pathName] = uiputfile('*.*', 'Create a directory to save your data');
nameDir = fullfile(pathName, fileName);

if pathName == 0
    warning('Select a file please');
    return;
end

disp('Saving...');

mkdir(nameDir);
fileName = 'data.mat';
nameData = fullfile(nameDir, fileName);

save(nameData, 'app');

n = length(dirPicture);

pathElongation = fullfile(nameDir,'dataElongation.csv');
pathAngle = fullfile(nameDir,'dataAngle.csv');
pathCurvature = fullfile(nameDir,'dataCurvature.csv');
pathRadius = fullfile(nameDir,'dataRadius.csv');

cols = cell(n,1);
for i = 1 : n
    cols{i} = strcat('picture', num2str(i));
end

colsElongation = cell(n-2,1);
for i = 2 : n-1
    colsElongation{i - 1} = strcat('picture', num2str(i));
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
  
set(handles.saveAllDataButton,'Enable','on')
set(handles.saveAllDataButton,'String','Save all data')


% --- Executes on button press in computeComposedKymographButton.
function computeComposedKymographButton_Callback(hObject, eventdata, handles)%#ok<INUSD>
% hObject    handle to computeComposedKymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
    
delete(gcf);

StartComposedElongation(app);
