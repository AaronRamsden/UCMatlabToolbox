function varargout = UCGUI(varargin)
% UCGUI MATLAB code for UCGUI.fig
% 
%   UCGUI is a Graphical User Interface that wraps around the Unit
%   Commitment solver and other associated code that make up the Matlab 
%   Unit Commitment Toolbox developed by Aaron Ramsden under the 
%   supervision of Gregor Verbic at the University of Sydney.
% 
%   The UC model and the functionality of the associated toolbox is 
%   explained in detail in the associated user manual, "Unit Commitment 
%   Modelling Toolbox User Manual.pdf".
%
%   If the GUI is not clearly visable, use GUIDE to manually adjust the 
%   images to suit the screen resolution of the system that is used.
% 
% Supervisor: Gregor Verbic
% Student: Aaron Ramsden
% 
%     Copyright (C) 2017  Aaron Ramsden
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UCGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @UCGUI_OutputFcn, ...
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

% --- Outputs from this function are returned to the command line.
function varargout = UCGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes just before UCGUI is made visible.
function UCGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UCGUI (see VARARGIN)

% Choose default command line output for UCGUI
handles.output = hObject;

% All case study input values are defined here:
global loops_simple_network; loops_simple_network = 15; % 15
global keep_days_simple_network; keep_days_simple_network = 2; % 2
global overlap_days_simple_network; overlap_days_simple_network = 6; % 6
global loops_58bus_network; loops_58bus_network = 30; % 30
global keep_days_58bus_network; keep_days_58bus_network = 1; % 1
global overlap_days_58bus_network; overlap_days_58bus_network = 1; % 3
global day; day = 1;
global month_a; month_a = 1; % NEM peak on 11 Jan 2016
global month_b; month_b = 1; % Same scenario to Case Study A (for direct comparison)
global month_c; month_c = 11; % November for CST (interesting gas dispatch)
global month_d; month_d = 4; % April for high PV (lower demand during the middle of the day)
global month_e; month_e = 2; % February (because it shows interesting gas behaviour even when coal is not at max output)
global month_f; month_f = 2; % Same scenario to Case Study E (for direct comparison)
global month_58bus; month_58bus = 1; % NEM peak on 11 Jan 2016 (all 58-bus case studies use the same date)
global year; year = 2016;
global time_step_length; time_step_length = 1; % 1 = 60 mins, 2 = 30 mins, 3 = 15 mins, 4 = 5 mins.
global file_name_cs_simple_a; file_name_cs_simple_a = 'UC_case_study_simple_network_A.xlsx';
global file_name_cs_simple_b; file_name_cs_simple_b = 'UC_case_study_simple_network_B.xlsx';
global file_name_cs_simple_c; file_name_cs_simple_c = 'UC_case_study_simple_network_C.xlsx';
global file_name_cs_simple_d; file_name_cs_simple_d = 'UC_case_study_simple_network_D.xlsx';
global file_name_cs_simple_e; file_name_cs_simple_e = 'UC_case_study_simple_network_E.xlsx';
global file_name_cs_simple_f; file_name_cs_simple_f = 'UC_case_study_simple_network_F.xlsx';
global file_name_cs_58bus_a; file_name_cs_58bus_a = 'UC_case_study_58bus_network_A.xlsx';
global file_name_cs_58bus_b; file_name_cs_58bus_b = 'UC_case_study_58bus_network_B.xlsx';
global file_name_cs_58bus_c; file_name_cs_58bus_c = 'UC_case_study_58bus_network_C.xlsx';
global file_name_cs_58bus_d; file_name_cs_58bus_d = 'UC_case_study_58bus_network_D.xlsx';
global file_name_cs_58bus_e; file_name_cs_58bus_e = 'UC_case_study_58bus_network_E.xlsx';
global file_name_cs_58bus_f; file_name_cs_58bus_f = 'UC_case_study_58bus_network_F.xlsx';
global spinning_reserve; spinning_reserve = 0.1;
global rooftop_pv_simple; rooftop_pv_simple = 4102; % 4102 MW - From "Detailed summary of 2015 electricity forecasts.pdf" for NEM
global rooftop_pv_simple_d; rooftop_pv_simple_d = 10000; % This case study has extra rooftop PV
global rooftop_pv_58bus; rooftop_pv_58bus = 4102; % 4102 MW - From "Detailed summary of 2015 electricity forecasts.pdf" for NEM
global subtract_rooftop_pv; subtract_rooftop_pv = 0;
global copper_plate; copper_plate = 0;
global save_results; save_results = 1;
global save_name_cs_simple_a; save_name_cs_simple_a = 'UC_case_study_simple_network_A';
global save_name_cs_simple_b; save_name_cs_simple_b = 'UC_case_study_simple_network_B';
global save_name_cs_simple_c; save_name_cs_simple_c = 'UC_case_study_simple_network_C';
global save_name_cs_simple_d; save_name_cs_simple_d = 'UC_case_study_simple_network_D';
global save_name_cs_simple_e; save_name_cs_simple_e = 'UC_case_study_simple_network_E';
global save_name_cs_simple_f; save_name_cs_simple_f = 'UC_case_study_simple_network_F';
global save_name_cs_58bus_a; save_name_cs_58bus_a = 'UC_case_study_58bus_network_A';
global save_name_cs_58bus_b; save_name_cs_58bus_b = 'UC_case_study_58bus_network_B';
global save_name_cs_58bus_c; save_name_cs_58bus_c = 'UC_case_study_58bus_network_C';
global save_name_cs_58bus_d; save_name_cs_58bus_d = 'UC_case_study_58bus_network_D';
global save_name_cs_58bus_e; save_name_cs_58bus_e = 'UC_case_study_58bus_network_E';
global save_name_cs_58bus_f; save_name_cs_58bus_f = 'UC_case_study_58bus_network_F';

