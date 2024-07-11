%% shadedSurfaceDisplay - Presents 3D data using Phong shading.
%
% This function presents 3D data using Phong shading, primarily used for displaying permittivity
% and conductivity distributions by drawInvpMap and drawMap.
%
% Usage:
%   shadedSurfaceDisplay(patternImage, varargin)
%
% Inputs:
%   patternImage - 3D matrix with parameter values to be presented.
%
% Varargin (optional):
%   mesh - Structure with X, Y, and Z meshgrid lists of pixel coordinates.
%
% Outputs:
%   None
%
% Example:
%   % Assume patternImage and mesh are already initialized
%   shadedSurfaceDisplay(patternImage, mesh);
%   % This will display the 3D data using Phong shading with the provided mesh coordinates.
%
% See also: drawInvpMap, drawMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function shadedSurfaceDisplay(data, numClusters, varargin)

sz = size(data);

if numel(varargin)
    mesh = varargin{1};
    xm = mesh.X;
    ym = mesh.Y;
    zm = mesh.Z;
else
    [xm, ym, zm] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3)); 
end
    
    dataVector = data(:);

    [idx, C] = kmeans(double(dataVector), numClusters);

    clusteredData = reshape(idx, size(data));

    uniqueElements = unique(clusteredData);

    figure

    for i = 1:length(uniqueElements)
        v = clusteredData;
        v(v~=uniqueElements(i)) = 0;
        s = isosurface(xm, ym, zm, v, 0.1);
        p = patch(s);
        set(p,'FaceColor',[rand rand rand]);  
        set(p,'EdgeColor','none');
    end

    axis([0 sz(1) 0 sz(2) 0 sz(3)]);
    view(3); 
    camlight right; 
    camlight left; 
    lighting gouraud
    axis image
end
