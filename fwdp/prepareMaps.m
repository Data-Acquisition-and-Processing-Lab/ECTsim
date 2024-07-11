%% prepareMaps - Prepares three essential maps for discretizing the mesh.
%
% This function prepares three essential maps required for discretizing the mesh
% in a numerical model. These maps include the relative permittivity, conductivity,
% and a pattern image of the elements in the model.
%
% Usage:
%   model = prepareMaps(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with the following prepared maps:
%           model.eps_map       - Map of relative permittivity (epsilon).
%           model.sigma_map     - Map of conductivity (sigma).
%           model.patternImage  - Map of elements in the model.
%
% Example:
%   % Assume model is already initialized
%   model = prepareMaps(model);
%   % This will prepare the necessary maps for mesh discretization in the model.
%
% See also: getElementMap and getPermittivityMap and getConductivityMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function model = prepareMaps(model)

    model.eps_map = getPermittivityMap(model);
    model.sigma_map = getConductivityMap(model);
    model = boundaryVoltageVector(model);
    [model.patternImage] = getElementMap(model);
    model = sensorElectrodePairs(model);

end