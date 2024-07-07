%% drawSensitivityMap 
% draws sensitivity maps for given electrodes
%
% *usage:* |drawSensitivityMap(model, data, draw, part)|
%
% * _model_  - model with a quad tree or sensitivity matrix (maps)
% * _mode_  -  px, mm (for 2D); slice, mpr (for 3D)
% * _part_  - real, imag
% * _draw_   - application electrode number (combinations with this electrode are selected)
%            or [e1 e2] pair of electrodes
%
% footer$$  

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
