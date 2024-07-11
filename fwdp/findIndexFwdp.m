%% findIndexFwdp - Finds indices in a quadtree mesh.
%
% This function finds the indices of a specified element within a quadtree mesh, which
% can be used for further processing or analysis within the mesh structure.
%
% Usage:
%   index = findIndexFwdp(model, element_name)
%
% Inputs:
%   model        - Structure with a numerical model description.
%   element_name - The name of the element for which indices are needed.
%
% Example:
%   index = findIndexFwdp(model, 'Element1');
%   % Returns indices of 'Element1' in the quadtree mesh of the model.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [index] = findIndexFwdp(model, name)
n  = findElement(name,model.Elements);
index = model.Elements{n}.location_index;
idxLocation=reshape(model.qt.idxMatrix,[],1);
index = unique(idxLocation(index),'stable');

