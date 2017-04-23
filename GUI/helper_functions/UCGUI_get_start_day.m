function [ start_day ] = UCGUI_get_start_day( day, month, year )
% UCGUI_Get_start_day returns a single number corresponding to the date
% given, that can be used to reference NTNDP traces.
% 
%   NTNDP traces are arranged in spreadsheets with each day represented by
%   an individual row. start_day is a reference used to read the correct 
%   row that corresponds to the day, month, and year given to this function
%   as an input.
% 
% Demand: 1/7/2014 - 30/6/2040 (row 9498)
% Wind: 1/7/2014 - 30/6/2045 (row 11324)
% Solar: 1/7/2010 - 30/6/2040 (row 10959)
% 
% Valid days are within: 1/7/2015 - 30/6/2040
% 1/7/2015 is chosen to allow enough previous days to run the
% pre-simulation.
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

%% Basic error checking:

if day < 1 || day > 31 || month < 1 || month > 12 || year < 2015 || year > 2040
    start_day = -1;
    return;
end
if (year == 2015 && month < 7) || (year == 2040 && month > 6) || (year == 2040 && month == 6 && day > 30)
    start_day = -1;
    return;
end

%% Get start day:

ref_data = csvread('2014 NSW1 High 10POE_0910refyr.csv',1,0,'A2..C9498');
start_day = find(ismember(ref_data,repmat([year,month,day],9497,1),'rows'));

end