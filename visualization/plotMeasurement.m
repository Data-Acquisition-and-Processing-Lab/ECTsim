%% plotMeasurement 
% plots mutual measurements  of electrodes 
% 
% *usage:* |[] = plotMeasurements(mode, part, index, nameList, varargin)|
%
% * _mode_  - linear, log
% * _part_  - C, G
% * _index_ - range of dispalyed pairs of electrodes - 1:30
% * _nameList_ - listo of names for capacitances vectors used in legend - ['min';'max']
% * -varargin-  - capacitances vectors, max three
% * maximally 8 plots  
%
% footer$$

function [] = plotMeasurement(mode, part, index, modelList, varargin)
if(numel(varargin))
    nameList = varargin{1};
else
    nameList = {};
end
palette = {'b-v', 'r-^', 'k-+', 'g-o', 'm-s', 'c-*', 'y-x', 'r-d'};
legendRow = cell(1,length(modelList));

if length(modelList)<1
    error('There is no data to display')
elseif length(modelList)>8
    error('plotMeasurement() can display a maximum of eight charts')
end
if (strcmp(part,'C') || strcmp(part,'G')) == 0
    error(['Unknown option: ', part, '!?']);
end

figure('Name',['Measurements - ' part ' part (' mode ' scale)'],'NumberTitle','off');
hold on

for i=1:length(modelList)
    if strcmp(part,'C')
        plot(index,modelList{i}.C(index),palette{i});
    elseif strcmp(part,'G')
        plot(index,modelList{i}.G(index),palette{i});
    end
    if length(nameList)>=i
        legendRow{i} = nameList{i};
    else
        legendRow{i} = ['model ', num2str(i)];
    end
end

legend(legendRow);
set(gca,'yscale',mode);
if strcmp(part,'C')
    strTitle=['Measurements of capacitance (' mode ' scale)'];
    ylabel('Capacitance [F]')
elseif strcmp(part,'G')
    strTitle=['Measurements of conductance (' mode ' scale)'];
    ylabel('Conductance [S]')
end
title(strTitle);
xlabel('Electrode pair')
grid minor
hold off










