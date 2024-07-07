%% plotNorm 
% plots mutual measurements  of electrodes 
% 
% *usage:* |[] = plotNorm(model, parameter)|
%
% * _model_ - ...
%
% footer$$

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