% Set up Case Study - Simple Network Case Study A as the default:
% Turn on the Simple Network Case Study A selection:
set(handles.radio_cs_simple_a,'Value',1);
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
% set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_a;
set(handles.edit_month,'String',month_a);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_a,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel (turn on copper plate):
handles.user_input_data.copper_plate = ~copper_plate;
set(handles.radio_copper_plate,'Value',~copper_plate);
set(handles.radio_full_dc,'Value',copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_a;
set(handles.edit_file_name,'String',file_name_cs_simple_a);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_a;
set(handles.edit_save_name,'String',save_name_cs_simple_a);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_a);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');
% Plotting panel (only plotting feature until file name is checked):
set(handles.push_plot,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialisation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Run Solver %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in push_run_uc_simulation.
function push_run_uc_simulation_Callback(hObject, eventdata, handles)
run_solver = true;

if exist(handles.user_input_data.file_name,'file') ~= 2
    errordlg('Input file not found in Matlab PATH','Error');
    return
end
% Gen_data = xlsread(handles.user_input_data.file_name,'Generator data','A2:T999');
% 14. Minimum energy storage charge/discharge rate          (MWh/h)
% 15. Utility storage charging ramp up rate                 (MW/h)
% 16. Utility storage charging ramp down rate               (MW/h)
% Check = Gen_data(:,15) < Gen_data(:,14) | Gen_data(:,16) < Gen_data(:,14);
% if (sum(Check))
%     choice = questdlg('Storage generator(s) charging ramp rate less than minimum charge rate - storage generator(s) unable to charge, run solver anyway?', ...
%     'Run solver?', ...
%     'Yes','No','No');
%     if choice(1) == 'N'
%         run_solver = false;
%     end
% else
if get(handles.radio_save,'Value')
    % Check if the save name will overwrite an existing file:
    if exist(strcat(handles.user_input_data.save_name,'.mat'),'file') == 2
        choice = questdlg('save name will overwrite existing saved results, run solver anyway?', ...
        'Run solver?', ...
        'Yes','No','No');
        if choice(1) == 'N'
            run_solver = false;
        end
    end    
else
    % Prompt user to enter save name:
    choice = questdlg('Results will not be saved, run solver anyway?', ...
        'Run solver?','Yes','No','No');
        if choice(1) == 'N'
            run_solver = false;
        end
end
if run_solver
    set(handles.push_run_uc_simulation,'String','Solving, please wait');
    set(handles.push_run_uc_simulation,'BackgroundColor',rgb('Yellow'));
    drawnow;
    % Turn the interface off for processing:
    InterfaceObj=findobj(handles.background,'Enable','on'); set(InterfaceObj,'Enable','off');
    drawnow; % Sometimes not all GUI features are greyed out - not sure how to force Matlab to update the GUI before running the UC solve script. The GUI refreshes if it is minimised.
    % Run UC_simulation script:
    UCGUI_simulation;
    % Turn back on the interface:
    set(InterfaceObj,'Enable','on');
    set(handles.push_run_uc_simulation,'String','Run UC solver');
    set(handles.push_run_uc_simulation,'BackgroundColor',rgb('LimeGreen')); drawnow;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Run Solver %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Time Frame Specifications %%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_loops_Callback(hObject, eventdata, handles)
loops = round(str2double(get(hObject,'String')));
if isnan(loops) || loops <= 0
    set(hObject, 'String', handles.user_input_data.loops);
    errordlg('Input must be a positive integer','Error');
else % save the new value:
    handles.user_input_data.loops = loops;
    set(hObject,'String',handles.user_input_data.loops);
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_loops_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_keep_days_Callback(hObject, eventdata, handles)
keep_days = round(str2double(get(hObject,'String')));
if isnan(keep_days) || keep_days <= 0
    set(hObject, 'String', handles.user_input_data.keep_days);
    errordlg('Input must be a positive integer','Error');
else % save the new value:
    handles.user_input_data.keep_days = keep_days;
    set(hObject,'String',handles.user_input_data.keep_days);
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_keep_days_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_overlap_days_Callback(hObject, eventdata, handles)
overlap_days = round(str2double(get(hObject,'String')));
if isnan(overlap_days) || overlap_days <= 0
    set(hObject, 'String', handles.user_input_data.overlap_days);
    errordlg('Input must be a positive integer','Error');
else % save the new value:
    handles.user_input_data.overlap_days = overlap_days;
    set(hObject,'String',handles.user_input_data.overlap_days);
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_overlap_days_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_day_Callback(hObject, eventdata, handles)
day = round(str2double(get(hObject,'String')));
if isnan(day) || day < 1 || day > 31
    set(hObject, 'String', handles.user_input_data.day);
    errordlg('Input must be a positive integer within the range of 1 to 31','Error');
else
    % Check for a valid date:
    start_day  = UCGUI_get_start_day(day,handles.user_input_data.month,handles.user_input_data.year);
    if start_day == -1
        set(hObject, 'String', handles.user_input_data.day);
        errordlg('Date must be in range of 1/7/2015 - 30/6/2040','Error');
    else
        handles.user_input_data.day = day;
        set(hObject,'String',handles.user_input_data.day);
        % Update the start edit_day used for UC_simulations:
        handles.user_input_data.start_day = start_day;
    end
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_day_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_month_Callback(hObject, eventdata, handles)
month = round(str2double(get(hObject,'String')));
if isnan(month) || month < 1 || month > 12
    set(hObject, 'String', handles.user_input_data.month);
    errordlg('Input must be a positive integer within the range of 1 to 12','Error');
else
    % Check for a valid date:
    start_day = UCGUI_get_start_day(handles.user_input_data.day,month,handles.user_input_data.year);
    if start_day == -1
        set(hObject, 'String', handles.user_input_data.month);
        errordlg('Date must be in range of 1/7/2015 - 30/6/2040','Error');
    else
        handles.user_input_data.month = month;
        set(hObject,'String',handles.user_input_data.month);
        % Update the start edit_day used for UC_simulations:
        handles.user_input_data.start_day = start_day;
    end
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_month_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_year_Callback(hObject, eventdata, handles)
year = round(str2double(get(hObject,'String')));
if isnan(year) || year < 2015 || year > 2040
    set(hObject, 'String', handles.user_input_data.year);
    errordlg('Input must be a positive integer within the range of 2015 to 2040','Error');
else
    % Check for a valid date:
    start_day = UCGUI_get_start_day(handles.user_input_data.day,handles.user_input_data.month,year);
    if start_day == -1
        set(hObject, 'String', handles.user_input_data.year);
        errordlg('Date must be in range of 1/7/2015 - 30/6/2040','Error');
    else
        handles.user_input_data.year = year;
        set(hObject,'String',handles.user_input_data.year);
        % Update the start edit_day used for UC_simulations:
        handles.user_input_data.start_day = start_day;
    end
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_year_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pop_time_step_length.
function pop_time_step_length_Callback(hObject, eventdata, handles)
switch(get(hObject,'Value'))
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_time_step_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%% Time Frame Specifications %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% File Name Input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_file_name_Callback(hObject, eventdata, handles)
file_name = get(hObject, 'String');
if exist(file_name,'file') ~= 2
    set(handles.edit_file_name,'string',handles.user_input_data.file_name);
    errordlg('File not found in Matlab PATH','Error');
else % save the new value:
    handles.user_input_data.file_name = file_name;
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_file_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%% File Name Input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PV Input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_rooftop_pv_Callback(hObject, eventdata, handles)
PV = str2double(get(hObject,'String'));
if isnan(PV) || PV < 0
    set(hObject, 'String', handles.user_input_data.PV);
    errordlg('Input must be a positive number','Error');
else % save the new value:
    handles.user_input_data.rooftop_pv = PV;
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_rooftop_pv_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radio_add_rooftop_pv.
function radio_add_rooftop_pv_Callback(hObject, eventdata, handles)
Add_PV = get(hObject,'Value');
set(handles.radio_subtract_rooftop_pv,'Value',~Add_PV);
handles.user_input_data.subtract_rooftop_pv = ~Add_PV;
% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_subtract_rooftop_pv.
function radio_subtract_rooftop_pv_Callback(hObject, eventdata, handles)
subtract_rooftop_pv = get(hObject,'Value');
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
% Update handles structure:
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PV Input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Spinning Reserve %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function edit_spinning_reserve_Callback(hObject, eventdata, handles)
spinning_reserve = str2double(get(hObject,'String'))/100;
if isnan(spinning_reserve) || spinning_reserve < 0 || spinning_reserve > 1
    set(hObject,'String',handles.user_input_data.spinning_reserve*100);
    errordlg('Input must be a positive number between 0 and 100','Error');
else % save the new value:
    handles.user_input_data.spinning_reserve = spinning_reserve;
end
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_spinning_reserve_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Spinning Reserve %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Full DC/Copper Plate %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in radio_copper_plate.
function radio_copper_plate_Callback(hObject, eventdata, handles)
copper_plate = get(hObject,'Value');
set(handles.radio_full_dc,'Value',~copper_plate);
handles.user_input_data.copper_plate = copper_plate;
% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_full_dc.
function radio_full_dc_Callback(hObject, eventdata, handles)
Full_DC = get(hObject,'Value');
set(handles.radio_copper_plate,'Value',~Full_DC);
handles.user_input_data.copper_plate = ~Full_DC;
% Update handles structure:
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%% Full DC/Copper Plate %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% save Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in radio_save.
function radio_save_Callback(hObject, eventdata, handles)
save_results = get(hObject,'Value');
handles.user_input_data.save_results = save_results;
if save_results % Turn on the interface:
    set(handles.edit_save_name,'Enable','on');
    set(handles.fixed_save_name,'Enable','on');
else % Turn off the interface:
    set(handles.edit_save_name,'Enable','off');
    set(handles.fixed_save_name,'Enable','off');
end
% Update handles structure:
guidata(hObject, handles);

function edit_save_name_Callback(hObject, eventdata, handles)
handles.user_input_data.save_name = get(hObject,'String');
% Update handles structure:
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_save_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%% save Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in push_plot.
function push_plot_Callback(hObject, eventdata, handles)
load_results = load(get(handles.edit_load_name,'String'));
if (~load_results.UC_simulation.UC_result.feasible)
    fprintf('Unable to plot results: Solution is not FEASIBLE (Check Check UC_simulation.UC_result.UC_infeasible_solution)\n');
    return;
end
UCGUI_plot_time_series(load_results.UC_simulation.input,load_results.UC_simulation.UC_result,load_results.UC_simulation.plotting);
% Turn off the interface:
set(handles.push_plot,'Enable','off');
set(handles.edit_load_name,'Enable','on');
set(handles.radio_load_enable,'Value',0);
% Update handles structure:
guidata(hObject, handles);

function edit_load_name_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_load_name_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radio_load_enable.
function radio_load_enable_Callback(hObject, eventdata, handles)
Load_enable = get(hObject,'Value');
if Load_enable
    Load_name = get(handles.edit_load_name,'String');
    if exist(Load_name,'file') == 2 || exist(strcat(Load_name,'.mat'),'file') == 2
        % Turn on the interface:
        set(handles.push_plot,'Enable','on');
        set(handles.edit_load_name,'Enable','off');
    else
        % Turn off the interface:
        set(handles.push_plot,'Enable','off');
        set(handles.edit_load_name,'Enable','on');
        set(hObject,'Value',0);
        errordlg('Cannot find specified mat file in path','Error');
    end
else
    % Turn off the interface:
    set(handles.push_plot,'Enable','off');
    set(handles.edit_load_name,'Enable','on');
end
% Update handles structure:
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in radio_user_defined_input.
function radio_user_defined_input_Callback(hObject, eventdata, handles)
% Keep radio_button on:
User_defined_input = get(hObject,'Value');
if User_defined_input == 0;
    set(handles.radio_user_defined_input,'Value',1);
    % Update handles structure:
    guidata(hObject, handles);
end

% Turn off the other selections:
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Turn on the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','on');
set(handles.edit_keep_days,'Enable','on');
set(handles.edit_overlap_days,'Enable','on');
set(handles.pop_time_step_length,'Enable','on');
set(handles.edit_day,'Enable','on');
set(handles.edit_month,'Enable','on');
set(handles.edit_year,'Enable','on');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','on');
set(handles.radio_add_rooftop_pv,'Enable','on');
set(handles.radio_subtract_rooftop_pv,'Enable','on');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','on');
set(handles.radio_copper_plate,'Enable','on');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','on');
% Input file name panel:
set(handles.edit_file_name,'Enable','on');
% save results panel:
set(handles.radio_save,'Enable','on');
set(handles.edit_save_name,'Enable','on');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_a.
function radio_cs_simple_a_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
% set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_a;
global year;
global file_name_cs_simple_a;
global spinning_reserve;
global rooftop_pv_simple;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_a;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_a;
set(handles.edit_month,'String',month_a);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_a,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel (turn on copper plate):
handles.user_input_data.copper_plate = ~copper_plate;
set(handles.radio_copper_plate,'Value',~copper_plate);
set(handles.radio_full_dc,'Value',copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_a;
set(handles.edit_file_name,'String',file_name_cs_simple_a);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_a;
set(handles.edit_save_name,'String',save_name_cs_simple_a);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_a);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_b.
function radio_cs_simple_b_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
% set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_b;
global year;
global file_name_cs_simple_b;
global spinning_reserve;
global rooftop_pv_simple;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_b;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_b;
set(handles.edit_month,'String',month_b);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_b,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_b;
set(handles.edit_file_name,'String',file_name_cs_simple_b);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_b;
set(handles.edit_save_name,'String',save_name_cs_simple_b);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_b);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_c.
function radio_cs_simple_c_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
% set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_c;
global year;
global file_name_cs_simple_c;
global spinning_reserve;
global rooftop_pv_simple;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_c;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_c;
set(handles.edit_month,'String',month_c);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_c,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_c;
set(handles.edit_file_name,'String',file_name_cs_simple_c);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_c;
set(handles.edit_save_name,'String',save_name_cs_simple_c);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_c);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_d.
function radio_cs_simple_d_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
% set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_d;
global year;
global file_name_cs_simple_d;
global spinning_reserve;
global rooftop_pv_simple_d; % This case study has extra rooftop PV
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_d;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_d;
set(handles.edit_month,'String',month_d);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_d,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple_d;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple_d);
handles.user_input_data.subtract_rooftop_pv = ~subtract_rooftop_pv; % Subtract rooftop PV from demand for this case study only.
set(handles.radio_subtract_rooftop_pv,'Value',~subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_d;
set(handles.edit_file_name,'String',file_name_cs_simple_d);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_d;
set(handles.edit_save_name,'String',save_name_cs_simple_d);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_d);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_e.
function radio_cs_simple_e_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
% set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_e;
global year;
global file_name_cs_simple_e;
global spinning_reserve;
global rooftop_pv_simple;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_e;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_e;
set(handles.edit_month,'String',month_e);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_e,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_e;
set(handles.edit_file_name,'String',file_name_cs_simple_e);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_e;
set(handles.edit_save_name,'String',save_name_cs_simple_e);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_e);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_simple_f.
function radio_cs_simple_f_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
% set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_simple_network;
global keep_days_simple_network;
global overlap_days_simple_network;
global time_step_length;
global day;
global month_f;
global year;
global file_name_cs_simple_f;
global spinning_reserve;
global rooftop_pv_simple;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_simple_f;
% Time frame panel:
handles.user_input_data.loops = loops_simple_network;
set(handles.edit_loops,'String',loops_simple_network);
handles.user_input_data.keep_days = keep_days_simple_network;
set(handles.edit_keep_days,'String',keep_days_simple_network);
handles.user_input_data.overlap_days = overlap_days_simple_network;
set(handles.edit_overlap_days,'String',overlap_days_simple_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_f;
set(handles.edit_month,'String',month_f);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_f,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_simple;
set(handles.edit_rooftop_pv,'String',rooftop_pv_simple);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_simple_f;
set(handles.edit_file_name,'String',file_name_cs_simple_f);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_simple_f;
set(handles.edit_save_name,'String',save_name_cs_simple_f);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_simple_f);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_a.
function radio_cs_58bus_a_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
% set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_a;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_a;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel (turn on copper plate):
handles.user_input_data.copper_plate = ~copper_plate;
set(handles.radio_copper_plate,'Value',~copper_plate);
set(handles.radio_full_dc,'Value',copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_a;
set(handles.edit_file_name,'String',file_name_cs_58bus_a);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_a;
set(handles.edit_save_name,'String',save_name_cs_58bus_a);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_a);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_b.
function radio_cs_58bus_b_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
% set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_b;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_b;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_b;
set(handles.edit_file_name,'String',file_name_cs_58bus_b);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_b;
set(handles.edit_save_name,'String',save_name_cs_58bus_b);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_b);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_c.
function radio_cs_58bus_c_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
% set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_c;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_c;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_c;
set(handles.edit_file_name,'String',file_name_cs_58bus_c);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_c;
set(handles.edit_save_name,'String',save_name_cs_58bus_c);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_c);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_d.
function radio_cs_58bus_d_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
% set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_d;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_d;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel:
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_d;
set(handles.edit_file_name,'String',file_name_cs_58bus_d);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_d;
set(handles.edit_save_name,'String',save_name_cs_58bus_d);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_d);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_e.
function radio_cs_58bus_e_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
% set(handles.radio_cs_58bus_e,'Value',0);
set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_e;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_e;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel (turn off copper plate selection):
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_e;
set(handles.edit_file_name,'String',file_name_cs_58bus_e);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_e;
set(handles.edit_save_name,'String',save_name_cs_58bus_e);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_e);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

