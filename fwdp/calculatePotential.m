%% calculatePotential - Calculates electric field potential at nonuniform mesh points.
%
% This function calculates the electric field potential at points of a nonuniform mesh
% stored in the qt structure. For 3D simulations in MATLAB that result in an "out of memory"
% error, an iterative calculation can be used by setting the mode to 'bicgstab'.
%
% Usage:
%   model = calculatePotential(model, mode, tol)
%
% Inputs:
%   model - Structure with a numerical model description.
%   mode  - 'mldivide' (default) or 'bicgstab'. 'bicgstab' is iterative and suggested
%           for 3D simulations with an excessive number of mesh elements.
%   tol   - Tolerance value for the 'bicgstab' algorithm, default is 1e-3.
%
% Outputs:
%   model - Updated model structure with calculated electric field potential.
%
% Example:
%   % Assume model is already initialized
%   mode = 'bicgstab';  % Use iterative calculation for large 3D simulations
%   tol = 1e-3;         % Set tolerance for the iterative solver
%   model = calculatePotential(model, mode, tol);
%   % This will calculate and store the electric field potential in the model.
%
% See also: calculateElectricField
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------


function model = calculatePotential(model,mode,tol)
    fprintf('Calculating potential ...... '); tic;
    

    if (strcmp(mode,'mldivide') || strcmp(mode,'bicgstab')) == 0
        error(['Unknown option: ', mode, '!?']);
    end

    qt = model.qt;
    dim = qt.dim;

    pixelSizeHorizontal=model.Mesh.pixelSizeHorizontal;
    pixelSizeVertical=model.Mesh.pixelSizeVertical;   
    minPxH = pixelSizeVertical;
    minPxV =  pixelSizeHorizontal;

    if dim == 3
        pixelSizeDiagonal=model.Mesh.pixelSizeDiagonal;
        minPxH = min([pixelSizeHorizontal pixelSizeVertical]);
        minPxV = min([pixelSizeHorizontal pixelSizeVertical]);
        minPxD = min([pixelSizeHorizontal pixelSizeVertical]);
    end
    
    Neigh = cellfun('size',qt.neighbors,2);
    neighSum = sum(Neigh(qt.isBoundary==1));
    
    iMat = zeros(neighSum+qt.length,1);
    jMat = zeros(neighSum+qt.length,1);
    v_eps_Mat = zeros(neighSum+qt.length,1);    
    
    bv = zeros(qt.length, size(model.boundary.B,2));
    count = 1;
    for n = 1:qt.length
        if qt.isBoundary(n) %for boundary set voltage 
            iMat(count) = n;
            jMat(count) = n;
            v_eps_Mat(count) = 1;
            bv(n,:) = qt.V(n,:); 
        else 
            if qt.edge(n) == -1 %set Dirichlet conditions at the edge of the grid 
                iMat(count) = n;
                jMat(count) = n;
                v_eps_Mat(count) = 1;
                bv(n)=0;
            else
                alfai = 0;
                for g = 1:size(qt.nN{n},2)
                    neighborIndex = qt.nN{n}(g);                  
                    esiz = qt.elSize(n);
                    nsiz = qt.elSize(neighborIndex);
                    if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                    else
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                    end   
                    alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                    alfai = alfai - alfaj*pixelSizeHorizontal/minPxH;
                    iMat(count) = n;
                    jMat(count) = neighborIndex;
                    v_eps_Mat(count) = alfaj*pixelSizeHorizontal/minPxH;
                    count = count + 1;
                end
                for g = 1:size(qt.nS{n},2)
                    neighborIndex = qt.nS{n}(g);                  
                    esiz = qt.elSize(n);
                    nsiz = qt.elSize(neighborIndex);
                    if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                    else
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                    end   
                    alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                    alfai = alfai - alfaj*pixelSizeHorizontal/minPxH;
                    iMat(count) = n;
                    jMat(count) = neighborIndex;
                    v_eps_Mat(count) = alfaj*pixelSizeHorizontal/minPxH;
                    count = count + 1;
                end
                for g = 1:size(qt.nE{n},2)
                    neighborIndex = qt.nE{n}(g);                  
                    esiz = qt.elSize(n);
                    nsiz = qt.elSize(neighborIndex);
                    if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                    else
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                    end   
                    alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                    alfai = alfai - alfaj*pixelSizeVertical/minPxV;
                    iMat(count) = n;
                    jMat(count) = neighborIndex;
                    v_eps_Mat(count) = alfaj*pixelSizeVertical/minPxV;
                    count = count + 1;
                end
                for g = 1:size(qt.nW{n},2)
                    neighborIndex = qt.nW{n}(g);                  
                    esiz = qt.elSize(n);
                    nsiz = qt.elSize(neighborIndex);
                    if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                    else
                       epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                    end   
                    alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                    alfai = alfai - alfaj*pixelSizeVertical/minPxV;
                    iMat(count) = n;
                    jMat(count) = neighborIndex;
                    v_eps_Mat(count) = alfaj*pixelSizeVertical/minPxV;
                    count = count + 1;
                end
                if qt.dim == 3
                    for g = 1:size(qt.nA{n},2)
                        neighborIndex = qt.nA{n}(g);                  
                        esiz = qt.elSize(n);
                        nsiz = qt.elSize(neighborIndex);
                        if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                           epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                        else
                           epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                        end   
                        alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                        alfai = alfai - alfaj*pixelSizeDiagonal/minPxD;
                        iMat(count) = n;
                        jMat(count) = neighborIndex;
                        v_eps_Mat(count) = alfaj*pixelSizeDiagonal/minPxD;
                        count = count + 1;
                    end
                    for g = 1:size(qt.nB{n},2)
                        neighborIndex = qt.nB{n}(g);                  
                        esiz = qt.elSize(n);
                        nsiz = qt.elSize(neighborIndex);
                        if qt.isBoundary(neighborIndex)      % dont take boundary point parameters!
                           epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(n)-(1i.*qt.sigma(n)))/nsiz    ) / (1/esiz+1/nsiz);
                        else
                           epsf = (   (qt.eps(n)-(1i.*qt.sigma(n)))/esiz   +    (qt.eps(neighborIndex)-(1i.*qt.sigma(neighborIndex)))/nsiz    ) / (1/esiz+1/nsiz);
                        end   
                        alfaj = epsf*(min(esiz,nsiz)^(dim-1))/(esiz+nsiz);
                        alfai = alfai - alfaj*pixelSizeDiagonal/minPxD;
                        iMat(count) = n;
                        jMat(count) = neighborIndex;
                        v_eps_Mat(count) = alfaj*pixelSizeDiagonal/minPxD;
                        count = count + 1;
                    end
                end
                iMat(count) = n;
                jMat(count) = n;
                v_eps_Mat(count) = alfai;
            end %if
        end %if
        count = count + 1;
    end %for
    A = sparse(iMat,jMat,v_eps_Mat);
    qt.A = A;
    qt.bv = bv;
    vt = zeros(size(bv));

    if strcmp(mode,'mldivide')
        qt.vt = A \ bv;
    else

        parpool; 
        pool = gcp('nocreate');
        if ~isempty(pool)
            num_blocks = pool.NumWorkers;
            fprintf('Number of workers assigned: %d\n', num_blocks);
        else
            num_blocks = 1;
            fprintf('No parallel pool available.\n');
        end
        
        block_size = ceil(qt.length / num_blocks);
        L_blocks = cell(num_blocks, 1);
        U_blocks = cell(num_blocks, 1);
        for i = 1:num_blocks
            start_idx = (i-1)*block_size + 1;
            end_idx = min(i*block_size, n);
            A_block = A(start_idx:end_idx, start_idx:end_idx);
            [L_blocks{i}, U_blocks{i}] = ilu(A_block, struct('type', 'ilutp', 'droptol', 1e-3));
        end            
        L = blkdiag(L_blocks{:});
        U = blkdiag(U_blocks{:});

        fprintf('Completed parallel block-wise incomplete LU factorization.\n');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        numWorkers = gcp('nocreate').NumWorkers;
        memUsedPerWorker = estimateMemoryUsage(A, bv(:,1), L, U);
        
        % Get available memory information
        if ispc
            [~, sysInfo] = memory;
            availableMemGB = sysInfo.PhysicalMemory.Available / 1e9;
        elseif isunix
            [~, memInfo] = system('free -m');
            memLines = strsplit(memInfo, '\n');
            memLine = strsplit(strtrim(memLines{2}));
            availableMemGB = str2double(memLine{7}) / 1024;
        else
            error('Unsupported operating system');
        end
        
        % Calculate the maximum number of workers based on available memory
        maxWorkers = floor(availableMemGB / (memUsedPerWorker / 1e9));
        
        % Set the number of workers to the minimum of available workers and the maximum number of workers
        numWorkers = min(numWorkers, maxWorkers);
        if ~numWorkers
            numWorkers = 1;
        end
        % Display information
        fprintf('Available RAM: %.2f GB\n', availableMemGB);
        fprintf('Estimated memory usage per worker: %.2f GB\n', memUsedPerWorker / 1e9);
        fprintf('Number of workers to be launched: %d\n', numWorkers);
        
        % Set new worker pool if needed
        if gcp('nocreate').NumWorkers ~= numWorkers
            delete(gcp('nocreate')); % Main computational loop with parfor
            parpool(numWorkers); % Launch a new worker pool
        end
        
        % Main computational loop with parfor
        length = qt.length;
        parfor (i = 1:size(bv, 2), numWorkers)
            fprintf('i:%d; ', i);
            [vt(:,i), flag, ~, ~] = bicgstab(A, bv(:,i), tol, 50, L, U, zeros(length,1));
            if flag ~= 0
                vt(:,i) = gmres(A, bv(:,i), 10, tol, 50, L, U);
            end
        end
        delete(gcp('nocreate')); 
 
        qt.vt = vt;
        
    end

    model.qt = qt;
    
    fprintf(' . Done. '); toc 

end

% Main computational loop with parfor
function memUsedPerWorker = estimateMemoryUsage(A, bv, L, U)
    % Size of matrix A (assuming sparse)
    numNonZerosA = nnz(A);
    sizeOfA = numNonZerosA * 8; % 8 bytes per non-zero value in sparse double

    % Size of matrices L and U (assuming sparse)
    numNonZerosL = nnz(L);
    numNonZerosU = nnz(U);
    sizeOfL = numNonZerosL * 8; % 8 bytes per non-zero value in sparse double
    sizeOfU = numNonZerosU * 8; % 8 bytes per non-zero value in sparse double

    % Size of vector bv (dense double)
    sizeOfbv = numel(bv) * 8; % 8 bytes per value in dense double

    % Reduce the additional memory estimation for intermediate computations and overhead
    extraMemory = 500 * 1024 * 1024; % 500 MB for other variables and overhead

    % Total memory used by one worker
    memUsedPerWorker = sizeOfA + sizeOfL + sizeOfU + sizeOfbv + extraMemory;
end
