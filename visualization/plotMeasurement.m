%% plotMeasurements - Plots mutual measurements of electrodes with a maximum of 8 plots at a time.
%
% This function plots mutual measurements of electrodes, with a maximum of 8 plots displayed at a time.
%
% Usage:
%   plotMeasurements(mode, part, index, modelList, nameList)
%
% Inputs:
%   mode      - Display mode ('linear', 'log').
%   part      - Type of measurement ('C' for capacitance, 'G' for conductance).
%   index     - Range of displayed pairs of electrodes (e.g., [1:31]).
%   modelList - List of models (e.g., {modelMin, modelMax}).
%   nameList  - (optional) Names for capacitance vectors used in legends (e.g., {'min', 'max'}); defaults to model1, model2, etc., if not provided.
%
% Outputs:
%   None
%
% Example:
%   % Assume modelList is already initialized
%   plotMeasurements('linear', 'C', [1:31], {modelMin, modelMax}, {'min', 'max'});
%   % This will plot the capacitance measurements for the specified range of electrode pairs in linear mode with custom legends.
%
% See also: plotNorm
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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










