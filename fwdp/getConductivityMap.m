%% getConductivityMap
% Create vector of conductivity of the elements in the workspace 
%
% *usage:* |[sigmaMap] = getConductivityMap(model)|
% 
% * _model_  - structure with a numerical model description
% * _sigmaMap_ - map of eps" = sigma/(2*pi*f*eps0)
%
% footer$

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
