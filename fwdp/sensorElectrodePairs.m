%% sensorElectrodePairs 
% sets number of electrode numbers in the electrode pairs
% sets vector of excitation voltages on excitation and receiving electrodes
%
% *usage:* |[model] = sensorElectrodePairs(model)|
%
% _model_    - structure with model description
%             (function requires some sensor field to be set befor running:
%             sensor.measurements_all)
%
% footer$$

function [model] = sensorElectrodePairs(model)

% ---TODO: przeniesione z setElectrodes
if model.measurements_all==1 % electrode combinations
    model.measurement_count = model.Electrodes.num*(model.Electrodes.num-1);  % number of measurement 
else
    model.measurement_count = model.Electrodes.num*(model.Electrodes.num-1)/2;  % number of measurement
end

% electrode numbers in electrode pairs
[model.Electrodes.app_el, model.Electrodes.rec_el] = electrodePairs(model.Electrodes.num, model.measurements_all);

% voltage on a measurement electrode pair
for indx=1:numel(model.Electrodes.app_el)
    model.Electrodes.app_v(indx)= model.Sensor{model.Electrodes.elements(model.Electrodes.app_el(indx))}.excitation_potential; % voltages on electrodes
    model.Electrodes.rec_v(indx)= model.Sensor{model.Electrodes.elements(model.Electrodes.rec_el(indx))}.potential;
end
