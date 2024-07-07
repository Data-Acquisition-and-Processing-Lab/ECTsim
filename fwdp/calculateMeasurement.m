%% calculateMeasurement
% calculates values of measurements ;
%
% *usage:*     |[model] = calculateMeasurements(model)|
%  
% _model_     - structure with a numerical model description
%
% * 
%
% footer$$

function [model] = calculateMeasurement(model)

    fprintf('Calculating measurement components ...... '); tic;

    model.K=((model.eps0*(model.qt.eps(:)+1i*model.qt.sigma(:))).'*model.qt.Sens(:,:)).'; %Complex capacitance

    model = calculateComponents(model); % C, G and Y

    fprintf(' . Done. '); toc
end