%% sensorElectrodePairs - Sets the number of electrode pairs and assigns excitation voltages.
%
% This function sets the number of electrode pairs and assigns excitation voltages to both
% excitation and receiving electrodes. It requires some sensor fields to be set before running.
%
% Usage:
%   model = sensorElectrodePairs(model)
%
% Inputs:
%   model - Structure with a model description. This function requires some sensor fields to be set before running: sensor.measurements_all.
%
% Outputs:
%   model - Updated model structure with the electrode pairs and excitation voltages set.
%
% Example:
%   % Assume model is already initialized and sensor fields are set
%   model = sensorElectrodePairs(model);
%   % This will set the number of electrode pairs and assign excitation voltages in the model.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = sensorElectrodePairs(model)

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
