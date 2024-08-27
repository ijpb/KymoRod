function varargout = SelectInputImagesDialog(varargin)
% SELECTINPUTIMAGESDIALOG MATLAB code for SelectInputImagesDialog.fig
%      SELECTINPUTIMAGESDIALOG, by itself, creates a new SELECTINPUTIMAGESDIALOG or raises the existing
%      singleton*.
%
%      H = SELECTINPUTIMAGESDIALOG returns the handle to a new SELECTINPUTIMAGESDIALOG or the handle to
%      the existing singleton*.
%
%      SELECTINPUTIMAGESDIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTINPUTIMAGESDIALOG.M with the given input arguments.
%
%      SELECTINPUTIMAGESDIALOG('Property','Value',...) creates a new SELECTINPUTIMAGESDIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectInputImagesDialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectInputImagesDialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectInputImagesDialog

% Last Modified by GUIDE v2.5 12-Jun-2015 17:33:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectInputImagesDialog_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectInputImagesDialog_OutputFcn, ...
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


% --- Executes just before SelectInputImagesDialog is made visible.
function SelectInputImagesDialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectInputImagesDialog (see VARARGIN)

% check input validity
if nargin ~= 4 || ~isa(varargin{1}, 'KymoRodData')
    error('Requires an KymoRodData object as input argument');
end

app = varargin{1};
setappdata(0, 'app', app);

app.logger.info('SelectInputImagesDialog.m', ...
    'Open dialog "SelectInputImagesDialog"');

% setup figure menu
gui = KymoRodGui.getInstance();
buildFigureMenu(gui, hObject, app);

% some gui listener adjustments
set(handles.inputImagesPanel, 'SelectionChangeFcn', ...
    @channelSelectionPanel_SelectionChangeFcn);

% if some data are already initialized, display widgets
if getProcessingStep(app) > ProcessingStep.None
    % update visibility and content of widgets
    makeAllWidgetsVisible(handles);
    updateFrameSliderBounds(handles);
    handles = updateFramePreview(handles);
end

% setup some widgets with current settings
imageList = app.analysis.InputImages.ImageList;
calib = app.analysis.InputImages.Calibration;
set(handles.filePatternEdit, 'String', imageList.FileNamePattern);
set(handles.spatialResolutionEdit, 'String', num2str(calib.PixelSize));
set(handles.spatialResolutionUnitEdit, 'String', calib.PixelSizeUnit);
set(handles.timeIntervalEdit, 'String', num2str(calib.TimeInterval));
set(handles.timeIntervalUnitEdit, 'String', calib.TimeIntervalUnit);

channelName = app.analysis.Parameters.MidlineImageChannel;
stringArray = get(handles.imageChannelPopup, 'String');
index = find(strcmpi(strtrim(cellstr(stringArray)), channelName));
if isempty(index)
    warning('could not find settings channel string in widgets options: %s', imageList.Channel);
    index = 1;
end
set(handles.imageChannelPopup, 'Value', index(1));
set(handles.lazyLoadingCheckbox, 'Value', imageList.LazyLoading);

% Choose default command line output for SelectInputImagesDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectInputImagesDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectInputImagesDialog_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Menu management

function mainFrameMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to mainFrameMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

app = getappdata(0, 'app');
delete(gcf);
KymoRodMenuDialog(app);


%% Input directory selection

% --- Executes on button press in chooseInputImagesButton.
function chooseInputImagesButton_Callback(hObject, eventdata, handles)
% To select the images from a directory

% extract app data
app = getappdata(0, 'app');

% open a dialog to select input image folder, restricting type to images
folderName = app.analysis.InputImages.ImageList.Directory;
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

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change input image folder to ' folderName]);

% update inner variables and GUI
set(handles.inputImageFolderEdit, 'String', folderName);
app.analysis.InputImages.ImageList.Directory = folderName;

% keep folder name is users preferences
gui = kymorod.gui.KymoRodGui.getInstance();
gui.UserPrefs.LastOpenDir = folderName;

