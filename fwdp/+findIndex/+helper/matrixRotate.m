%% matrixRotate
% Function matrixRotate rotates a set of 3d cartesian meshgrids around the x, y and z axies
%
% *usage:* |[X, Y, Z] = matrixRotate(meshgrid_X, meshgrid_Y, meshgrid_Z, angle_x, angle_y, angle_z)|
%
% * _X_ - Meshgrid with X axis values
% * _Y_ - Meshgrid with Y axis values
% * _Z_ - Meshgrid with Z axis values
% * _angle_x_ - Angle to be rotated around the X axis
% * _angle_y_ - Angle to be rotated around the Y axis
% * _angle_z_ - Angle to be rotated around the Z axis
%
% footer$$

function [X_rotated, Y_rotated, Z_rotated] = matrixRotate(X, Y, Z, angle_x, angle_y, angle_z)
    % create rotation matrixes

    rot_x = [1, 0, 0; ...
                 0, cosd(angle_x), -sind(angle_x); ...
                 0, sind(angle_x), cosd(angle_x)];

    rot_y = [cosd(angle_y), 0, sind(angle_y); ...
                 0, 1, 0; ...
                 -sind(angle_y), 0, cosd(angle_y)];

    rot_z = [cosd(angle_z), -sind(angle_z), 0; ...
                 sind(angle_z), cosd(angle_z), 0; ...
                 0, 0, 1];

    % convert to and back from linear indecies to preform martix
    % multiplication on rotation matrix
    temp = [X(:), Y(:), Z(:)] * rot_x * rot_y * rot_z;
    X_rotated = reshape(temp(:, 1), size(X));
    Y_rotated = reshape(temp(:, 2), size(Y));
    Z_rotated = reshape(temp(:, 3), size(Z));
end
