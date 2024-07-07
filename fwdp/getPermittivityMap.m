%% getPermittivityMap
% Create vector of permittivity of the elements in the workspace 
%
% *usage:* |[epsMap] = getPermittivityMap(model)|
% 
% * _model_  - structure with a numerical model description
% * _epsMap_ - relative epsilon(permittivity) map
%
% footer$

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