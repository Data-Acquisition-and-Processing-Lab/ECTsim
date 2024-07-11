%% setElectrodes - Identifies and enumerates electrodes based on their excitation potential within the model.
%
% This function identifies and enumerates electrodes in the numerical model based on their
% excitation potential.
%
% Usage:
%   model = setElectrodes(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with identified and enumerated electrodes.
%
% Example:
%   % Assume model is already initialized
%   model = setElectrodes(model);
%   % This will identify and enumerate the electrodes in the model based on their excitation potential.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = setElectrodes(model)
% TODO: this function requires verification
model.Electrodes.num = 0;
model.Electrodes.elements = [];


for i=1:numel(model.Sensor)
    if ~isempty(model.Sensor{i}.excitation_potential)
        model.Electrodes.num = model.Electrodes.num + 1;
        model.Electrodes.elements = [model.Electrodes.elements,i];
    end
end

if model.Electrodes.num==0
    disp('Electrodes with the excitation voltage have not been found!');
else
    if model.Electrodes.num==1
        disp('One excitation electrode has been found.');
    elseif model.Electrodes.num>1
        string=[int2str(model.Electrodes.num),' excitation electrodes have been found.'];
        disp(string);
    end
    string = [];
    for i=1:model.Electrodes.num
        string = [string, model.Sensor{model.Electrodes.elements(i)}.name, ', '];
    end
    disp(string);
end
