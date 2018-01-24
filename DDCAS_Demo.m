function varargout = DDCAS_Demo(varargin)
% DDCAS_DEMO MATLAB code for DDCAS_Demo.fig
%   Copyright R Hyde 2017
%   Released under the GNU GPLver3.0
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/
%   DDCAS_Demo is a GUI for carrying out demonstartion analysis of the
%   DDCAS algorithm.
%   For a detailed description, see:
%   A new algorithm for initialising online and evolving clustering and eliminating start up times
%   R Hyde, R Hossaini, A Leeson, submitted to Data Mining and Knowledge
%   Discovery Jan 2018
%
%      DDCAS_DEMO, by itself, creates a new DDCAS_DEMO or raises the existing
%      singleton*.
%
%      H = DDCAS_DEMO returns the handle to a new DDCAS_DEMO or the handle to
%      the existing singleton*.
%
%      DDCAS_DEMO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DDCAS_DEMO.M with the given input arguments.
%
%      DDCAS_DEMO('Property','Value',...) creates a new DDCAS_DEMO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DDCAS_Demo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DDCAS_Demo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DDCAS_Demo

% Last Modified by GUIDE v2.5 25-Sep-2017 17:01:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DDCAS_Demo_OpeningFcn, ...
                   'gui_OutputFcn',  @DDCAS_Demo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if(~isdeployed)
  cd(fileparts(which(mfilename)));
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DDCAS_Demo is made visible.
function DDCAS_Demo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DDCAS_Demo (see VARARGIN)

% Choose default command line output for DDCAS_Demo
handles.output = hObject;

% My code
[handles] = SetParams(handles); 
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DDCAS_Demo wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DDCAS_Demo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnGo.
function btnGo_Callback(hObject, eventdata, handles)
% hObject    handle to btnGo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject.Value == 1
    if any([str2double(handles.editMT.String), str2double(handles.editIR.String),...
            handles.popDataSet.Value, handles.popTestSelect.Value,...
            str2double(handles.textT2.String)]==0)...
        | any(isnan([str2double(handles.editMT.String), str2double(handles.editIR.String),...
            handles.popDataSet.Value, handles.popTestSelect.Value,...
            str2double(handles.textT2.String)]))
        StatusOutput(handles,'Error, parameters not set')
        drawnow
        set(hObject, 'Value', 0)
        return
    end
    set(findall(handles.uipanelSetup, '-property', 'enable'), 'enable', 'off');
    set(hObject, 'enable', 'on', 'BackgroundColor', 'red', 'String', 'Interrupt');
    switch handles.popTestSelect.Value
        case 1 % Compare online / Hybrid
            Analysis1(handles);

        case 2 % Switch Online / Hybrid
            Analysis2(handles);

        case 3 % Evolving Hybrid
            Analysis3( handles);

    end % end switch
end
set(hObject, 'enable', 'on', 'BackgroundColor', 'green', 'String', 'Start', 'Value', 0);
set(findall(handles.uipanelSetup, '-property', 'enable'), 'enable', 'on');
   


% --- Executes on selection change in popDataSet.
function popDataSet_Callback(hObject, eventdata, handles)
% hObject    handle to popDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popDataSet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popDataSet
SetParams(handles);

% --- Executes during object creation, after setting all properties.
function popDataSet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popDataSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
DataFiles = dir('Data\*.csv');
for idx = 1:size(DataFiles,1)
	[~,n,~]=fileparts(DataFiles(idx).name);
    DataNames{idx} = n;
end
hObject.String = sort(DataNames);


% --- Executes on selection change in popTestSelect.
function popTestSelect_Callback(hObject, eventdata, handles)
% hObject    handle to popTestSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popTestSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popTestSelect
Test = hObject.Value;
switch Test
    case 1
        handles.uipanelConvergence.Visible = 'off';
        hMAS = findobj(handles.uipanel15,'Type','uicontrol'); % find everything in the panel
        set(hMAS,'Visible','off'); % turn them all off before turning on what's required
    case 2
        hMAS = findobj(handles.uipanel15,'Type','uicontrol'); % find everything in the panel
        set(hMAS,'Visible','off'); % turn them all off before turning on what's required
        handles.uipanelConvergence.Visible = 'on';
        handles.sliderAdjMerge.Visible = 'on';
        handles.editMerge.Visible = 'on';
        handles.editMergeTest.Visible = 'on';
        handles.textConv.Visible = 'on';
        handles.textTestRate.Visible = 'on';
        
    case 3
        handles.uipanelConvergence.Visible = 'off';
        hMAS = findobj(handles.uipanel15,'Type','uicontrol'); % find everything in the panel
        set(hMAS,'Visible','off'); % turn them all off before turning on what's required
        handles.editDecay.Visible = 'on';
        handles.textDecay.Visible = 'on';
end


% --- Executes during object creation, after setting all properties.
function popTestSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popTestSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String = {'Compare Online / Hybrid', 'Switch Online / Hybrid', 'Compare DDCAS / CEDAS'};


function textT2_Callback(hObject, eventdata, handles)
% hObject    handle to textT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textT2 as text
%        str2double(get(hObject,'String')) returns contents of textT2 as a double


% --- Executes during object creation, after setting all properties.
function textT2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushRandomT2.
function pushRandomT2_Callback(hObject, eventdata, handles)
% hObject    handle to pushRandomT2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NumData = handles.NumData;
MinT2 = floor(NumData/4);
MaxT2 = floor(MinT2*3);
T2 = randi( (MaxT2 - MinT2) ) + MinT2;
handles.textT2.String = T2;

function editIR_Callback(hObject, eventdata, handles)
% hObject    handle to editIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editIR as text
%        str2double(get(hObject,'String')) returns contents of editIR as a double


% --- Executes during object creation, after setting all properties.
function editIR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMT_Callback(hObject, eventdata, handles)
% hObject    handle to editMT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMT as text
%        str2double(get(hObject,'String')) returns contents of editMT as a double


% --- Executes during object creation, after setting all properties.
function editMT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listPurityStd.
function listPurityStd_Callback(hObject, eventdata, handles)
% hObject    handle to listPurityStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listPurityStd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listPurityStd


% --- Executes during object creation, after setting all properties.
function listPurityStd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listPurityStd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listPurityHyb.
function listPurityHyb_Callback(hObject, eventdata, handles)
% hObject    handle to listPurityHyb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listPurityHyb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listPurityHyb


% --- Executes during object creation, after setting all properties.
function listPurityHyb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listPurityHyb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderAdjMerge_Callback(hObject, eventdata, handles)
% hObject    handle to sliderAdjMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.editMerge.String = hObject.Value


% --- Executes during object creation, after setting all properties.
function sliderAdjMerge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderAdjMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editMerge_Callback(hObject, eventdata, handles)
% hObject    handle to editMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMerge as text
%        str2double(get(hObject,'String')) returns contents of editMerge as a double


% --- Executes during object creation, after setting all properties.
function editMerge_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMerge (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editMergeTest_Callback(hObject, eventdata, handles)
% hObject    handle to editMergeTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMergeTest as text
%        str2double(get(hObject,'String')) returns contents of editMergeTest as a double


% --- Executes during object creation, after setting all properties.
function editMergeTest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMergeTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDecay_Callback(hObject, eventdata, handles)
% hObject    handle to editDecay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDecay as text
%        str2double(get(hObject,'String')) returns contents of editDecay as a double


% --- Executes during object creation, after setting all properties.
function editDecay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDecay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkClass.
function checkClass_Callback(hObject, eventdata, handles)
% hObject    handle to checkClass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkClass
