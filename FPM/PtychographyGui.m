function varargout = PtychographyGui(varargin)
% PTYCHOGRAPHYGUI MATLAB code for PtychographyGui.fig
%      PTYCHOGRAPHYGUI, by itself, creates a new PTYCHOGRAPHYGUI or raises the existing
%      singleton*.
%
%      H = PTYCHOGRAPHYGUI returns the handle to a new PTYCHOGRAPHYGUI or the handle to
%      the existing singleton*.
%
%      PTYCHOGRAPHYGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTYCHOGRAPHYGUI.M with the given input arguments.
%
%      PTYCHOGRAPHYGUI('Property','Value',...) creates a new PTYCHOGRAPHYGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PtychographyGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PtychographyGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PtychographyGui

% Last Modified by GUIDE v2.5 09-Apr-2018 18:26:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PtychographyGui_OpeningFcn, ...
    'gui_OutputFcn',  @PtychographyGui_OutputFcn, ...
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


% --- Executes just before PtychographyGui is made visible.
function PtychographyGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PtychographyGui (see VARARGIN)

% Create the data to plot.
handles.iterations = 1;
handles.recon = 1;
handles.xmax = 7;
handles.wavelength = 650e-9;
handles.color = [7 0 0];
handles.name = 'Initial';
handles.colorsetting = 1;
handles.object = 0;

axes(handles.axes3);
matlabImage = imread('csu.png');
image(matlabImage);
axis off
axis image

% Choose default command line output for PtychographyGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PtychographyGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PtychographyGui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.recon == 1
    handles.object = fast_recon(handles.name, handles.iterations);
    axes(handles.axes1)
    imagesc(abs(handles.object));
    text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
    colormap pink
    axis off
    freezeColors;
    
    axes(handles.axes2)
    imagesc(angle(handles.object));
    text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
    colormap hsv
    axis off
    freezeColors;
    
elseif handles.recon == 2
    handles.object = real_time_recon(handles.name, handles.iterations);
    axes(handles.axes1)
    imagesc(abs(handles.object));
    text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
    colormap pink
    axis off
    freezeColors;
    
    axes(handles.axes2)
    imagesc(angle(handles.object));
    text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
    colormap hsv
    axis off
    freezeColors;
    
elseif handles.recon == 3
    handles.object = reconstructRGB(handles.name, handles.iterations);
    axes(handles.axes1)
    imagesc(abs(handles.object));
    text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
    colormap pink
    axis off
    freezeColors;
    
    axes(handles.axes2)
    imagesc(angle(handles.object));
    colormap hsv
    axis off
    freezeColors;
    
end
guidata(gcbf,handles);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
    case 'Fast' 
        handles.recon = 1;
    case 'Real Time' 
        handles.recon = 2;
    case 'RGB Recon'
        handles.recon = 3;
end
% Save the handles structure.
guidata(gcbf,handles);
%guidata(hObject,handles)



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% setup camera
%Creates a camera element, and returns the camera information for the
%attached camera

if(~exist('cameraFlag','var'))
    [vid,cameraFlag] = camerasetup();
elseif(exist('cameraFlag','var'))
    cam_setup = msgbox('Camera is already setup','Camera');
    uiwait(cam_setup);
end
% Preview image
preview(vid);
%pause for autoexposure
mbox_preview = msgbox('Preview looks good','Preview');
uiwait(mbox_preview);
closepreview(vid);

% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val};
    case '3x3' % User selects 1.
        handles.xmax = [3];
    case '5x5' % User selects 5.
        handles.xmax = [5];
    case '7x7' % User selects 10.
        handles.xmax = [7];
end
% Save the handles structure.
guidata(hObject,handles)


% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Determine the selected data set.
str = get(hObject,'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
switch str{val}
    case 'Blue' % User selects 1.
        handles.wavelength = 450e-9;
        handles.color = [0 0 7];
        handles.colorsetting = 1;
    case 'Red' % User selects 5.
        handles.wavelength = 650e-9;
        handles.color = [7 0 0];
        handles.colorsetting = 1;
    case 'Green' % User selects 10.
        handles.wavelength = 550e-9;
        handles.colorsetting = 1;
        handles.color = [0 7 0];
    case 'White' % User selects 10.
        handles.wavelength = 550e-9;
        handles.colorsetting = 1;
        handles.color = [7 7 7];
    case 'RGB' % User selects 15.
        handles.wavelength = [650e-9 550e-9 450e-9];
        handles.colorsetting = 3;
        handles.color = [7 7 7];
end
% Save the handles structure.
guidata(hObject,handles)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.name = get(hObject,'String');
guidata(gcbf,handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
serialcamtrig(handles.xmax, handles.wavelength, handles.color, handles.colorsetting, handles.name);

% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure(1)
imagesc(abs(handles.object));
text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
title('Reconstructed Magnitude')
colormap pink
axis off
axis image

figure(2)
imagesc((angle(handles.object)));
text(3000,3900,"|------------|100um",'color', 'w','fontsize', 11)
title('Reconstructed Phase')
colormap hsv
colorbar
axis off
axis image



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

handles.iterations = str2double(get(hObject,'String'));
guidata(gcbf,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
