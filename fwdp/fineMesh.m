%% fineMesh - Modifies a pattern image used by the meshing algorithm.
%
% This function adjusts a pattern within a specific geometrical element
% to create a finer mesh in that area. It typically generates a chessboard
% pattern in the selected element of the space to enhance mesh resolution.
%
% Usage:
%   model = fineMesh(model, element, elementSize)
%
% Inputs:
%   model       - Structure with a numerical model description.
%   element     - Name of the element where the mesh will be refined.
%   elementSize - Numerical value that determines the size of the mesh.
%
% Example:
%   model = fineMesh(model, 'Area1', 1);
%   % Refines the mesh in 'Area1' with the specified element size.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------


function model = fineMesh(model,element,elementSize)
    dimension = length(fieldnames(model.Workspace));

    n = findElement(element,model.Elements);
    
    if (~((isfield(model, 'patternImage')) || (isfield(model, 'patternImageSigma'))))
        error('No pattern image to work on')
    end

    if (isfield(model, 'patternImage') && ~isfield(model, 'patternImage_orginal'))
        model.patternImage_orginal = model.patternImage;
    end

    if (isfield(model, 'patternImageSigma') && ~isfield(model, 'patternImageSigma_orginal'))
        model.patternImageSigma_orginal = model.patternImageSigma;
    end
        
    if n == 0
        error ('Element of this name does not exist!');
    end
    
    indx = model.Elements{n}.location_index;
    
    if dimension == 2
        [i, j] = ind2sub(size(model.Mesh.X),indx);
        
        % chessboard generation with the given size of element 
        for it = 1:numel(indx)
            if mod(floor((i(it)-1)/elementSize),2)==mod(floor((j(it)-1)/elementSize),2)
                model.patternImage(i(it),j(it)) = 0;
                model.patternImageSigma(i(it),j(it)) = 0;
            end
        end
    elseif dimension == 3
        [i, j, k] = ind2sub(size(model.Mesh.X),indx);
        
        % chessboard generation with the given size of element 
        for it = 1:numel(indx)
            if mod(floor((i(it)-1)/elementSize),2)==mod(floor((j(it)-1)/elementSize),2)
                model.patternImage(i(it),j(it),k(it)) = 0;
                model.patternImageSigma(i(it),j(it), k(it)) = 0;
            end
        end
    else
        printf(2, 'model.Workspace should have 2 or 3 fields corresponding to 2D or 3D space.');
        return
    end
end