% --- Executes on button press in radio_cs_58bus_f.
function radio_cs_58bus_f_Callback(hObject, eventdata, handles)
% Turn off the other selections:
% User defined input:
set(handles.radio_user_defined_input,'Value',0);
% Simple Network:
set(handles.radio_cs_simple_a,'Value',0);
set(handles.radio_cs_simple_b,'Value',0);
set(handles.radio_cs_simple_c,'Value',0);
set(handles.radio_cs_simple_d,'Value',0);
set(handles.radio_cs_simple_e,'Value',0);
set(handles.radio_cs_simple_f,'Value',0);
% 58-bus Network:
set(handles.radio_cs_58bus_a,'Value',0);
set(handles.radio_cs_58bus_b,'Value',0);
set(handles.radio_cs_58bus_c,'Value',0);
set(handles.radio_cs_58bus_d,'Value',0);
set(handles.radio_cs_58bus_e,'Value',0);
% set(handles.radio_cs_58bus_f,'Value',0);

% Set all of the default values for both the UC_simulation and the GUI display:
global loops_58bus_network;
global keep_days_58bus_network;
global overlap_days_58bus_network;
global time_step_length;
global day;
global month_58bus;
global year;
global file_name_cs_58bus_f;
global spinning_reserve;
global rooftop_pv_58bus;
global subtract_rooftop_pv;
global copper_plate;
global save_results;
global save_name_cs_58bus_f;
% Time frame panel:
handles.user_input_data.loops = loops_58bus_network;
set(handles.edit_loops,'String',loops_58bus_network);
handles.user_input_data.keep_days = keep_days_58bus_network;
set(handles.edit_keep_days,'String',keep_days_58bus_network);
handles.user_input_data.overlap_days = overlap_days_58bus_network;
set(handles.edit_overlap_days,'String',overlap_days_58bus_network);
switch(time_step_length)
    case 1 % 60 mins
        handles.user_input_data.time_step_length = 1;
    case 2 % 30 mins
        handles.user_input_data.time_step_length = 30/60;
    case 3 % 15 mins
        handles.user_input_data.time_step_length = 15/60;
    case 4 % 5 mins
        handles.user_input_data.time_step_length = 5/60;
