%% recNeighSearch - Recurrent neighbor searching.
%
% This function performs recurrent neighbor searching within a quadtree structure.
% It is used by the findNeighbors function to locate neighboring pixels or elements.
%
% Usage:
%   nList = recNeighSearch(QT, index, pixSize, nList, plane)
%
% Inputs:
%   QT      - Quadtree structure with a numerical model description.
%   index   - Index of the pixel for which neighbors are being searched.
%   pixSize - Size of an element.
%   nList   - Structure with the latest list of neighbors in the plane.
%   plane   - Name of the plane to search:
%             1 - k (z-axis)
%             2 - j (y-axis)
%             3 - i (x-axis)
%
% Outputs:
%   nList   - Updated list of neighbors.
%
% Example:
%   % Assume QT is already initialized and other parameters are defined
%   nList = recNeighSearch(QT, 150, 1, nList, 3);
%   % This will search for neighbors of the pixel at index 150 in the x-axis plane.
%
% See also findNeighbors
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [nList] = recNeighSearch(QT, index, pixSize, nList, plane)

elSize = QT.elSize(index);
i = QT.i(index);
j = QT.j(index);
k = QT.k(index);

if (plane == 1) %plate i
    if (elSize<pixSize)    
        idx = QT.idxMatrix(i, j, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i, j + pixSize/2, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i, j, k + pixSize/2);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i, j + pixSize/2, k + pixSize/2);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
    else
        nList = [nList index];
    end
elseif (plane == 2) %plate j
    if (elSize<pixSize)    
        idx = QT.idxMatrix(i, j, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i + pixSize/2, j, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i, j, k + pixSize/2);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i + pixSize/2, j, k + pixSize/2);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
    else
        nList = [nList index];
    end
else %plate k
    if (elSize<pixSize)    
        idx = QT.idxMatrix(i, j, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i + pixSize/2, j, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i, j + pixSize/2, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
        idx = QT.idxMatrix(i + pixSize/2, j + pixSize/2, k);
        nList = recNeighSearch(QT, idx, pixSize/2, nList, plane);
    else
        nList = [nList index];
    end
end
end