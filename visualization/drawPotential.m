%% drawPotential 
% Draws potential maps for all excitations;
%
% *usage:* |drawPotential(model,mode)|
%
% * _model_   - structure with a numerical model description
% * _part_  - real, imag
% * _electrode_    -  0 potential maps for every electrode, 
%                    >0 only selected electrode
%
%
% footer$

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