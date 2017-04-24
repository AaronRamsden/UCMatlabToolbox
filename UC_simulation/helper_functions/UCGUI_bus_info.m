function [b,b_bus,bus_connections] = UCGUI_bus_info(file_name, p_cap, gen_index)
% UCGUI_bus_info B-Bus calculation from input spreadsheet "file_name"
% 
% This function calculates the negated bus admittance matrix as well as a
% table of bus connections with MW transfer limits and susceptances for 
% each connection. The number of busses is also returned.
%
% The bus admittance matrix is intended to be used for "DC Power flow" 
% simulations and so only the series reactances are used. Both transmission
% lines and transformers are considered. There are only susceptances 
% included in the bus, hence it is called the "B_bus". Further, the 
% susceptances are negated so that b = 1/x rather than b = -1/x. This is 
% done so that the power equation in the DC Power Flow simulation becomes 
% p = b*delta_theta rather than p = (-b)*delta_theta.
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

%% Variable to keep track of number of busses in system:

b = max(xlsread(file_name,'Bus index','A:A'));

%% Load data from Excel:

connection_data = xlsread(file_name,'Bus connections','A:F');
connection_data(:,3) = (connection_data(:,3).^(-1)).*connection_data(:,4);
% Columns of Connection_data: 
%       1.  From Index
%       2.  To Index
%       3.  Absolute value of total susceptance (pu on 100 MVA)
%       4.  Number of parallel lines/tx's
%       5.  Total transmission limit (MW) (already combined all parallel connections)
%       6.  Boolean to indicate generator isolating connection (1 or 0)

%% Correct MW transfer limits for connections that isolate a generator:
% This is done so that a generator is not limited to produce below its
% rating due to a weak connection to the grid.

% Temporary copy of Connection_data to index the rows corresponding to 
% isolating connections only:
connection_data_isolating = connection_data(logical(connection_data(:,6)),:);

% Vector to overwrite the power transfer limits for the rows where there is
% an isolating connection:
transfer_limit_new = connection_data_isolating(:,5);
for j = 1:size(connection_data_isolating,1)    
    for k = 1:size(gen_index,1)    
        if connection_data_isolating(j,1) == gen_index(k) || connection_data_isolating(j,2) == gen_index(k)
            transfer_limit_new(j) = p_cap(k);
        end
    end
end
% Set new transfer limits:
connection_data(logical(connection_data(:,6)),5) = transfer_limit_new;

%% Index of bus connections via transformer or transmission line:
%  bus_connections ----------- ?*4 matrix listing all transmission line
%                              and transformer connections between busses.
%                              Columns correspond to:
%                                       1. From bus number
%                                       2. To bus number
%                                       3. Series susceptance between
%                                          busses (pu)
%                                       4. Maximum power limit (MW)

bus_connections = [ connection_data(:,1:3) , connection_data(:,5) ];

%% Sort Bus_connections:
% Required so that removing parallel connections works correctly.

% First sort by "To bus":
[~,I] = sort(bus_connections,1);
bus_connections = bus_connections(I(:,2),:);
% Then sort by "From bus":
[~,I] = sort(bus_connections,1);
bus_connections = bus_connections(I(:,1),:);

%% Remove duplicates (parallel connections) of Bus_connections:

k = 1;
while k < (size(bus_connections,1) - 1)
    if bus_connections(k,1:2) == bus_connections(k+1,1:2) % Order of Bus_connections is already sorted, so parallel connections will be listed sequentially.
        bus_connections(k,3:4) = bus_connections(k,3:4) + bus_connections(k+1,3:4); % Add susceptances and power limits.
        bus_connections(k+1,:) = []; % Remove row of parallel connection.
    end
    k = k + 1;
end

%% Allocate space for B Bus (Bus Admittance Matrix):

b_bus = zeros(b);

%% Diagonal entries of B Bus:

for k = 1:length(bus_connections(:,1))
    kk = bus_connections(k,1);
    b_bus(kk,kk) = b_bus(kk,kk) + bus_connections(k,3);
    kk = bus_connections(k,2);
    b_bus(kk,kk) = b_bus(kk,kk) + bus_connections(k,3);
    
end

%% Off-diagonal entries of B Bus:

for k = 1:length(bus_connections(:,1))
    from_bus = bus_connections(k,1);
    to_bus = bus_connections(k,2);
    b_bus(from_bus,to_bus) = b_bus(from_bus,to_bus) - bus_connections(k,3);
    b_bus(to_bus,from_bus) = b_bus(to_bus,from_bus) - bus_connections(k,3);
end

%% Convert to sparse matrix to save storage space:

b_bus = sparse(b_bus);

end