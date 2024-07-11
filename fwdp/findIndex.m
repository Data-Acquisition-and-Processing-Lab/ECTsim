%% findIndex - Finds indices in a mesh based on the element name.
%
% This function finds the indices of a specified element in a mesh based on the element name.
%
% Usage:
%   index = findIndex(model, element_name)
%
% Inputs:
%   model        - Structure with a numerical model description.
%   element_name - The name of the element.
%
% Outputs:
%   index - Indices of the specified element in the mesh.
%
% Example:
%   % Assume model is already initialized and element_name is specified
%   element_name = 'targetElement';
%   index = findIndex(model, element_name);
%   % This will return the indices of 'targetElement' in the mesh.
%
% See also: findIndexFwdp and findIndexInvp
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [index] = findIndex(model, name)
    n  = findElement(name,model.Elements);
    index = model.Elements{n}.location_index;
end
