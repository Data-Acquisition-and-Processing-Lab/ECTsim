%% drawMap - Draws maps based on selected parameters.
%
% This function draws maps based on the selected parameters provided in the numerical model description.
%
% Usage:
%   drawMap(model, parameter, varargin)
%
% Inputs:
%   model     - Structure with numerical model description.
%   parameter - Parameter to be presented:
%               * 'V' - Electric potential distribution.
%               * 'Em', 'Ex', 'Ey', 'Ez' - Electric field distribution components.
%               * 'S' - Sensitivity matrix.
%               * 'pattern' - List of elements in the model.
%               * 'permittivity', 'epsilon' - Permittivity distribution.
%               * 'conductivity', 'sigma' - Conductivity distribution.
%
% Varargin:
%   Values are interpreted by drawInterpreter and can be provided in any order:
%     sets.mode      - 'mm' or 'px'.
%     sets.part      - 'real' or 'imag', applicable to potential, electric field, and sensitivity matrix.
%     sets.electrode - Number of electrode or pair of electrodes.
%     sets.method    - 'mpr', 'surf', or 'slice' (only for 3D).
%     sets.ix        - Indices of mesh elements to present; 0 indicates the whole matrix will be presented.
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized and parameter is 'V'
%   drawMap(model, 'V', 'mm', 'real', 0);
%   % This will draw the electric potential distribution in millimeters for every electrode showing the real part.
%
% See also: drawInterpreter, drawInvpMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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