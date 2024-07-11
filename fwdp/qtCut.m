%% qtCut - Performs a single cut in a quadtree structure.
%
% This function is used primarily within a recursive decomposition algorithm
% (like qtDecom) to divide a matrix based on a measure of non-uniformity, 
% dynamically adjusting the mesh resolution between specified pixel size limits.
%
% Usage:
%   qt = qtCut(QT, A, S, param, pixMin, pixMax)
%
% Inputs:
%   QT     - Quadtree mesh structure.
%   A      - Full matrix that needs to be cut.
%   S      - Temporary matrix that is part of A.
%   param  - Measure of non-uniformity, determining the cutting criteria.
%   pixMin - Minimum pixel size in the mesh.
%   pixMax - Maximum pixel size in the mesh.
%
% Outputs:
%   qt     - Updated quadtree mesh structure after the cut.
%
% Example:
%   % Assume QT is already initialized and A, S are defined
%   param = 0.05;  % Define non-uniformity threshold
%   pixMin = 1;
%   pixMax = 5;
%   qt = qtCut(QT, A, S, param, pixMin, pixMax);
%   % This will perform a cut on A using the specified parameters and update QT.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function [qt, S] = qtCut(qt, A, S, param, pixMin, pixMax)
    temp = qt;
    fin = 0;
    if qt.dim == 2
        while (min(fin)~=1)
            idx = 1;
            for e = 1:qt.length
                i = qt.i(e);
                j = qt.j(e);
                elSize = qt.elSize(e);
                elMax = max(A(i:(i+elSize-1), j:(j+elSize-1)),[],[1 2]);
                elMin = min(A(i:(i+elSize-1), j:(j+elSize-1)),[],[1 2]);
                dif = elMax-elMin;
                if(elSize<=pixMax)&&((dif<=param)||(elSize<=pixMin))
                    fin(idx) = 1;
                    temp.i(idx) = i;
                    temp.j(idx) = j;
                    temp.elSize(idx) = elSize;
                    temp.v(idx) = elMin;
                    S(i,j) = elSize;
                    idx = idx + 1;
                else
                    temp.length = temp.length + 3;
                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx)) = elSize/2;
                    idx = idx + 1;
        
                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx)) = elSize/2;
                    idx = idx + 1;
        
                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j + elSize/2;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx)) = elSize/2;
                    idx = idx + 1;
        
                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j + elSize/2;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx)) = elSize/2;
                    idx = idx + 1;
                end %if
            end %for
            qt = temp;
        end %while
    else % 3D
        while (min(fin)~=1)
            idx = 1;
            for e = 1:qt.length
                i = qt.i(e);
                j = qt.j(e);
                k = qt.k(e);
                elSize = qt.elSize(e);
                elMax = max(A(i:(i+elSize-1), j:(j+elSize-1), k:(k+elSize-1)),[],[1 2 3]);
                elMin = min(A(i:(i+elSize-1), j:(j+elSize-1), k:(k+elSize-1)),[],[1 2 3]);
                dif = elMax-elMin;
                if(elSize<=pixMax)&&((dif<=param)||(elSize<=pixMin))
                    fin(idx) = 1;
                    temp.i(idx) = i;
                    temp.j(idx) = j;
                    temp.k(idx) = k;
                    temp.elSize(idx) = elSize;
                    S(i,j,k) = elSize;
                    temp.v(idx) = elMin;
                    idx = idx + 1;
                else
                    temp.length = temp.length + 7;
                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j;
                    temp.k(idx) = k;
                    temp.elSize(idx) = elSize/2; 
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j;
                    temp.k(idx) = k;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j + elSize/2;
                    temp.k(idx) = k;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j + elSize/2;
                    temp.k(idx) = k;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j;
                    temp.k(idx) = k + elSize/2;
                    temp.elSize(idx) = elSize/2;       
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j;
                    temp.k(idx) = k + elSize/2;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i;
                    temp.j(idx) = j + elSize/2;
                    temp.k(idx) = k + elSize/2;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;

                    fin(idx) = 0;
                    temp.i(idx) = i + elSize/2;
                    temp.j(idx) = j + elSize/2;
                    temp.k(idx) = k + elSize/2;
                    temp.elSize(idx) = elSize/2;
                    S(temp.i(idx),temp.j(idx),temp.k(idx)) = elSize/2;
                    idx = idx + 1;
                end %if
            end %for
            qt = temp;
        end %while
    end%if
end