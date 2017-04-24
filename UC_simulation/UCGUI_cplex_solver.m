function [ UC_solution ] = UCGUI_cplex_solver(UC_input)
% UCGUI_cplex_solver is a Unit Committment MILP optimiser that uses the
% CPLEX optimisation toolbox.
%
%   Input arguments are required to be dimensionally correct - no error
%   checking is performed. Input struct "UC_input" contains the following 
%   fields:
%   b ------------------------- Number of busses in system.
%   t ------------------------- Number of timesteps.
%   tsl ----------------------- Time step length in hours.
%   copper_plate -------------- Boolean to indicate whether to implement
%                               transmission line and transformer power 
%                               transfer limits or not.
%   b_bus --------------------- B*B symmetric matrix containing bus 
%                               susceptances only (pu).
%   bus_connections ----------- ?*4 matrix listing all transmission line
%                               and transformer connections between busses.
%                               Must not contain more than one row listing 
%                               the same two busses.
%                               Columns correspond to:
%                                           1. From bus number
%                                           2. To bus number
%                                           3. Series susceptance between
%                                              busses (pu)
%                                           4. Maximum power limit (MW)
%   degrees ------------------- Variable used to limit power flow across
%                               bus connections by forcing the voltage
%                               angle across the connection to be less than
%                               or equal to degrees. If degrees is zero
%                               then power transfer limits are taken from
%                               bus_connections.
%   s_base -------------------- Base power used for susceptances.
%   spin ---------------------- Spinning reserve as percentage of demand 
%                               (applies only to synchronous generators).
%   demand -------------------- b*t matrix containing the demand at each 
%                               bus for each time step (MW).
%   solar_input --------------- g*t matrix containing the solar input at 
%                               each generator bus for each time step, 
%                               normalised to power available to generator 
%                               (MW).
%   wind_input ---------------- g*t matrix containing the wind input at 
%                               each generator bus for each time step, 
%                               normalised to power available to generator 
%                               (MW). No need to ensure that (wind_input <=
%                               gen_cap), wind generator output is capped.
%   generation ---------------- g*17 matrix. Columns correspond to:
%                                       1. bus number
%                                       2. type               (numeric key)
%                                               1. brown coal
%                                               2. black coal
%                                               3. CCGT
%                                               4. OCGT
%                                               5. CST
%                                               6. utility storage
%                                               7. wind
%                                               8. utility PV
%                                       3. Max output         (MW)
%                                       4. Min output         (MW)
%                                       5. Ramp-up rate       (MW/h) 
%                                          * Cannot be "inf"
%                                       6. Ramp-down rate     (MW/h)
%                                          * Cannot be "inf"
%                                       7. Start-up cost      ($)
%                                       8. Shut-down cost     ($)
%                                       9. SRMC               ($/MWh)
%                                       10. Minimum up time   (h)
%                                       11. Minimum down time (h)
%                                       12. Energy storage
%                                           capacity          (MWh)
%                                       13. Max energy storage charge/
%                                           discharge rate    (MWh/h)
%                                       14. Min energy storage charge/
%                                           discharge rate    (MWh/h)
%                                       15. Utility storage charging
%                                           ramp up rate      (MW/h)
%                                       16. Utility storage charging
%                                           ramp down rate    (MW/h)
%                                       17. Utility storage efficiency
%                                           (normalised to unity)
%                                           * Utility storage plant only
%   p_gen_initial ------------- g*1 initial condition, previous hour.
%   p_use_initial ------------- g*1 initial condition, previous hour.
%   q_initial ----------------- g*1 initial condition, previous hour.
%   v_initial ----------------- g*1 initial condition, previous hour.
%   y_initial ----------------- g*(16/time_step_length) initial condition, 
%                               16 hours - maximum of mut/mdt.
%   z_initial ----------------- g*(16/time_step_length) initial condition, 
%                               16 hours - maximum of mut/mdt.
%   s_gen_initial ------------- g*1 initial condition, previous hour.
%
%   The variables that are defined in the MILP problem are t consecutive 
%   repeats of the following vector:
%       Vector of variables to solve for in each time step (each listed 
%       variable is repeated b times, once for each bus in the system):
%       1 - p_gen (Generated power, MW)           * Continuous
%       2 - p_use (Stored power, MW)              * Continuous
%       3 - theta (Voltage angle, radians)        * Continuous
%       4 - s_gen (Energy storage, MWh)           * Continuous
%       5 - q (Binary charging indicator)         * Integer
%       6 - v (Binary generating indicator)       * Integer
%       7 - y (Binary start-up indicator)         * Integer
%       8 - z (Binary shut-down indicator)        * Integer
%   
%       Variable indexing for each time step:
%           (1)...(b)         = p_gen(1...b)
%           (b+1)...(2*b)     = p_use(1...b)
%           (2*b+1)...(3*b)   = theta(1...b)
%           (3*b+1)...(4*b)   = s_gen(1...b)
%           (4*b+1)...(5*b)   = q(1...b)
%           (5*b+1)...(6*b)   = v(1...b)
%           (6*b+1)...(7*b)   = y(1...b)
%           (7*b+1)...(8*b)   = z(1...b)
%
%   Return struct "UC_solution" contains the following fields:
%   feasible ------------------ Boolean to indicate if the optimisation 
%                               problem was feasible. If it was not 
%                               feasible then the Cplex object is stored as 
%                               another field: "cpx".
%   p ------------------------- Power generated at each generator (MW).
%   q ------------------------- Binary charging decision at each generator.
%   v ------------------------- Binary ON/OFF decision at each generator.
%   y ------------------------- Binary startup indicator at each generator.
%   z ------------------------- Binary shutdown indicator at each generator.
%   s ------------------------- Energy storage at each generator (MWh).
%   delta_theta --------------- Voltage angle difference across each bus
%                               connection, transmission lines and
%                               transformers, (radians). Indexing matches
%                               "bus_connections" input matrix.
%   p_trans ------------------- Power transmitted across each bus
%                               connection, transmission lines and
%                               transformers, (MW). Indexing matches
%                               "bus_connections" input matrix.
%   wind_spilled -------------- Spilled (unused) available wind power.
%   cost ---------------------- Objective function value - optimal total
%                               cost for all generators ($).
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

