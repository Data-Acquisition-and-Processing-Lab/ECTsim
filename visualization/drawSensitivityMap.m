%% drawSensitivityMap - Draws sensitivity maps for specified electrodes.
%
% This function draws sensitivity maps for specified electrodes in the numerical model.
%
% Usage:
%   drawSensitivityMap(model, mode, part, draw, method)
%
% Inputs:
%   model  - Numerical model structure.
%   mode   - 'px' for pixels, 'mm' for millimeters.
%   part   - 'real' or 'imag'.
%   draw   - Application electrode number or a pair of electrodes [e1, e2], e.g., [2, 13].
%   method - (optional) Presentation method for 3D ('mpr' or 'slice').
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized
%   drawSensitivityMap(model, 'mm', 'real', [2, 13], 'mpr');
%   % This will draw the real part of the sensitivity map in millimeters for the specified pair of electrodes using the 'mpr' method.
%
% See also: drawMap, drawInvpMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function drawSensitivityMap(model, mode, part, draw, varargin)

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

if (dim == 2) % 2D
    if (strcmp(mode,'px') || strcmp(mode,'mm')) == 0
        error(['Unknown option: ', mode, ' for 2D image. Try px or mm.']);
    end
    if isscalar(draw)
        if draw>0 && draw<(model.Electrodes.num+1)
            index = find(model.Electrodes.app_el==draw);
            for j=1:numel(index)
                S = qtComp(model.qt,model.qt.Sens(:,index(j)),1);   % 1 to scale sensitivity by voxel size
                figname = strcat('Sensitivity El', int2str(model.Electrodes.app_el(j)), ' x El', int2str(model.Electrodes.rec_el(j)), ' (', part,' part)');
                if strcmp(part,'real')
                    mapa = real(S);
                else
                    mapa = imag(S);
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
        end
    elseif numel(draw)==2 && draw(1)>0 && draw(1)<(model.Electrodes.num+1) && draw(2)>0 && draw(2)<(model.Electrodes.num+1) && (draw(1)~=draw(2))
        mes = find(model.Electrodes.app_el==draw(1) & model.Electrodes.rec_el==draw(2));
        if isscalar(mes)
            S = qtComp(model.qt,model.qt.Sens(:,mes),1);    % 1 to scale sensitivity by voxel size
            figname = strcat('Sensitivity El', int2str(model.Electrodes.app_el(mes)), ' x El', int2str(model.Electrodes.rec_el(mes)), ' (', part,' part)');
            if strcmp(part,'real')
                mapa = real(S);
            else
                mapa = imag(S);
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
    end
else % 3D
    if (strcmp(method,'mpr') || strcmp(method,'slice') || strcmp(method,'surf')) == 0
        error(['Unknown option: ', method, ' for drawSensitivityMap. Try mpr or slice.']);
    end
    if strcmp(method,'surf')
        error('There is no surf option for drawSensitivityMap. Try mpr or slice.');
    end
    if isscalar(draw)
        if draw>0 && draw<(model.Electrodes.num+1)
            index = find(model.Electrodes.app_el==draw);
            for j=1:numel(index)
                S = qtComp(model.qt,model.qt.Sens(:,index(j)),1);   % 1 to scale sensitivity by voxel size
                figname = strcat('Sensitivity El', int2str(model.Electrodes.app_el(j)), ' x El', int2str(model.Electrodes.rec_el(j)), ' (', part,' part)'); 

                if strcmp(part,'real')
                    mapa = real(S);
                else
                    mapa = imag(S);
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
                sgtitle(figname);
            end
        end
    elseif numel(draw)==2 && draw(1)>0 && draw(1)<(model.Electrodes.num+1) && draw(2)>0 && draw(2)<(model.Electrodes.num+1) && (draw(1)~=draw(2))
        mes = find(model.Electrodes.app_el==draw(1) & model.Electrodes.rec_el==draw(2));
        if isscalar(mes)
            S = qtComp(model.qt,model.qt.Sens(:,mes),1);    % 1 to scale sensitivity by voxel size
            figname = strcat('Sensitivity El', int2str(model.Electrodes.app_el(mes)), ' x El', int2str(model.Electrodes.rec_el(mes)), ' (', part,' part)');
            if strcmp(part,'real')
                mapa = real(S);
            else
                mapa = imag(S);
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
            sgtitle(figname);
        end
    end
end
