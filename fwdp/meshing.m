%% meshing - Creates and manages a quadtree of an image.
%
% This function constructs and maintains a quadtree structure for an image,
% which is useful for managing hierarchical spatial data. The function
% adjusts the mesh based on specified minimum and maximum pixel sizes,
% optimizing spatial indexing and access.
%
% Usage:
%   model = meshing(model, pixMin, pixMax)
%
% Inputs:
%   model   - Structure with a numerical model description.
%   pixMin  - Minimum pixel size in the mesh.
%   pixMax  - Maximum pixel size in the mesh.
%
% Example:
%   model = meshing(model, 1, 4);
%   % Constructs a quadtree for the model with pixel sizes ranging from 1 to 4.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function model = meshing(model,pixMin,pixMax)

    dimension = model.dimension;
    B = model.boundary.B;
    M = model.patternImage;
    ib = model.boundary_points;
    
    model.eps=reshape(model.eps_map,[],1);
    model.sigma=reshape(model.sigma_map,[],1);

    if dimension == 2
        [qt.meshHeight, qt.meshWidth] = size(model.Mesh.X);  %size of source matrix
        
        if (nextpow2(qt.meshHeight)==nextpow2(qt.meshHeight+1)) && (nextpow2(qt.meshWidth)==(nextpow2(qt.meshWidth+1))) % both are not a power of 2
            error('Wrong regular mesh size! At least one component must be a power of 2. The second component can be equal to it or a multiple of it.');
        end
        
        if nextpow2(qt.meshHeight)==nextpow2(qt.meshHeight+1) % first is not a power of 2
            if mod(qt.meshHeight, qt.meshWidth)
                error('Wrong regular mesh size! At least one component must be a power of 2. The second component can be equal to it or a multiple of it.');    
            end
        elseif (nextpow2(qt.meshWidth)==(nextpow2(qt.meshWidth+1))) % second is not a power of 2
            if mod(qt.meshWidth, qt.meshHeight)
                error('Wrong regular mesh size! At least one component must be a power of 2. The second component can be equal to it or a multiple of it.');    
            end
        end
        
        if (pixMin<1) || (pixMin>qt.meshWidth/8) || (pixMax<1) || (pixMax>qt.meshWidth/4) || (pixMin>pixMax)
            error('Wrong minimum and maximum pixel size!');
        end
    
        fprintf('Generating an irregular mesh ...... '); tic;

        F=zeros(qt.meshHeight, qt.meshWidth);
        F(ib) = 1;  
        qt.dim = 2; % 2D
        %------------------------------
        qt = qtDecom(qt, M, .05, pixMin, pixMax);
    %     qt.S = qtdecomp(M,.05,[pixMin pixMax]); %creatring quadtree from source matrix
    %     [i,j,elSize] = find(qt.S);  %decomposition of sprase matrix

        qt.minElSize = min(qt.elSize); %minimal size of pixel in quadtree
        qt.maxElSize = max(qt.elSize); %maximal size of pixel in quadtree
        qt.length = length(qt.elSize); %number of sparse matrix elements
        qt.eps = zeros(qt.length,1);    %preparing vector of pixels permitivities 
        qt.sigma = zeros(qt.length,1);
        qt.V = zeros(qt.length,size(B,2));    %preparing vector of voltage
        qt.splitLevel = zeros(qt.length,1); %preparing vector of pixels split level
        qt.Y = zeros(qt.length,1);
        qt.X = zeros(qt.length,1);
        qt.edge = zeros(qt.length,1);

        qt.Y(:) = (qt.i(:)-1 + qt.elSize(:)/2)/qt.meshHeight * model.Workspace.height - model.Workspace.height/2;
        qt.X(:) = (qt.j(:)-1 + qt.elSize(:)/2)/qt.meshWidth * model.Workspace.width - model.Workspace.width/2;
        qt.splitLevel(:) = log2(qt.meshWidth/qt.elSize(:))+1;  %pixel split level depends on size of source matrix and pixel size

        qt.idxMatrix=qtComp(qt); %matrix fill with index of voxels

        fprintf('. Done. Elements: %d ', qt.length); toc
        % Searching for neighbors 
        fprintf('Searching for neighbors ...... ');tic;

        for n = 1:qt.length
            qt.eps(n) = model.eps_map(qt.i(n),qt.j(n)); %creates sparse vector of permitivites 
            qt.sigma(n) = model.sigma_map(qt.i(n),qt.j(n)); %creates sparse vector of conductivity    
            qt = findNeighbors(qt,n); %searching for all neighbors of every pixel
            qt.edge(n) = min(qt.neighbors{n}); %edge = -1 if one face has no any neighbors 
            qt.isBoundary(n) = F(qt.i(n),qt.j(n));
        end %for

        ix = qt.isBoundary(:)==1;
        qt.V(ix,:) = B(sub2ind(size(M),qt.i(ix),qt.j(ix)),:);

        model.qt = qt;

        fprintf('. Done. Elements: %d ', qt.length); toc

    elseif dimension == 3
        sizeBoundary = size(model.boundary.B,2); %number of boundary points
        [qt.meshHeight, qt.meshWidth, qt.meshDepth] = size(model.Mesh.X);  %size of source matrix
        
        if (nextpow2(qt.meshHeight)==nextpow2(qt.meshHeight+1)) && (nextpow2(qt.meshWidth)==(nextpow2(qt.meshWidth+1))) && (nextpow2(qt.meshDepth)==(nextpow2(qt.meshDepth+1))) % all are not a power of 2
            error('Wrong regular mesh size! At least one component must be a power of 2. Second and third components can be equal to it or a multiple of it.');
        end

        if nextpow2(qt.meshHeight)==nextpow2(qt.meshHeight+1) % first is not a power of 2
            if mod(qt.meshHeight, qt.meshWidth) && mod(qt.meshHeight, qt.meshDepth)
                error('Wrong regular mesh size! At least one component must be a power of 2. Second and third components can be equal to it or a multiple of it.');    
            end
        end

        if (nextpow2(qt.meshWidth)==(nextpow2(qt.meshWidth+1))) % second is not a power of 2
            if mod(qt.meshWidth, qt.meshHeight) && mod(qt.meshWidth, qt.meshDepth)
                error('Wrong regular mesh size! At least one component must be a power of 2. Second and third components can be equal to it or a multiple of it.');    
            end
        end

        if (nextpow2(qt.meshDepth)==(nextpow2(qt.meshDepth+1))) % third is not a power of 2
            if mod(qt.meshDepth, qt.meshHeight) && mod(qt.meshDepth, qt.meshWidth)
                error('Wrong regular mesh size! At least one component must be a power of 2. Second and third components can be equal to it or a multiple of it.');    
            end
        end
        
        if (pixMin<1) || (pixMin>qt.meshWidth/16) || (pixMax<1) || (pixMax>qt.meshWidth/16) || (pixMax>qt.meshDepth/16) || (pixMin>pixMax)
            error('Wrong minimum and maximum pixel size!');
        end

        fprintf('Generating an irregular mesh ...... '); tic;
        F=zeros(qt.meshHeight, qt.meshWidth, qt.meshDepth);
        F(ib) = 1; 
        qt.dim = 3; % 3D

        qt = qtDecom(qt, M, 0.5, pixMin,pixMax);
        i = qt.i; %row index of sparse matrix
        j = qt.j; %column index of sparse matrix
        k = qt.k;
        qt.minElSize = min(qt.elSize); %minimal size of pixel in quadtree
        qt.maxElSize = max(qt.elSize); %maximal size of pixel in quadtree

        qt.eps = zeros(qt.length,1);    %preparing vector of pixels permitivities
        qt.sigma = zeros(qt.length,1);    %preparing vector of pixels permitivities 

        qt.V = zeros(qt.length,sizeBoundary);    %preparing vector of voltage
        qt.splitLevel = zeros(qt.length,1); %preparing vector of pixels split level
        qt.edge = zeros(qt.length,1);
        qt.Y = zeros(qt.length,1);
        qt.X = zeros(qt.length,1);
        qt.Z = zeros(qt.length,1);
        qt.isBoundary = zeros(qt.length,1);

        qt.Y(:) = (qt.i(:)-1 + qt.elSize(:)/2)/qt.meshHeight * model.Workspace.height - model.Workspace.height/2;
        qt.X(:) = (qt.j(:)-1 + qt.elSize(:)/2)/qt.meshWidth * model.Workspace.width - model.Workspace.width/2;
        qt.Z(:) = (qt.k(:)-1 + qt.elSize(:)/2)/qt.meshDepth * model.Workspace.depth - model.Workspace.depth/2;
        qt.splitLevel(:) = log2(qt.meshWidth/qt.elSize(:))+1;  %pixel split level depends on size of source matrix and pixel size

        qt.idxMatrix=qtComp(qt); %matrix fill with index of voxels

        fprintf('. Done. Elements: %d ', qt.length); toc

        %% Searching for neighbors 
        fprintf('Searching for neighbors ...... '); tic;

        for n = 1:qt.length
            qt.eps(n) = model.eps_map(i(n),j(n),k(n)); %creates sparse vector of permitivites

            if isfield(model, 'sigma_map')
                qt.sigma(n) = model.sigma_map(i(n),j(n),k(n)); %creates sparse vector of permitivites    
            end

            qt = findNeighbors(qt,n); %searching for all neighbors of every pixel
            qt.edge(n) = min(qt.neighbors{n}); %edge = -1 if one face has no any neighbors 
            qt.isBoundary(n) = F(i(n),j(n),k(n));        
        end %for

        ix = qt.isBoundary(:)==1;
        qt.V(ix,:) = B(sub2ind(size(M),i(ix),j(ix),k(ix)),:);

        model.qt = qt;
        fprintf('. Done. '); toc
    else
        printf(2, 'model.Workspace should have 2 or 3 fields corresponding to 2D or 3D space.');
        return
    end    

    if isfield(model, 'FOV_name')
        model.FOV_fwdp = findIndexFwdp(model, model.FOV_name); % Determine the indices of the area of interest inside the sensor
    end
end