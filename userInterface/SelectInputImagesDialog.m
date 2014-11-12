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

% Last Modified by GUIDE v2.5 12-Nov-2014 14:37:52

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
function SelectInputImagesDialog_OpeningFcn(hObject, eventdata, handles, varargin)%#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectInputImagesDialog (see VARARGIN)

set(handles.inputImagesPanel, 'SelectionChangeFcn', ...
    @channelSelectionPanel_SelectionChangeFcn);

if nargin == 4 && isa(varargin{1}, 'HypoGrowthAppData')
    disp('init from HypoGrowthAppData');
    
    app = varargin{1};
    app.currentStep = 'selection';
    setappdata(0, 'app', app);
    
elseif nargin == 6 
    % TODO: adapt code below to the case app already contains images or settings
    col = varargin{1};
    set(handles.currentFrameLabel, 'Visible', 'On');
    set(handles.axis2Label, 'Visible', 'On');
    set(handles.currentFrameAxes, 'Visible', 'On');
    set(handles.axes2, 'Visible', 'On');
    set(handles.keepAllFramesRadioButton, 'Visible', 'On');
    set(handles.selectFramesIndicesRadioButton, 'Visible', 'On');
    
    nImages = length(col);
    
    set(handles.framePreviewSlider, 'Value', 1);
    set(handles.framePreviewSlider, 'Min', 1);
    set(handles.framePreviewSlider, 'Max', nImages - 1);
    set(handles.framePreviewSlider, 'Visible', 'On');
    
    % setup slider such that 1 image is changed at a time
    step1 = 1 / (nImages - 1);
    step2 = min(10 / (nImages - 1), .5);
    set(handles.framePreviewSlider, 'SliderStep', [step1 step2]);
    
    set(handles.framePreviewLabel, 'Visible', 'On');

    updateFramePreview(handles);

    string = sprintf('Select a range among the %d frames', nb);
    set(handles.selectFramesIndicesRadioButton, 'String', string);
    
    set(handles.selectImagesButton, 'Visible', 'On');
end

% Choose default command line output for SelectInputImagesDialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectInputImagesDialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectInputImagesDialog_OutputFcn(hObject, eventdata, handles) %#ok
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
HypoGrowthMenu(app);

%% Input directory selection

% --- Executes on button press in chooseInputImagesButton.
function chooseInputImagesButton_Callback(hObject, eventdata, handles)%#ok 
% To select the images from a directory

% extract app data
app = getappdata(0, 'app');

% folderName = getappdata(0, 'RepertoireImage');
folderName = app.inputImagesDir;
folderName = uigetdir(folderName);

% check if cancel button was selected
if folderName == 0;
    return;
end

set(handles.directoryNameEdit, 'String', folderName);
app.inputImagesDir = folderName;

filePattern = '*.*';
if get(handles.selectChannelRadioButton, 'Value') == 1;
    % keep only images starting with a given letter
    str = get(handles.filePatternEdit, 'String');
    if isempty(str)
        warning('Text area is empty');
        return;
    end
   
    filePattern = strcat(str, '*.*');
end

% list files in chosen directory
fileList = dir(fullfile(folderName, filePattern));
fileList = fileList(~[fileList.isdir]);

if isempty(fileList)
    errordlg({'The chosen directory contains no file.', ...
        'Please choose another one'}, ...
        'Empty Directory Error', 'modal')
    return;
end

frameNumber = length(fileList);

imageNames = cell(frameNumber, 1);
for i = 1:frameNumber
    imageNames{i} = fileList(i).name;
end

set(handles.inputImagesPanel, 'Visible', 'On');
set(handles.calibrationPanel, 'Visible', 'On');
set(handles.frameSelectionPanel, 'Visible', 'On');

set(handles.currentFrameLabel, 'Visible', 'On');
set(handles.currentFrameAxes, 'Visible', 'On');

set(handles.framePreviewSlider, 'Visible', 'Off');
set(handles.framePreviewSlider, 'Value', 1);
set(handles.framePreviewSlider, 'Min', 1);
set(handles.framePreviewSlider, 'Max', frameNumber);
% setup slider such that 1 image is changed at a time
step1 = 1 / frameNumber;
step2 = min(10 / frameNumber, .5);
set(handles.framePreviewSlider, 'SliderStep', [step1 step2]);
set(handles.framePreviewSlider, 'Visible', 'On');

string = sprintf('Keep All Frames (%d)', frameNumber);
set(handles.keepAllFramesRadioButton, 'String', string);
string = sprintf('Select a range among the %d frames', frameNumber);
set(handles.selectFramesIndicesRadioButton, 'String', string);

