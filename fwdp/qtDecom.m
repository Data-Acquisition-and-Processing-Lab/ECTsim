%% qtDecom 
% Function to create quadtree structure
%
% *usage:* qt = qtDecom(QT, A, param, pixMin, pixMax)
%
% * _QT_ - structure with a numerical model description necessary to
% create a quadtree
% * _A_ - a map used for formation a uniform mesh
% * _param_ - measure of non-uniformity, unused now
% * _pixMin_ - min pixel size in a mesh
% * _pixMax_ -  max pixel size in a mesh
% * _qt_ -  quadtree structure with a numerical model description
%
% footer$$


function qt = qtDecom(QT, A, param, pixMin, pixMax)
    
    QT.size = size(A);
    QT.length = 1;
    QT.i = 1;
    QT.j = 1;
    QT.elSize = QT.size;
    
    if QT.dim == 2
        qt=QT;
        S = zeros(qt.size);
        if qt.size(1)>qt.size(2)
            qt.length = 0;
            QT.elSize = QT.size(2);
            for i=1:qt.size(1)/qt.size(2)
                tempS = zeros(qt.size(2));
                tempQT = QT;
                [tempQT, tempS] = qtCut(tempQT, A((i-1)*qt.size(2)+1:i*qt.size(2),:), tempS, param, pixMin, pixMax);
                S((i-1)*qt.size(2)+1:i*qt.size(2),:) = tempS; 
                qt.i(qt.length+1:qt.length+tempQT.length) = tempQT.i(1:tempQT.length)+(i-1)*qt.size(2);
                qt.j(qt.length+1:qt.length+tempQT.length) = tempQT.j(1:tempQT.length);
                qt.elSize(qt.length+1:qt.length+tempQT.length) = tempQT.elSize(1:tempQT.length);
                qt.v(qt.length+1:qt.length+tempQT.length) = tempQT.v(1:tempQT.length);
                qt.length = qt.length + tempQT.length;
            end
        elseif qt.size(1)<qt.size(2)
            qt.length = 0;
            QT.elSize = QT.size(1);
            for i=1:qt.size(2)/qt.size(1)
                tempS = zeros(qt.size(1));
                tempQT = QT;
                [tempQT, tempS] = qtCut(tempQT, A(:,(i-1)*qt.size(1)+1:i*qt.size(1)), tempS, param, pixMin, pixMax);    
                S(:,(i-1)*qt.size(1)+1:i*qt.size(1)) = tempS; 
                qt.i(qt.length+1:qt.length+tempQT.length) = tempQT.i(1:tempQT.length);
                qt.j(qt.length+1:qt.length+tempQT.length) = tempQT.j(1:tempQT.length)+(i-1)*qt.size(1);
                qt.elSize(qt.length+1:qt.length+tempQT.length) = tempQT.elSize(1:tempQT.length);
                qt.v(qt.length+1:qt.length+tempQT.length) = tempQT.v(1:tempQT.length);
                qt.length = qt.length + tempQT.length;
            end        
        else
            [qt, S] = qtCut(qt, A, S, param, pixMin, pixMax);
        end
        qt.S = S;
    elseif QT.dim == 3
        QT.k = 1;
        qt=QT;
        S = zeros(qt.size);
        if min(qt.size)~=max(qt.size)
            qt.length = 0;
            if qt.size(1) == min(qt.size)
                QT.elSize = QT.size(1);
                for j=1:qt.size(3)/qt.size(1)
                    for i=1:qt.size(2)/qt.size(1)
                        tempS = zeros(qt.size(1));
                        tempQT = QT;
                        [tempQT, tempS] = qtCut(tempQT, A(:,(i-1)*qt.size(1)+1:i*qt.size(1),(j-1)*qt.size(1)+1:j*qt.size(1)), tempS, param, pixMin, pixMax);
                        S(:,(i-1)*qt.size(1)+1:i*qt.size(1),(j-1)*qt.size(1)+1:j*qt.size(1)) = tempS;
                        qt.i(qt.length+1:qt.length+tempQT.length) = tempQT.i(1:tempQT.length);
                        qt.j(qt.length+1:qt.length+tempQT.length) = tempQT.j(1:tempQT.length)+(i-1)*qt.size(1);
                        qt.k(qt.length+1:qt.length+tempQT.length) = tempQT.k(1:tempQT.length)+(j-1)*qt.size(1);
                        qt.elSize(qt.length+1:qt.length+tempQT.length) = tempQT.elSize(1:tempQT.length);
                        qt.v(qt.length+1:qt.length+tempQT.length) = tempQT.v(1:tempQT.length);
                        qt.length = qt.length + tempQT.length;
                    end
                end
            elseif qt.size(2) == min(qt.size)
                QT.elSize = QT.size(2);
                for j=1:qt.size(3)/qt.size(2)
                    for i=1:qt.size(1)/qt.size(2)
                        tempS = zeros(qt.size(2));
                        tempQT = QT;
                        [tempQT, tempS] = qtCut(tempQT, A((i-1)*qt.size(2)+1:i*qt.size(2),:,(j-1)*qt.size(2)+1:j*qt.size(2)), tempS, param, pixMin, pixMax);
                        S((i-1)*qt.size(2)+1:i*qt.size(2),:,(j-1)*qt.size(2)+1:j*qt.size(2)) = tempS;
                        qt.i(qt.length+1:qt.length+tempQT.length) = tempQT.i(1:tempQT.length)+(i-1)*qt.size(2);
                        qt.j(qt.length+1:qt.length+tempQT.length) = tempQT.j(1:tempQT.length);
                        qt.k(qt.length+1:qt.length+tempQT.length) = tempQT.k(1:tempQT.length)+(j-1)*qt.size(2);
                        qt.elSize(qt.length+1:qt.length+tempQT.length) = tempQT.elSize(1:tempQT.length);
                        qt.v(qt.length+1:qt.length+tempQT.length) = tempQT.v(1:tempQT.length);
                        qt.length = qt.length + tempQT.length;
                    end
                end
            elseif qt.size(3) == min(qt.size)
                QT.elSize = QT.size(3);
                for j=1:qt.size(2)/qt.size(3)
                    for i=1:qt.size(1)/qt.size(3)
                        tempS = zeros(qt.size(3));
                        tempQT = QT;
                        [tempQT, tempS] = qtCut(tempQT, A((i-1)*qt.size(3)+1:i*qt.size(3),(j-1)*qt.size(3)+1:j*qt.size(3),:), tempS, param, pixMin, pixMax);
                        S((i-1)*qt.size(3)+1:i*qt.size(3),(j-1)*qt.size(3)+1:j*qt.size(3),:) = tempS;
                        qt.i(qt.length+1:qt.length+tempQT.length) = tempQT.i(1:tempQT.length)+(i-1)*qt.size(3);
                        qt.j(qt.length+1:qt.length+tempQT.length) = tempQT.j(1:tempQT.length)+(j-1)*qt.size(3);
                        qt.k(qt.length+1:qt.length+tempQT.length) = tempQT.k(1:tempQT.length);
                        qt.elSize(qt.length+1:qt.length+tempQT.length) = tempQT.elSize(1:tempQT.length);
                        qt.v(qt.length+1:qt.length+tempQT.length) = tempQT.v(1:tempQT.length);
                        qt.length = qt.length + tempQT.length;
                    end
                end
            end
        else
            [qt, S] = qtCut(qt, A, S, param, pixMin, pixMax);
        end
        qt.S = S;
    else
        printf(2, 'qt.dim should be 2 or 3');
        return
    end
end