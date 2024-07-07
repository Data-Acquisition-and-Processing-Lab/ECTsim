%% polygon
% Function polygon finds the indicies of polygon shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.polygon(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
%
% * _model_ - structure with a numerical model description
% * _coordinates_ - coordinates of the edges of the polygon
% * _angle_ - rotation of the created element.
% * _dimensions_ - dimentions of the object in x, y
% * _bounding_angle1_   - start angle; default 0 (this will cut the shape around the Z axis)
% * _bounding_angle2_   - end angle; default 360 (this will cut the shape around the Z axis)
% * _ring_width_        - width of wall of the hoolow center (if 0 the center is solid).
%
% footer$$

function [Index] = polygon(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
    % todo

    % all calculations are preformed on a mesh represenation (see matlab meshgrid)
    X = model.Mesh.X;
    Y = model.Mesh.Y;

    % geometric mean of polygon
    xc = prod(coordinates(:, 1)) .^ (1 / numel(coordinates(:, 1)));
    yc = prod(coordinates(:, 1)) .^ (1 / numel(coordinates(:, 2)));

    % scaling
    if dimensions(1) ~= 1 || dimensions(2) ~= 1
        coordinates(:, 1) = coordinates(:, 1) - xc;
        coordinates(:, 1) = coordinates(:, 1) .* dimensions(1);
        coordinates(:, 1) = coordinates(:, 1) + xc;
        coordinates(:, 2) = coordinates(:, 2) - yc;
        coordinates(:, 2) = coordinates(:, 2) .* dimensions(2);
        coordinates(:, 2) = coordinates(:, 2) + yc;
    end

    % move coordinate system to geometric middle of polygon and rotate
    X2 = (X) * cos(angle) + (Y) * sin(angle);
    Y2 =- (X) * sin(angle) + (Y) * cos(angle);

    if ring_width > 0
        % todo
        Index = inpolygon(X2, Y2, coordinates(:, 1), coordinates(:, 2));
    else
        Index = inpolygon(X2, Y2, coordinates(:, 1), coordinates(:, 2));
    end

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        [Theta, ~] = cart2pol(X2, Y2);
        Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
        Theta = Angles2pi(Theta);
        Theta = rad2deg(Theta);
        Index = intersect(Index, findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    end

end
