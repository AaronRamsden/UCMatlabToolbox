% UCGUI_UC_simulation is a script to solve a rolling horizon UC problem.
% 
% This UC model is explained in detail in the associated user manual, 
% "Unit Commitment Modelling Toolbox User Manual.pdf".
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

%% Measure total time taken to set up and solve problem:

start_time = tic;

%% GUI specified inputs:

% Input file:
file_name = handles.user_input_data.file_name;

save_results = handles.user_input_data.save_results;
save_name = handles.user_input_data.save_name;

% Number of time steps:
% Adjust accordingly:
keep_days = handles.user_input_data.keep_days; % Number of days to keep from each simulation.
overlap_days = handles.user_input_data.overlap_days; % Number of days to discard from each simulation.

loops = handles.user_input_data.loops; % Number of simulations.
start_day = handles.user_input_data.start_day-keep_days;

% Ignore transmission MW constraints:
UC_input.copper_plate = handles.user_input_data.copper_plate; % Boolean
UC_input.degrees = 0; % Limit to voltage angle across each bus connection.
% (Set to zero to use power transfer limits from input spreadsheet instead)

% spinning Reserve (applies only to synchronous generators):
UC_input.spin = handles.user_input_data.spinning_reserve; % Percent of demand.

rooftop_pv = handles.user_input_data.rooftop_pv;

% Boolean to indicate whether to subtract rooftop PV from demand traces or whether to add it on:
subtract_rooftop_pv = handles.user_input_data.subtract_rooftop_pv;

% Time step length (in hours):
time_step_length = handles.user_input_data.time_step_length;
UC_input.tsl = time_step_length;

%% Number of time steps (do not edit!):

sim_days = keep_days + overlap_days;
t_keep = 24*keep_days/time_step_length;
t_sim = 24*sim_days/time_step_length;
UC_input.t = t_sim; % Number of time steps per simulation

%% Generator characteristics:
% "Gen_data" is a G*18 matrix containing relevant generator data.
% Columns correspond to:
% 1. Bus number
% 2. Type                                                   (numeric key)
%      1. Brown Coal
%      2. Black Coal
%      3. CCGT
%      4. OCGT
%      5. cst
%      6. Utility storage
%      7. Wind
%      8. Utility PV
% 3. Maximum output (generator capacity)                    (MW)
% 4. Minimum output                                         (MW)
% 5. Generator output ramp up rate                          (MW/h)
% 6. Generator output ramp down rate                        (MW/h)
% 7. Start-up cost                                          ($)
% 8. Shut-down cost                                         ($)
% 9. Short run marginal cost (SRMC)                         ($/MWh)
% 10. Minimum up time                                       (hr)
% 11. Minimum down time                                     (hr)
% 12. Energy storage capacity                               (MWh)
% 13. Maximum energy storage charge/discharge rate          (MWh/h)
% 14. Minimum energy storage charge/discharge rate          (MWh/h)
% 15. Utility storage charging ramp up rate                 (MW/h)
% 16. Utility storage charging ramp down rate               (MW/h)
% 17. Utility storage efficiency                            (normalised to unity)
% 18. CST solar multiple                                    (unitless)
% 
% "gen_names" and "gen_colours" are used for plotting.

[gen_data, gen_names, gen_colours] = UCGUI_generation(file_name);

% Keep relevant info:
gen_index = gen_data(:,1);
g = size(gen_index,1);
type = gen_data(:,2);
p_cap = gen_data(:,3);
srmc = gen_data(:,9);
s_cap = gen_data(:,12);
solar_multiple = gen_data(:,18);

UC_input.generation = gen_data(:,1:17); % Do not require cst solar multiple in the solver.

% Delete unwanted variables:
clear gen_data

% Rooftop PV details for plotting:
[~,text,~] = xlsread(file_name,'Node index','D2:E999');
rooftop_pv_names = text(:,1);
rooftop_pv_colours = text(:,2);
[node_num,~,~] = xlsread(file_name,'Node index','A2:A999');
clear text

%% Bus characteristics:
% "Bus_Connections" lists all connections between busses. No more than one
% row per unique combination of busses (parallel connections are combined).

[b,b_bus,bus_connections] = UCGUI_bus_info(file_name,p_cap,gen_index);

UC_input.b = b; % Number of busses in system.
UC_input.b_bus = b_bus; % Bus admittance matrix.
UC_input.bus_connections = bus_connections;
UC_input.s_base = 100; % MVA

UC_result.bus_connections = bus_connections; % Keep in UC_result struct to reference p_trans and delta_theta.

clear b_bus

