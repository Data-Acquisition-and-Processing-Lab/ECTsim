%% getConductivityMap - Creates a vector of conductivity values for the elements in the workspace.
%
% This function creates a vector of conductivity values for the elements in the workspace,
% normalized by 2πfε₀.
%
% Usage:
%   sigmaMap = getConductivityMap(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   sigmaMap - Vector of conductivity values normalized by 2πfε₀.
%
% Example:
%   % Assume model is already initialized
%   sigmaMap = getConductivityMap(model);
%   % This will return the conductivity map for the elements in the workspace.
%
% See also: getPermittivityMap and getElementMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [sigmaMap] = getConductivityMap(model)

if model.dimension == 2
    sigmaMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints);
else
    sigmaMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints, model.Mesh.depthPoints);
end

for i=1:numel(model.Sensor)
    sigmaMap(model.Sensor{i}.location_index)=model.Sensor{i}.conductivity;
end


end
