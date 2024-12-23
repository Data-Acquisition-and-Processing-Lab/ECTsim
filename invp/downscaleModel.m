%% downscaleModel - Interpolates a model to a coarser mesh used in the inverse problem.
%
% This function interpolates a numerical model to a coarser mesh used in the inverse problem.
% The process involves decimation and sensitivity adjustment for the complex permittivity
% distribution within the model.
%
% Usage:
%   model = downscaleModel(mesh, model)
%
% Inputs:
%   mesh  - Inverse problem mesh.
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure interpolated to the coarser mesh.
%
% Example:
%   % Assume mesh and model are already initialized
%   model = downscaleModel(mesh, model);
%   % This will interpolate the model to the coarser inverse problem mesh.
%
% See also: upscaleModel
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [invp] = downscaleModel(mesh, model)
fprintf('Downscaling ...... '); tic;

mesh = mesh.MeshInvp;
invp.C = model.C;
invp.G = model.G;
invp.K = model.K;
invp.Y = model.Y;


meshWidth = mesh.meshWidth;
meshHeight = mesh.meshHeight;

xSN=model.qt.meshWidth/meshWidth;
ySN=model.qt.meshHeight/meshHeight;

count =1;
if model.qt.dim == 3 %3D
    meshDepth = mesh.meshDepth;
    zSN=model.qt.meshDepth/meshDepth;
    eps = zeros(meshWidth*meshHeight*meshDepth,1);
    sigma = zeros(meshWidth*meshHeight*meshDepth,1);
    invp.S = zeros([model.measurement_count,meshWidth*meshHeight*meshDepth]); 
    for k=0:zSN:model.qt.meshDepth-zSN
        for j=0:ySN:model.qt.meshHeight-ySN
            for i=0:xSN:model.qt.meshWidth-xSN
                uniqueSet = unique(model.qt.idxMatrix(floor(i)+1:floor(i+xSN),floor(j)+1:floor(j+ySN),floor(k)+1:floor(k+zSN)));
                invp.S(:,count)=sum(model.qt.Sens(uniqueSet,:));
                eps(count)=sum(model.qt.eps(uniqueSet,:).*(model.qt.elSize(uniqueSet).^3)')/sum(model.qt.elSize(uniqueSet).^3);
                sigma(count)=sum(model.qt.sigma(uniqueSet,:).*(model.qt.elSize(uniqueSet).^3)')/sum(model.qt.elSize(uniqueSet).^3);  
                count= count+1;
            end
        end
    end
    invp.S(isnan(invp.S))=0;

    % normalize sensitivity maps - version B
    % integral sensitivity in each column (image voxel) has to be equal
    W = abs(sum(invp.S,1)); 
    W(W==0)=1;    % to avoid division by zero 
    invp.Sn     = zeros([model.measurement_count,meshWidth*meshHeight*meshDepth]);
    for i=1:meshWidth*meshHeight*meshDepth
        invp.Sn(:,i) = invp.S(:,i)./W(i);
    end
    
    invp.eps = eps;
    invp.eps_map = reshape(eps, [meshHeight,meshWidth,meshDepth]);
    
    invp.sigma = sigma;
    invp.sigma_map = reshape(sigma, [meshHeight,meshWidth,meshDepth]);

else %2D
    eps = zeros(meshWidth*meshHeight,1);
    sigma = zeros(meshWidth*meshHeight,1);
    invp.S = zeros([model.measurement_count,meshWidth*meshHeight]); 
    for j=0:ySN:model.qt.meshHeight-ySN
        for i=0:xSN:model.qt.meshWidth-xSN
            uniqueSet = unique(model.qt.idxMatrix(floor(j)+1:floor(j+ySN),floor(i)+1:floor(i+xSN)));
            
            invp.S(:,count)=sum(model.qt.Sens(uniqueSet,:));
            eps(count)=sum(model.qt.eps(uniqueSet,:).*(model.qt.elSize(uniqueSet).^2)')/sum(model.qt.elSize(uniqueSet).^2);  
            sigma(count)=sum(model.qt.sigma(uniqueSet,:).*(model.qt.elSize(uniqueSet).^2)')/sum(model.qt.elSize(uniqueSet).^2);  
            count= count+1;
        end
    end
    invp.S(isnan(invp.S))=0;

    W = abs(sum(invp.S,1)); 
    W(W==0)=1;    % to avoid division by zero    
    invp.Sn     = zeros([model.measurement_count,meshWidth*meshHeight]);
    for i=1:meshWidth*meshHeight
        invp.Sn(:,i) = invp.S(:,i)./W(i);
    end

    invp.eps = eps;
    invp.eps_map = reshape(eps, [meshWidth,meshHeight])';

    
    invp.sigma = sigma;
    invp.sigma_map = reshape(sigma, [meshWidth,meshHeight])';

end

fprintf(' . Done. '); toc 

