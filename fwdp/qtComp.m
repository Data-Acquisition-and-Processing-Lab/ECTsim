%% qtComp
% qtcomp generates a regular matrix from a sparse quadtree mesh (interpolation);
% converts data from an irregular grid to a regular Cartesian grid;        
%
% *usage:*     |[fullMat] = qtComp(model.qt,varargin)|
%
% * _model.qt_  - a quadtree structure that describes an irregular mesh
% * _varargin_  
% * _values_    - a vector of voltage or sensitivity data (samples in non-uniform
% mesh)
% * _scaled_    - the sensitivity map needs to be scaled before displaying
%
% * _fullMat_   - matrix (uniform sampling)
%
% footer$$

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

