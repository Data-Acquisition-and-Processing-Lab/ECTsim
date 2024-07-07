%% boundaryVoltageVector
% * finds points with boundary conditions;
% * finds points with unknown potential;
% * sets the voltage on electrodes and screen (Dirichlet); generates a linear vector (1D) 
%   of voltage distribution for given electrode number;
%   the matrix B is built using the collumn vectors of boundary voltage;
%   IMPORTANT: the voltage can be reduced slowly at the tips of the electrodes
%   to avoid singular points on the sharp edges using the smotting
%   coefficient;
% * write result to the model struct
%
% *usage:* |[model] = boundaryVoltageVector(model, varargin)|
%
% * _model_     - structure with a numerical model description
%
% If varargin: 
%
% * _scoeff_    - optional value in the range (0; 0.5> which controls the smoothness
%
% footer$$

function[model] = boundaryVoltageVector(model, varargin)

[model.boundary_points, model.electrodes_points, model.calculate_points]=findBoundaryCondInd(model);
if(isempty(model.boundary_points) || isempty(model.electrodes_points) || isempty(model.calculate_points) ...
    || (numel(model.unused_points)>0) || ((numel(model.boundary_points)+numel(model.calculate_points))~=numel(model.sensor_points)))
    error('Halted. Mesh points are not assigned!');
else
    disp('Points found with: boundary conditions, exciting electrodes, unknown potential.');
end

[rows,cols]=size(model.Mesh.X);

n=model.Electrodes.elements;
B=[];

% vector of static potential from boundary conditions (screen and electrodes)
b0=sparse(rows*cols,1);
for i=1:numel(model.Sensor)
    if ~isempty(model.Sensor{i}.potential)
        b0(model.Sensor{i}.location_index) = model.Sensor{i}.potential;
    end
end

if numel(varargin) == 0    % voltage on electrodes as defined by user
    % individual vector b for each voltage excitation on electrode
    for i=1:model.Electrodes.num
        b=b0;
        % voltage on excitation electrode
        b(model.Sensor{n(i)}.location_index) = model.Sensor{n(i)}.excitation_potential;
        B=[B,b];
    end
else                % voltage on electrodes smoothed at the ends
    % smoothing coefficient (tip size as a fraction of angular width) 
    sc = varargin{1};
    if sc<0 || sc>0.5    % throw error
        error('boundary smoothing coefficient out of range (0; 0.5>')
    end
    % individual vector b for each voltage excitation on electrode
    for i=1:model.Electrodes.num
        b=b0;
        % find the tips of electrode (angular range)
        %       a2         a3
        %   a1                  a4
        a1 = model.Sensor{n(i)}.bounding_angle1;   
        a4 = model.Sensor{n(i)}.bounding_angle2;
        if a4<a1;    a4 = a4 + 2*pi; end
        aw = a4-a1; 
        a2 = a1 + sc*aw; 
        a3 = a4 - sc*aw;
        % angular distance between electrodes
        a5 = (2*pi-model.Electrodes.num*aw)/model.Electrodes.num+a4;
        v0 = model.Sensor{n(i)}.excitation_potential;
        v1 = v0 * (a5-a4)/(a5-a3);
        % smoothed voltage on excitation electrode
        for k=1:numel(model.Sensor{n(i)}.location_index)
            % calculate the angular position of the mesh point using the X,Y coordinates
            % in relation to the circle center
            x = model.Mesh.X(model.Sensor{n(i)}.location_index(k)) - model.Sensor{n(i)}.centre_x_coordinate;
            y = model.Mesh.Y(model.Sensor{n(i)}.location_index(k)) - model.Sensor{n(i)}.centre_y_coordinate;
            dg = atan2d(y,x);
            if dg<0; dg=360+dg; end
            a = deg2rad(dg);
            if InBoundingAngles(a,a2,a3)        % center of the electrode 
                b(model.Sensor{n(i)}.location_index(k)) = model.Sensor{n(i)}.excitation_potential;  % value defined by the user
            elseif InBoundingAngles(a,a1,a2)    % electrode left tip
                if a1<0;  a11=2*pi+a1; 
                else   ;  a11=a1; end
                b(model.Sensor{n(i)}.location_index(k)) = (v0-v1)*(a-a11)/(a2-a1)+v1;
            elseif InBoundingAngles(a,a3,a4)    % electrode right tip
                if a3>2*pi; a33=a3-2*pi; 
                else   ;    a33=a3; end
                b(model.Sensor{n(i)}.location_index(k)) =(v0-v1)*(1-(a-a33)/(a4-a3))+v1;
            else
                error('error! angular position; boundary smoothing for electrodes')
            end
        end
        B=[B,b];
    end
end
model.boundary.B=B;
