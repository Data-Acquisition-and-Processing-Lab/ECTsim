%% findNeighbors 
% Finds pixels (4 neighbors in 2D and 6 in 3D) near a pixel with a given index
%
% *usage:*     |[QT] = findNeighbors(QT,index)|
%  
% * _QT_     - quadtree structure with a numerical model description
% * _index_  - a pixel's index for which the neighbors are searched
%
% footer$$

function QT = findNeighbors(QT,index)
%UNTITLED Summary of this function goes here
%   mode - optional "horizontal" or "vertical"
%   posJ - vertical position of pixel
%   posI - horizontal position of pixel
%   step - size of current pixel

step = QT.elSize(index);
QT.nE{QT.length+1,1} = []; %vector preallocation for neighbourList on the right
QT.nS{QT.length+1,1} = []; %vector preallocation for neighbourList below
QT.nW{QT.length+1,1} = []; %vector preallocation for neighbourList on the left
QT.nN{QT.length+1,1} = []; %vector preallocation for neighbourList above
QT.neighbors{QT.length+1,1} = []; %vector preallocation for neighbourList above

if QT.dim == 2
    %-------------------------------
    %   vertical
    posI = QT.i(index); %set start position of iterator
    posJ = QT.j(index);
    
    if posI == 1 %if a border above
        QT.nS{index,1} = -1;
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end %if
    
    posI = posI+step; 
    
    if posI<=QT.meshHeight %if not a border below
        if QT.S(posI,posJ) == 0 %if bigger pixel below
            neighborIndex = QT.idxMatrix(posI,posJ);
            QT.nN{index,1} = neighborIndex;
            QT.neighbors{index,1} = [QT.neighbors{index,1} neighborIndex];
            QT.nS{neighborIndex,1} = [QT.nS{neighborIndex,1}, index];%adding current pixel position to neighborList of bigger pixel
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index];%------------------
        else %if this same size pixel or smaller below
            step2 = QT.S(posI,posJ);
            sum = step2;
            neighborIndex = QT.idxMatrix(posI,posJ); %if this same size pixel
            if neighborIndex == 0
                dummy =0;
            end
            QT.nN{index,1} = neighborIndex; %adding postion of neighbor pixel to current pixel neighborList
            QT.nS{neighborIndex,1} = [QT.nS{neighborIndex,1}, index];%adding current pixel position to neighborList of neighbor pixel
            QT.neighbors{index,1} = [QT.neighbors{index,1}, neighborIndex];%------------------
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index];%------------------
            
            while sum < step %if smaller then execute while whole side (sum of every neighbor pixel)
                posJ = posJ + step2;
                step2 = QT.S(posI,posJ); %step2 adapts to neighbor pixel size
                sum = sum + step2;
                neighborIndex = QT.idxMatrix(posI,posJ); %if this same size pixel
                QT.nN{index,1} = [QT.nN{index,1}, neighborIndex];
                QT.nS{neighborIndex,1} = [QT.nS{neighborIndex,1}, index];
                QT.neighbors{index,1} = [QT.neighbors{index,1}, neighborIndex];%------------------
                QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index];%------------------
            end %while
        end %if
    else
        QT.nN{index,1} = -1; %if there is border above
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end
    
    %-------------------------------
    %   horizontal
    posI = QT.i(index); %reset of iterator
    posJ = QT.j(index);
    
    if posJ == 1 %if a border on the left
        QT.nW{index,1} = -1;
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end %if
    
    posJ = posJ+step;
    
    if posJ<=QT.meshWidth %if not a border on the left
        if QT.S(posI,posJ) == 0 %bigger pixel on the left
            neighborIndex = QT.idxMatrix(posI,posJ);
            QT.nE{index,1} = neighborIndex;
            QT.neighbors{index,1} = [QT.neighbors{index,1} neighborIndex];
            QT.nW{neighborIndex,1} = [QT.nW{neighborIndex,1}, index];%adding current pixel position to neighborList of bigger pixel
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index];%------------------
        else %this same size pixel or smaller on the right 
            step2 = QT.S(posI,posJ);
            sum = step2;
            neighborIndex = QT.idxMatrix(posI,posJ); %if this same size pixel
            QT.nE{index,1} = [QT.nE{index,1}, neighborIndex];
            QT.nW{neighborIndex,1} = [QT.nW{neighborIndex,1}, index];
            QT.neighbors{index,1} = [QT.neighbors{index,1}, neighborIndex]; %------------------
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index]; %------------------
            
            while sum < step %if smaller then execute while whole side
                posI = posI + step2;
                step2 = QT.S(posI,posJ);
                sum = sum + step2;
                neighborIndex = QT.idxMatrix(posI,posJ); %if this same size pixel
                QT.nE{index,1} = [QT.nE{index,1}, neighborIndex];
                QT.nW{neighborIndex,1} = [QT.nW{neighborIndex,1}, index];
                QT.neighbors{index,1} = [QT.neighbors{index,1}, neighborIndex];%------------------
                QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1}, index];%------------------
            end   %while
        end %if
    else
        QT.nE{index,1} = -1; %if there is border on the right side
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end
else
    QT.nA{QT.length+1,1} = []; %vector preallocation for neighbourList on the above
    QT.nB{QT.length+1,1} = []; %vector preallocation for neighbourList on the below
    
    posI = QT.i(index); %set start position of iterator
    posJ = QT.j(index);
    posK = QT.k(index);
    
    if posI == 1 %if a border at the front
        QT.nS{index,1} = [-1];
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end %if
    
    if posJ == 1 %if a border at the front
        QT.nW{index,1} = [-1];
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end %if
    
    if posK == 1 %if a border at the front
        QT.nA{index,1} = [-1];
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end %if
    
    %------------------------
    %%   searching neighnors on I plate
    posI = posI+step; 
    
    if posI<=QT.meshHeight %if not a border in the back
        if QT.S(posI,posJ,posK) == 0 %if bigger voxel in the back
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nN{index,1} = neighborIndex;
            QT.neighbors{index,1} = [QT.neighbors{index,1} neighborIndex];
        else %this same size voxel or smaller on the front
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nN{index,1} = recNeighSearch(QT, neighborIndex, QT.elSize(index), QT.nN{index,1}, 1);
            QT.neighbors{index,1} = [QT.neighbors{index,1} QT.nN{index,1}];
        end %if
        
        for g = 1:size(QT.nN{index},2) %adding current index to neighbor list of voxel on the back
            neighborIndex = QT.nN{index}(g);
            QT.nS{neighborIndex,1} = [QT.nS{neighborIndex,1} index];
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1} index];
        end %for
    else
        QT.nN{index,1} = [-1]; %if there is border above
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end
    
    % -------------------------------
    %%   searching neighnors on J plate
    posI = QT.i(index); %reset of iterator
    posJ = QT.j(index);
    posK = QT.k(index);
    posJ = posJ+step;
    
    if posJ<=QT.meshWidth %if not a border on the left
        if QT.S(posI,posJ,posK) == 0 %bigger pixel on the left
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nE{index,1} = neighborIndex;
            QT.neighbors{index,1} = [QT.neighbors{index,1} neighborIndex];
        else
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nE{index,1} = recNeighSearch(QT, neighborIndex, QT.elSize(index), QT.nE{index,1}, 2);
            QT.neighbors{index,1} = [QT.neighbors{index,1} QT.nE{index,1}];
        end %if
        
        for g = 1:size(QT.nE{index},2) %adding current index to neighbor list of voxel on the right
            neighborIndex = QT.nE{index}(g);
            QT.nW{neighborIndex,1} = [QT.nW{neighborIndex,1} index];
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1} index];
        end %for
    else
        QT.nE{index,1} = [-1]; %if there is border on the right side
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end
    
    % -------------------------------
    %%   searching neighnors on K plate
    posI = QT.i(index); %reset of iterator
    posJ = QT.j(index);
    posK = QT.k(index);
    posK = posK+step;
    
    if posK<=QT.meshDepth %if not a border on the left
        if QT.S(posI,posJ,posK) == 0 %bigger pixel on the left
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nB{index,1} = neighborIndex;
            QT.neighbors{index,1} = [QT.neighbors{index,1} neighborIndex];
        else %this same size voxel or smaller below
            neighborIndex = QT.idxMatrix(posI,posJ,posK);
            QT.nB{index,1} = recNeighSearch(QT, neighborIndex, QT.elSize(index), QT.nB{index,1}, 3);
            QT.neighbors{index,1} = [QT.neighbors{index,1} QT.nB{index,1}];
        end %if
        
        for g = 1:size(QT.nB{index},2) %adding current index to neighbor list of voxel above
            neighborIndex = QT.nB{index}(g);
            QT.nA{neighborIndex,1} = [QT.nA{neighborIndex,1} index];
            QT.neighbors{neighborIndex,1} = [QT.neighbors{neighborIndex,1} index];
        end %for
    else
        QT.nB{index,1} = [-1]; %if there is border on the right side
        QT.neighbors{index,1} = [QT.neighbors{index,1}, -1];
    end
end