%% Indexing for generator type
gen_type_brown_coal = 1;
gen_type_black_coal = 2;
gen_type_ccgt = 3;
gen_type_ocgt = 4;
gen_type_cst = 5;
gen_type_utility_storage = 6;
gen_type_wind = 7;
gen_type_utility_pv = 8;

%% Retrieve inputs from struct:

b = UC_input.b;
t = UC_input.t;
tsl = UC_input.tsl;
copper_plate = UC_input.copper_plate;
degrees = UC_input.degrees;
spin = UC_input.spin;
solar_input = UC_input.solar_input;
wind_input = UC_input.wind_input;
demand = UC_input.demand;
b_bus = UC_input.b_bus;

bus_connections = UC_input.bus_connections;
num_bus_connections = size(bus_connections,1);

s_base = UC_input.s_base;

% Generation characteristics:
gen_index = UC_input.generation(:,1);
type_g = UC_input.generation(:,2);
p_cap_g = UC_input.generation(:,3);
p_min_g = UC_input.generation(:,4);
ramp_up_g = UC_input.generation(:,5)*tsl; % tsl converts to MW/t from MW/h
ramp_down_g = UC_input.generation(:,6)*tsl; % tsl converts to MW/t from MW/h
start_cost_g = UC_input.generation(:,7);
shut_cost_g = UC_input.generation(:,8);
srmc_g = UC_input.generation(:,9)*tsl; % tsl converts to $/MWT from $/MWh
mut_g = UC_input.generation(:,10)/tsl; % tsl converts to t from h;
mdt_g = UC_input.generation(:,11)/tsl; % tsl converts to t from h;
s_cap_g = UC_input.generation(:,12);
s_rate_max_g = UC_input.generation(:,13)*tsl; % tsl converts to MWh/t from MWh/h;
s_rate_min_g = UC_input.generation(:,14)*tsl; % tsl converts to MWh/t from MWh/h;
p_use_ramp_up_g = UC_input.generation(:,15)*tsl; % tsl converts to MW/t from MW/h
p_use_ramp_down_g = UC_input.generation(:,16)*tsl; % tsl converts to MW/t from MW/h
s_efficiency_g = UC_input.generation(:,17);

g = size(gen_index,1);

% Create generator characteristics with b rows:
type_b = zeros(b,1); type_b(gen_index) = type_g;
p_cap_b = zeros(b,1); p_cap_b(gen_index) = p_cap_g;
p_min_b = zeros(b,1); p_min_b(gen_index) = p_min_g;
ramp_up_b = zeros(b,1); ramp_up_b(gen_index) = ramp_up_g;
ramp_down_b = zeros(b,1); ramp_down_b(gen_index) = ramp_down_g;
shut_cost_b = zeros(b,1); shut_cost_b(gen_index) = shut_cost_g;
start_cost_b = zeros(b,1); start_cost_b(gen_index) = start_cost_g;
srmc_b = zeros(b,1); srmc_b(gen_index) = srmc_g;
% mut_b = zeros(b,1); mut_b(gen_index) = mut_g; % Not used.
% mdt_b = zeros(b,1); mdt_b(gen_index) = mdt_g; % Not used.
s_cap_b = zeros(b,1); s_cap_b(gen_index) = s_cap_g;
s_rate_max_b = zeros(b,1); s_rate_max_b(gen_index) = s_rate_max_g;
s_rate_min_b = zeros(b,1); s_rate_min_b(gen_index) = s_rate_min_g;
s_efficiency_b = zeros(b,1); s_efficiency_b(gen_index) = s_efficiency_g;
% p_use_ramp_up_b = zeros(b,1); p_use_ramp_up_b(gen_index) = p_use_ramp_up_g; % Not used.
% p_use_ramp_down_b = zeros(b,1); p_use_ramp_down_b(gen_index) = p_use_ramp_down_g; % Not used.
% Additional generator characteristics that are used:
p_use_min_b = s_rate_min_b; p_use_min_b(type_b ~= gen_type_utility_storage) = 0;
p_use_max_b = s_rate_max_b; p_use_max_b(type_b ~= gen_type_utility_storage) = 0;

