%% ellipse
% Function ellipse finds the indicies of ellipse shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.ellipse(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
%
% * _model_ - structure with a numerical model description
% * _coordinates_ - coordinates of the centre of the shape. Should 2 values in an array
% * _angle_ - rotation of the created element.
% * _dimensions_ - dimentions of the object in x, y
% * _bounding_angle1_   - start angle; default 0 (this will cut the shape around the Z axis)
% * _bounding_angle2_   - end angle; default 360 (this will cut the shape around the Z axis)
% * _ring_width_        - width of wall of the hoolow center (if 0 the center is solid). Allows creation of rings
%
% footer$$

function [Index] = ellipse(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
    haxis = dimensions(1);
    vaxis = dimensions(2);

    xc = coordinates(1);
    yc = coordinates(2);

    X = model.Mesh.X;
    Y = model.Mesh.Y;

    % rotation is done by rotating the coordinate sytem
    X2 = (X - xc) * cosd(angle) + (Y - yc) * sind(angle);
    Y2 =- (X - xc) * sind(angle) + (Y - yc) * cosd(angle);

    % change to polar coordinate system
    [Theta, R] = cart2pol(X2, Y2);

    Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
    Theta = Angles2pi(Theta);
    Theta = rad2deg(Theta);

    Rmax = (vaxis) ./ (sqrt((sind(Theta)) .^ 2 + ((cosd(Theta)) .^ 2) .* ((vaxis / haxis) ^ 2)));

    if (ring_width == 0 || ring_width >= vaxis || ring_width >= haxis)
        Rmin = zeros(size(Theta));
    else
        Rmin = (vaxis - ring_width) ./ (sqrt((sind(Theta)) .^ 2 + ((cosd(Theta)) .^ 2) .* (((vaxis - ring_width) / (haxis - ring_width)) ^ 2)));
    end

    Index = find(R <= Rmax & R >= Rmin);

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        Index = intersect(Index, findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    end

end
