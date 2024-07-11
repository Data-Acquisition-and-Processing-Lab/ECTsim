%% defineWorkspace - Initiates work on a model.
%
% This function initializes a workspace for constructing a model. The input arguments
% describe the size of the area in which the model will be constructed. Values for
% width and height should be provided in millimeters. The function creates global
% variables to store elements of the model.
%
% Usage:
%   model = defineWorkspace(width, height, depth)
%
% Inputs:
%   width  - Workspace width in millimeters.
%   height - Workspace height in millimeters.
%   depth  - Workspace depth in millimeters (optional for 3D).
%
% Outputs:
%   model - Structure with a numerical model description.
%
% Global Variables:
%   Elements - Cell array that stores all created simple and complex elements.
%   Sensor   - Cell array that stores elements making up the final sensor model.
%
% Notes:
%   nargin = 2 for 2D models.
%   nargin = 3 for 3D models.
%
% Example:
%   % Define a 2D workspace
%   model = defineWorkspace(100, 200);
%   % Define a 3D workspace
%   model = defineWorkspace(100, 200, 50);
%   % This will initialize a workspace with the specified dimensions.
%
% See also: defineMesh
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model]=defineWorkspace(varargin)


if (2 <= nargin) && (nargin <= 3)
    fprintf('ECT sensor numerical modelling.\n');
    fprintf('Creating the workspace ...... \n');
    
    model.f = 0;
    model.eps0 = 8.854187817*10^-12;

    model.Elements={};
    model.Sensor={};
    model.Workspace.width=varargin{1};
    model.Workspace.height=varargin{2};
    model.dimension = 2;
    if nargin == 3
        model.Workspace.depth=varargin{3}; % 3D
        model.dimension = 3;
    end
else
    disp('(defineWorkspace) Wrong number of arguments');
    return;
end
end