%% Variables:

% Vector of variables to solve for at each bus in each time step:
% 1 - p_gen (MW)                        * Continuous
% 2 - p_use (MW)                        * Continuous
% 3 - theta (radians)                   * Continuous
% 4 - s_gen (MWh)                       * Continuous
% 5 - q (binary charging indicator)     * Integer
% 6 - v (binary generating indicator)   * Integer
% 7 - y (binary start-up indicator)     * Integer
% 8 - z (binary shut-down indicator)    * Integer

% Allocate space for final result (after looping):
UC_result.p_gen = zeros(g,t_keep*loops);
UC_result.p_use = zeros(g,t_keep*loops);
UC_result.s_gen = zeros(g,t_keep*loops);
UC_result.q = zeros(g,t_keep*loops);
UC_result.v = zeros(g,t_keep*loops);
UC_result.delta_theta = zeros(size(bus_connections,1),t_keep*loops);
UC_result.p_trans = zeros(size(bus_connections,1),t_keep*loops);
UC_result.wind_spilled = zeros(g,t_keep*loops); % Store spilled wind power.
UC_result.solar_input = zeros(g,t_keep*loops);

%% Save total demand in network and rooftop PV in each node:

[network_demand,UC_result.rooftop_pv_generation,node_demand] = UCGUI_demand_rooftop_pv(file_name,loops*keep_days,start_day+keep_days,rooftop_pv,subtract_rooftop_pv,time_step_length);
UC_result.network_demand = sum(network_demand,1); % Sum of demand at all load centres
UC_result.node_demand = node_demand; % Demand at each node

%% Initial conditions (will be updated after each loop):

UC_input.p_gen_initial = zeros(g,1); % Power output in previous time step.
UC_input.p_use_initial = zeros(g,1); % Storage power usage in previous time step.
UC_input.s_gen_initial = ones(g,1).*p_cap.*(type == 5); % Storage energy in previous time step (only CST with initial storage for feasible solution).
UC_input.q_initial = zeros(g,1); % Charging state in previous time step.
UC_input.v_initial = zeros(g,1); % Generating state in previous time step.
UC_input.y_initial = fliplr(zeros(g,16/time_step_length)); % On decsion in previous time steps. MAX(MUT/MDT) = 16 hours
UC_input.z_initial = fliplr(zeros(g,16/time_step_length)); % Off decsion in previous time steps.
% Fliped left-right so that index 1 is the most recent time step.

%% Feasibility (changed to zero if a solution is not feasible):

UC_result.feasible = 1;

%% Set up loop:

iteration = 0;

