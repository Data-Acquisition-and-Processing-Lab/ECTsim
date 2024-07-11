%% plotNorm - Plots norms calculated during the reconstruction process.
%
% This function plots norms calculated during the reconstruction process.
%
% Usage:
%   plotNorm(parameter, model, name, part)
%
% Inputs:
%   parameter - Norm to plot ('residue' or 'error').
%   model     - Structure with a numerical model description of the inverse problem.
%   name      - List of model names (e.g., {'LBP', 'PINV'}).
%   part      - (optional) Specifies whether to plot the real or imaginary part of the norm.
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized
%   plotNorm('residue', modelInvp, {'LBP', 'PINV'}, 'real');
%   % This will plot the real part of the residue norm for the specified models.
%
% See also: plotMeasurement
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [] = plotNorm(parameter, model, name, varargin)

palette = {'r-', 'b-', 'k-', 'g-', 'm-', 'c-', 'y-'};
if(numel(varargin))
    part = varargin{1};
else
    part = 'real';
end

if strcmp(parameter,'residue') || strcmp(parameter,'error')

    if ~isempty(name)
        figure
        hold on
        for cnt=1:length(name)  
            if strcmp(part,'real')
                plot(1:length(model.(name{cnt}).(parameter)),real(model.(name{cnt}).(parameter)),palette{cnt})
            elseif strcmp(part,'imag')
                plot(1:length(model.(name{cnt}).(parameter)),imag(model.(name{cnt}).(parameter)),palette{cnt})
            else
                error(['Unknown option: ', part, '!?']);
            end
        end

        legend(name)
        xlabel('Number of iterations')
        grid minor

        if strcmp(parameter,'residue')
            ylabel({'$\|C_{i} - C_{m}\|_2^2 / \|C_{0} - C_{m}\|_2^2$'}, 'Interpreter', 'latex');
            title({'Normalized capacitance error','as a function of reconstruction algorithm iterations'});
        else
            ylabel({'$\|\varepsilon_{i} - \varepsilon_{m}\|_2^2 / \|\varepsilon_{0} - \varepsilon_{m}\|_2^2$'}, 'Interpreter', 'latex');
            title({'Normalized permittivity error','as a function of reconstruction algorithm iterations'})
        end

        hold off
    end

end

end










