%% readFormula - Extracts names of elements and symbols of operations from an algebraic expression.
%
% This function extracts the names of elements and the symbols of operations from
% an algebraic expression. It is primarily used by the newComplexElement function
% to parse and interpret the formula provided for creating a new complex element.
%
% Usage:
%   [components, operations] = readFormula(formula)
%
% Inputs:
%   formula     - Algebraic expression, e.g., from newComplexElement.
%
% Outputs:
%   components  - Cell array containing the names of the elements in the formula.
%   operations  - Cell array containing the operational symbols used in the formula.
%
% Example:
%   % Define a formula for a new complex element
%   formula = 'el1+el2-el3';
%   [components, operations] = readFormula(formula);
%   % This will extract the components {'el1', 'el2', 'el3'} and the operations {'+', '-'}.
%
% See also: newComplexElement
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [components,operations] = readFormula(formula)
operations=string();
components=string();
index=[];
for i=1:length(formula)
    if  (strcmp('+',formula(i)) || strcmp('-',formula(i)) || strcmp('&',formula(i)))
        operations(length(operations)+1)=formula(i);
        index=[index, i];
        if isscalar(index)
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
