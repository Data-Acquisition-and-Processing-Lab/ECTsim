%% rectangle
% Function rectangle finds the indicies of rectangle shaped objects in a meshgrid.
%
% *usage:* |[Index] = findIndex.rectangle(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width);|
%
% * _model_ - structure with a numerical model description
% * _coordinates_ - coordinates of the centre of the shape. Should 2 values in an array
% * _angle_ - rotation of the created element.
% * _dimensions_ - dimentions of the object in x, y
% * _bounding_angle1_   - start angle; default 0 (this will cut the shape around the Z axis)
% * _bounding_angle2_   - end angle; default 360 (this will cut the shape around the Z axis)
% * _ring_width_        - width of wall of the hoolow center (if 0 the center is solid).
%
% footer$$

function [Index] = rectangle(model, coordinates, angle, dimensions, bounding_angle1, bounding_angle2, ring_width)
    % all calculations are preformed on a mesh represenation (see matlab meshgrid)
    X = model.Mesh.X;
    Y = model.Mesh.Y;

    xc = coordinates(1);
    yc = coordinates(2);

    width = dimensions(1);
    height = dimensions(2);

    %finding points belonging to the element
    X2 = (X - xc) * cosd(angle) + (Y - yc) * sind(angle);
    Y2 =- (X - xc) * sind(angle) + (Y - yc) * cosd(angle);

    if ring_width > 0
        Index = find(X2 <= (0.5 * width) & X2 >= - (0.5 * width) & X2 <= (0.5 * width) & X2 >= - (0.5 * width) & Y2 <= (0.5 * height) & Y2 >= - (0.5 * height));
        inside = find(X2 <= (0.5 * width - ring_width) & X2 >= - (0.5 * width - ring_width) & Y2 <= (0.5 * height - ring_width) & Y2 >= - (0.5 * height - ring_width));
        Index = setdiff(Index, inside);
    else
        Index = find(X2 <= (0.5 * width) & X2 >= - (0.5 * width) & Y2 <= (0.5 * height) & Y2 >= - (0.5 * height));
    end

    if bounding_angle1 ~= 0 || bounding_angle1 ~= 360
        [Theta, ~] = cart2pol(X2, Y2);
        Angles2pi = @(a) rem(2 * pi + a, 2 * pi); % instead of wrapto2pi which requires Mapping Toolbox
        Theta = Angles2pi(Theta);
        Theta = rad2deg(Theta);
        Index = intersect(Index, findIndex.helper.pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2));
    end

end
