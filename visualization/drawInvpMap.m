%% drawInvpMap
% Draws maps od selected parameter for all excitations;
%
% *usage:* |drawInvpMap(model,parameter,mode)|
%
% * _model_   - structure with a numerical model description
% * _mode_  - mm, px
% * _parameter_  - conductivity, permittivity 
% * _part_  - min, max, obj ... 
%
% footer$

function drawInvpMap(model, part, parameter, varargin)

    sets = drawInterpreter(varargin);

    if (strcmp(sets.mode,'px') || strcmp(sets.mode,'mm')) == 0
        error(['Unknown option: ', mode, '!?']);
    end

    dim = length(fieldnames(model.Workspace));
    
    if strcmp(parameter,'conductivity')
        mapa=model.(part).sigma_map*(2*pi*model.f)*model.eps0;
        figname = strcat('Conductivity distribution');
    elseif strcmp(parameter,'permittivity')
        mapa=model.(part).eps_map;
        figname = strcat('Permittivity distribution');
    else
        error(['Unknown option: ', parameter, '!?']);
    end
    
    if sets.ix
        temp = ones(size(mapa)) * min(mapa, [], 'all');
        temp(sets.ix) = mapa(sets.ix);
        mapa = temp;
    end
    
    if dim == 3
        if (strcmp(sets.method,'mpr'))
            if (strcmp(sets.mode,'mm'))
                mpr(mapa,model.MeshInvp);
            else
                mpr(mapa);
            end
        elseif (strcmp(sets.method,'surf'))
            if (strcmp(sets.mode,'mm'))
                shadedSurfaceDisplay(mapa, 2, model.MeshInvp);
            else
                shadedSurfaceDisplay(mapa, 2);
            end
        else
            if (strcmp(sets.mode,'mm'))
                sliceView(mapa,model.MeshInvp);
            else
                sliceView(mapa);
            end
        end
    else 
        if strcmp(sets.mode,'mm')
            oneSliceView(mapa,model.Mesh);
        else
            oneSliceView(mapa);
        end
    end
    fig = gcf;
    sgtitle(fig,figname);

end