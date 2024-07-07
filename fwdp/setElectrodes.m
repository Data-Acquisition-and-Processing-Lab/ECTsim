%% setElectrodes 
% finds elements with the excitation potential and enumerates
% electrodes;
%
% *usage:* |[model] = setElectrodes(model)|
% 
% _model_   - structure with a numerical model description
%
% footer$$


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
