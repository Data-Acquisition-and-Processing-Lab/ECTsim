%% drawElectricField - Draws a selected component or modulus of the electric field.
%
% This function draws a selected component or modulus of the electric field from the
% numerical model.
%
% Usage:
%   drawElectricField(model, mode, part, comp, electrode, method)
%
% Inputs:
%   model     - Numerical model structure.
%   mode      - Display mode ('px' for pixels, 'mm' for millimeters).
%   part      - Part of the field to display ('real', 'imag').
%   comp      - Component of the field to display ('Ex', 'Ey', 'Em' for modulus).
%   electrode - 0 to map potential for every electrode, or a specific electrode number to map only that electrode.
%   method    - (optional) Method of presentation for 3D ('mpr' or 'slice').
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized
%   drawElectricField(model, 'mm', 'real', 'Ex', 0);
%   % This will draw the real part of the Ex component of the electric field in millimeters for every electrode.
%
% See also: drawPotential and drawSensitivityMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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

