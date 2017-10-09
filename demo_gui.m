function varargout = demo_gui(varargin)
% DEMO_GUI MATLAB code for demo_gui.fig
%   Run this code for a demo of the paper "Dress lika a Star: 
%   Retrieving Fashion Products from Videos".
%
%   Citation:
%     N. Garcia, G. Vogiatzis. Dress like a Star: Retrieving Fashion Products from Videos. In ICCVW 2017.

% Last Modified by GUIDE v2.5 09-Oct-2017 15:10:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @demo_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @demo_gui_OutputFcn, ...
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


% --- INIT
function demo_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to demo_gui (see VARARGIN)

% Choose default command line output for demo_gui
handles.output = hObject;

% Directories
handles.videoDir = 'Demo/Videos/';
handles.dataDir = 'Demo/Data/';
handles.queryDir = 'Demo/Queries/';
handles.featuresFile = 'Demo/Data/KeyFeatures.mat';
handles.treeFile = 'Demo/Data/tree.mat';

% popup menu - list of images
queryDir = 'Demo/Queries/';
queries = dir(fullfile(queryDir, '*.jpg'));
set(handles.popupmenu1,'String',{queries.name});

% Show first query in axis1
img = imread(fullfile(handles.queryDir, queries(1).name));
imshow(img, 'Parent', handles.axes1);

% Delete image in axis2 if any
imshow(img, 'Parent', handles.axes2);
axesHandlesToChildObjects = findobj(handles.axes2, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
	delete(axesHandlesToChildObjects);
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = demo_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- TRAINING BUTTON
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Info
text_to_show = sprintf('Building the model for videos.\nIt may take a while.');
set(handles.infotext,'String',text_to_show);
drawnow;

% Training
opts.thumbs = true;
opts.thumbsRes = 640;
training(handles.videoDir, handles.dataDir, opts);

% Info
text_to_show = sprintf('Training finished.');
set(handles.infotext,'String',text_to_show);
drawnow;


% --- SEARCH BUTTON
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

listQueries = get(handles.popupmenu1,'String');
nameImg = char(listQueries(get(handles.popupmenu1,'Value')));
img = imread(fullfile(handles.queryDir, nameImg));

% Check if training has occurred
if ~exist(handles.featuresFile, 'file') || ~exist(handles.treeFile, 'file')
    text_to_show = sprintf('Please, train the model first.');
    set(handles.infotext,'String',text_to_show);
    drawnow;
else
    % Info
    text_to_show = sprintf('Processing image %s.', nameImg);
    set(handles.infotext,'String',text_to_show);
    drawnow;

    % Process
    opts.B = 10;
    [frame, videoName] = query2frame(img, handles.dataDir, opts);

    % Draw
    dirThumbs = fullfile(handles.dataDir, videoName, 'Thumbs/');
    imshow(imread(sprintf('%sframe%08d.png', dirThumbs, frame)), 'Parent', handles.axes2);

    % Info
    text_to_show = sprintf('Found frame %d from "%s" video.', frame, videoName);
    set(handles.infotext,'String',text_to_show);
    drawnow;
end


% --- QUERIES MENU
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

% Show query in axis1 when selected
listQueries = get(handles.popupmenu1,'String');
img = imread(fullfile(handles.queryDir, ...
        char(listQueries(get(handles.popupmenu1,'Value')))));
imshow(img, 'Parent', handles.axes1);

% Delete image in axis2 if any
axesHandlesToChildObjects = findobj(handles.axes2, 'Type', 'image');
if ~isempty(axesHandlesToChildObjects)
	delete(axesHandlesToChildObjects);
end


% --- QUERIES MENU
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');



end
