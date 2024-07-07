function  [rec] = Landweber(invp,maxiter,alpha)
% performs Landweber algorithm
%
% [invp] = Landweber(invp);
%
% * _invp_ - structure with inverse model description
% * _maxiter_ - a max number of iteration
% * _alpha_ - a relaxation factor values
% ectsim - Electrical Capacitance Tomography Image Reconstruction Toolbox

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
St = alpha*S';

res0 = sum((Cr-Cm).^2);
res=ones(maxiter,1);

if isfield(invp, 'obj')
    epsTrue = invp.obj.eps;
else
    epsTrue = rec.eps;
end

err0 = sum((eps(ix)-epsTrue(ix)).^2);
err=ones(maxiter,1);

epsSave = eps;
CrSave = Cr;
% nana = ones(size(rec.eps_map));
for i=2:maxiter
% nana(ix) = eps(ix);
% figure(101)
% imagesc(nana);
% figure(102)
% plot(1:120,Cr,1:120,Cm)
    eps = eps - St*(Cr - Cm);
    eps(eps<1)=1;

    Cr = S*eps;

    res(i) = sum((Cr - Cm).^2)./res0;
    err(i) = sum((eps(ix) - epsTrue(ix)).^2)./err0;

    if (res(i-1)-res(i) < 0)
        eps = epsSave;        
        Cr = CrSave;
        if alpha>(alpha0*1e-4)
            alpha=alpha*90/100;
            St=alpha*S';
            res(i) = res(i-1);
            err(i) = err(i-1);
            fprintf('i: %d; alpha: %d;',i,alpha);
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

rec.residue     = res;
rec.error     = err;

fprintf('\n Residue: %d; Error: %d; \n',rec.residue(i),rec.error(i));
