function [ solar_input ] = UCGUI_solar(file_name, num_days, start_day, p_cap, type, solar_multiple, gen_index, time_step_length)
% UCGUI_solar generates solar input traces for the Matlab Unit Commitment 
% Toolbox.
% 
% g*t matrix containing the solar input at each bus for each time step (MW).
%
%   Ensure all relevant Excel files are included in the Matlab path.
%   Start_day is mapped to the same dates as for other traces. For
%   example, 366 is mapped to 1/7/2015.
%
% Use PV traces for CST generators because CR traces are shifted by AEMO to
% later in the day as their attempt to model thermal storage.
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

%% Read, scale, and re-arrange input data to be presented in required form:

% Number of generators:
g = size(p_cap,1);

% Names of traces associated with each bus:
[~,solar_trace_names,~] = xlsread(file_name,'Bus index','E2:E999');

% Number of hours:
h = num_days*24;

r1 = start_day+1461; % 1461 adjusts from 1/7/2010 to 1/7/2014
c1 = 3;
r2 = r1+num_days-1;
c2 = 26;

solar_input = zeros(g,h);
for j = 1:g
   if (type(j) == 5) || (type(j) == 8) % 5 is for CST, 8 is for Utility PV.
      solar_input(j,:) = reshape(transpose(csvread(solar_trace_names{gen_index(j)},r1,c1,[r1, c1,  r2, c2])),1,h);
   end
end
% Solar traces found to have negative values (for example "LV Solar Real PV.csv").
% This is a waste of computational time, but at least it is robust against AEMO's erroneous data:
solar_input(solar_input<0) = 0;

% Scale solar input traces to the power available to each generator:
solar_input = solar_input.*repmat(solar_multiple.*p_cap,1,h);

%% Extend matrices from hourly to required number of time steps:
% Currently I'm just repeating the trace throughout each whole
% hour, a better solution would be to fit a curve that gives a different
% value at each time step while keeping the total energy constant!

solar_input = repelem(solar_input,1,1/time_step_length);

end