set(handles.selectImagesButton, 'Visible', 'On');

% save user data for future use
app.inputImagesDir = folderName;
app.inputImagesFilePattern = filePattern;
app.imageNameList = imageNames;
app.firstIndex = 1;
app.lastIndex = frameNumber;
app.indexStep = 1;

updateFramePreview(handles);

guidata(hObject, handles);


% --- Executes on button change in channelSelectionPanel
function channelSelectionPanel_SelectionChangeFcn(hObject, eventdata)
% this function is used to catch selection of radiobuttons in selection panel


function filePatternEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filePatternEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePatternEdit as text
%        str2double(get(hObject,'String')) returns contents of filePatternEdit as a double


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


%% Calibration section

function spatialResolutionEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to spatialResolutionEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatialResolutionEdit as text
%        str2double(get(hObject,'String')) returns contents of spatialResolutionEdit as a double

app = getappata(0, 'app');
resolString = get(handles.spatialResolutionEdit, 'String');
resol = str2double(resolString);
app.pixelSize = resol;


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


function timeIntervalEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to timeIntervalEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeIntervalEdit as text
%        str2double(get(hObject,'String')) returns contents of timeIntervalEdit as a double

app = getappata(0, 'app');

timeString = get(handles.timeIntervalEdit, 'String');
time = str2double(timeString);
app.timeInterval = time;

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


% --- Executes on slider movement.
function framePreviewSlider_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to framePreviewSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

app = getappdata(0, 'app');
frameIndex = round(get(handles.framePreviewSlider, 'Value'));
app.currentFrameIndex = frameIndex;

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


function firstFrameIndexEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to firstFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of firstFrameIndexEdit as a double

string = strtrim(get(hObject, 'String'));
val = parseValue(string);

app = getappdata(0, 'app');
app.firstIndex = val;

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



function lastFrameIndexEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to lastFrameIndexEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lastFrameIndexEdit as text
%        str2double(get(hObject,'String')) returns contents of lastFrameIndexEdit as a double

string = strtrim(get(hObject, 'String'));
val = parseValue(string);

app = getappdata(0, 'app');
app.lastIndex = val;

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



function frameIndexStepEdit_Callback(hObject, eventdata, handles) %#ok<INUSL>
% hObject    handle to frameIndexStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frameIndexStepEdit as text
%        str2double(get(hObject,'String')) returns contents of frameIndexStepEdit as a double

string = strtrim(get(hObject, 'String'));
val = parseValue(string);

app = getappdata(0, 'app');
app.indexStep = val;

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


% --- Executes on button press in keepAllFramesRadioButton.
function keepAllFramesRadioButton_Callback(hObject, eventdata, handles) %#ok<INUSL>
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
set(handles.selectFramesIndicesRadioButton, 'Value', 0);

guidata(hObject, handles);

% --- Executes on button press in selectFramesIndicesRadioButton.
function selectFramesIndicesRadioButton_Callback(hObject, eventdata, handles)%#ok
% hObject    handle to selectFramesIndicesRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selectFramesIndicesRadioButton
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
set(handles.selectFramesIndicesRadioButton, 'Value', 1);

guidata(hObject, handles);


function updateFrameSliderBounds(handles)

% extract app data
app = getappdata(0, 'app');

% determine indices of files to read
indices = app.firstIndex:app.indexStep:app.lastIndex;
frameNumber = length(indices);

frameIndex = min(app.currentFrameIndex, frameNumber);

set(handles.framePreviewSlider, 'Visible', 'Off');
set(handles.framePreviewSlider, 'Value', frameIndex);
set(handles.framePreviewSlider, 'Min', 1);
set(handles.framePreviewSlider, 'Max', frameNumber);
% setup slider such that 1 image is changed at a time
step1 = 1 / frameNumber;
step2 = min(10 / frameNumber, .5);
set(handles.framePreviewSlider, 'SliderStep', [step1 step2]);
set(handles.framePreviewSlider, 'Visible', 'On');


function updateFramePreview(handles)
% Determine the current frame from widgets, and display it

% extract app data
app = getappdata(0, 'app');

% extract global data
folderName  = app.inputImagesDir;
imageNames  = app.imageNameList;

% determine indices of files to read
indices = app.firstIndex:app.indexStep:app.lastIndex;
frameNumber = length(indices);

% extract index of first frame to display
frameIndex = min(app.currentFrameIndex, length(indices));

