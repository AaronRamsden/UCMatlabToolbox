function [ gen_data, gen_names, gen_colours ] = UCGUI_generation(file_name)
% UCGUI_generation reads generator characteristics from input spreadsheet "File_name"
% 
% "gen_data" is a g*18 matrix containing relevant generator data.
% Columns correspond to:
% 1. Bus number
% 2. Type                                                   (numeric key)
%      1. Brown Coal
%      2. Black Coal
%      3. CCGT
%      4. OCGT
%      5. CST
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
% 18. Solar multiple                                        (unitless)
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

%% Read generation data from excel:

[gen_data, text, ~] = xlsread(file_name,'Generator data','A2:T999');
% "999" is a "magic number" but I can't find another way of getting a variable cell range that omits row 1

%% Re-arrange row order:

[~, sort_index] = sort(gen_data(:,1));
gen_data = gen_data(sort_index,:);
gen_names = text(sort_index,1);
gen_colours = text(sort_index,2);

%% Clear numbers that are not valid:

type = gen_data(:,2);
gen_data(type~=6,17) = 0; % S_efficiency (6 is for utility storage)
gen_data(type~=5 & type~=8,18) = 0; % Solar_multiple (5 is for CST, 8 is for utility PV)

end