%% prepareMaps
% Create vector of permittivity of the elements in the workspace 
%
% *usage:* |model = preapreMaps(model)|
% 
% * _model_  - structure with a numerical model description
% * _eps_map_ - relative epsilon(permittivity) map
% * _sigma_map_ - sigma(conductivity) map
% * _patternImage_ - map of elements in the model
% footer$

function model = prepareMaps(model)

    model.eps_map = getPermittivityMap(model);
    model.sigma_map = getConductivityMap(model);
    model = boundaryVoltageVector(model);
    [model.patternImage] = getElementMap(model);
    model = sensorElectrodePairs(model);

end