% Initial conditions:
p_gen_initial = UC_input.p_gen_initial;
p_use_initial = UC_input.p_use_initial;
s_gen_initial = UC_input.s_gen_initial;
% q_initial = UC_input.q_initial; % Not used.
v_initial = UC_input.v_initial;
y_initial = UC_input.y_initial;
z_initial = UC_input.z_initial;

%% Use the following variable indexing for each time step:
% Index 1:          % Index 2:
p_gen_i1 = (1);     p_gen_i2 = (b);
p_use_i1 = (b+1);   p_use_i2 = (2*b);
theta_i1 = (2*b+1); theta_i2 = (3*b);
s_gen_i1 = (3*b+1); s_gen_i2 = (4*b);
q_i1 = (4*b+1);     q_i2 = (5*b);
v_i1 = (5*b+1);     v_i2 = (6*b);
y_i1 = (6*b+1);     y_i2 = (7*b);
z_i1 = (7*b+1);     z_i2 = (8*b);

%% Number of varaibles in one time step:

num_vars = z_i2; % The total number of variables is Num_vars*T

%% Objective function:

%           |-p_gen*-|-p_use*-----|-theta*-----|-s_gen*-----|-q*---------|-v*---------|-y*-----------|-z*----------|
f1 = sparse([ srmc_b ; zeros(b,1) ; zeros(b,1) ; zeros(b,1) ; zeros(b,1) ; zeros(b,1) ; start_cost_b ; shut_cost_b ]); % One time step.
f = repmat(f1,[t,1]); % All time steps.

%% Blocks in Aineq and A matricies:

I_t = speye(t);
I_b_b = speye(b);
O_b_b = sparse(b,b);
I_b_g = I_b_b(gen_index,:); % Identity matrix, rows without connected generator removed.
O_b_g = zeros(g,b); % Zero matrix, rows without connected generator removed.

%% A equality matrix & b equality vector:

disp('    Calculating constraint matrices...');

% Power balance at each bus.
if copper_plate % APPLIES: GEN BUSES ONLY.
    Ablk1 = sparse(1,num_vars);
    Ablk1(gen_index) = 1; % Row to pick out p_gen for busses with generators.
    Ablk1(gen_index+p_use_i1-1) = -1; % Row to pick out -p_use for busses with generators.
    Aeq_pwr_balance = kron(I_t,Ablk1);
    beq_pwr_balance = transpose(sum(demand,1));
else % APPLIES: EACH BUS.
    %       |-p_gen*-|-p_use*----|-theta*--------|-s_gen*-|-q*----|-v*----|-y*----|-z*----|
    Ablk1 = [ I_b_b  , -I_b_b    , -b_bus*s_base , O_b_b  , O_b_b , O_b_b , O_b_b , O_b_b ];
    Aeq_pwr_balance = kron(I_t,Ablk1);
    beq_pwr_balance = reshape(demand,[t*b,1]);
end

% Startup from off, shutdown from on. APPLIES: GEN BUSES ONLY.
%       |-p_gen*-|-p_use*-|-theta*-|-s_gen*-|-q*----|-v*----|-y*-----|-z*----|
Ablk1 = [ O_b_g  , O_b_g  , O_b_g  , O_b_g  , O_b_g , I_b_g , -I_b_g , I_b_g ]; % Atmp is a block used in Aeq_start_shut, this refers to the current time step.
Aeq_start_shut = kron(I_t,Ablk1); % Diagonal blocks in Aeq_start_shut.
%       |-p_gen*-|-p_use*-|-theta*-|-s_gen*-|-q*----|-v*-----|-y*----|-z*----|
Ablk2 = [ O_b_g , O_b_g   , O_b_g  , O_b_g  , O_b_g , -I_b_g , O_b_g , O_b_g ]; % Atmp is a block used in Aeq_start_shut, this refers to the on/off state in the previous time step.
Aeq_start_shut = Aeq_start_shut + [ sparse(g,num_vars*t) ; kron(speye(t-1),Ablk2) , sparse(g*(t-1),num_vars) ]; % Off-diagonal blocks in Aeq_start_shut.
beq_start_shut = [ v_initial ; sparse(g*(t-1),1) ];

