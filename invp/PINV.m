%% PINV - Performs the Moore-Penrose pseudoinverse operation.
%
% This function performs the Moore-Penrose pseudoinverse operation for solving
% inverse problems. It updates the inverse model structure by applying the pseudoinverse
% method. An optional damping parameter can be provided.
%
% Usage:
%   invp = PINV(invp, tol)
%
% Inputs:
%   invp - Structure with an inverse model description.
%   tol  - Damping parameter value (optional).
%
% Outputs:
%   invp.rec - Updated inverse model structure after applying the pseudoinverse operation.
%
% Example:
%   % Assume invp is already initialized
%   tol = 1e-5;  % Set the optional damping parameter
%   invp = PINV(invp, tol);
%   % This will perform the pseudoinverse operation on the inverse model with the specified damping parameter.
%
% See also: semiLM and LBP
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function  [rec] = PINV(invp,tol)

rec = invp.min;

if invp.real_data
    Kmax = invp.max.C_real;
    Kmin = invp.min.C_real;
    Kobj = invp.obj.C_real;
else
    Kmax = (invp.max.K);
    Kmin = (invp.min.K);
    Kobj = (invp.obj.K);
end

dK=Kmax-Kmin;

Km = real(Kobj-Kmin)./real(dK)-1i*(imag(Kobj-Kmin)./imag(dK));
Km(isnan(Km))=0;

S = rec.S;
for i = 1:size(S,1)
    S(i,:)= real(rec.S(i,:))./real(dK(i))-1i*(imag(rec.S(i,:))./imag(dK(i)));
end
S(isnan(S))=0;
% 
% solution
W = sum(S,1); 
W(W==0)=1;    % to avoid division by zero    
Sn     = S;
for i=1:size(S,2)
    Sn(:,i) = S(:,i)./W(i);
end

% This formula gives ->   upsilon = (epsilon - i * sigma / omega) / epsilon0
% so  ->  real(upsilon) = epsilon / epislon0
% and ->  imag(upsilon) = -(sigma / omega) / epislon0
% normalized (min<->max)

% ups = pinv(invp.rec.S,tol)*kNorm;
% ups = pinv(S,tol)*kNorm;

% ups = pinv(invp.rec.Sn,tol)*kNorm;
ups = pinv(Sn,tol)*Km;

eps = rec.eps;
eps = eps + real(ups).*(invp.max.eps - invp.min.eps);
eps(eps<1)=1;

sigma = rec.sigma;
sigma = sigma - imag(ups).*(invp.max.sigma - invp.min.sigma);
sigma(sigma<0)=0;

rec.eps     = eps;
rec.sigma     = sigma;

if invp.qt.dim == 2
    rec.eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight).';
    rec.sigma_map = reshape(sigma,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight).';
elseif invp.qt.dim == 3
    rec.eps_map = reshape(eps,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight,invp.MeshInvp.meshDepth);
    rec.sigma_map = reshape(sigma,invp.MeshInvp.meshWidth,invp.MeshInvp.meshHeight,invp.MeshInvp.meshDepth);
end