%% Loop: 
for iteration = iteration:loops
    %% Timing of each loop:
    
    loop_time = tic;
    
    %% Demand, Solar Input, and Wind traces (1st hour is 12am-1am):
    
    % Demand: Start day 1 = 1/7/2014
    [UC_input.demand,~,~] = UCGUI_demand_rooftop_pv(file_name,sim_days,start_day,rooftop_pv,subtract_rooftop_pv,time_step_length);
    
    % Solar Input: Start day 1 = 1/7/2014
    UC_input.solar_input = UCGUI_solar(file_name,sim_days,start_day,p_cap,type,solar_multiple,gen_index,time_step_length);
    
    % Wind: Start day 1 = 1/7/2014
    UC_input.wind_input = UCGUI_wind(file_name,sim_days,start_day,p_cap,type,gen_index,time_step_length);
    
    % Update start_day for next loop:
    start_day = start_day + keep_days;

    %% Solve MILP problem:

    UC_solution = UCGUI_cplex_solver(UC_input);

    %% Post processing:

    if ~UC_solution.feasible
        fprintf('NOT FEASIBLE: Check UC_simulation.UC_result.UC_infeasible_solution\n');
        sim_data.infeasible_iteration = iteration;
        sim_data.finish_minutes = toc(start_time)/60;
        UC_result.feasible = 0;
        UC_result.UC_infeasible_solution = UC_solution;
        UC_simulation.input = handles.user_input_data;
        UC_simulation.sim_data = sim_data;
        UC_simulation.UC_result = UC_result;
        if save_results
            save(save_name,'UC_simulation');
        end
        return
    end

    p_gen = UC_solution.p_gen; % Power generated at busses with a generator connected.
    p_use = UC_solution.p_use; % Power generated at busses with a generator connected.
    s_gen = UC_solution.s_gen; % Energy storage at busses with a generator connected.
    q = UC_solution.q;
    v = UC_solution.v;
    y = UC_solution.y;
    z = UC_solution.z;
    delta_theta = UC_solution.delta_theta;
    p_trans = UC_solution.p_trans;
    wind_spilled = UC_solution.wind_spilled;
    cost = UC_solution.cost;

    clear UC_solution

    if iteration
        % Save key information:
        index_0 = (iteration-1)*t_keep+1;
        index_1 = iteration*t_keep;
        UC_result.p_gen(:,index_0:index_1) = p_gen(:,1:t_keep);
        UC_result.p_use(:,index_0:index_1) = p_use(:,1:t_keep);
        UC_result.s_gen(:,index_0:index_1) = s_gen(:,1:t_keep);
        UC_result.q(:,index_0:index_1) = q(:,1:t_keep);
        UC_result.v(:,index_0:index_1) = v(:,1:t_keep);
        UC_result.delta_theta(:,index_0:index_1) = rad2deg(delta_theta(:,1:t_keep));
        UC_result.p_trans(:,index_0:index_1) = p_trans(:,1:t_keep);
        UC_result.wind_spilled(:,index_0:index_1) = wind_spilled(:,1:t_keep);
        UC_result.solar_input(:,index_0:index_1) = UC_input.solar_input(:,1:t_keep);
    end
    
    %% Update inputs for next loop:
    
    UC_input.p_gen_initial = p_gen(:,t_keep); % Power output in previous time step.
    UC_input.p_use_initial = p_use(:,t_keep); % Storage power usage in previous time step.
    UC_input.s_gen_initial = s_gen(:,t_keep); % Energy storage in previous time step.
    UC_input.q_initial = q(:,t_keep); % Charging state in previous time step.
    UC_input.v_initial = v(:,t_keep); % Generating state in previous time step.
    UC_input.y_initial = fliplr(y(:,(t_keep-((16/time_step_length)-1)):t_keep)); % On decsion in previous time step. MAX(MUT/MDT) = 16 hours
    UC_input.z_initial = fliplr(z(:,(t_keep-((16/time_step_length)-1)):t_keep)); % Off decsion in previous time step.
    % Fliped left-right so that index 1 is the most recent time step.

    %% Output to console:
    
    fprintf('\n\nCompleted: %d of %d loops. Loop time: %.2f seconds. %1.0f minutes from starting.\n\n\n',...
        iteration,loops,toc(loop_time),toc(start_time)/60);
    
end

%% Post processing - Useful plotting Re-arrangement:

% First sort by SRMC:
[srmc, srmc_index] = sort(srmc);
type = type(srmc_index);
gen_names = gen_names(srmc_index);
gen_colours = gen_colours(srmc_index,:);
% Re-arrange all variables that apply to generators only:
UC_result.p_gen = UC_result.p_gen(srmc_index,:);
UC_result.p_use = UC_result.p_use(srmc_index,:);
UC_result.s_gen = UC_result.s_gen(srmc_index,:);
UC_result.q = UC_result.q(srmc_index,:);
UC_result.v = UC_result.v(srmc_index,:);
UC_result.solar_input = UC_result.solar_input(srmc_index,:);
UC_result.wind_spilled = UC_result.wind_spilled(srmc_index,:);

% Next sort by generation type:
[type, type_index] = sort(type);
srmc = srmc(type_index);
gen_names = gen_names(type_index);
gen_colours = gen_colours(type_index,:);
% Re-arrange all variables that apply to generators only:
UC_result.p_gen = UC_result.p_gen(type_index,:);
UC_result.p_use = UC_result.p_use(type_index,:);
UC_result.s_gen = UC_result.s_gen(type_index,:);
UC_result.q = UC_result.q(type_index,:);
UC_result.v = UC_result.v(type_index,:);
UC_result.solar_input = UC_result.solar_input(type_index,:);
UC_result.wind_spilled = UC_result.wind_spilled(type_index,:);

%% Save plotting information:

plotting.gen_colours = gen_colours;
plotting.rooftop_pv_colours = rooftop_pv_colours;
plotting.gen_names = gen_names;
plotting.rooftop_pv_names = rooftop_pv_names;
plotting.node_num = node_num;

%% Output to console:

finish_minutes = toc(start_time)/60;
fprintf('\nFinished solving UC problem in %1.0f minutes.\n',finish_minutes);

%% Useful simulation data:

sim_data.finish_minutes = finish_minutes;
sim_data.iteration = iteration;

%% Save all data:

UC_simulation.input = handles.user_input_data;
UC_simulation.UC_result = UC_result;
UC_simulation.plotting = plotting;
UC_simulation.sim_data = sim_data;
if save_results
    save(save_name,'UC_simulation');
end