%% addNoise - Adds noise to measurements based on the specified signal-to-noise ratio.
%
% This function introduces noise into the measurements of a numerical model,
% based on a specified Signal-to-Noise Ratio (SNR). This is useful for simulating
% real-world measurement conditions.
%
% Usage:
%   model = addNoise(model, SNRdb)
%
% Inputs:
%   model - Structure with a numerical model description.
%   SNRdb - Signal to Noise Ratio (SNR) in decibels for the measurement.
%
% Outputs:
%   model - Updated model structure with added noise in the measurements.
%
% Example:
%   % Assume model is already initialized
%   SNRdb = 20;  % Define the desired SNR in decibels
%   model = addNoise(model, SNRdb);
%   % This will add noise to the model's measurements with the specified SNR.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function  [model] = addNoise(model,SNRdb)
    fprintf('Adding noise to measurement ...... '); tic;

    SNR = 10^(SNRdb/20);  
    rand('twister', sum(100*clock));

    model.K = real(model.K) + ((real(model.K)'/SNR).*randn(1, length(model.K)))'+1i*(imag(model.K)+((imag(model.K)'/SNR).*randn(1, length(model.K)))');

    model = calculateComponents(model);
    
    fprintf(' . Done. '); toc
end