if isfield(handles, 'currentFrameImage')
    handles = rmfield(handles, 'currentFrameImage');
end

updateImageNameList(handles);


% --- Executes on button change in channelSelectionPanel
function channelSelectionPanel_SelectionChangeFcn(hObject, eventdata)
% this function is used to catch selection of radiobuttons in selection panel


function filePatternEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of filePatternEdit as a double

app = getappdata(0, 'app');
string = get(handles.filePatternEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change input images file pattern to ' string]);

disp(['update file pattern: ' string]);

app.analysis.InputImages.ImageList.FileNamePattern = string;
gui = KymoRodGui.getInstance();
gui.userPrefs.inputImagesFilePattern = string;

updateImageNameList(handles);


% --- Executes during object creation, after setting all properties.
function filePatternEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in imageChannelPopup.
function imageChannelPopup_Callback(hObject, eventdata, handles)
% hObject    handle to imageChannelPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageChannelPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageChannelPopup

app = getappdata(0, 'app');
stringArray = get(handles.imageChannelPopup, 'String');
value = get(handles.imageChannelPopup, 'Value');
channelString = char(strtrim(stringArray(value,:)));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change image segmentation channel to ' channelString]);

app.analysis.Parameters.MidlineImageChannel = string;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.imageSegmentationChannel = channelString;


% --- Executes during object creation, after setting all properties.
function imageChannelPopup_CreateFcn(hObject, eventdata, handles)
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

app.logger.info('SelectInputImagesDialog.m', ...
    'Update image name list');

hDialog = msgbox(...
    {'Reading Image File Infos,', 'Please wait...'}, ...
    'Read Images');

% read new list of image names, used to compute frame number
fprintf('Read image name list...');
imageList = app.analysis.InputImages.ImageList;
computeFileNameList(imageList);
fprintf(' done\n');

if ishandle(hDialog)
    close(hDialog);
end

if isempty(imageList.FileNameList)
    errordlg({'The chosen directory contains no file.', ...
        'Please choose another one'}, ...
        'Empty Directory Error', 'modal');
    
    % disable preview and other settings
    set(handles.calibrationPanel, 'Visible', 'Off');
    set(handles.frameSelectionPanel, 'Visible', 'Off');
    set(handles.currentFrameLabel, 'Visible', 'Off');
    cla(handles.currentFrameAxes);
    set(handles.currentFrameAxes, 'Visible', 'Off');
    set(handles.framePreviewSlider, 'Visible', 'Off');
    set(handles.selectImagesButton, 'Visible', 'On');

    return;
end

setProcessingStep(app, ProcessingStep.Selection);

% choose to display color image selection
img = imread(fullfile(imageList.Directory, imageList.FileNameList{1}));
if ismatrix(img)
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

% init image selection indices
frameNumber = length(imageList.FileNameList);
imageList.IndexFirst = 1;
imageList.IndexLast = frameNumber;
imageList.IndexStep = 1;

makeAllWidgetsVisible(handles);

updateFrameSliderBounds(handles);
handles = updateFramePreview(handles);

guidata(handles.figure1, handles);


function makeAllWidgetsVisible(handles)

% update widgets with app information
app = getappdata(0, 'app');
imageList = app.analysis.InputImages.ImageList;
calib = app.analysis.InputImages.Calibration;

% show all panels
set(handles.inputImagesPanel, 'Visible', 'On');
set(handles.calibrationPanel, 'Visible', 'On');
set(handles.frameSelectionPanel, 'Visible', 'On');

% update input data widgets
set(handles.inputImageFolderEdit, 'String', imageList.Directory);
set(handles.filePatternEdit, 'String', imageList.FileNamePattern);

% choose to display color image selection
img = imread(fullfile(imageList.Directory, imageList.FileNameList{1}));
if ismatrix(img)
    set(handles.imageChannelLabel, 'Enable', 'Off');
    set(handles.imageChannelPopup, 'Enable', 'Off');
else
    set(handles.imageChannelLabel, 'Enable', 'On');
    set(handles.imageChannelPopup, 'Enable', 'On');
end

% update calibration widgets
set(handles.spatialResolutionEdit, 'String', num2str(calib.PixelSize));
set(handles.timeIntervalEdit, 'String', num2str(calib.TimeInterval));

% display image preview
set(handles.currentFrameLabel, 'Visible', 'On');
set(handles.currentFrameAxes, 'Visible', 'On');

frameSelectionHandles = [...
    handles.firstFrameIndexLabel, handles.firstFrameIndexEdit, ...
    handles.lastFrameIndexLabel, handles.lastFrameIndexEdit, ...
    handles.frameIndexStepLabel, handles.frameIndexStepEdit  ];

nFiles = length(imageList.FileNameList);
if imageList.IndexFirst == 1 && imageList.IndexLast == nFiles && imageList.IndexStep == 1
    set(handles.keepAllFramesRadioButton, 'Value', 1);
    set(handles.selectFrameIndicesRadioButton, 'Value', 0);
    set(frameSelectionHandles, 'Visible', 'Off');
else
    set(handles.keepAllFramesRadioButton, 'Value', 0);
    set(handles.selectFrameIndicesRadioButton, 'Value', 1);
    set(frameSelectionHandles, 'Visible', 'On');
end

string = sprintf('Keep All Frames (%d)', nFiles);
set(handles.keepAllFramesRadioButton, 'String', string);
string = sprintf('Select a range among the %d frames', nFiles);
set(handles.selectFrameIndicesRadioButton, 'String', string);

set(handles.firstFrameIndexEdit, 'String', num2str(imageList.IndexFirst));
set(handles.lastFrameIndexEdit, 'String', num2str(imageList.IndexLast));
set(handles.frameIndexStepEdit, 'String', num2str(imageList.IndexStep));

set(handles.wholeWorkflowButton, 'Visible', 'On');
set(handles.selectImagesButton, 'Visible', 'On');


%% Calibration section

function spatialResolutionEdit_Callback(hObject, eventdata, handles)
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionEdit as a double

app = getappdata(0, 'app');
calib = app.analysis.InputImages.Calibration;
resolString = get(handles.spatialResolutionEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change spatial resolution to ' resolString]);

resol = str2double(resolString);
calib.PixelSize = resol;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.pixelSize = resol;

% --- Executes during object creation, after setting all properties.
function spatialResolutionEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function spatialResolutionUnitEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to spatialResolutionUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionUnitEdit as a double

app = getappdata(0, 'app');
calib = app.analysis.InputImages.Calibration;
unitString = get(handles.spatialResolutionUnitEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change spatial resolution unit to ' unitString]);

calib.PixelSizeUnit = unitString;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.pixelSizeUnit = unitString;

% --- Executes during object creation, after setting all properties.
function spatialResolutionUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatialResolutionUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeIntervalEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalEdit as a double

app = getappdata(0, 'app');
calib = app.analysis.InputImages.Calibration;
timeString = get(handles.timeIntervalEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change time interval between frames to ' timeString]);

time = str2double(timeString);
calib.TimeInterval = time;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.timeInterval = time;

% --- Executes during object creation, after setting all properties.
function timeIntervalEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeIntervalUnitEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to timeIntervalUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalUnitEdit as a double

app = getappdata(0, 'app');
calib = app.analysis.InputImages.Calibration;
unitString = get(handles.timeIntervalUnitEdit, 'String');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change time interval unit to ' unitString]);

calib.TimeIntervalUnit = unitString;

gui = KymoRodGui.getInstance();
gui.userPrefs.settings.timeIntervalUnit = unitString;


% --- Executes during object creation, after setting all properties.
function timeIntervalUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeIntervalUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in keepAllFramesRadioButton.
function keepAllFramesRadioButton_Callback(hObject, eventdata, handles) 
% hObject    handle to keepAllFramesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of keepAllFramesRadioButton
set(handles.selectImagesButton, 'Visible', 'On');

% make file selection widgets invisible
set(handles.firstFrameIndexLabel, 'Visible', 'Off');
set(handles.lastFrameIndexLabel, 'Visible', 'Off');
set(handles.frameIndexStepLabel, 'Visible', 'Off');
set(handles.firstFrameIndexEdit, 'Visible', 'Off');
set(handles.lastFrameIndexEdit, 'Visible', 'Off');
set(handles.frameIndexStepEdit, 'Visible', 'Off');

% select appropriate radio button
set(handles.keepAllFramesRadioButton, 'Value', 1);
set(handles.selectFrameIndicesRadioButton, 'Value', 0);

app = getappdata(0, 'app');
setProcessingStep(app, ProcessingStep.Selection);

guidata(hObject, handles);

% --- Executes on button press in selectFrameIndicesRadioButton.
function selectFrameIndicesRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectFrameIndicesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectFrameIndicesRadioButton
set(handles.selectImagesButton, 'Visible', 'On');

% make file selection widgets visible
set(handles.firstFrameIndexLabel, 'Visible', 'On');
set(handles.lastFrameIndexLabel, 'Visible', 'On');
set(handles.frameIndexStepLabel, 'Visible', 'On');
set(handles.firstFrameIndexEdit, 'Visible', 'On');
set(handles.lastFrameIndexEdit, 'Visible', 'On');
set(handles.frameIndexStepEdit, 'Visible', 'On');

% select appropriate radio button
set(handles.keepAllFramesRadioButton,'Value', 0);
set(handles.selectFrameIndicesRadioButton, 'Value', 1);

app = getappdata(0, 'app');
setProcessingStep(app, ProcessingStep.Selection);

guidata(hObject, handles);


function firstFrameIndexEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to firstFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of firstFrameIndexEdit as a double

app = getappdata(0, 'app');
imageList = app.analysis.InputImages.ImageList;
string = strtrim(get(hObject, 'String'));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change first frame index to ' string]);

% convert string to valid index
val = parseValue(string);
val = max(val, 1);

% update app data
imageList.IndexFirst = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);

% --- Executes during object creation, after setting all properties.
function firstFrameIndexEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lastFrameIndexEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to lastFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of lastFrameIndexEdit as a double

app = getappdata(0, 'app');
imageList = app.analysis.InputImages.ImageList;
string = strtrim(get(hObject, 'String'));

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change last frame index to ' string]);

% compute number of image files
nFiles = getFileNumber(app);

val = parseValue(string);
val = min(val, nFiles);

imageList.IndexLast = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function lastFrameIndexEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function frameIndexStepEdit_Callback(hObject, eventdata, handles) 
% hObject    handle to frameIndexStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameIndexStepEdit as text
%        str2double(get(hObject,'String')) returns contents of frameIndexStepEdit as a double

app = getappdata(0, 'app');

string = strtrim(get(hObject, 'String'));
app.logger.info('SelectInputImagesDialog.m', ...
    ['Change frame index step to ' string]);

imageList = app.analysis.InputImages.ImageList;

val = parseValue(string);

imageList.IndexStep = val;
setProcessingStep(app, ProcessingStep.Selection);

updateFrameSliderBounds(handles);
updateFramePreview(handles);

% --- Executes during object creation, after setting all properties.
function frameIndexStepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frameIndexStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function val = parseValue(string)

if isempty(string)
    warning('empty string');
    string = '';
end

val = str2double(string);
if isnan(val)
    warning(['could not parse value: ' string]);
    val = 0;
end


function handles = updateFramePreview(handles)
% Determine the current frame from widgets, and display it

% extract app data
app = getappdata(0, 'app');
imageList = app.analysis.InputImages.ImageList;

% extract global data
folderName  = imageList.Directory;
fileList = dir(fullfile(folderName, imageList.FileNamePattern));

% ensure no directory is load (can happen under linux)
fileList = fileList(~[fileList.isdir]);

% determine indices of files to read
indices = selectedFileIndices(imageList);
frameCount = length(indices);

% extract index of first frame to display
frameIndex = min(app.analysis.CurrentFrameIndex, length(indices));

% determine index of file to read
if frameIndex > 0
    fileIndex = indices(frameIndex);
else
    fileIndex = 1;
end

% read image to display
currentImageName = fileList(fileIndex).name;
img = imread(fullfile(folderName, currentImageName));

if ~ismatrix(img)
    switch app.analysis.Parameters.MidlineImageChannel
        case 'red'; img = img(:,:,1);
        case 'green'; img = img(:,:,2);
        case 'blue'; img = img(:,:,3);
    end
end
% keep image size
app.analysis.InputImages.ImageSize = [size(img, 1) size(img, 2)];

% eventually converts to uint8
if isa(img, 'uint16') && ndims(img) == 2 %#ok<ISMAT>
    img = kymorod.core.image.AdjustDynamic(img, .1);
end

% display current frame image
if isfield(handles, 'currentFrameImage')
    set(handles.currentFrameImage, 'CData', img);
else
    axes(handles.currentFrameAxes);
    handles.currentFrameImage = imshow(img);
    set(handles.currentFrameAxes, 'CLim', [0 255]);
end

% display the index and name of current frame
string = sprintf('frame %d / %d (%s)', frameIndex, frameCount, currentImageName);
set(handles.currentFrameLabel, 'String', string);


% --- Executes on button press in lazyLoadingCheckbox.
function lazyLoadingCheckbox_Callback(hObject, eventdata, handles) 
% hObject    handle to lazyLoadingCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lazyLoadingCheckbox

value = get(handles.lazyLoadingCheckbox, 'Value');
app = getappdata(0, 'app');

app.logger.info('SelectInputImagesDialog.m', ...
    ['Change lazy loading to ' char(value)]);

flag = value > 0;
app.analysis.InputImages.ImageList.LazyLoading = flag;
gui = KymoRodGui.getInstance();
gui.userPrefs.inputImagesLazyLoading = flag;


% --- Executes on slider movement.
function framePreviewSlider_Callback(hObject, eventdata, handles)
% hObject    handle to framePreviewSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');
frameIndex = round(get(handles.framePreviewSlider, 'Value'));
app.analysis.CurrentFrameIndex = frameIndex;

updateFramePreview(handles);


% --- Executes during object creation, after setting all properties.
function framePreviewSlider_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
% hObject    handle to framePreviewSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateFrameSliderBounds(handles)

% extract app data
app = getappdata(0, 'app');

% determine indices of files to read
indices = selectedFileIndices(app.analysis.InputImages.ImageList);
frameCount = length(indices);

frameIndex = min(app.analysis.CurrentFrameIndex, frameCount);

set(handles.framePreviewSlider, 'Visible', 'Off');
set(handles.framePreviewSlider, 'Value', frameIndex);
set(handles.framePreviewSlider, 'Min', 1);
set(handles.framePreviewSlider, 'Max', max(frameCount, 1));
% setup slider such that 1 image is changed at a time
step1 = 1 / max(frameCount, 1);
step2 = max(min(10 / frameCount, .5), step1);
set(handles.framePreviewSlider, 'SliderStep', [step1 step2]);

if frameCount > 1
    set(handles.framePreviewSlider, 'Visible', 'On');
end


%% Validation buttons

% --- Executes on button press in wholeWorkflowButton.
function wholeWorkflowButton_Callback(hObject, eventdata, handles)
% hObject    handle to wholeWorkflowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extract global data
app = getappdata(0, 'app');
app.logger.info('SelectInputImagesDialog.m', ...
    'Compute the whole workflow');

computeAll(app);

delete(gcf);
DisplayKymograph(app);


% --- Executes on button press in selectImagesButton.
function selectImagesButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% readAllImages();

% extract global data
app = getappdata(0, 'app');

loadImageData(app);
app.analysis.IntensityImages = app.analysis.InputImages.clone();

nFrames = frameNumber(app);
app.analysis.CurrentFrameIndex = min(app.analysis.CurrentFrameIndex, nFrames);
delete(gcf);

ChooseThresholdDialog(app);

