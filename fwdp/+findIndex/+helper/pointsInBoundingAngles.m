%% pointsInBoundingAngles
% Function returns indices of Theta matrix points between bounding angles
% solves problem if bounding angles are below 0 or grater than 360
%
% *usage:*     |[Index] = pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2)|
%
% * _Theta_ - matrix  with angle value; degrees from 0 to 360
% * _bounding_angle1_ - start angle
% * _bounding_angle2_ - end angle
%
%
% footer$$

function [Index] = pointsInBoundingAngles(Theta, bounding_angle1, bounding_angle2)

    if bounding_angle1 >= 0 && bounding_angle1 <= bounding_angle2 && bounding_angle2 <= 360
        Index = find(Theta >= bounding_angle1 & Theta <= bounding_angle2);
    elseif bounding_angle1 >= 0 && bounding_angle1 <= 360 && bounding_angle2 > 360 && (bounding_angle2 - 360 <= bounding_angle1)
        Index = find(Theta >= bounding_angle1 | Theta <= (bounding_angle2 - 360));
    elseif bounding_angle1 < 0 && bounding_angle2 >= 0 && bounding_angle2 <= 360 + bounding_angle1 % for example (-15 : +15 deg)
        Index = find((Theta >= (360 + bounding_angle1) | Theta <= (bounding_angle2)));
    else
        error('Halted. Bounding angles mismatch! Are you sure?');
    end
