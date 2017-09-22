function varargout = KymoRodStartupDialog(varargin)
% KYMORODSTARTUPDIALOG MATLAB code for KymoRodStartupDialog.fig
%      KYMORODSTARTUPDIALOG, by itself, creates a new KYMORODSTARTUPDIALOG or raises the existing
%      singleton*.
%
%      H = KYMORODSTARTUPDIALOG returns the handle to a new KYMORODSTARTUPDIALOG or the handle to
%      the existing singleton*.
%
%      KYMORODSTARTUPDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KYMORODSTARTUPDIALOG.M with the given input arguments.
%
%      KYMORODSTARTUPDIALOG('Property','Value',...) creates a new KYMORODSTARTUPDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before KymoRodStartupDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to KymoRodStartupDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help KymoRodStartupDialog

% Last Modified by GUIDE v2.5 11-Jun-2015 18:06:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @KymoRodStartupDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @KymoRodStartupDialog_OutputFcn, ...
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


% --- Executes just before KymoRodStartupDialog is made visible.
function KymoRodStartupDialog_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to KymoRodStartupDialog (see VARARGIN)

% Choose default command line output for KymoRodStartupDialog
handles.output = hObject;

set(hObject, 'Name', 'KymoRod Startup Dialog');

% setup the demo image
img = imread('kymorod-splash.png');
imshow(img, 'parent', handles.splashImageAxis);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes KymoRodStartupDialog wait for user response (see UIRESUME)
% uiwait(handles.mainFigure);


% --- Outputs from this function are returned to the command line.
function varargout = KymoRodStartupDialog_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadAnalysisButton.
function loadAnalysisButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to loadAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFigure);

gui = KymoRodGui.getInstance();
try
    app = loadKymoRodAppData(gui);
    
catch ME
    logger = log4m.getLogger;
    logger.error(mfilename, ME.message);
    h = errordlg(ME.message, 'Loading Error', 'modal');
    uiwait(h);
    KymoRodStartupDialog();
    return;
end

% if cancel button was clicked, app result is empty, and we re-open the
% dialog.
if isempty(app)
    KymoRodStartupDialog();
    return;
end

% assumes only 'complete' analyses can be saved, and call the dialog for
% showing results
displayProcessingDialog(gui, app);


% --- Executes on button press in newAnalysisButton.
function newAnalysisButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to newAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFigure);

% create new empty application data structure
app = KymoRod();

% initialize with default directory
path = fileparts(mfilename('fullpath'));
app.inputImagesDir = fullfile(path, '..', '..', '..', 'sampleImages', '01');

% open first dialog of application
SelectInputImagesDialog(app);


% --- Executes on button press in loadSettingsButton.
function loadSettingsButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to loadSettingsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open a dialog to select input image folder, restricting type to images
[fileName, folderName] = uigetfile(...
    {'*-settings.txt', 'KymoRod Settings File';...
    '*.*', 'All Files' }, ...
    'Select Settings File');
      
% check if cancel button was selected
if fileName == 0
    return;
end

close(handles.mainFigure);

logger = log4m.getLogger;
logger.info('KymoRodStartupDialog', ...
    ['Read settings from file: ' fullfile(folderName, fileName)]);

% read settings
settings = KymoRodSettings.read(fullfile(folderName, fileName));

% create new application, and setup its settings
app = KymoRod;
app.settings = settings;

% choose input images
SelectInputImagesDialog(app);


% --- Executes on button press in quitButton.
function quitButton_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to quitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.mainFigure);
