%% addNoise
% adds noise to measurements ;
%
% *usage:*     |[model] = addNoise(model)|
%  
% _model_     - structure with a numerical model description
%
% * SNRdb - signal to noise ratio of measurement
%
% footer$$


function  [model] = addNoise(model,SNRdb)
    fprintf('Adding noise to measurement ...... '); tic;

    SNR = 10^(SNRdb/20);  
    rand('twister', sum(100*clock));

    model.K = real(model.K) + ((real(model.K)'/SNR).*randn(1, length(model.K)))'+1i*(imag(model.K)+((imag(model.K)'/SNR).*randn(1, length(model.K)))');

    model = calculateComponents(model);
    
    fprintf(' . Done. '); toc
end