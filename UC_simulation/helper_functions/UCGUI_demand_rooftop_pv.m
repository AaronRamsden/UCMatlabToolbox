function [ demand_bus_trace,pv_node_trace,demand_node_trace ] = UCGUI_demand_rooftop_pv(file_name, num_days, start_day, rooftop_pv, subtract_rooftop_pv, time_step_length)
% UCGUI_demand_rooftop_pv returns demand at each bus as a b*t matrix.
% 
% Rows correspond to busses, columns correspond to individual time-steps.
% Each node corresponds to a single aggregated demand trace.
% Demand for each node is disaggregated and allocated to busses within that
% node according to the relative weighting for each bus within the same 
% node.
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

%% Read input data:

[bus_data,trace_names,~] = xlsread(file_name,'Bus index','A2:E999');
% Names of solar traces associated with each bus:
solar_trace_names = trace_names(:,2);
bus_node_index = bus_data(:,2);
bus_demand_weighting = bus_data(:,3);
for i = 1:size(bus_data,1) % The relative weightings are normalised to sum to 1 because they may not already do so.
    node_total_weighting = sum(bus_demand_weighting(bus_data(:,2) == bus_data(i,2)));
    if node_total_weighting
        bus_data(i,3) = bus_demand_weighting(i)/node_total_weighting;
    end
end
bus_demand_weighting = bus_data(:,3);

derate_pv = 0.55; % Derating used to match annual energy to capacity.

[node_data, node_text, ~] = xlsread(file_name,'Node index','A2:C999');
node_pv_cap = (node_data(:,3)./sum(node_data(:,3)))*derate_pv*rooftop_pv;
node_index = node_data(:,1);

%% Solar PV traces (with scaling by capacity):

% Number of hours:
h = num_days*24;

r1 = start_day+1461; % 1461 adjusts from 1/7/2010 to 1/7/2014
c1 = 3;
r2 = r1+num_days-1;
c2 = 26;

pv_node_trace = zeros(size(node_index,1),h);
% Average each solar trace within this node:
for j = 1:size(node_index,1) % Iterate through each node.
    current_node = node_index(j);
    current_solar_trace_names = solar_trace_names(bus_node_index == current_node);
    current_busses = sum(bus_node_index == current_node,1);
    for k = 1:current_busses % Iterate through each bus in current node.
        pv_node_trace(j,:) = pv_node_trace(j,:) +...
            reshape(transpose(csvread(current_solar_trace_names{k},r1,c1,[r1, c1,  r2, c2])),1,h);
    end
    % Normalise trace back to unity and scale by capacity:
    pv_node_trace(j,:) = (pv_node_trace(j,:)/current_busses)*node_pv_cap(node_index==current_node);
end

%% Demand at each node:

demand_node_trace = zeros(size(node_index,1),h);
for j = 1:size(node_index,1)
    demand_node_trace(j,:) = reshape(transpose(csvread(node_text{j},start_day,3,[start_day,3,start_day+num_days-1,26])),[1,num_days*24]);
end

%% Correct if PV is to be subtracted:

if subtract_rooftop_pv
    demand_node_trace = demand_node_trace - pv_node_trace;
end

%% Allocate demand to individual busses within each node:

demand_bus_trace = zeros(size(bus_data,1),h);
for j = 1:size(bus_data,1)
    demand_bus_trace(j,:) = demand_node_trace(find(node_index == bus_data(j,2),1),:)*bus_demand_weighting(j);
end

%% Extend matrices from hourly to required number of time steps:
% Currently I'm just repeating the demand and PV throughout each whole
% hour, a better solution would be to fit a curve that gives a different
% value at each time step while keeping the total energy constant!

demand_bus_trace = repelem(demand_bus_trace,1,1/time_step_length);
pv_node_trace = repelem(pv_node_trace,1,1/time_step_length);
demand_node_trace = repelem(demand_node_trace,1,1/time_step_length);

end