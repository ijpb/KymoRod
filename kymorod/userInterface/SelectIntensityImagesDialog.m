function varargout = SelectIntensityImagesDialog(varargin)
% SELECTINTENSITYIMAGESDIALOG MATLAB code for SelectIntensityImagesDialog.fig
%      SELECTINTENSITYIMAGESDIALOG, by itself, creates a new SELECTINTENSITYIMAGESDIALOG or raises the existing
%      singleton*.
%
%      H = SELECTINTENSITYIMAGESDIALOG returns the handle to a new SELECTINTENSITYIMAGESDIALOG or the handle to
%      the existing singleton*.
%
%      SELECTINTENSITYIMAGESDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTINTENSITYIMAGESDIALOG.M with the given input arguments.
%
%      SELECTINTENSITYIMAGESDIALOG('Property','Value',...) creates a new SELECTINTENSITYIMAGESDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectIntensityImagesDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectIntensityImagesDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectIntensityImagesDialog

% Last Modified by GUIDE v2.5 16-Mar-2018 14:54:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectIntensityImagesDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectIntensityImagesDialog_OutputFcn, ...
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


% --- Executes just before SelectIntensityImagesDialog is made visible.
function SelectIntensityImagesDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectIntensityImagesDialog (see VARARGIN)

% check input validity
if nargin ~= 4 || ~isa(varargin{1}, 'KymoRodData')
    error('Requires a KymoRodData object as input argument');
end

app = varargin{1};
setappdata(0, 'app', app);

app.logger.info('SelectIntensityImagesDialog.m', ...
    'Open dialog "SelectIntensityImagesDialog"');

% setup figure menu
gui = KymoRodGui.getInstance();
buildFigureMenu(gui, hObject, app);

% populate widgets
imageList = app.analysis.IntensityImages.ImageList;
set(handles.inputImageFolderEdit, 'String', imageList.Directory);
set(handles.filePatternEdit, 'String', imageList.FileNamePattern);
set(handles.imageChannelPopup, 'String', app.analysis.Parameters.IntensityImageChannel);

% some gui listener adjustments
set(handles.inputImagesPanel, 'SelectionChangeFcn', ...
    @channelSelectionPanel_SelectionChangeFcn);

% Choose default command line output for SelectIntensityImagesDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectIntensityImagesDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectIntensityImagesDialog_OutputFcn(hObject, eventdata, handles) %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Menu management

function mainFrameMenuItem_Callback(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


%% Input directory selection

% --- Executes on button press in chooseImagesDirectoryButton.
function chooseImagesDirectoryButton_Callback(hObject, eventdata, handles)  %#ok<INUSL>
% To select the images from a directory

% extract app data
app = getappdata(0, 'app');

% open a dialog to select input image folder, restricting type to images
folderName = app.analysis.IntensityImages.ImageList.Directory;
[fileName, folderName] = uigetfile(...
    {'*.tif;*.jpg;*.png;*.gif', 'All Image Files';...
    '*.tif;*.tiff;*.gif', 'Tagged Image Files (*.tif)';...
    '*.jpg;', 'JPEG images (*.jpg)';...
    '*.*','All Files' }, ...
    'Select Input Folder', ...
    fullfile(folderName, '*.*'));
      
% check if cancel button was selected
if fileName == 0
    return;
end

app.logger.info('SelectIntensityImagesDialog.m', ...
    ['Change intensity image folder to ' folderName]);

% update inner variables and GUI
set(handles.inputImageFolderEdit, 'String', folderName);
app.analysis.IntensityImages.ImageList.Directory = folderName;

updateImageNameList(handles);


% --- Executes on button change in channelSelectionPanel
function channelSelectionPanel_SelectionChangeFcn(hObject, eventdata)%#ok<INUSL>
% this function is used to catch selection of radiobuttons in selection panel


function filePatternEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of filePatternEdit as a double

app = getappdata(0, 'app');
string = get(handles.filePatternEdit, 'String');

app.logger.info('SelectIntensityImagesDialog.m', ...
    ['Change intensity images file pattern to ' string]);

app.analysis.IntensityImages.ImageList.FileNamePattern = string;
disp(['update file pattern: ' string]);

updateImageNameList(handles);


% --- Executes during object creation, after setting all properties.
function filePatternEdit_CreateFcn(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imageChannelPopup.
function imageChannelPopup_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to imageChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageChannelPopup

app = getappdata(0, 'app');
stringArray = get(handles.imageChannelPopup, 'String');
value = get(handles.imageChannelPopup, 'Value');
channelString = char(strtrim(stringArray(value,:)));

app.logger.info('SelectIntensityImagesDialog.m', ...
    ['Change intensity image channel to ' channelString]);

app.analysis.Parameters.IntensityImageChannel = channelString;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.intensityImagesChannel = channelString;


% --- Executes during object creation, after setting all properties.
function imageChannelPopup_CreateFcn(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to imageChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateImageNameList(handles)
% should be called after change of input directory, or file pattern

% extract app data
app = getappdata(0, 'app');

app.logger.info('SelectIntensityImagesDialog.m', ...
    'Update image name list');

hDialog = msgbox(...
    {'Reading Image File Infos,', 'Please wait...'}, ...
    'Read Images');

% read new list of image names, used to compute frame number
imageList = app.analysis.IntensityImages.ImageList;
imageList.computeImageFileNameList();
imageNames = imageList.ImageFileNameList;

if ishandle(hDialog)
    close(hDialog);
end

if isempty(imageNames)
    errordlg({'The chosen directory contains no file.', ...
        'Please choose another one'}, ...
        'Empty Directory Error', 'modal');
    
    % disable preview and other settings
    set(handles.selectImagesButton, 'Visible', 'On');
    return;
end

% choose to display color image selection
info = imfinfo(fullfile(imageList.Directory, imageNames{1}));
if strcmpi(info(1).ColorType, 'grayscale')
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

makeAllWidgetsVisible(handles);


guidata(handles.figure1, handles);


function makeAllWidgetsVisible(handles)

% update widgets with app information
app = getappdata(0, 'app');

% show all panels
set(handles.inputImagesPanel, 'Visible', 'On');

% update input data widgets
imageList = app.analysis.IntensityImages.ImageList;
set(handles.inputImageFolderEdit, 'String', imageList.Directory);
set(handles.filePatternEdit, 'String', imageList.FileNamePattern);

% choose to display color image selection
info = imfinfo(fullfile(imageList.Directory, imageList.ImageFileNameList{1}));
if strcmpi(info(1).ColorType, 'grayscale')
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

% set(handles.wholeWorkflowButton, 'Visible', 'On');
set(handles.selectImagesButton, 'Visible', 'On');


%% Validation button

% --- Executes on button press in selectImagesButton.
function selectImagesButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to selectImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% readAllImages();

% extract global data
app = getappdata(0, 'app');

%  compute intensity kymograph and display it
computeIntensityKymograph(app);

delete(handles.figure1);
DisplayKymograph(app);

