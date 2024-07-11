%% getElementMap - Generates a pixel map of elements in the model.
%
% This function generates a pixel map of elements in the model, where pixel values correspond
% to the unique number of each element. It creates two matrices: epsilon_map and sigma_map,
% containing the epsilon and sigma values for the model, respectively.
%
% Usage:
%   [epsMap, sigmaMap] = getElementMap(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   epsMap - 2D matrix containing epsilon values for the model.
%   sigmaMap   - 2D matrix containing sigma values for the model.
%
% Example:
%   % Assume model is already initialized
%   [epsMap, sigmaMap] = getElementMap(model);
%   % This will return the epsilon and sigma maps for the elements in the model.
%
% See also: getConductivityMap and getPermittivityMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------


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