%% fineMesh 
% Modifies a pattern image used by the meshing algorithm.
% Generation of a pattern in a given geometrical element makes a finer mesh
% in this area.
% A chessboard pattern is genereted in the selected element of the space. 
% 
% *usage:* |model = fineMesh(model,element,elementSize,draw)|
%
% * _model_        - structure with a numerical model description
% * _element_      - a name of the element
% * _elementSize_  - determines the mesh size
% * _draw_         - 0: dont draw the mesh, 1: draw the mesh 
%
% footer$$

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

