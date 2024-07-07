%% findElement 
% Finds an element of the given name in the cell array 
% and returns its index.  
% If no element of that name exists the function returns 0.
%
% *usage:* |[n] = findElement(name,cellArray)|
% 
% * _name_       - a name of the element 
% * _cellArray_  - model.elements or model.Sensor
% * _n_          - an elements index
%
% footer$ 


function [n]=findElement(name,CellArray)
    if ~(isempty(CellArray))
        for i=1:length(CellArray)
            if strcmp(name,CellArray{i}.name)
                n=i;
                break;
            else
                n=0;
            end
        end
    else
        n=0;
    end        
end