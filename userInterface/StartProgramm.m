function varargout = StartProgramm(varargin)
% STARTPROGRAMM MATLAB code for StartProgramm.fig
%      STARTPROGRAMM, by itself, creates a new STARTPROGRAMM or raises the existing
%      singleton*.
%
%      H = STARTPROGRAMM returns the handle to a new STARTPROGRAMM or the handle to
%      the existing singleton*.
%
%      STARTPROGRAMM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STARTPROGRAMM.M with the given input arguments.
%
%      STARTPROGRAMM('Property','Value',...) creates a new STARTPROGRAMM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StartProgramm_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StartProgramm_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StartProgramm

% Last Modified by GUIDE v2.5 15-Oct-2014 16:49:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StartProgramm_OpeningFcn, ...
                   'gui_OutputFcn',  @StartProgramm_OutputFcn, ...
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


% --- Executes just before StartProgramm is made visible.
function StartProgramm_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StartProgramm (see VARARGIN)

% Choose default command line output for StartProgramm
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StartProgramm wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StartProgramm_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in frameEditButton.
function frameEditButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to frameEditButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of frameEditButton
set(handles.frameEditButton,'Value',1);
set(handles.frameSelectButton,'Value',0);
set(handles.elongationButton,'Value',0);
set(handles.specificElongationButton,'Value',0);
set(handles.displayKymographButton,'Value',0);

% --- Executes on button press in frameSelectButton.
function frameSelectButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to frameSelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of frameSelectButton
set(handles.frameEditButton,'Value',0);
set(handles.frameSelectButton,'Value',1);
set(handles.elongationButton,'Value',0);
set(handles.specificElongationButton,'Value',0);
set(handles.displayKymographButton,'Value',0);


% --- Executes on button press in elongationButton.
function elongationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to elongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of elongationButton
set(handles.frameEditButton,'Value',0);
set(handles.frameSelectButton,'Value',0);
set(handles.elongationButton,'Value',1);
set(handles.specificElongationButton,'Value',0);
set(handles.displayKymographButton,'Value',0);


% --- Executes on button press in specificElongationButton.
function specificElongationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to specificElongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of specificElongationButton
set(handles.frameEditButton,'Value',0);
set(handles.frameSelectButton,'Value',0);
set(handles.elongationButton,'Value',0);
set(handles.specificElongationButton,'Value',1);
set(handles.displayKymographButton,'Value',0);


% --- Executes on button press in displayKymographButton.
function displayKymographButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to displayKymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayKymographButton
set(handles.frameEditButton,'Value',0);
set(handles.frameSelectButton,'Value',0);
set(handles.elongationButton,'Value',0);
set(handles.specificElongationButton,'Value',0);
set(handles.displayKymographButton,'Value',1);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.frameEditButton,'Value') == 1
    delete(gcf);
    StartRGB();
elseif get(handles.frameSelectButton,'Value') == 1
    delete(gcf);
    StartSkeleton();
elseif get(handles.elongationButton,'Value') == 1
    delete(gcf);
    StartElongation();
elseif get(handles.specificElongationButton,'Value') == 1
    delete(gcf);
    StartComposedElongation();
elseif get(handles.displayKymographButton,'Value') == 1
    delete(gcf);
    DisplayKymograph();
end
