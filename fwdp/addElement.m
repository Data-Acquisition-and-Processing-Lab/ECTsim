%% addElement - Adds an element with a given name to a numerical model.
%
% This function adds an element with a specified name to the 'Sensor' cell array within a numerical model.
% The element must exist in the 'Elements' cell array to be included in the final model and simulation.
% The function ensures that no element sharing grid points with any other element is added.
%
% Usage:
%   model = addElement(model, el_name, permittivity, varargin)
%
% Inputs:
%   model        - Structure with a numerical model description.
%   el_name      - Name of the element to be added.
%   permittivity - Relative permittivity value (>=1).
%   varargin     - Optional parameters including:
%                  conductivity - Conductivity value applied if boundary conditions are set on this element.
%                  potential    - Potential value applied if boundary conditions are set on this element.
%                  excitation   - Excitation potential if the potential is switched on the electrode.
%
% Outputs:
%   model - Updated model structure with the added element.
%
% Example:
%   % Assume model is already initialized and element exists in 'Elements' cell array
%   model = addElement(model, 'Element1', 2.5, 0.01);
%   % This will add 'Element1' with the specified permittivity and conductivity.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

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

