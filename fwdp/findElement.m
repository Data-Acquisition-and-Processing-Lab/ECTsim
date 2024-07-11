%% findElement - Finds an element by name within a cell array and returns its index.
%
% This function searches for an element by name within a specified cell array and returns
% its index. If no element with the given name exists, the function returns 0.
%
% Usage:
%   n = findElement(name, cellArray)
%
% Inputs:
%   name      - The name of the element to find.
%   cellArray - Cell array to search within (e.g., model.elements or model.sensor).
%
% Outputs:
%   n - The index of the element, or 0 if no element with the given name exists.
%
% Example:
%   % Assume cellArray is already initialized and contains elements
%   name = 'targetElement';
%   n = findElement(name, cellArray);
%   % This will return the index of 'targetElement' in the cell array, or 0 if it does not exist.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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