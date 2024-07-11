%% findBoundaryCondInd - Finds mesh points with specific boundary conditions.
%
% This function finds mesh points where:
%   1. Boundary conditions are set (every point in the model that has a known value of electric potential).
%   2. Potential is switched (e.g., excitation electrodes).
%   3. Potential is unknown and should be calculated.
%
% Usage:
%   [bcInd, elInd, calcInd] = findBoundaryCondInd(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   bcInd   - Indices of points with boundary conditions set.
%   elInd   - Indices of points where potential is switched.
%   calcInd - Indices of points where potential is unknown and should be calculated.
%
% Example:
%   % Assume model is already initialized
%   [bcInd, elInd, calcInd] = findBoundaryCondInd(model);
%   % This will return the indices of points with boundary conditions, switched potential, and unknown potential.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [bcInd, elInd, calcInd] = findBoundaryCondInd(model)

bcInd=[];
elInd=[];
calcInd=[];


for i=1:numel(model.Sensor)
    if isempty(model.Sensor{i}.potential)
        calcInd=[calcInd, model.Sensor{i}.location_index'];
    else
        bcInd=[bcInd, model.Sensor{i}.location_index'];
        if ~isempty(model.Sensor{i}.excitation_potential)
            elInd=[elInd, model.Sensor{i}.location_index'];
        end
    end
end

