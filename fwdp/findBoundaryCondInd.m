%% findBoundaryCondInd
%
% Finds mesh points where: 
%
% * boundary conditions are set (every point in the model that has a 
%   known value of electric potential);
% * potential is switched (e.g. excitation electrodes)
% * potential is unknown and should be calculated
% 
% *usage:* |[bcInd, elInd, calcInd] = findBoundaryCondInd(model)|
%
% * _model_     - structure with a numerical model description
%
% *returnes:* three set of point indices
%
% footer$$

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

