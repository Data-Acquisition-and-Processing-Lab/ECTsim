%% ellipsoid
% Function ellipsoid finds the indicies of ellipsoid shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.ellipsoid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
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

function [Index] = ellipsoid(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
    a = dimensions(1);
    b = dimensions(2);
    c = dimensions(3);

    xc = coordinates(1);
    yc = coordinates(2);
    zc = coordinates(3);

    if numel(angle) == 3
        angle_x = angle(1);
        angle_y = angle(2);
        angle_z = angle(3);
    else
        angle_x = 0;
        angle_y = 0;
        angle_z = angle(3);
    end

    X = model.Mesh.X;
    Y = model.Mesh.Y;
    Z = model.Mesh.Z;

    % shift coordinates to center of ellispoid
    X = X - xc;
    Y = Y - yc;
    Z = Z - zc;

    % apply rotation
    [X, Y, Z] = findIndex.helper.matrixRotate(X, Y, Z, angle_x, angle_y, angle_z);

    % ellipsoid equation
    eq = X .^ 2 / a .^ 2 + Y .^ 2 / b .^ 2 + Z .^ 2 / c .^ 2;

    if ring_width > 0
        Index = find(eq < 1 & eq > ((max([a, b, c]) - ring_width) / max([a, b, c])) .^ 2);
    else
        Index = find(eq < 1);
    end

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        [Theta, ~, ~] = cart2pol(X, Y, Z);
        Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
        Theta = Angles2pi(Theta);
        Theta = rad2deg(Theta);
        Index = intersect(Index, findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    end

end
