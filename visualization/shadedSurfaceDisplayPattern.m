%% shadedSurfaceDisplayPattern - Specific version of shadedSurfaceDisplay for presenting model element lists.
%
% This function is a specific version of shadedSurfaceDisplay used for presenting lists of model elements,
% typically utilized by drawPatternImage with the 'surf' method.
%
% Usage:
%   shadedSurfaceDisplayPattern(patternImage, varargin)
%
% Inputs:
%   patternImage - 3D matrix with numbers indicating the numbering of elements in the model.
%
% Varargin (optional):
%   mesh - Structure with X, Y, and Z meshgrid lists of pixel coordinates.
%
% Outputs:
%   None
%
% Example:
%   % Assume patternImage and mesh are already initialized
%   shadedSurfaceDisplayPattern(patternImage, mesh);
%   % This will display the pattern image using the provided mesh coordinates.
%
% See also: shadedSurfaceDisplay, drawPatternImage
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function shadedSurfaceDisplayPattern(patternImage, varargin)

sz = size(patternImage);

if numel(varargin)
    mesh = varargin{1};
    xm = mesh.X;
    ym = mesh.Y;
    zm = mesh.Z;
else
    [xm, ym, zm] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3)); 
end
    uniqueElements = unique(patternImage);

    figure

    for i = 1:length(uniqueElements)
        v = patternImage;
        v(v~=uniqueElements(i)) = 0;
        s = isosurface(xm, ym, zm, v, 0.1);
        p = patch(s);
        set(p,'FaceColor',[rand rand rand]);  
        set(p,'EdgeColor','none');
    end

    axis([0 sz(2) 0 sz(1) 0 sz(3)]);
    view(3); 
    camlight right; 
    camlight left; 
    lighting gouraud
    axis image
end
