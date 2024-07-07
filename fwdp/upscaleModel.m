%% upscaleModel 
% upscaleModel interpolates permittivity map to finer qt mesh;
%
% This function requires expanding of FOV data (extrapolating at FOV's edges). 
%
% *usage:* |[model] = upscaleModel(eps_map, model)|
%
% * _eps_map_ - inverse problem mesh
% * _model_ - structure with a numerical model description
%
% footer$$

function [model] = upscaleModel(model, map)

fprintf('Upscaling ...... '); tic;

meshWidth = model.MeshInvp.meshWidth;
meshHeight = model.MeshInvp.meshHeight;

xSN=model.Mesh.widthPoints/meshWidth;
ySN=model.Mesh.heightPoints/meshHeight;

indx = model.FOV_fwdp;

%d = mean(Ep(model.InvpFOV_points));

if model.qt.dim == 3 %3D
    meshDepth = model.MeshInvp.meshDepth;
    zSN=model.Mesh.depthPoints/meshDepth;
    cntK=1;
    for k=0:zSN:model.Mesh.depthPoints-zSN
        cntJ=1;
        for j=0:ySN:model.Mesh.heightPoints-ySN
            cntI=1;
            for i=0:xSN:model.Mesh.widthPoints-xSN
                uniqueSet = unique(model.qt.idxMatrix(floor(i)+1:floor(i+xSN),floor(j)+1:floor(j+ySN),floor(k)+1:floor(k+zSN)));
                val=intersect(uniqueSet,indx);
                if val    
                    model.qt.eps(val) = real(map(cntJ,cntI,cntK));
                    model.qt.sigma(val) = imag(map(cntJ,cntI,cntK));                  
                end
                cntI=cntI+1;
            end
            cntJ=cntJ+1;
        end
        cntK=cntK+1;
    end
else %2D     
    cntJ=1;
    for j=0:ySN:model.Mesh.heightPoints-ySN
        cntI=1;
        for i=0:xSN:model.Mesh.widthPoints-xSN
            uniqueSet = unique(model.qt.idxMatrix(floor(j)+1:floor(j+ySN),floor(i)+1:floor(i+xSN)));
            val=intersect(uniqueSet,indx);
            if val
                model.qt.eps(val) = real(map(cntJ,cntI));
                model.qt.sigma(val) = imag(map(cntJ,cntI));
            end
            cntI=cntI+1;
        end
        cntJ=cntJ+1;
    end

end
% model.qt.sigma(1:length(model.qt.sigma)) = 0; 

[model.Electrodes.app_el, model.Electrodes.rec_el] = electrodePairs(model.Electrodes.num, 1);

fprintf(' . Done. '); toc 

%         for p=1:numel(model.downscaledFOV_points)
%         k = model.downscaledFOV_points(p);
%         i = round(model.qt.i(k)/SN);
%         j = round(model.qt.j(k)/SN);
%         model.qt.eps(k)   = 0.8; % real(Ep(i,j));
%         model.qt.sigma(k) = 0.8; % imag(Ep(i,j));
%         end
