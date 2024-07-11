%% defineMeshInvp - Distributes points over the workspace to create a mesh grid.
%
% This function distributes points (pixels) over the workspace and creates two matrices,
% X and Y, which store the x and y coordinates representing the grid. The input values
% specify the number of points spread along the width and height of the workspace.
%
% Usage:
%   model = defineMeshInvp(model, widthPoints, heightPoints, depthPoints)
%
% Inputs:
%   model        - Structure with a numerical model description.
%   widthPoints  - Number of points along the width of the mesh.
%   heightPoints - Number of points along the height of the mesh.
%   depthPoints  - Number of points along the depth of the mesh (optional, for 3D).
%
% Outputs:
%   model - Updated model structure with the defined mesh grid.
%
% Example:
%   % Assume model is already initialized
%   widthPoints = 100;
%   heightPoints = 200;
%   depthPoints = 50; % For 3D
%   model = defineMeshInvp(model, widthPoints, heightPoints, depthPoints);
%   % This will create a mesh grid with the specified number of points along each dimension.
%
% See also: defineMesh
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model]=defineMeshInvp(modelInput,widthPoints, heightPoints, varargin)

[model.Electrodes.app_el, model.Electrodes.rec_el] = electrodePairs(modelInput.Electrodes.num,modelInput.measurements_all);
model.Elements = modelInput.Elements;
model.measurement_count=modelInput.measurement_count;
model.real_data = 0;    % reconstruction from simulated data 
if isfield(modelInput,'FOV_name')
    model.FOV_name = modelInput.FOV_name;
end
if isfield(modelInput,'FOV_full')
    model.FOV_full = modelInput.FOV_full;
end
if isfield(modelInput,'FOV_fwdp')
    model.FOV_fwdp = modelInput.FOV_fwdp;
end
if isfield(modelInput,'Workspace')
    if(numel(varargin))
        depthPoints = varargin{1};
        if (widthPoints<2 || heightPoints<2 || depthPoints<2)
            error('There should be at least 2 points along each axis.\n');
        elseif (widthPoints<=modelInput.Mesh.widthPoints && heightPoints<=modelInput.Mesh.heightPoints && depthPoints<=modelInput.Mesh.depthPoints)
            fprintf('Creating the mesh for the inverse problem.\n');
            
            width=modelInput.Workspace.width;
            height=modelInput.Workspace.height;
            depth = modelInput.Workspace.depth;

            w = width/(widthPoints-1);
            h = height/(heightPoints-1);
            d = depth/(depthPoints-1);
            [X,Y,Z]=meshgrid((-width/2):w:(width/2),(-height/2):h:(height/2),(-depth/2):d:(depth/2));
            model.MeshInvp.X=X;
            model.MeshInvp.Y=Y;
            model.MeshInvp.Z=Z;
            model.MeshInvp.meshWidth=widthPoints;
            model.MeshInvp.meshHeight=heightPoints;
            model.MeshInvp.meshDepth=depthPoints;

            model.MeshInvp.pixelSizeHorizontal = w;    
            model.MeshInvp.pixelSizeVertical = h;      % pixelSizeHorizontal, pixelSizeVertical
            model.MeshInvp.pixelSizeDiagonal = d;   
            model.Mesh = modelInput.Mesh;
            
            model.f=modelInput.f;
            model.eps0 = modelInput.eps0;
            model.qt.dim=modelInput.qt.dim;
            model.qt.idxMatrix = modelInput.qt.idxMatrix;
            model.boundary = modelInput.boundary;
            model.measurements_all=modelInput.measurements_all;
            model.Electrodes=modelInput.Electrodes;
            model.Workspace=modelInput.Workspace;
            model.qt.neighbors = modelInput.qt.neighbors;
            model.qt.nE = modelInput.qt.nE;
            model.qt.nW = modelInput.qt.nW;
            model.qt.nN = modelInput.qt.nN;
            model.qt.nS = modelInput.qt.nS;
            model.qt.nA = modelInput.qt.nA;
            model.qt.nB = modelInput.qt.nB;
            model.qt.isBoundary = modelInput.qt.isBoundary;
            model.qt.length = modelInput.qt.length;
            model.qt.V = modelInput.qt.V;
            model.qt.edge = modelInput.qt.edge;
            model.qt.elSize = modelInput.qt.elSize;
            model.qt.eps = modelInput.qt.eps;
            model.qt.sigma = modelInput.qt.sigma;
            model.qt.meshHeight = modelInput.qt.meshHeight;
            model.qt.meshWidth = modelInput.qt.meshWidth;
            model.qt.meshDepth = modelInput.qt.meshDepth;         
            model.qt.size = modelInput.qt.size;                   
            model.qt.i = modelInput.qt.i;                
            model.qt.j = modelInput.qt.j;                
            model.qt.k = modelInput.qt.k;         
        else
            error('The mesh for inverse problem cannot be finner than the forward problem mesh.\n');
        end
    else
        if (widthPoints<2 || heightPoints<2)
            error('There should be at least 2 points along each axis.\n');
        elseif (widthPoints<=modelInput.Mesh.widthPoints && heightPoints<=modelInput.Mesh.heightPoints)
            fprintf('Creating the mesh for the inverse problem.\n');
            width=modelInput.Workspace.width;
            height=modelInput.Workspace.height;

            w = width/(widthPoints-1);
            h = height/(heightPoints-1);
            [X,Y]=meshgrid((-width/2):w:(width/2),(-height/2):h:(height/2));
            model.MeshInvp.X=X;
            model.MeshInvp.Y=Y;
            model.MeshInvp.meshWidth=widthPoints;
            model.MeshInvp.meshHeight=heightPoints;

            model.MeshInvp.pixelSizeHorizontal = w;   
            model.MeshInvp.pixelSizeVertical = h;      % pixelSizeHorizontal, pixelSizeVertical
            model.Mesh = modelInput.Mesh;
            model.qt.idxMatrix = modelInput.qt.idxMatrix;
            model.qt.neighbors = modelInput.qt.neighbors;
            model.qt.nE = modelInput.qt.nE;
            model.qt.nW = modelInput.qt.nW;
            model.qt.nN = modelInput.qt.nN;
            model.qt.nS = modelInput.qt.nS;
            model.qt.isBoundary = modelInput.qt.isBoundary;
            model.qt.length = modelInput.qt.length;
            model.qt.V = modelInput.qt.V;
            model.qt.edge = modelInput.qt.edge;
            model.qt.elSize = modelInput.qt.elSize;
            model.qt.eps = modelInput.qt.eps;
            model.qt.sigma = modelInput.qt.sigma;
            model.qt.meshHeight = modelInput.qt.meshHeight;
            model.qt.meshWidth = modelInput.qt.meshWidth;  
            model.qt.size = modelInput.qt.size;                    
            model.qt.i = modelInput.qt.i;                
            model.qt.j = modelInput.qt.j;          
            
            model.f=modelInput.f;
            model.eps0 = modelInput.eps0;
            model.qt.dim=modelInput.qt.dim;
            model.boundary = modelInput.boundary;
            model.measurements_all=modelInput.measurements_all;
            model.Electrodes=modelInput.Electrodes;
            model.Workspace=modelInput.Workspace;
        else
            error('The mesh for inverse problem cannot be finner than the forward problem mesh.\n');
        end
    end        
else
    error('The workspace should be declared first.\n');
end  
if isfield(modelInput, 'FOV_name')
    model.FOV_invp = findIndexInvp(model, modelInput.FOV_name); % finds indices of fov in invp matrix
end
end

