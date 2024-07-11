%% defineMesh - Distributes points across the workspace.
% 
% This function distributes points (pixels) across the workspace and
% creates two matrices—X and Y—that store x and y coordinates, representing
% the grid. The inputs are numbers of points spread along the width and
% height of the workspace.
%
% Usage:
%   [model] = defineMesh(model, widthPoints, heightPoints, depthPoints)
%
% Inputs:
%   model        - Structure with a numerical model description.
%   widthPoints  - Number of points along the width of the mesh.
%   heightPoints - Number of points along the height of the mesh.
%   depthPoints  - Number of points along the depth of the mesh (only for 3D).
%
% Example:
%   model = defineMesh(model, 100, 200);
%   % For 2D with 100 points along width and 200 points along height.
%
%   model = defineMesh(model, 100, 200, 50);
%   % For 3D with additional 50 points along depth.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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
