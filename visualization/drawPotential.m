%% drawPotential - Draws potential maps for selected excitations.
%
% This function draws potential maps for selected excitations in the numerical model.
%
% Usage:
%   drawPotential(model, mode, part, electrode, method)
%
% Inputs:
%   model     - Numerical model structure.
%   mode      - 'px' for pixels, 'mm' for millimeters.
%   part      - 'real' or 'imag'.
%   electrode - 0 for potential maps of every electrode, >0 for only the selected electrode.
%   method    - (optional) Presentation method for 3D ('mpr' or 'slice').
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized
%   drawPotential(model, 'mm', 'real', 0, 'mpr');
%   % This will draw the real part of the potential map in millimeters for every electrode using the 'mpr' method.
%
% See also: drawMap, drawInvpMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [V_cell]=drawPotential(model, mode, part, electrode, varargin)
if numel(varargin)
    method = varargin{1};
else
    method = 'mpr';
end

if numel(varargin)>1
    ix = varargin{2};
else
    ix = 0;
end

dim = length(fieldnames(model.Workspace));

if (strcmp(part,'real') || strcmp(part,'imag')) == 0
    error(['Unknown option: ', part, '!?']);
end

if dim == 2 
    if (strcmp(mode,'px') || strcmp(mode,'mm')) == 0
        error(['Unknown option: ', mode, ' for 2D image. Try px or mm.']);
    end
    if ~electrode
        V_cell=cell(1,model.Electrodes.num);
        for el = 1:model.Electrodes.num
            V = qtComp(model.qt,model.qt.vt(:,el),0);
            V_cell{el}=V;
            figname = strcat('Potential map for driving electrode ', int2str(el), ' (', part, ' part)' );
            if strcmp(part,'real')
                mapa = real(V);
            else
                mapa = imag(V);
            end
            if ix
                temp = ones(size(mapa)) * min(mapa, [], 'all');
                temp(ix) = mapa(ix);
                mapa = temp;
            end
            if strcmp(mode,'mm')
                oneSliceView(mapa,model.Mesh);
            else
                oneSliceView(mapa);
            end
            title(figname);
        end
    elseif electrode<=model.Electrodes.num
        V = qtComp(model.qt,model.qt.vt(:,electrode),0);
        V_cell=cell(1,1);
        V_cell{1}=V;
        figname = strcat('Potential map for driving electrode ', int2str(electrode), ' (', part, ' part)' );
        if strcmp(part,'real')
            mapa = real(V);
        else
            mapa = imag(V);
        end
        if ix
            temp = ones(size(mapa)) * min(mapa, [], 'all');
            temp(ix) = mapa(ix);
            mapa = temp;
        end
        if strcmp(mode,'mm')
            oneSliceView(mapa,model.Mesh);
        else
            oneSliceView(mapa);
        end
        title(figname);
    end
else  % 3D
    if (strcmp(method,'mpr') || strcmp(method,'slice') || strcmp(method,'surf')) == 0
        error(['Unknown option: ', method, ' for drawPotential 3D. Try mpr or slice.']);
    end
    if strcmp(method,'surf')
        error('There is no surf option for drawPotential. Try mpr or slice.');
    end
    if ~electrode
        V_cell=cell(1,model.Electrodes.num);
        for el = 1:model.Electrodes.num
            V = qtComp(model.qt,model.qt.vt(:,el),0); 
            V_cell{el}=V;
            if strcmp(part,'real')
                mapa = real(V);
            else
                mapa = imag(V);
            end
            if ix
                temp = ones(size(mapa)) * min(mapa, [], 'all');
                temp(ix) = mapa(ix);
                mapa = temp;
            end
            if strcmp(method,'mpr')
                if (strcmp(mode,'mm'))
                    mpr(mapa,model.Mesh);
                else
                    mpr(mapa);
                end
            elseif strcmp(method,'slice')
                if (strcmp(mode,'mm'))
                    sliceView(mapa,model.Mesh)
                else
                    sliceView(mapa)
                end
            else
                if (strcmp(mode,'mm'))
                    shadedSurfaceDisplay(mapa,10,model.Mesh)
                else
                    shadedSurfaceDisplay(mapa,10)
                end
            end
            
        end
    elseif electrode<=model.Electrodes.num
        V = qtComp(model.qt,model.qt.vt(:,electrode),0);
        V_cell=cell(1,1);
        V_cell{1}=V;
        if strcmp(part,'real')
            mapa = real(V);
        else
            mapa = imag(V);
        end
        if ix
            temp = ones(size(mapa)) * min(mapa, [], 'all');
            temp(ix) = mapa(ix);
            mapa = temp;
        end
        if strcmp(method,'mpr')
            if (strcmp(mode,'mm'))
                mpr(mapa,model.Mesh);
            else
                mpr(mapa);
            end
        elseif strcmp(method,'slice')
            if (strcmp(mode,'mm'))
                sliceView(mapa,model.Mesh)
            else
                sliceView(mapa)
            end
        else
            if (strcmp(mode,'mm'))
                shadedSurfaceDisplay(mapa,10,model.Mesh)
            else
                shadedSurfaceDisplay(mapa,10)
            end
        end
    end
    figname = strcat('Potential map for driving electrode ', int2str(electrode), ' (', part, ' part)' );
    sgtitle(figname,'FontSize',12);
end