% read sample images
fileIndex = indices(frameIndex);
img = imread(fullfile(folderName, imageNames{fileIndex}));

% display first frame
axes(handles.currentFrameAxes);
imshow(img);
string = sprintf('frame %d / %d (%s)', frameIndex, frameNumber, imageNames{fileIndex});
set(handles.currentFrameLabel, 'String', string);


%% Validate images and continue

% --- Executes on button press in selectImagesButton.
function selectImagesButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectImagesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% extract global data
app = getappdata(0, 'app');
% folderName  = app.inputImagesDir;
% fileList    = app.imageNameList;
% imageNames  = app.imageNameList;

% imagesLoaded = ~isempty(app.imageList);
% if imagesLoaded
%     nb = length(imageList);
% else
%     nb = length(app.imageNameList);
% end

% if get(handles.keepAllFramesRadioButton, 'Value') == 1 
%    % For all pictures
%     set(handles.selectImagesButton, 'Enable', 'Off')
%     set(handles.selectImagesButton, 'String', 'Wait please...')
%     pause(0.01);
%     
%     debut = 1;
%     fin = nb;
%     step = 1;
%     
%     disp('Opening directory ...');
%     col = cell(nb, 1);
%     parfor_progress(length(fileList));
%     for i = 1:nb
%         if imagesLoaded 
%             img = app.imageList{i};
%         else
%             img = imread(fullfile(folderName, imageNames{i}));
%         end
%         
%         if ndims(img) > 2 %#ok<ISMAT>
%             img = img(:,:,1);
%         end
%         col{i} = img;
%         
%         parfor_progress;
%     end
%     parfor_progress(0); 
%     
% else
%     % For pictures by step
%     
%     % To take the range of pictures
%     firstPicture = get(handles.firstFrameIndexEdit, 'String');
%     lastPicture = get(handles.lastFrameIndexEdit, 'String');
%     stepPicture = get(handles.frameIndexStepEdit, 'String');
%     
%     % set some widget to waiting state
%     set(handles.selectImagesButton, 'Enable', 'Off')
%     set(handles.selectImagesButton, 'String', 'Wait please...')
%     pause(0.01);
%     
%     if length(firstPicture) ~= 0   %#ok isempty does'nt work i dont know why
%         firstPicture = str2num(firstPicture);%#ok I want [] if it's a string and not NaN to test it
%     elseif length(firstPicture) == 0%#ok
%         firstPicture = 1;
%     end
%     if length(lastPicture) ~= 0%#ok
%         lastPicture = str2double(lastPicture);
%     elseif length(lastPicture) == 0%#ok
%         lastPicture = nb;
%     end
%     if length(stepPicture) ~=0 %#ok
%         stepPicture = str2double(stepPicture);
%     elseif length(stepPicture) == 0 %#ok
%         stepPicture = 1;
%     end
%     
%     % check input validity
%     if isempty(firstPicture) || isempty(lastPicture) || isempty(stepPicture)
%         errordlg({'Please set a numeric value for the first, the last,', ...
%             'and the step indices'}, ...
%             'Wrong indices', 'modal')
%         return;
%     end
%     
%     % compute number of images after selection
%     selectedIndices = firstPicture:stepPicture:lastPicture;
%     nbstep = length(selectedIndices);
%     
%     % re-load necessary images
%     disp('Opening directory ...');
%     col = cell(nbstep, 1);
%     parfor_progress(nbstep);
%     for i = 1:nbstep
%         fileIndex = firstPicture + stepPicture * (i - 1);
%         if imagesLoaded
%             img = app.imageList{fileIndex};
%         else
%             fileName = imageNames{fileIndex};
%             img = imread(fullfile(folderName, fileName));
%         end
%         
%         if ndims(img) > 2 %#ok<ISMAT>
%             img = img(:,:,1);
%         end
%         col{i} = img;
% 
%         parfor_progress;
%     end
%     parfor_progress(0);
%     
%     debut = firstPicture;
%     fin = lastPicture;
%     step = stepPicture;
%     app.imageNameList = imageNames(selectedIndices);
% end

% % save indices for retrieving images
% app.firstIndex = debut;
% app.lastIndex = fin;
% app.indexStep = step;
app.readAllImages();

% % get study calibration
% resolString = get(handles.spatialResolutionEdit, 'String');
% resol = str2double(resolString);
% app.pixelSize = resol;
% timeString = get(handles.timeIntervalEdit, 'String');
% time = str2double(timeString);
% app.timeInterval = time;

delete(gcf);

ValidateThres(app);
