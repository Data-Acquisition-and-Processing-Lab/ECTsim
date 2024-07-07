%% findIndexFwdp
% findIndexFwdp finds indices in a quadtree mesh.
%
% *usage:* |index = findIndexFwdp(model, element_name);|
%
% * _model_  - structure with a numerical model description 
% * _element_name_  - a name of the element 
% 
% footer$ 

function [index] = findIndexFwdp(model, name)
n  = findElement(name,model.Elements);
index = model.Elements{n}.location_index;
idxLocation=reshape(model.qt.idxMatrix,[],1);
index = unique(idxLocation(index),'stable');