end
set(handles.pop_time_step_length,'Value',time_step_length);
handles.user_input_data.day = day;
set(handles.edit_day,'String',day);
handles.user_input_data.month = month_58bus;
set(handles.edit_month,'String',month_58bus);
handles.user_input_data.year = year;
set(handles.edit_year,'String',year);
handles.user_input_data.start_day = UCGUI_get_start_day(day,month_58bus,year);
% Rooftop PV panel:
handles.user_input_data.rooftop_pv = rooftop_pv_58bus;
set(handles.edit_rooftop_pv,'String',rooftop_pv_58bus);
handles.user_input_data.subtract_rooftop_pv = subtract_rooftop_pv;
set(handles.radio_subtract_rooftop_pv,'Value',subtract_rooftop_pv);
set(handles.radio_add_rooftop_pv,'Value',~subtract_rooftop_pv);
% Bus representation panel (turn off copper plate selection):
handles.user_input_data.copper_plate = copper_plate;
set(handles.radio_copper_plate,'Value',copper_plate);
set(handles.radio_full_dc,'Value',~copper_plate);
% Spinning reserve panel:
handles.user_input_data.spinning_reserve = spinning_reserve;
set(handles.edit_spinning_reserve,'String',spinning_reserve*100);
% Input file name panel:
handles.user_input_data.file_name = file_name_cs_58bus_f;
set(handles.edit_file_name,'String',file_name_cs_58bus_f);
% save results panel:
handles.user_input_data.save_results = save_results;
set(handles.radio_save,'Value',save_results);
handles.user_input_data.save_name = save_name_cs_58bus_f;
set(handles.edit_save_name,'String',save_name_cs_58bus_f);
% Plotting panel:
set(handles.edit_load_name,'String',save_name_cs_58bus_f);

% Turn off the user input fields:
% Time frame panel:
set(handles.edit_loops,'Enable','off');
set(handles.edit_keep_days,'Enable','off');
set(handles.edit_overlap_days,'Enable','off');
set(handles.pop_time_step_length,'Enable','off');
set(handles.edit_day,'Enable','off');
set(handles.edit_month,'Enable','off');
set(handles.edit_year,'Enable','off');
% Rooftop PV panel:
set(handles.edit_rooftop_pv,'Enable','off');
set(handles.radio_add_rooftop_pv,'Enable','off');
set(handles.radio_subtract_rooftop_pv,'Enable','off');
% Bus representation panel:
set(handles.radio_full_dc,'Enable','off');
set(handles.radio_copper_plate,'Enable','off');
% Spinning reserve panel:
set(handles.edit_spinning_reserve,'Enable','off');
% Input file name panel:
set(handles.edit_file_name,'Enable','off');
% save results panel:
set(handles.radio_save,'Enable','off');
set(handles.edit_save_name,'Enable','off');

% Update handles structure:
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
