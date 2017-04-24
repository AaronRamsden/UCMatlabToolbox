function [ wind_input ] = UCGUI_wind(file_name, num_days, start_day, p_cap, type, gen_index, time_step_length)
% UCGUI_wind generates wind input traces for the Matlab Unit Commitment 
% Toolbox.
% 
% g*h matrix containing the wind input at each bus for each time step (MW).
%
%   Ensure all relevant Excel files are included in the Matlab path.
%   Start_day is mapped to the same dates as for other traces. For
%   example, 366 is mapped to 1/7/2015.
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

%% Read, normalise, and rearrange input data:

% Number of generators:
g = size(p_cap,1);

% Names of traces associated with each bus:
[~,wind_trace_names,~] = xlsread(file_name,'Bus index','D2:D999');

% Number of hours:
h = num_days*24;

r1 = start_day;
c1 = 3;
r2 = start_day+num_days-1;
c2 = 26;

wind_input = zeros(g,h);

for j = 1:g
   if type(j) == 7 % Wind is type 7
      wind_input(j,:) = reshape(transpose(csvread(wind_trace_names{gen_index(j)},r1,c1,[r1, c1,  r2, c2])),1,h);
   end
end

% Ensure that wind profiles are normalised to 1. The traces should be 
% normalised to one, but some traces seem to have a few values > 1. The 
% traces that I chose don't seem to have this problem, but this check is 
% included for robustness.
wind_input(wind_input > 1) = 1;

% Normalise to wind capacity:
wind_input = wind_input.*repmat(p_cap,1,h);

%% Extend matrices from hourly to required number of time steps:
% Currently I'm just repeating the trace throughout each whole
% hour, a better solution would be to fit a curve that gives a different
% value at each time step while keeping the total energy constant!

wind_input = repelem(wind_input,1,1/time_step_length);

end