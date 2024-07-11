%% qtComp - Recreates a full matrix from a quadtree sparse with new chosen values.
%
% This function takes a sparse representation of a matrix, typically stored
% in a quadtree format, and reconstructs a full, uniform matrix from it. This
% is useful for operations that require a full matrix representation after
% manipulations or calculations have been done in a more compressed form.
%
% Usage:
%   fullMat = qtComp(QT, varargin)
%
% Inputs:
%   QT    - Structure with a numerical model description necessary to create a quadtree.
%   varargin - Additional parameters including the nonuniform mesh to be
%              represented in a uniform mesh.
%
% Outputs:
%   fullMat  - The resulting full, uniform matrix.
%
% Example:
%   fullMat = qtComp(model.qt,model.qt.eps,0);
%   % This example demonstrates how to call qtComp with additional parameters
%   % that modify how the full matrix is constructed from the quadtree.
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function fullMat = qtComp(QT,varargin)
    %  Method needs:
    %   QT.i - vector of horizontal indexes of sparse matrix
    %   QT.j - vector of vertical indexes of sparse matrix
    %   QT.elSize - vector of pixel sizes in sparse matrix
    %   values - vector of new values to put in fullmatrix
    %   QT.length - length of sparse matrix

    if QT.dim == 2
        if(numel(varargin)==0)
            fullMat = zeros(QT.size);
            for f = 1:QT.length
                fullMat(QT.i(f):QT.i(f)+QT.elSize(f)-1,QT.j(f):QT.j(f)+QT.elSize(f)-1) = f;
            end
        else
            if numel(varargin)
                values = varargin{1};
                if varargin{2}==1
                    values = values ./ (QT.elSize(:).^2);
                end
            end
            fullMat = zeros(QT.size);
            for f = 1:QT.length
                fullMat(QT.i(f):QT.i(f)+QT.elSize(f)-1,QT.j(f):QT.j(f)+QT.elSize(f)-1) = values(f);
            end
        end
    elseif QT.dim == 3
        if(numel(varargin)==0)
            fullMat = zeros(QT.size);
            for f = 1:QT.length
                fullMat(QT.i(f):QT.i(f)+QT.elSize(f)-1,QT.j(f):QT.j(f)+QT.elSize(f)-1,QT.k(f):QT.k(f)+QT.elSize(f)-1) = f;
            end
        else
            if numel(varargin)
                values = varargin{1};
                if varargin{2}==1
                    values = values ./ (QT.elSize(:).^3);
                end
            end
            fullMat = zeros(QT.size);
            for f = 1:QT.length
                fullMat(QT.i(f):QT.i(f)+QT.elSize(f)-1,QT.j(f):QT.j(f)+QT.elSize(f)-1,QT.k(f):QT.k(f)+QT.elSize(f)-1) = values(f);
            end
        end
    else
        printf(2, 'qt.dim should be 2 or 3');
    end
end

