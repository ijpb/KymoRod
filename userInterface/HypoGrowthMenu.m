function varargout = HypoGrowthMenu(varargin)
% HYPOGROWTHMENU MATLAB code for HypoGrowthMenu.fig
%      HYPOGROWTHMENU, by itself, creates a new HYPOGROWTHMENU or raises the existing
%      singleton*.
%
%      H = HYPOGROWTHMENU returns the handle to a new HYPOGROWTHMENU or the handle to
%      the existing singleton*.
%
%      HYPOGROWTHMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYPOGROWTHMENU.M with the given input arguments.
%
%      HYPOGROWTHMENU('Property','Value',...) creates a new HYPOGROWTHMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HypoGrowthMenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HypoGrowthMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HypoGrowthMenu

% Last Modified by GUIDE v2.5 28-Oct-2014 12:10:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HypoGrowthMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @HypoGrowthMenu_OutputFcn, ...
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


% --- Executes just before HypoGrowthMenu is made visible.
function HypoGrowthMenu_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HypoGrowthMenu (see VARARGIN)

% Choose default command line output for HypoGrowthMenu
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    disp('Run HypoGrowthMenu using HypoGrowthAppData class');
    app = varargin{1};
elseif nargin == 3
    app = HypoGrowthAppData();
end

setappdata(0, 'app', app);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HypoGrowthMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HypoGrowthMenu_OutputFcn(hObject, eventdata, handles) %#ok
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
set(handles.frameEditButton,            'Value', 1);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);

% --- Executes on button press in imagesSelectionButton.
function imagesSelectionButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to imagesSelectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imagesSelectionButton
set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 1);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in validateThresholdButton.
function validateThresholdButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateThresholdButton

set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 1);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateContourButton

set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 1);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);

% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateSkeletonButton

set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 1);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);

% --- Executes on button press in elongationButton.
function elongationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to elongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of elongationButton

set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 1);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in specificElongationButton.
function specificElongationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to specificElongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of specificElongationButton

set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 1);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in displayKymographButton.
function displayKymographButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to displayKymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayKymographButton
set(handles.frameEditButton,            'Value', 0);
set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.specificElongationButton,   'Value', 0);
set(handles.displayKymographButton,     'Value', 1);


% --- Executes on button press in validationButton.
function validationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to validationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');

if get(handles.imagesSelectionButton, 'Value') == 1
    delete(gcf);
    SelectInputImagesDialog(app);
    
elseif get(handles.validateThresholdButton, 'Value') == 1
    delete(gcf);
    ChooseThresholdDialog(app);
    
elseif get(handles.validateContourButton, 'Value') == 1
    delete(gcf);
    ValidateContour(app);
    
elseif get(handles.validateSkeletonButton, 'Value') == 1
    delete(gcf);
    ValidateSkeleton(app);
    
elseif get(handles.elongationButton, 'Value') == 1
    delete(gcf);
    StartElongation(app);
    
elseif get(handles.specificElongationButton, 'Value') == 1
    delete(gcf);
    StartComposedElongation(app);
    
elseif get(handles.displayKymographButton, 'Value') == 1
    delete(gcf);
    DisplayKymograph(app);
end
