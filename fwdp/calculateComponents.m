%% calculateComponents
% calculates values of components of measurements ;
%
% *usage:*     |[model] = calculateMeasurements(model)|
%  
% _model_     - structure with a numerical model description
%
% * 
%
% footer$$

function [model] = calculateComponents(model)
    
    model.G = imag(model.K)*2*pi*model.f; % Conductance
    if any(model.G<0)
        model.G = abs(model.G); % If value is smaller than 0 it is numerical error
        fprintf('Conductane part was not calculated correctly. The grid resolution is too low for a case with such low conductivity');
    end
    model.C = real(model.K); % Capacitance
    if any(model.C<0)
        model.C = abs(model.C); % If value is smaller than 0 it is numerical error
        fprintf('Capacitance part was not calculated correctly. The grid resolution is too low for a case with such high conductivity');
    end
    model.Y = model.G+1i*model.C*2*pi*model.f; % Admitance

end