function [nList] = recNeighSearch(QT, index, pixSize, nList, plane)
%recNeighSearch - recurrent neighbors searching
%   plane 1 - k, 2 - j, 3 - i
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