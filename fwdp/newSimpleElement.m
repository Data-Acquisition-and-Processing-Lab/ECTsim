%% newSimpleElement - Creates a new solid geometry element and adds it to the 'Elements' cell array.
%
% This function creates a new solid geometry element and adds it to the 'Elements' cell array
% in the numerical model. It checks whether the name has already been used and selects the 
% appropriate function for calculating the geometry.
%
% Usage:
%   model = newSimpleElement(model, shape, name, coord, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
%
% Inputs:
%   model           - Structure with a numerical model description.
%   shape           - Shape of the element, options include: 'ellipse', 'rectangle', 'ellipsoid', 'cuboid', and 'cylinder'.
%   name            - Name of the new element.
%   coord           - Coordinates of the center of the shape, matching the dimensionality of the model.
%   angle           - Rotation angle of the element.
%   dimensions      - Dimensions of the object along the x, y, and z axes (for 3D objects).
%   bounding_angle1 - Start angle for an ellipse segment; default is 0.
%   bounding_angle2 - End angle for an ellipse segment; default is 360.
%   ring_width      - Width of a created ring; default creates a solid interior.
%
% Outputs:
%   model - Updated model structure with the new simple element added.
%
% Example:
%   % Assume model is already initialized
%   model = newSimpleElement(model, 'cylinder', 'test_element1', [0, 0, 0], [0, 45, 15], [50, 50, 50], 0, 270, 25);
%   % This will create a new fragment of cylindrical element named 'test_element1' with the specified parameters.
%
% See also: newComplexElement
%
% If varargin:
% * _bounding_angle1_   - if ellipse segment, start angle; default 0
% * _bounding_angle2_   - if ellipse segment, end angle; default 360
% * _ring_width_        - if ring, width of the created ring. Default is 0 and creates a solid interior
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [model] = newSimpleElement(model, shape, name, coordinates, angle, dimensions, varargin)
    % argument size checks
    if numel(coordinates) ~= length(fieldnames(model.Workspace))
        fprintf(2, 'Coordinates should have the same dimensions (2D, 3D) as the workspace!\n');
    end

    [n] = findElement(name, model.Elements);

    if n > 0
        error('Element %s already exists!\n', model.Elements{n}.name);
    end

    if ~strcmp(shape, 'polygon')
        dim = numel(coordinates); % length of coordinates argument implicadtes 2d or 3d shape
    else
        dim = 2;
    end

    if dim ~= 2 & dim ~= 3
        fprintf(2, 'coordinates shoud be of length 2 or 3, not %i\n', dim);
    end

    if dim == 2

        if numel(angle) ~= 1
            fprintf(2, 'angle for 2d shape should be of length 1, not %i\n', numel(angle));
        end

        if numel(dimensions) ~= 2
            fprintf(2, 'dimentions for 2d shape should be of length 2, not %i\n', numel(dimensions));
        end

    elseif dim == 3

        if numel(angle) ~= 1 & numel(angle) ~= 3
            fprintf(2, 'angle for 3d shape should be of length 1 or 3, not %i\n', numel(angle));
        end

        if numel(dimensions) ~= 3
            fprintf(2, 'dimentions for 3d shape should be of length 3, not %i\n', numel(dimensions));
        end

    end

    % parse varargin
    switch numel(varargin)
        case 0
            bounding_angle1 = 0;
            bounding_angle2 = 360;
            ring_width = 0;
        case 1
            if (numel(varargin{1}) == 1)
                bounding_angle1 = 0;
                bounding_angle2 = varargin{1}(1);
            else
                bounding_angle1 = varargin{1}(1);
                bounding_angle2 = varargin{1}(2);
            end
            ring_width = 0;
        case 2
            if (numel(varargin{1}) == 1)
                bounding_angle1 = 0;
                bounding_angle2 = varargin{1}(1);
            else
                bounding_angle1 = varargin{1}(1);
                bounding_angle2 = varargin{1}(2);
            end
            ring_width = varargin{2};
        otherwise
            if (numel(varargin{1}) == 1)
                bounding_angle1 = 0;
                bounding_angle2 = varargin{1}(1);
            else
                bounding_angle1 = varargin{1}(1);
                bounding_angle2 = varargin{1}(2);
            end
            ring_width = varargin{2};
            printf(2, 'max number of varargin is 3, not %i, but will continue anyway\n', numel(dimensions));
    end

    % shape specific part
    switch shape
        case 'ellipse'

            if dim ~= 2
                fprintf(2, 'You are probably trying to make a 2d shape with 3d arguments, this should work but be careful!')
            end

            [Index] = findIndex.ellipse(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        case 'rectangle'

            if dim ~= 2
                fprintf(2, 'You are probably trying to make a 2d shape with 3d arguments, this should work but be careful!')
            end

            [Index] = findIndex.rectangle(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        case 'polygon'
            % todo
            if numel(coordinates) < 3
                fprintf(2, "too few edges to make a polygon. At least 3 pairs of coordinates needed")
            end

            [Index] = findIndex.polygon(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        case 'ellipsoid'

            if dim ~= 3
                fprintf(2, 'You are probably trying to make a 3d shape with the wrong size of positional arguments. This will probably not work!')
            end

            [Index] = findIndex.ellipsoid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        case 'cuboid'

            if dim ~= 3
                fprintf(2, 'You are probably trying to make a 3d shape with the wrong size of positional arguments. This will probably not work!')
            end

            [Index] = findIndex.cuboid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        case 'cylinder'

            if dim ~= 3
                fprintf(2, 'You are probably trying to make a 3d shape with the wrong size of positional arguments. This will probably not work!')
            end

            [Index] = findIndex.cylinder(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);
        otherwise
            error(2, 'No shape "%s" found. Please input a valid shape name. Valid options are: "ellipse", "rectangle", "ellipsoid", "cuboid" and "cylinder"\n', shape);
    end

    % declaration of the structure
    struct.name = name;
    struct.type = 'simple element';
    struct.shape = shape;
    struct.dimensions = dimensions;
    struct.width = dimensions(1);
    struct.height = dimensions(2);
    struct.bounding_angle1 = bounding_angle1;
    struct.bounding_angle2 = bounding_angle2;
    struct.ring_width = ring_width;
    struct.coordinates = coordinates;
    struct.centre_x_coordinate = coordinates(1);
    struct.centre_y_coordinate = coordinates(2);
    struct.location_index = Index;

    if numel(angle) == 1
        struct.rotation_angle = angle;
    else
        struct.rotation_angle_x = angle(1);
        struct.rotation_angle_y = angle(2);
        struct.rotation_angle_z = angle(3);
    end

    if dim == 3
        struct.depth = dimensions(3);
        struct.centre_z_coordinate = coordinates(3);
    end

    model.Elements{length(model.Elements) + 1} = struct;
    fprintf(1, 'New element %s created.\n', name);

end
