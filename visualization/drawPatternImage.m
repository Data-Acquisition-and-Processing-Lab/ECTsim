%% drawPatternImage - Draws a pattern image representing the distribution of objects in the model.
%
% This function draws a pattern image representing the distribution of objects in the numerical model.
%
% Usage:
%   drawPatternImage(model, mode, method)
%
% Inputs:
%   model  - Numerical model structure.
%   mode   - 'px' for pixels, 'mm' for millimeters.
%   method - (optional) Presentation method for 3D ('surf', 'mpr', or 'slice').
%
% Outputs:
%   None
%
% Example:
%   % Assume model is already initialized
%   drawPatternImage(model, 'mm', 'surf');
%   % This will draw a pattern image in millimeters using the 'surf' presentation method.
%
% See also: drawPotential and drawMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function drawPatternImage(model,mode, varargin)

if numel(varargin)
    method = varargin{1};
else
    method = 'mpr';
end

if numel(varargin)>1
    ix = varargin{2};
else
    ix = 0;
end

dim = length(fieldnames(model.Workspace));

if (isfield(model, 'patternImage_orginal'))
    mapa = model.patternImage_orginal;
elseif(isfield(model, 'patternImage'))
    mapa = model.patternImage;        
else
    error('No pattern image to draw');
end

if ix
    temp = ones(size(mapa)) * max(mapa, [], 'all');
    temp(ix) = mapa(ix);
    mapa = temp;
end

if (dim==3) % 3D

    if (strcmp(method,'surf') || strcmp(method,'mpr') || strcmp(method,'slice')) == 0
        error(['Unknown option: ', method, ' for 3D image. Try surf or mpr.']);
    end

    if (strcmp(method,'surf'))
        if (strcmp(mode,'mm'))
            shadedSurfaceDisplayPattern(mapa,model.Mesh);
        else
            shadedSurfaceDisplayPattern(mapa);
        end
        xlabel(['x [' mode ']'])
        ylabel(['y [' mode ']'])
        zlabel(['z [' mode ']'])
        title('Distribution of objects in the model')
    elseif (strcmp(method,'mpr'))
        if (strcmp(mode,'mm'))
            mpr(mapa,model.Mesh);
        else
            mpr(mapa);
        end
        sgtitle('Distribution of objects in the model','FontSize',12)
    elseif (strcmp(method,'slice'))
        if (strcmp(mode,'mm'))
            sliceView(mapa,model.Mesh);
        else
            sliceView(mapa);
        end
        sgtitle('Distribution of objects in the model','FontSize',12)
    end
else % 2D
    if (strcmp(mode,'px') || strcmp(mode,'mm')) == 0
        error(['Unknown option: ', mode, ' for 2D image. Try px or mm.']);
    end
    if strcmp(mode,'mm')
        oneSliceView(mapa,model.Mesh);
    else
        oneSliceView(mapa);
    end
    title('Distribution of objects in the model')
end
end
