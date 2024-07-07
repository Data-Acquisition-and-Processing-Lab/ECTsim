%% findIndex
% findIndex finds indices in a coarse mesh.
%
% *usage:* |Index = findIndexInvp(model, element_name)|
% 
% * model  - structure with a numerical model description 
% * _element_name_  - a name of the element 
% 
% footer$ 


function [index] = findIndex(model, name)
    n  = findElement(name,model.Elements);
    index = model.Elements{n}.location_index;
end
