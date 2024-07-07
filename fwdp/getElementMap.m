%% getElementMap
%
% getElementMap generates a pixel map of elements in the model. Pixel 
% values is equal to the unique number of the element. 
%
% *usage:*     |[epsilon_map, sigma_map] = getElementMap(model)|
%  
% * _model_       - structure with a numerical model description
% * _epsilon_map_ - 2D matrix with epsilon values in the described model
% * _sigma_map_   - 2D matrix with sigma values in the described model
%
% footer$$


function [epsMap,sigmaMap] = getElementMap(model)

if model.dimension == 2
    epsMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints);
    sigmaMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints);
else
    epsMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints, model.Mesh.depthPoints);
    sigmaMap=zeros(model.Mesh.heightPoints, model.Mesh.widthPoints, model.Mesh.depthPoints);
end

    for i=1:numel(model.Sensor)
        epsMap(model.Sensor{i}.location_index)=i;
        sigmaMap(model.Sensor{i}.location_index)=i;
    end

end