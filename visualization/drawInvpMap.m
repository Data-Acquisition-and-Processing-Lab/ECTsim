%% drawInvpMap - Draws maps of selected parameters for the inverse problem.
%
% This function draws maps of selected parameters for the inverse problem based on
% the provided numerical model description.
%
% Usage:
%   drawInvpMap(model, parameter, varargin)
%
% Inputs:
%   model     - Structure with numerical model description.
%   parameter - Parameter to be presented:
%               * 'permittivity' - Permittivity distribution.
%               * 'conductivity' - Conductivity distribution.
%
% Varargin:
%   Values are interpreted by drawInterpreter and can be provided in any order:
%     sets.mode      - 'mm' or 'px'.
%     sets.method    - 'mpr', 'surf', or 'slice' (only for 3D).
%     sets.ix        - Indices of mesh elements to present; 0 indicates the whole matrix will be presented.
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized and parameter is 'permittivity'
%   drawInvpMap(model, 'permittivity', 'mm', 'mpr', 0);
%   % This will draw the permittivity distribution map in millimeters using the 'mpr' method for the whole matrix.
%
% See also: drawInterpreter, drawMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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