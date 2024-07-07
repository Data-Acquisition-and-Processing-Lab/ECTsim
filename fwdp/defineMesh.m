%% defineMesh 
% Distributes points (pixels) over the workspace.
% It creates two variables - matrices X and Y storing respectively
% x and y co-ordinates that represent the grid. 
% Values at the input are numbers of points spread along the width and
% height of the workspace.
%
% # nargin = 3 ->2D
% # nargin = 4 ->3D
%
% *usage:* |[model] = defineMesh(model,widthPoints,heightPoints,(depthPoints))|
%
% * _model_     - structure with a numerical model description
% * _widthPoints_        -  mesh width
% * _heightPoints_       -  mesh height
% * _depthPoints_        -  mesh depth
%
% footer$$

function [model]=defineMesh(varargin)

if (3 <= nargin) && (nargin <= 4)
    model = varargin{1};
    if isfield(model,'Workspace')
        widthPoints = varargin{2};
        heightPoints = varargin{3};
        if nargin == 4
            depthPoints = varargin{4};
        else
            depthPoints = 2;
        end
        if (widthPoints<2 || heightPoints<2 || depthPoints<2)
            error('There should be at least 2 points along each axis.\n');
        else
            fprintf('Creating the regular mesh for the forward problem.\n');
            model.sensor_points=[];
            width=model.Workspace.width;
            height=model.Workspace.height;
            w = width/(widthPoints-1);          
            h = height/(heightPoints-1);
            model.Mesh.pixelSizeHorizontal = w; 
            model.Mesh.pixelSizeVertical = h;
            model.Mesh.widthPoints = widthPoints;
            model.Mesh.heightPoints = heightPoints;
            if nargin == 3
                [X,Y]=meshgrid((-width/2):w:(width/2),(-height/2):h:(height/2));
                model.unused_points=1:1:widthPoints*heightPoints;
            else
                depth=model.Workspace.depth;
                d = depth/(depthPoints-1);
                [X,Y,Z]=meshgrid((-width/2):w:(width/2),(-height/2):h:(height/2),(-depth/2):d:(depth/2));              
                model.unused_points=1:1:widthPoints*heightPoints*depthPoints;
                model.Mesh.pixelSizeDiagonal = d;
                model.Mesh.depthPoints = depthPoints;
                model.Mesh.Z=Z;
            end          
            model.Mesh.X=X;
            model.Mesh.Y=Y;          
        end
    else
        error('The workspace should be declared first.\n');
    end  
else
    error('(defineMesh) Wrong number of arguments');
end
end
