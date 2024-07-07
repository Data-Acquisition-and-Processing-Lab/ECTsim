%% cylinder
% Function cylinder finds the indicies of cylinder shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.cylinder(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
%
% * _model_ - structure with a numerical model description
% * _coordinates_ - coordinates of the centre of the shape. Should 3 values in an array
% * _angle_ - rotation of the created element. Can be 1 or 3 values. If its a single value, the rotation is in the Z axis
% * _dimensions_ - dimentions of the object in x, y and z
% * _bounding_angle1_   - start angle; default 0 (this will cut the shape around the Z axis)
% * _bounding_angle2_   - end angle; default 360 (this will cut the shape around the Z axis)
% * _ring_width_        - width of wall of the hoolow center (if 0 the center is solid). Allows creation of rings
%
% footer$$

function [Index] = cylinder(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)

    haxis = dimensions(1);
    vaxis = dimensions(2);
    depth = dimensions(3);

    xc = coordinates(1);
    yc = coordinates(2);
    zc = coordinates(3);

    X = model.Mesh.X;
    Y = model.Mesh.Y;
    Z = model.Mesh.Z;

    X2 = X - xc;
    Y2 = Y - yc;
    Z2 = Z - zc;

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

    %finding points belonging to the element
    [Theta, R, Z2] = cart2pol(X2, Y2, Z2);

    Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
    Theta = Angles2pi(Theta);
    Theta = rad2deg(Theta);

    Rmax = (vaxis) ./ (sqrt((sind(Theta)) .^ 2 + ((cosd(Theta)) .^ 2) .* ((vaxis / haxis) ^ 2)));

    if (ring_width == 0 || ring_width >= vaxis || ring_width >= haxis)
        Rmin = zeros(size(Theta));
    else
        Rmin = (vaxis - ring_width) ./ (sqrt((sind(Theta)) .^ 2 + ((cosd(Theta)) .^ 2) .* (((vaxis - ring_width) / (haxis - ring_width)) ^ 2)));
    end

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        Index = intersect(find(R <= Rmax & R >= Rmin & Z2 <= (0.5 * depth) & Z2 >= - (0.5 * depth)), findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    else
        Index = find(R <= Rmax & R >= Rmin & Z2 <= (0.5 * depth) & Z2 >= - (0.5 * depth));
    end

end
