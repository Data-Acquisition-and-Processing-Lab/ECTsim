%% defineWorkspace
% Function initiate the work on a model. The imput arguments are used to
% describe the size of the area which the model will be constructed in.
% Values of width and height should be in mm.
% Function creates global variables: 
%
% * cell array _Elements_ that stores all created simple and complex elements; 
% * cell array _Sensor_ that stores elements that make up the final model of the sensor.
%
% # nargin =2 ->2D
% # nargin =3 ->3D
%
% *usage:* |[model] = defineWorkspace(width, height, (depth))|
%
% * _model_     - structure with a numerical model description
% * _width_        -  workspace width
% * _height_       -  workspace height
% * _depth_        -  workspace depth
%
% footer$$
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