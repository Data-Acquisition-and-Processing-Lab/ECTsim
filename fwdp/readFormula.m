%% readFormula
% Function extracts names of elements and symbols of operations out of a formula at the input
%
% *usage:* |[components,operations] = readFormula(formula)|
%
% * _formula_ - algebraic expression e.g. from newComplexElement
% * _components_ -  components in formula name
% * _operations_ - operation in formula character
% 
% footer$$

function [components,operations] = readFormula(formula)
operations=string();
components=string();
index=[];
for i=1:length(formula)
    if  (strcmp('+',formula(i)) || strcmp('-',formula(i)) || strcmp('&',formula(i)))
        operations(length(operations)+1)=formula(i);
        index=[index, i];
        if length(index)==1
            components(length(components))=formula(1:(i-1));
            operations(1)=[];
        else
            components(length(components)+1)=formula((index(length(index)-1)+1):(i-1)); 
        end
    elseif i==length(formula)
            components(length(components)+1)=formula(index(length(index))+1:i); 
    end
end

for i=1:length(components)
    if strcmp(' ',components{i}(1))
        components{i}(1)=[];
    end
    if strcmp(' ',components{i}(length(components{i})))
        components{i}(length(components{i}))=[];
    end
end
