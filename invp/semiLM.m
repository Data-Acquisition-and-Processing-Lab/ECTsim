%% semiLM - Performs the semilinear Levenberg-Marquardt algorithm.
%
% This function performs the semilinear Levenberg-Marquardt algorithm for solving
% inverse problems. It iteratively updates the inverse model to minimize the error
% between the measured and calculated data.
%
% Usage:
%   invp = semiLM(invp, maxiter, alpha, lambda, maxUpdate)
%
% Inputs:
%   invp      - Structure with an inverse model description.
%   maxiter   - Maximum number of iterations.
%   alpha     - Relaxation factor.
%   lambda    - Damping parameter value.
%   maxUpdate - Maximum number of sensitivity matrix updates.
%
% Outputs:
%   invp.rec - Updated inverse model structure after applying the semilinear Levenberg-Marquardt algorithm.
%
% Example:
%   % Assume invp is already initialized
%   maxiter = 100;    % Set the maximum number of iterations
%   alpha = 0.01;     % Set the relaxation factor
%   lambda = 1e-2;    % Set the damping parameter
%   maxUpdate = 10;   % Set the maximum number of sensitivity matrix updates
%   invp = semiLM(invp, maxiter, alpha, lambda, maxUpdate);
%   % This will perform the semilinear Levenberg-Marquardt algorithm on the inverse model.
%
% See also: Landweber and LBP and PINV
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function  [rec] = semiLM(invp,maxiter,alpha,lambda,maxUpdate)

stop = 1e-5;

rec = invp.min;

if isfield(invp,'FOV_invp')
    ix = invp.FOV_invp;
else
    ix = 1:length(rec.eps);
end

if invp.real_data
    Cmax = invp.max.C_real;
    Cmin = invp.min.C_real;
    Cobj = invp.obj.C_real;
else
    Cmax = (invp.max.C)/invp.eps0;
    Cmin = (invp.min.C)/invp.eps0;
    Cobj = (invp.obj.C)/invp.eps0;
end

alpha0 = alpha;
dC=Cmax-Cmin;

Cm = (Cobj)./dC;
Cm(isnan(Cm))=0;

S = real(rec.S);
for i = 1:size(S,1)
    S(i,:)= real(rec.S(i,:))./dC(i);
end
S(isnan(S))=0;

eps = rec.eps;
Cr = S*eps;

Sama=S.'*S;
Sama = Sama+lambda*eye(size(Sama,1));
Sasa=Sama\S.';

St = alpha*Sasa;

res0 = sum((Cr-Cm).^2);
res=ones(maxiter,1);

dis0 = res0;
dis = res;

if isfield(invp, 'obj')
    epsTrue = invp.obj.eps;
else
    epsTrue = rec.eps;
end

err0 = sum((eps(ix)-epsTrue(ix)).^2);
err=ones(maxiter,1);

epsSave = eps;
CrSave = Cr;
updateNo = 0;

for i=2:maxiter

    eps = eps - St*(Cr - Cm);
    eps(eps<1)=1;

    Cr = S*eps;

    res(i) = sum((Cr - Cm).^2)./res0;
    dis(i) = sum((Cr - Cm).^2)./dis0;
    err(i) = sum((eps(ix) - epsTrue(ix)).^2)./err0;

    if ((dis(i-1)-dis(i)) < stop)
        eps = epsSave;        
        Cr = CrSave;
        if alpha>(alpha0*stop)
            alpha=alpha*80/100;
            St=alpha*Sasa;
            res(i) = res(i-1);
            dis(i) = dis(i-1);
            err(i) = err(i-1);
            fprintf('i: %d; alpha: %d;',i,alpha);
        elseif (updateNo<maxUpdate)
            updateNo=updateNo+1;
            fprintf('\n Sensitivity matrix update no. %d; iteration: %d \n',updateNo,i);
            invp.qt.sigma = zeros(size(invp.qt.sigma));
            eps(eps<1)=1;
            if invp.qt.dim == 2
                eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight).';
                modelUp = upscaleModel(invp,eps_map);
                modelUp = calculateElectricField(modelUp);
            elseif invp.qt.dim == 3
                eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight,invp.MeshInvp.meshDepth);
                eps_map = permute(eps_map,[2 1 3]);
                modelUp = upscaleModel(invp,eps_map);
                modelUp = calculateElectricField(modelUp,'bicgstab',1e-4);
            end

            modelUp = calculateSensitivityMaps(modelUp); 
            modelUp = calculateMeasurement(modelUp);
            
            [invp.Electrodes.app_el, invp.Electrodes.rec_el] = electrodePairs(modelUp.Electrodes.num,1);
            invp.post = downscaleModel(invp, modelUp);
            
            invp=withoutRepetition(invp, {'post'});
            clear modelUp;
            
            S = real(invp.post.S);
            for j = 1:size(S,1)
                S(j,:)= real(invp.post.S(j,:))./dC(j);
            end
            S(isnan(S))=0;

            alpha=alpha0/10;
            
            Sama=S.'*S;
            Sama = Sama+lambda*eye(size(Sama,1));
            Sasa=Sama\S.';

            St=alpha*Sasa;

            Cr = S*eps;

            res(i) = 1;
            dis0 = sum((Cr-Cm).^2);
            dis(i) = 1;
        else
            fprintf('\n Residum i: %d; alpha: %d; STOP: no change of estimate.\n',i,alpha);
            break;
        end
    else
        CrSave = Cr;
        epsSave = eps;
    end
end

rec.eps     = eps;

if invp.qt.dim == 2
    rec.eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight).';
elseif invp.qt.dim == 3
    rec.eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight,invp.MeshInvp.meshDepth);
end

rec.residue     = res(1:i);
rec.error     = err(1:i);