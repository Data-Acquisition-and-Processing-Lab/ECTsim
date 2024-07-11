%% specifyFOV - Determines the indices of the area of interest inside the sensor.
%
% This function identifies the indices of the area of interest (Field of View, FOV)
% inside the sensor. These indices are subsequently used by other functions to present
% data and in upscaleModel during nonlinear reconstruction.
%
% Usage:
%   model = specifyFOV(model, name)
%
% Inputs:
%   model - Structure with a numerical model description.
%   name  - Name of the element to be saved as the Field of View (FOV).
%
% Outputs:
%   model - Updated model structure with the specified Field of View.
%   model.FOV_name and model.FOV_full
%
% Example:
%   % Assume model is already initialized
%   model = specifyFOV(model, 'FOV_Element');
%   % This will determine the indices of 'FOV_Element' and save it as the Field of View.
%
% See also: upscaleModel
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = specifyFOV(model,name)

    model.FOV_name = name;
    model.FOV_full = findIndex(model, name); % Determine the indices of the area of interest inside the sensor

end