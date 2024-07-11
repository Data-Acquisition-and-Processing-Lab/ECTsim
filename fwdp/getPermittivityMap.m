%% getPermittivityMap - Creates a vector of permittivity values for the elements in the workspace.
%
% This function creates a vector of permittivity values for the elements in the workspace,
% providing a map of relative permittivity values.
%
% Usage:
%   epsMap = getPermittivityMap(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   epsMap - Map of relative permittivity values.
%
% Example:
%   % Assume model is already initialized
%   epsMap = getPermittivityMap(model);
%   % This will return the permittivity map for the elements in the workspace.
%
% See also: getElementMal and getConductivityMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [epsMap] = getPermittivityMap(model)

if model.dimension == 2
    epsMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints);
else 
    epsMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints, model.Mesh.depthPoints);
end

for i=1:numel(model.Sensor)
    epsMap(model.Sensor{i}.location_index)=model.Sensor{i}.permittivity;
end


end