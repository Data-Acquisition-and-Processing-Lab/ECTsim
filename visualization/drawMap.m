%% drawMap
% Draws maps od selected parameter for all excitations;
%
% *usage:* |drawMap(model,parameter,mode,part,electrode)|
%
% * _model_   - structure with a numerical model description
% * _mode_  - mm, px
% * _part_  - real, imag
% * _electrode_    
%
% footer$

function drawMap(model, parameter, varargin)
    
    dim = length(fieldnames(model.Workspace));
    sets = drawInterpreter(varargin);

    if strcmp(parameter,'V')
        drawPotential(model, sets.mode, sets.part, sets.electrode, sets.method,sets.ix);
    elseif (strcmp(parameter,'Em') || strcmp(parameter,'Ex') || strcmp(parameter,'Ey') || strcmp(parameter,'Ez'))
        drawElectricField(model, sets.mode, sets.part, parameter, sets.electrode, sets.method,sets.ix); 
    elseif strcmp(parameter,'S')
        drawSensitivityMap(model, sets.mode, sets.part, sets.electrode, sets.method,sets.ix);   
    elseif strcmp(parameter,'pattern')
        drawPatternImage(model, sets.mode, sets.method, sets.ix);

    elseif strcmp(parameter,'epsilon') || strcmp(parameter,'sigma') || strcmp(parameter,'conductivity') || strcmp(parameter,'permittivity')
        if strcmp(parameter,'epsilon')
            map = qtComp(model.qt,model.qt.eps,0);
            figname = strcat('Permittivity map');
        elseif strcmp(parameter,'sigma')
            map = qtComp(model.qt,model.qt.sigma,0);
            figname = strcat('Conductivity map');
        elseif strcmp(parameter,'conductivity')
            map = model.sigma_map*(2*pi*model.f)*model.eps0;
            figname = strcat('Conductivity map');
        elseif strcmp(parameter,'permittivity')
            map = model.eps_map;
            figname = strcat('Permittivity map');
        end
        if sets.ix
            temp = ones(size(map)) * min(map, [], 'all');
            temp(sets.ix) = map(sets.ix);
            map = temp;
        end
        if dim == 2
            if strcmp(sets.mode,'mm')
                oneSliceView(map,model.Mesh);
            else
                oneSliceView(map);
            end
            xlabel(['x [' sets.mode ']'])
            ylabel(['y [' sets.mode ']'])
        else
            if strcmp(sets.method,'mpr')
                if strcmp(sets.mode,'mm')
                    mpr(map, model.Mesh)
                else
                    mpr(map)
                end
            elseif strcmp(sets.method,'slice')
                if strcmp(sets.mode,'mm')
                    sliceView(map, model.Mesh)
                else
                    sliceView(map)
                end
            elseif strcmp(sets.method,'surf')
                if strcmp(sets.mode,'mm')
                    shadedSurfaceDisplay(map, 2, model.Mesh)
                else
                    shadedSurfaceDisplay(map, 2)
                end
            end
        end
        fig = gcf;
        sgtitle(fig,figname);
    end
end