% Utility storage plant power balance equation. APPLIES: GEN BUSES ONLY.
utility_storage_index_g = (type_g == gen_type_utility_storage); % Logical index to pick out utility storage units.
utility_storage_index_b = (type_b == gen_type_utility_storage);
num_gen_storage = sum(utility_storage_index_g,1);
Ablk1 = sparse(num_gen_storage,num_vars);
Ablk1(:,p_gen_i1:p_gen_i2) = (-1)*I_b_g(utility_storage_index_g,:); % Block to pick out -p_gen only for utility storage units.
S_efficiency_diag = diag(s_efficiency_b);
Ablk1(:,p_use_i1:p_use_i2) = S_efficiency_diag(utility_storage_index_b,:); % Block to pick out (S_efficiency)*p_use only for utility storage units.
Ablk1(:,s_gen_i1:s_gen_i2) = (-1)*I_b_g(utility_storage_index_g,:)/tsl; % Block to pick out -s_gen only for utility storage units.
Ablk2 = sparse(num_gen_storage,num_vars);
Ablk2(:,s_gen_i1:s_gen_i2) = I_b_g(utility_storage_index_g,:)/tsl; % Block to pick out s_gen only for utility storage units.
Aineq_utility_storage_balance = kron(I_t,Ablk1); % Diagonal blocks.
Aineq_utility_storage_balance = Aineq_utility_storage_balance + [ sparse(num_gen_storage,num_vars*t) ; kron(speye(t-1),Ablk2) , sparse(num_gen_storage*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_storage_balance.
bineq_utility_storage_balance = [sparse(num_gen_storage,1) - s_gen_initial(utility_storage_index_g)/tsl ; sparse(num_gen_storage*(t-1),1)];

% Combine all components of Aeq and beq:
Aeq = [ Aeq_pwr_balance ; Aeq_start_shut ; Aineq_utility_storage_balance ];
beq = [ beq_pwr_balance ; beq_start_shut ; bineq_utility_storage_balance ];

%% A inequality matrix & b inequality vector:

% Charging / discharging mutually exclusive requirement. GEN BUSES ONLY.
Ablk1 = sparse(g,num_vars); % Ablk1 is a block used in Aineq sub-matricies.
Ablk1(:,q_i1:q_i2) = I_b_g; % One block inside Ablk1 is the identity matrix to pick out q.
Ablk1(:,v_i1:v_i2) = I_b_g; % One block inside Ablk1 is the identity matrix to pick out v.
Aineq_charge_discharge = kron(I_t,Ablk1); % This creates diagonal blocks of Ablk1.
bineq_charge_discharge = repmat(ones(g,1),[t,1]);

% Generator output limits. APPLIES: GEN BUSES ONLY.
diag_1 = diag(p_min_b); diag_2 = -diag(p_cap_b);
%       |-p_gen*--|-p_use*-|-theta*-|-s_gen*-|-q*----|-v*------------------|-y*----|-z*----|
Ablk1 = [  -I_b_g , O_b_g  , O_b_g  , O_b_g  , O_b_g , diag_1(gen_index,:) , O_b_g , O_b_g ;...
           I_b_g  , O_b_g  , O_b_g  , O_b_g  , O_b_g , diag_2(gen_index,:) , O_b_g , O_b_g ];
Aineq_gen_out_lim = kron(I_t,Ablk1);
bineq_gen_out_lim = repmat(sparse(2*g,1),[t,1]);

% Utility storage charge limits. APPLIES: GEN BUSES ONLY.
diag_1 = diag(p_use_min_b); diag_2 = -diag(p_use_max_b);
%       |-p_gen*--|-p_use*-|-theta*-|-s_gen*-|-q*------------------|-v*----|-y*----|-z*----|
Ablk1 = [ O_b_g   , -I_b_g , O_b_g  , O_b_g  , diag_1(gen_index,:) , O_b_g , O_b_g , O_b_g ;...
          O_b_g   , I_b_g  , O_b_g  , O_b_g  , diag_2(gen_index,:) , O_b_g , O_b_g , O_b_g ];
Aineq_gen_in_lim = kron(I_t,Ablk1);
bineq_gen_in_lim = repmat(sparse(2*g,1),[t,1]);

% Generator output ramp up rates. APPLIES: GEN BUSES ONLY.
Ablk1 = sparse(g,num_vars); % Ablk1 is a block used in Aineq sub-matricies.
Ablk1(:,p_gen_i1:p_gen_i2) = I_b_g; % One block inside Ablk1 is the identity matrix to pick out p_gen.
Ablk2 = Ablk1;
diag_1 = diag(ramp_up_b-max(ramp_up_b,p_min_b)); %% *** Changed due to previous error *** 20/1/2016 % Diag = diag(Ramp_up_b-p_min_b); *** 4/1/2017 removed tsl from "p_min_b*tsl"
% Need to multiply p_min_b by tsl because it has not already been adjusted to allow variable tsl, whereas Ramp_up_b has. *** 4/1/2017 incorrect - must allow generator to transition from 0MW to p_min MW regardless of the time step length.
Ablk2(:,y_i1:y_i2) = diag_1(gen_index,:); % One block inside Ablk2 is the diagonal matrix with RampUp-max(RampUp,p_min) across diagonals, pick out y.
Aineq_ramp_up = kron(I_t,Ablk2); % This creates diagonal blocks of Ablk2.
Aineq_ramp_up = Aineq_ramp_up + [ sparse(g,num_vars*t) ; kron(speye(t-1),-Ablk1) , sparse(g*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_ramp_up.
bineq_ramp_up = [ ramp_up_g+p_gen_initial ; repmat(ramp_up_g,[t-1,1]) ];

% Generator output ramp down rates. APPLIES: GEN BUSES ONLY.
Ablk2 = -Ablk1; % Pick out -p_gen.
diag_1 = diag(ramp_down_b-max(ramp_down_b,p_min_b)); %% *** Changed due to previous error *** 20/1/2016 % Diag = diag(Ramp_down_b-p_min_b); *** 4/1/2017 removed tsl from "p_min_b*tsl"
% Need to multiply p_min_b by tsl because it has not already been adjusted to allow variable tsl, whereas Ramp_down_b has. *** 4/1/2017 incorrect - must allow generator to transition from 0MW to p_min MW regardless of the time step length.
Ablk2(:,z_i1:z_i2) = diag_1(gen_index,:); % One block inside Ablk2 is the diagonal matrix with RampDown-max(RampDown,pmin) across diagonals, pick out z.
Aineq_ramp_down = kron(I_t,Ablk2); % This creates diagonal blocks of Ablk2.
Aineq_ramp_down = Aineq_ramp_down + [sparse(g,num_vars*t) ; kron(eye(t-1),Ablk1) , sparse(g*(t-1),num_vars)]; % Adding off-diagonal blocks of Aineq_ramp_down.
bineq_ramp_down = [ ramp_down_g-p_gen_initial ; repmat(ramp_down_g,[t-1,1]) ];

% Storage charge rates. APPLIES: GEN BUSES ONLY.
% Required because p_use is not used for CST generators, so this is the only equation to limit their charge rates.
Ablk1 = sparse(g,num_vars); % Ablk1 is a block used in Aineq sub-matricies.
Ablk1(:,s_gen_i1:s_gen_i2) = I_b_g; % One block inside Ablk1 is the identity matrix to pick out s_gen.
Aineq_charge = kron(I_t,Ablk1); % This creates diagonal blocks of Ablk1.
Aineq_charge = Aineq_charge + [ sparse(g,num_vars*t) ; kron(speye(t-1),-Ablk1) , sparse(g*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_charge.
bineq_charge = [ s_rate_max_g+s_gen_initial ; repmat(s_rate_max_g,[t-1,1]) ];

% Storage discharge rates. APPLIES: GEN BUSES ONLY.
% Required because p_use is not used for CST generators, so this is the only equation to limit their charge rates.
Aineq_discharge = kron(I_t,-Ablk1); % This creates diagonal blocks of -Ablk1.
Aineq_discharge = Aineq_discharge + [ sparse(g,num_vars*t) ; kron(speye(t-1),Ablk1) , sparse(g*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_discharge.
bineq_discharge = [ s_rate_max_g-s_gen_initial ; repmat(s_rate_max_g,[t-1,1]) ];

% Storage charging ramp up rates. APPLIES: GEN BUSES ONLY.
Ablk1 = sparse(g,num_vars); % Ablk1 is a block used in Aineq sub-matricies.
Ablk1(:,p_use_i1:p_use_i2) = I_b_g; % One block inside Ablk1 is the identity matrix to pick out p_use.
Aineq_charge_ramp_up = kron(I_t,Ablk1); % This creates diagonal blocks of Ablk1.
Aineq_charge_ramp_up = Aineq_charge_ramp_up + [ sparse(g,num_vars*t) ; kron(speye(t-1),-Ablk1) , sparse(g*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_charge_ramp_up.
bineq_charge_ramp_up = [ p_use_ramp_up_g+p_use_initial ; repmat(p_use_ramp_up_g,[t-1,1]) ];

% Storage charging ramp down rates. APPLIES: GEN BUSES ONLY.
Aineq_charge_ramp_down = kron(I_t,-Ablk1); % This creates diagonal blocks of Ablk1.
Aineq_charge_ramp_down = Aineq_charge_ramp_down + [sparse(g,num_vars*t) ; kron(eye(t-1),Ablk1) , sparse(g*(t-1),num_vars)]; % Adding off-diagonal blocks of Aineq_charge_ramp_down.
bineq_charge_ramp_down = [ p_use_ramp_down_g-p_use_initial ; repmat(p_use_ramp_down_g,[t-1,1]) ];

% mut. APPLIES: GEN BUSES ONLY.
Ablk1 = zeros(g,num_vars); % Don't use sparse, slow indexing pattern.
Ablk2 = Ablk1;
Ablk2(:,v_i1:v_i2) = -I_b_g; % Block to pick out -v for busses with generators.
Ablk3 = Ablk1;
Aineq_mut = kron(I_t,Ablk2); % Diagonal blocks to pick out -v for busses with generators.
for k = 1:(max(mut_g)-1)
    % Update Ablk3 to remove unwanted gen rows:
    Ablk3_gen_index = O_b_g;
    Ablk3_gen_index((mut_g-k)>0,:) = I_b_g((mut_g-k)>0,:); % Generator index with zero rows for no remaining mut.
    Ablk3(:,y_i1:y_i2) = Ablk3_gen_index; % Block to pick out y for busses with remaining mut.
    % Add next off-diagonal blocks of Aineq_mut:
    Aineq_mut = Aineq_mut + [ zeros(k*g,num_vars*t) ; kron(eye(t-k),Ablk3) , zeros(g*(t-k),num_vars*k) ];
end
Aineq_mut = sparse(Aineq_mut);
bineq_mut = zeros(g*t,1);
for k = 1:(max(mut_g)-1) % Iterate to add initial conditions.
    bineq_mut_block = zeros(g,1);
    bineq_temp = zeros(sum((mut_g-k)>0),1);
    y_init_mut_remaining = y_initial((mut_g-k)>0,:);
    mut_remaining = mut_g((mut_g-k)>0) - k;
    % Inner loop is for generator buses with remaining mut only.
    for kk = 1:length(bineq_temp)
       bineq_temp(kk) =  0 - sum(y_init_mut_remaining(kk,1:mut_remaining(kk)));
    end
    bineq_mut_block((mut_g-k)>0) = bineq_temp;
    bineq_mut((k-1)*g+1:k*g) = bineq_mut_block;
end

% mdt. APPLIES: GEN BUSES ONLY.
Ablk1 = zeros(g,num_vars); % Don't use sparse, slow indexing pattern.
Ablk2 = Ablk1;
Ablk2(:,v_i1:v_i2) = I_b_g; % Block to pick out v for busses with generators.
Ablk3 = Ablk1;
Aineq_mdt = kron(I_t,Ablk2); % Diagonal blocks to pick out v for busses with generators.
for k=1:(max(mdt_g)-1)
    % Update Ablk3 to remove unwanted gen rows:
    Ablk3_gen_index = O_b_g;
    Ablk3_gen_index((mdt_g-k)>0,:) = I_b_g((mdt_g-k)>0,:); % Generator index with zero rows for no remaining mdt.
    Ablk3(:,z_i1:z_i2) = Ablk3_gen_index; % Block to pick out z for busses with remaining mdt.
    % Add next off-diagonal blocks of Aineq_mdt:
    Aineq_mdt = Aineq_mdt + [ zeros(k*g,num_vars*t) ; kron(eye(t-k),Ablk3) , zeros(g*(t-k),num_vars*k) ];
end
Aineq_mdt = sparse(Aineq_mdt);
bineq_mdt = zeros(g*t,1);
for k = 1:t % Iterate to add initial conditions:
    bineq_mdt_block = ones(g,1);
    bineq_temp = zeros(sum((mdt_g-k)>0),1);
    z_init_mdt_remaining = z_initial((mdt_g-k)>0,:);
    mdt_remaining = mdt_g((mdt_g-k)>0) - k;
    % Inner loop is for generator buses with remaining mdt only.
    for kk = 1:length(bineq_temp)
       bineq_temp(kk) =  1 - sum(z_init_mdt_remaining(kk,1:mdt_remaining(kk)));
    end
    bineq_mdt_block((mdt_g-k)>0) = bineq_temp;
    bineq_mdt((k-1)*g+1:k*g) = bineq_mdt_block;
end

% Transmission limits. APPLIES: EACH BUS.
if (copper_plate)
    Aineq_trans_limits = [];
else
    block = zeros(2*num_bus_connections,num_vars);
    for k = 1:num_bus_connections
        row = zeros(1,num_vars);
        row((theta_i1-1)+bus_connections(k,1)) = 1; % Pick out theta
        row((theta_i1-1)+bus_connections(k,2)) = -1; % Pick out -theta
        block(2*k-1,:) = row;
        block(2*k,:) = -row;
    end
    Aineq_trans_limits = kron(I_t,block); % Dimensions: (T*2*num_bus_connections,T*Num_vars) 
end
% Each element of bineq_trans_limits is repeated twice.
if (copper_plate)
    bineq_trans_limits = [];
else
    if degrees
        % Voltage angle difference fixed at delta_theta <= degrees
        bineq_trans_limits = deg2rad(degrees)*ones(2*num_bus_connections,1);
    else
        % Power limit from bus_connections
        bineq_trans_limits = reshape(transpose(repmat(bus_connections(:,4)./(bus_connections(:,3)*s_base),1,2)),2*num_bus_connections,1);
    end
    bineq_trans_limits = repmat(bineq_trans_limits,t,1);
end

% CST generator thermal storage balance requirements. APPLIES: GEN BUSES ONLY.
cst_index = (type_g == gen_type_cst); % Logical index to pick out CST generators.
num_cst = sum(cst_index,1);
Ablk1 = sparse(num_cst,num_vars);
Ablk1(:,p_gen_i1:p_gen_i2) = I_b_g(cst_index,:); % Block to pick out p_gen only for CST generators.
Ablk1(:,s_gen_i1:s_gen_i2) = I_b_g(cst_index,:)/tsl; % Block to pick out s_gen only for CST generators.
Ablk2 = sparse(num_cst,num_vars);
Ablk2(:,s_gen_i1:s_gen_i2) = -I_b_g(cst_index,:)/tsl; % Block to pick out -s_gen only for CST generators.
Aineq_cst_storage_balance = kron(I_t,Ablk1); % Diagonal blocks.
Aineq_cst_storage_balance = Aineq_cst_storage_balance + [ sparse(num_cst,num_vars*t) ; kron(speye(t-1),Ablk2) , sparse(num_cst*(t-1),num_vars) ]; % Adding off-diagonal blocks of Aineq_storage_balance.
bineq_cst_storage_balance = [solar_input(cst_index,1) + s_gen_initial(cst_index)/tsl ; reshape(solar_input(cst_index,2:t),num_cst*(t-1),1)];

% Spinning reserve (synchronous generators only). APPLIES: EACH BUS.
synch_index = (type_b == gen_type_brown_coal) | (type_b == gen_type_black_coal) | (type_b == gen_type_ccgt) | (type_b == gen_type_ocgt) | (type_b == gen_type_cst);
% Generators not able to provide spinning reserve: gen_type_wind, gen_type_utility_pv, gen_type_utility_storage.
Ablk1 = sparse(1,num_vars);
Ablk1(p_gen_i1:p_gen_i2) = synch_index; % Row to pick out p_gen for busses with synchronous generators.
Ablk2 = zeros(1,b);
Ablk2(synch_index) = -p_cap_b(synch_index);
Ablk1(v_i1:v_i2) = Ablk2; % Row to pick out v for busses with synchronous generators (with values -p_cap).
Aineq_spin_res = kron(I_t,Ablk1);
bineq_spin_res = transpose(sum(demand,1))*(-spin);

% Combine all components of Aineq and bineq:
Aineq = [ Aineq_charge_discharge; Aineq_gen_out_lim ; Aineq_gen_in_lim; Aineq_ramp_up ; Aineq_ramp_down ; Aineq_charge ;...
    Aineq_discharge ; Aineq_charge_ramp_up ; Aineq_charge_ramp_down ; Aineq_mut ; Aineq_mdt ; Aineq_trans_limits ; Aineq_cst_storage_balance ; Aineq_spin_res];
bineq = [ bineq_charge_discharge ; bineq_gen_out_lim ; bineq_gen_in_lim ; bineq_ramp_up ; bineq_ramp_down ; bineq_charge ;...
    bineq_discharge ; bineq_charge_ramp_up ; bineq_charge_ramp_down ; bineq_mut ; bineq_mdt ; bineq_trans_limits ; bineq_cst_storage_balance ; bineq_spin_res];

%% Bounds (bus 1 theta = 0 as reference bus):

O_b1 = sparse(b,1);
gen_index_b1 = zeros(b,1); gen_index_b1(gen_index) = 1;
p_cap_utility_storage = s_rate_max_b; p_cap_utility_storage(type_b ~= gen_type_utility_storage) = 0;
s_min_b = p_cap_b.*(type_b==gen_type_cst); % s_min limited to p_cap (so that CST can provide spinning reserve)

%     |-p_gen*--|-p_use*----------------|-theta*---------------|-s_gen*--|-q*-----------------------------------|-v*-----------|-y*-----------|-z*-----------|
LB1 = [ O_b1    ; O_b1                  ; 0 ; -Inf*ones(b-1,1) ; s_min_b ; O_b1                                 ; O_b1         ; O_b1         ; O_b1         ]; % One time step.
UB1 = [ p_cap_b ; p_cap_utility_storage ; 0 ; Inf*ones(b-1,1)  ; s_cap_b ; (type_b == gen_type_utility_storage) ; gen_index_b1 ; gen_index_b1 ; gen_index_b1 ]; % One time step.
LB = repmat(LB1,[t,1]); % All time steps.
UB = repmat(UB1,[t,1]); % All time steps.

% Include wind generator output constraint due to available input power at each time step:
%                         |-p_gen*--------------------|-p_use*-----|-theta*-----|-s_gen*-----|-q*---------|-v*---------|-y*---------|-z*---------|
wind_p_gen_index = repmat([ (type_b == gen_type_wind) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ],t,1);
UB(wind_p_gen_index) = reshape(wind_input(type_g == gen_type_wind,:),sum(type_g == gen_type_wind)*t,1);

% Include utility PV generator output constraint due to available input power at each time step:
%                               |-p_gen*--------------------------|-p_use*-----|-theta*-----|-s_gen*-----|-q*---------|-v*---------|-y*---------|-z*---------|
utility_pv_p_gen_index = repmat([ (type_b == gen_type_utility_pv) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ; false(b,1) ],t,1);
UB(utility_pv_p_gen_index) = reshape(solar_input(type_g == gen_type_utility_pv,:),sum(type_g == gen_type_utility_pv)*t,1);

%% Specify integer/continuous variables:

%       |---Continuous------|---Integer---------|
ctype = [ repmat('C',4*b,1) ; repmat('I',4*b,1) ]; % One time step.
ctype = repmat(ctype,t,1); % All time steps.


%% Set up MILP problem as Cplex object:

cpx = Cplex('UC_MILP_Model');

cpx.Model.sense = 'minimize';

      cpx.Model.obj   = f;
      cpx.Model.lb    = LB;
      cpx.Model.ub    = UB;
      cpx.Model.A     = [Aeq ; Aineq];
      cpx.Model.lhs   = [beq ; -inf*ones(length(bineq),1)];
      cpx.Model.rhs   = [beq ; bineq];
      cpx.Model.ctype = ctype';
      cpx.DisplayFunc = [];
      cpx.output.clonelog = -1; % Inhibits log file creation for Cplex V 12.6.0.1 and later.
      cpx.Param.mip.tolerances.absmipgap.Cur = 1e-2; % Reduce required tolerance gap to speed up solution.

%% Solve:

disp('    Solving with CPLEX...');

cpx.solve();

%% Retrieve solution:

if (cpx.Solution.status ~= 101) && (cpx.Solution.status ~= 102)
    UC_solution.feasible = false;
    UC_solution.cpx = cpx; % Used to check infeasibility.
    UC_solution.cpx_solution = cpx.Solution; % Solution saved separately because it is not saved when cpx object is saved.
    fprintf('UC problem is INFEASIBLE.\n');
    return;
end
UC_solution.feasible = true;

% Save solution in return struct:
x = reshape(cpx.Solution.x,[num_vars,t]);
p_gen_b = x(p_gen_i1:p_gen_i2,:); % Power generated at each bus.
p_use_b = x(p_use_i1:p_use_i2,:); % Power used for storage at each bus.
theta_b = x(theta_i1:theta_i2,:); % Voltage angle at each bus.
s_gen_b = x(s_gen_i1:s_gen_i2,:); % Energy storage at each bus.
q_b = round(x(q_i1:q_i2,:)); % Binary charging decision
v_b = round(x(v_i1:v_i2,:)); % Binary generating decision
y_b = round(x(y_i1:y_i2,:)); % Binary turn-on decision.
z_b = round(x(z_i1:z_i2,:)); % Binary turn-off decision.
% v, y, and z seem to have some values with rounding error - very close to
% 0 or very close to 1. I'm not sure how this affects the solution when 
% used as initial conditions so I have decided to remove rounding error. 
% The function round() is very fast.

UC_solution.p_gen = p_gen_b(gen_index,:);
UC_solution.p_use = p_use_b(gen_index,:);
UC_solution.s_gen = s_gen_b(gen_index,:);
UC_solution.q = q_b(gen_index,:);
UC_solution.v = v_b(gen_index,:);
UC_solution.y = y_b(gen_index,:);
UC_solution.z = z_b(gen_index,:);

% Calculate the voltage angle difference across each line:
delta_theta = zeros(num_bus_connections,t);
for t = 1:t
   th = theta_b(:,t);
   delta_theta(:,t) = (th(bus_connections(:,1)) - th(bus_connections(:,2)));
end
UC_solution.delta_theta = delta_theta;

UC_solution.p_trans = repmat((bus_connections(:,3)*s_base),1,t).*delta_theta;

% Calculate spilled wind:
wind_spilled = zeros(g,t);
wind_spilled((type_g == gen_type_wind),:) = round(wind_input((type_g == gen_type_wind),:) - UC_solution.p_gen((type_g == gen_type_wind),:),2);
UC_solution.wind_spilled = wind_spilled;

UC_solution.cost = cpx.Solution.objval; % Optimal total cost.

end