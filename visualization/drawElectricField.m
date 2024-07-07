%% drawElectricField 
% draws a selected component or module of E
%
% *usage:*    |drawElectricField(model,mode,part,comp,electrode)|
%
% * _model_   - numerical model 
% * _mode_  -  px, mm (for 2D); slice, mpr (for 3D)
% * _part_  - real, imag
% * _comp_    - Ex, Ey, Em (modulus) 
% * _electrode_    -  0 potential maps for every electrode, 
%                    >0 only selected electrode
%
% footer$$

function E_cell=drawElectricField(model, mode, part, comp, electrode, varargin)
temp = comp;
dim = length(fieldnames(model.Workspace));

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

if (strcmp(part,'real') || strcmp(part,'imag')) == 0
    error(['Unknown option: ', part, '!?']);
end

if (strcmp(comp,'Ex') || strcmp(comp,'Ey') || strcmp(comp,'Em')) == 0
    error(['Unknown option: ', comp, '!?']);
end

if (dim==2) % 2D
    if (strcmp(mode,'px') || strcmp(mode,'mm')) == 0
        error(['Unknown option: ', mode, ' for 2D image. Try px or mm.']);
    end

    if ~electrode 
        E_cell=cell(1,model.Electrodes.num);
        
        for el = 1:model.Electrodes.num  
            if strcmp(comp,'Ex')
                E = qtComp(model.qt,model.qt.Ex(:,el),0);
            elseif strcmp(comp,'Ey')
                E = qtComp(model.qt,model.qt.Ey(:,el),0);
            else
                E = qtComp(model.qt,model.qt.Em(:,el),0);
                temp = 'Modulus';
            end
            E_cell{el} = E;
            
            figname = strcat(temp, ' of electric field for driving electrode ', int2str(el), ' (', part, ' part)' );  
            if strcmp(part,'real')
                mapa = real(E);
            else
                mapa = imag(E);
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
        E_cell=cell(1,1);
        if strcmp(comp,'Ex')
            E = qtComp(model.qt,model.qt.Ex(:,electrode),0);
        elseif strcmp(comp,'Ey')
            E = qtComp(model.qt,model.qt.Ey(:,electrode),0);
        else
            E = qtComp(model.qt,model.qt.Em(:,electrode),0);
            temp = 'Modulus';
        end
        E_cell{1} = E;
        
        figname = strcat(temp, ' of electric field for driving electrode ', int2str(electrode), ' (', part, ' part)' );  
        if strcmp(part,'real')
            mapa = real(E);
        else
            mapa = imag(E);
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
else % 3D
    if (strcmp(method,'mpr') || strcmp(method,'slice') || strcmp(method,'surf')) == 0
        error(['Unknown option: ', method, ' for drawElectricField 3D. Try mpr or slice.']);
    end
    if strcmp(method,'surf')
        error('There is no surf option for drawElectricField. Try mpr or slice.');
    end
    
    if ~electrode
        E_cell=cell(1,model.Electrodes.num);
        for el = 1:model.Electrodes.num
            if strcmp(comp,'Ex')
                E = qtComp(model.qt,model.qt.Ex(:,electrode),0);
            elseif strcmp(comp,'Ey')
                E = qtComp(model.qt,model.qt.Ey(:,electrode),0);
            else
                E = qtComp(model.qt,model.qt.Em(:,electrode),0);
                temp = 'Modulus';
            end
            E_cell{el}=E;
            

            if strcmp(part,'real')
                mapa = real(E);
            else
                mapa = imag(E);
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

            figname = strcat(temp, ' of electric field for driving electrode ', int2str(electrode), ' (', part, ' part)' );  
            sgtitle(figname,'FontSize',12);
        end
    elseif electrode<=model.Electrodes.num
        if strcmp(comp,'Ex')
            E = qtComp(model.qt,model.qt.Ex(:,electrode),0);
        elseif strcmp(comp,'Ey')
            E = qtComp(model.qt,model.qt.Ey(:,electrode),0);
        else
            E = qtComp(model.qt,model.qt.Em(:,electrode),0);
            temp = 'Modulus';
        end
        E_cell=cell(1,1);
        E_cell{1}=E;        
        if strcmp(part,'real')
            mapa = real(E);
        else
            mapa = imag(E);
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

        figname = strcat(temp, ' of electric field for driving electrode ', int2str(electrode), ' (', part, ' part)' ); 
        sgtitle(figname,'FontSize',12);
    end
end

