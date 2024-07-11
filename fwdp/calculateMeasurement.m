%% calculateMeasurement - Calculates values of measurements.
%
% This function calculates various measurement values for a numerical model.
% It computes the complex capacitance and uses the calculateComponents function
% to obtain additional parameters such as capacitance, conductivity, and admittance.
%
% Usage:
%   model = calculateMeasurement(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with calculated measurement values, including:
%           model.K - Complex capacitance.
%           The function also uses calculateComponents to obtain:
%             model.C - Capacitance.
%             model.G - Conductivity.
%             model.Y - Admittance.
%
% Example:
%   % Assume model is already initialized
%   model = calculateMeasurement(model);
%   % This will calculate and store the measurement values in the model.
%
% See also: calculateComponents
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = calculateMeasurement(model)

    fprintf('Calculating measurement components ...... '); tic;

    model.K=((model.eps0*(model.qt.eps(:)+1i*model.qt.sigma(:))).'*model.qt.Sens(:,:)).'; %Complex capacitance

    model = calculateComponents(model); % C, G and Y

    fprintf(' . Done. '); toc
end