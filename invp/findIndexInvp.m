%% findIndexInvp
% findIndexInvp finds indices in a coarse mesh.
%
% *usage:* |Index = findIndexInvp(modelInvp, element_name)|
% 
% * _modelInvp_  - structure with a numerical model description 
% * _element_name_  - a name of the element 
% 
% footer$ 


function [Index] = findIndexInvp(model, name)

n  = findElement(name,model.Elements);
index = model.Elements{n}.location_index;

A=zeros(size(model.MeshInvp.X));

dx = max(model.Mesh.X(:)) - min(model.Mesh.X(:));
dy = max(model.Mesh.Y(:)) - min(model.Mesh.Y(:));

if model.qt.dim == 3
    dz = max(model.Mesh.Z(:)) - min(model.Mesh.Z(:));
    [~, ~, s3] = size(model.Mesh.X);
    [t1, t2, t3] = size(model.MeshInvp.X);
else
    [t1, t2] = size(model.MeshInvp.X);
end

for k=1:numel(index)
    x = model.Mesh.X(index(k));
    y = model.Mesh.Y(index(k));
    i = round(1+(x+0.5*dx)/(dx)*(t1-1));
    j = round(1+(y+0.5*dy)/(dy)*(t2-1));
    i(i<1)=1;    j(j<1)=1;
    i(i>t1)=t1;  j(j>t2)=t2;
    
    if model.qt.dim == 3
        z = model.Mesh.Z(index(k));
        l = round(1+(z+0.5*dz)/(dz)*(t3-1));
        l(l<1)=1;   l(l>s3)=s3;
        A(i,j,l) = A(i,j,l) + 1;
    else  
        A(i,j) = A(i,j) + 1;
    end
    
end
m = mean(A(A>0));
Index = find(A>0.5*m);
% model.ix = Index; TODO
