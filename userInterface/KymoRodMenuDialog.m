function varargout = KymoRodMenuDialog(varargin)
% KYMORODMENUDIALOG MATLAB code for KymoRodMenuDialog.fig
%      KYMORODMENUDIALOG, by itself, creates a new KYMORODMENUDIALOG or raises the existing
%      singleton*.
%
%      H = KYMORODMENUDIALOG returns the handle to a new KYMORODMENUDIALOG or the handle to
%      the existing singleton*.
%
%      KYMORODMENUDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KYMORODMENUDIALOG.M with the given input arguments.
%
%      KYMORODMENUDIALOG('Property','Value',...) creates a new KYMORODMENUDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KymoRodMenuDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KymoRodMenuDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KymoRodMenuDialog

% Last Modified by GUIDE v2.5 25-Mar-2015 12:31:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KymoRodMenuDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @KymoRodMenuDialog_OutputFcn, ...
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


% --- Executes just before KymoRodMenuDialog is made visible.
function KymoRodMenuDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KymoRodMenuDialog (see VARARGIN)

% Choose default command line output for KymoRodMenuDialog
handles.output = hObject;

if nargin == 4 && isa(varargin{1}, 'KymoRod')
    app = varargin{1};
elseif nargin == 3
    app = KymoRod();
end

setappdata(0, 'app', app);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KymoRodMenuDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = KymoRodMenuDialog_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in imagesSelectionButton.
function imagesSelectionButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to imagesSelectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of imagesSelectionButton

set(handles.imagesSelectionButton,      'Value', 1);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in validateThresholdButton.
function validateThresholdButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateThresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateThresholdButton

set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 1);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in validateContourButton.
function validateContourButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateContourButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateContourButton

set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 1);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
set(handles.displayKymographButton,     'Value', 0);

% --- Executes on button press in validateSkeletonButton.
function validateSkeletonButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to validateSkeletonButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of validateSkeletonButton

set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 1);
set(handles.elongationButton,           'Value', 0);
set(handles.displayKymographButton,     'Value', 0);

% --- Executes on button press in elongationButton.
function elongationButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to elongationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of elongationButton

set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 1);
set(handles.displayKymographButton,     'Value', 0);


% --- Executes on button press in displayKymographButton.
function displayKymographButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to displayKymographButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayKymographButton

set(handles.imagesSelectionButton,      'Value', 0);
set(handles.validateThresholdButton,    'Value', 0);
set(handles.validateContourButton,      'Value', 0);
set(handles.validateSkeletonButton,     'Value', 0);
set(handles.elongationButton,           'Value', 0);
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
    SmoothContourDialog(app);
    
elseif get(handles.validateSkeletonButton, 'Value') == 1
    delete(gcf);
    ValidateSkeleton(app);
    
elseif get(handles.elongationButton, 'Value') == 1
    delete(gcf);
    ChooseElongationSettingsDialog(app);
    
elseif get(handles.displayKymographButton, 'Value') == 1
    delete(gcf);
    DisplayKymograph(app);
end
