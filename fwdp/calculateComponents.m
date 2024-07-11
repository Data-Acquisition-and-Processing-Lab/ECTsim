%% calculateComponents - Calculates values of measurement components.
%
% This function calculates key measurement components, which are then used
% by the calculateMeasurement function. The calculated components include
% capacitance, conductivity, and admittance.
%
% Usage:
%   model = calculateComponents(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with calculated measurement components.
%           The calculated values include:
%             model.C - Capacitance.
%             model.G - Conductivity.
%             model.Y - Admittance.
%
% Example:
%   % Assume model is already initialized
%   model = calculateComponents(model);
%   % This will calculate and store the capacitance, conductivity, and admittance in the model.
%
% See also: calculateMeasurement
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = calculateComponents(model)
    
    model.G = imag(model.K)*2*pi*model.f; % Conductance
    if any(model.G<0)
        model.G = abs(model.G); % If value is smaller than 0 it is numerical error
        fprintf('Conductane part was not calculated correctly. The grid resolution is too low for a case with such low conductivity');
    end
    model.C = real(model.K); % Capacitance
    if any(model.C<0)
        model.C = abs(model.C); % If value is smaller than 0 it is numerical error
        fprintf('Capacitance part was not calculated correctly. The grid resolution is too low for a case with such high conductivity');
    end
    model.Y = model.G+1i*model.C*2*pi*model.f; % Admitance

end