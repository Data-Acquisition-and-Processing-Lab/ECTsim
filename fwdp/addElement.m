%% addElement
% addElement adds an element of given name to a numerical model ('Sensor' cell array). 
% The element must exist in the 'Elements' cell array. 
% This means it will be included in the final model and simulation.
% It prevents from adding element that shares grid points with any other
% element in the numerical model.
%
% *usage:* |[model] = addElement(model,'el_name',permittivity,varargin)|
% 
% * _model_     - structure with a numerical model description
% * _elname_    - a name of the element 
% * _permittivity_        - relative permittivity value (>=1)
% * _varargin_   
% *             - conductivity value [S/m]
% *             - potential value [V] applied if boundary conditions are set on this element; 
% *             - excitation potential [V] if the potential is switched on the electrode
% *             - display mode: 'silent' or 'verbose'
%
% example: to add the element (wihout specifing voltage) to the model without a message
%          model=addElement(model,'circle',plastic_eps,plastic_sigma,[],[],0);
%
% footer$$

%%
function [model] = addElement(model, name, permittivity, varargin)


if numel(varargin)>4
    error('The function takes no more than 7 input arguments: model, name, permittivity and optionally conductivity and one or two potential value!');
end

if isempty(varargin)
    conductivity = 0;
    potential=[];
    excitation_potential = [];
    dspmode = 'verbose';
elseif numel(varargin) == 1
    conductivity = varargin{1};
    potential = [];
    excitation_potential = [];
    dspmode = 'verbose';
elseif numel(varargin) == 2
    conductivity = varargin{1};
    potential=varargin{2};
    excitation_potential = [];
    dspmode = 'verbose';
elseif numel(varargin) == 3
    conductivity = varargin{1};
    potential = varargin{2};
    excitation_potential = varargin{3};
    dspmode = 'verbose';
elseif numel(varargin) == 4
    conductivity = varargin{1};
    potential = varargin{2};
    excitation_potential = varargin{3};
    dspmode = varargin{4};
    if isa(dspmode,'char')
        if ~strcmp(dspmode,'silent') && ~strcmp(dspmode,'verbose')
            error('Wrong arguments. Display can be "silent" or "verbose" only!');
        end
    else
        error('Wrong arguments. Display can be "silent" or "verbose" only!');
    end
end

% check if the element was defined in Elements; it has to be;
[n1]=findElement(name,model.Elements);
if (n1==0)
    error('Element %s does not exist.', name);
end

% the element should be defined in the Sensor model only once
[n2]=findElement(name,model.Sensor);
if (n2~=0)
    error('Element %s has already been added to the Numerical model.', name);
end

% check if the element overlaps with other elements in the Sensor
% model.sensor_points are occupied by elements defined already in the model
% model.unused_points are free
index=model.Elements{n1}.location_index;
if numel(model.unused_points)>=numel(model.sensor_points)
    [C,~,~]=intersect(index,model.sensor_points);
    if isempty(C)
        n3=[];
    else
        n3=1;
    end
else
    [C,~,~]=intersect(index,model.unused_points);
    if numel(C)==numel(index)
        n3=[];
    else
        n3=1;
    end
end
% if(~isempty(n3))
%     error('Element %s shares gridpoints with other element in the Numerical model. Different elements cannnot overlap.', name);
% end

% now we can add the element to the Sensor model       
struct = model.Elements{n1};
struct.permittivity = permittivity;      % eps' - relative permittivity
struct.conductivity = conductivity/(2*pi*model.f*model.eps0);  % eps"
struct.potential = potential;
struct.excitation_potential = excitation_potential;

model.Sensor{length(model.Sensor)+1}=struct;
model.sensor_points=[model.sensor_points,struct.location_index'];
model.unused_points=combineElements(model.unused_points,struct.location_index,'-');

if strcmp(dspmode,'verbose')
    fprintf(1,'Element %s has been added to the Numerical model.\n', name);
end

