%% cuboid
% Function cuboid finds the indicies of cuboid shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.cuboid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
%
% * _model_ - structure with a numerical model description
% * _coordinates_ - coordinates of the centre of the shape. Should 3 values in an array
% * _angle_ - rotation of the created element. Can be 1 or 3 values. If its a single value, the rotation is in the Z axis
% * _dimensions_ - dimentions of the object in x, y and z
% * _bounding_angle1_   - start angle; default 0 (this will cut the shape around the Z axis)
% * _bounding_angle2_   - end angle; default 360 (this will cut the shape around the Z axis)
% * _ring_width_        - width of wall of the hoolow center (if 0 the center is solid)
%
% footer$$

function [Index] = cuboid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
    X = model.Mesh.X;
    Y = model.Mesh.Y;
    Z = model.Mesh.Z;

    width = dimensions(1);
    height = dimensions(2);
    depth = dimensions(3);

    xc = coordinates(1);
    yc = coordinates(2);
    zc = coordinates(3);

    % move to desired position
    X2 = X - xc;
    Y2 = Y - yc;
    Z2 = Z - zc;

    % rotate in 3d
    if numel(angle) == 1
        angle_x = 0;
        angle_y = 0;
        angle_z = angle;
    else
        angle_x = angle(1);
        angle_y = angle(2);
        angle_z = angle(3);
    end

    [X2, Y2, Z2] = findIndex.helper.matrixRotate(X2, Y2, Z2, angle_x, angle_y, angle_z);

    if ring_width > 0
        Index = find(X2 <= (0.5 * width) & X2 >= - (0.5 * width) & Y2 <= (0.5 * height) & Y2 >= - (0.5 * height) & Z2 <= (0.5 * depth) & Z2 >= - (0.5 * depth));
        inside = find(X2 <= (0.5 * width - ring_width) & X2 >= - (0.5 * width - ring_width) & Y2 <= (0.5 * height - ring_width) & Y2 >= - (0.5 * height - ring_width) & Z2 <= (0.5 * depth - ring_width) & Z2 >= - (0.5 * depth - ring_width));
        Index = setdiff(Index, inside);
    else
        Index = find(X2 <= (0.5 * width) & X2 >= - (0.5 * width) & Y2 <= (0.5 * height) & Y2 >= - (0.5 * height) & Z2 <= (0.5 * depth) & Z2 >= - (0.5 * depth));
    end

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        [Theta, ~, ~] = cart2pol(X2, Y2, Z2);
        Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
        Theta = Angles2pi(Theta);
        Theta = rad2deg(Theta);
        Index = intersect(Index, findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    end

end
