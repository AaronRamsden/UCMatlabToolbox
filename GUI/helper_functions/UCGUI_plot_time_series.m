function [ ] = UCGUI_plot_time_series( input, result, plotting )
% UCGUI_plot_time_series plots generator output, total demand, and rooftop 
% PV generation for the Matlab Unit Commitment Toolbox.
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

%% Plot:

tsl = input.time_step_length;

fig = figure; % Use a new figure window.
fig.Units = 'centimeters';
fig.Position = [5   5   27   14];
fig.Color = 'white';
ax = gca;
ax.Box = 'on';
ax.Color = 'white';

set(ax,'FontName', 'mwa_cmr10');

H = area(transpose([result.p_gen;result.rooftop_pv_generation]));
for i = 1:size(plotting.gen_colours,1)
    set(H(i),'FaceColor',rgb(plotting.gen_colours(i)),'LineStyle','none');
end
for i = 1:size(plotting.rooftop_pv_colours,1)
    set(H(i+size(plotting.gen_colours,1)),'FaceColor',rgb(plotting.rooftop_pv_colours(i)),'LineStyle','none');
end

labels = repmat({''},1,24/tsl); % 1 day
labels(1:(1/tsl):24/tsl) = num2cell([0 1:12 13:23]);
labels = repmat(labels,1,input.loops);
% Even if the labels are too bunched one can zoom in and see the time of day rather than having to calculate that from the first hour of the simulation.
set(ax,'XLim',[1 (24/tsl)*input.keep_days*input.loops],'XTick',1:(24/tsl)*input.keep_days*input.loops+1,'XTickLabel',labels,'Layer','Top');

yl = get(ax, 'ylim');
ylim([0 yl(2)]);

% Plot total demand as a line:
hold on;
h = plot(result.network_demand,'-.');
set(h,'Color',rgb('Black'));
hold off;

num_items = size(H,2);
num_pv = size(plotting.rooftop_pv_names,1);
legend([H(num_items:-1:num_items-num_pv+1),h,H(num_items-num_pv:-1:1)],[flipud(plotting.rooftop_pv_names);{'Total demand'};flipud(plotting.gen_names)],'interpreter','latex','Location','Best');
title(ax,'Generator output power','interpreter','latex');
ylabel('MW','interpreter','latex');
xlabel('Hours','interpreter','latex');
ax.FontSize = 8;

end