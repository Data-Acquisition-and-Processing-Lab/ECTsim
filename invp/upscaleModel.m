%%  upscaleModel - Interpolates the permittivity map to a finer qt mesh.
%
% This function interpolates the permittivity map to a finer quadtree (qt) mesh.
% It requires the expansion of Field of View (FOV) data, extrapolating at the edges
% of the FOV to ensure accurate interpolation.
%
% Usage:
%   model = upscaleModel(eps_map, model)
%
% Inputs:
%   eps_map - Complex permittivity map from an inverse problem mesh.
%   model   - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with the interpolated permittivity map.
%
% Example:
%   % Assume eps_map and model are already initialized
%   model = upscaleModel(eps_map, model);
%   % This will interpolate the permittivity map to a finer qt mesh in the model.
%
% See also: downscaleModel
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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
