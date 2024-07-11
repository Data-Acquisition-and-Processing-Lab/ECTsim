%% sliceView - Presents a single image slice from 3D data (a slice across the Z-axis).
%
% This function presents a single image slice from 3D data. Users can view different cross-sections
% by clicking and dragging the left mouse button from left to right or bottom to top. Dragging the
% right mouse button adjusts the 'w' and 'c' parameters of windowing. This method is used by
% drawMap and drawInvpMap for 3D data.
%
% Usage:
%   sliceView(data, varargin)
%
% Inputs:
%   data - 3D matrix with values to be presented.
%
% Varargin (optional):
%   mesh - Structure with X, Y, and Z meshgrid lists of pixel coordinates.
%
% Outputs:
%   None
%
% Example:
%   % Assume data and mesh are already initialized
%   sliceView(data, mesh);
%   % This will display a single image slice from the 3D data using the provided mesh coordinates.
%
% See also: drawMap, drawInvpMap
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function sliceView(data, varargin)
    % Create a new figure with a single axis
    
    sz = size(data);
    if numel(varargin)
        mesh = varargin{1};
        xm = mesh.X;
        ym = mesh.Y;
        zm = mesh.Z;
        unit = 'mm';
    else
        [xm, ym, zm] = meshgrid(1:sz(2), 1:sz(1), 1:sz(3)); 
        unit = 'px';
    end

    fig = figure('Name', 'Slice View', 'NumberTitle', 'off');
    ax = axes('Parent', fig);
    
    % Initial Z position
    zPos = round(size(data, 3) / 2);
    zPosReal = floor((max(zm(1,1,:))+min(zm(1,1,:)))/2);

    % Display the initial slice
    img = imagesc(ax, xm(1,:,1), ym(:,1,1), squeeze(data(:, :, zPos)));
    axis image;
    ylabel(['y [', unit, ']']);
    xlabel(['x [', unit, ']']);
    colormap(ax, 'jet'); % Set colormap to jet
    clim([min(data(:)), max(data(:))]);
    
    % Initial window level and window width
    initialWindowLevel = (max(data(:)) + min(data(:))) / 2;
    initialWindowWidth = max(data(:)) - min(data(:));
    userData.scaleFactor = 0.001 * initialWindowWidth;

    % Add text annotation for Z position and windowing
    posText = annotation('textbox', [0.70, 0.01, 0.3, 0.05], ...
        'String', sprintf('Z: %d', zPosReal), ...
        'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    wcText = annotation('textbox', [0.01, 0.01, 0.3, 0.05], ...
    'String', sprintf('W: %.1e, C: %.1e', initialWindowWidth, initialWindowLevel), ...
    'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    
    % Add colorbar and adjust its position
    colorbar;

    % Store initial data in UserData
    userData.zPos = zPos;
    userData.data = data;
    userData.img = img;
    userData.posText = posText;
    userData.WindowLevel = initialWindowLevel;
    userData.WindowWidth = initialWindowWidth;
    fig.UserData = userData;
    
    % Add mouse button callbacks
    set(fig, 'WindowButtonDownFcn', @(src, event) mouseButtonCallback(src, event, wcText, zm));
end

function mouseButtonCallback(src, ~, wcText, zm)
    % Check the type of mouse click
    clickType = get(src, 'SelectionType');
    
    if strcmp(clickType, 'normal') % Left mouse button click
        set(src, 'WindowButtonMotionFcn', @(s, e) mouseMotionCallback(s, e, zm));
        set(src, 'WindowButtonUpFcn', @(s, e) mouseReleaseLeftCallback(s, e));
    elseif strcmp(clickType, 'alt') % Right mouse button click
        set(src, 'WindowButtonMotionFcn', @(s, e) windowLevelCallback(s, e, wcText));
        set(src, 'WindowButtonUpFcn', @(s, e) mouseReleaseCallback(s, e));        
    end
        % Store the initial point of the cursor
        src.UserData.InitialPoint = get(src, 'CurrentPoint');
        
end

function mouseMotionCallback(src, ~, zm)
   
    % Get the current cursor position
    src.UserData.CurrentPoint = get(src, 'CurrentPoint');
    sizeZ = size(src.UserData.data, 3);
    
    shiftFactor = sizeZ * 0.001;
    % Calculate the displacement
    % deltaY = round((src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2))*shiftFactor);
    deltaY = (src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2));
    deltaX = src.UserData.CurrentPoint(1) - src.UserData.InitialPoint(1);
    delta = round((deltaX+deltaY)*shiftFactor);

    % Update the Z position based on the displacement
    zPos = src.UserData.zPos + delta; % Adjust scaling factor if needed
    zPos = max(1, min(sizeZ, zPos)); % Ensure zPos stays within bounds
    zPosReal = floor(zm(1,1,zPos));

    % disp(['deltaY: ',int2str(delta),' zPos: ',int2str(zPos)]); % Debug print


    % Update the displayed image
    src.UserData.img.CData = squeeze(src.UserData.data(:, :, zPos));
    
    % Update the Z position text
    src.UserData.posText.String = sprintf('Z: %d', zPosReal);
    
    % Store the updated Z position and cursor point
    % src.UserData.zPos = zPos;
    % src.UserData.InitialPoint = src.UserData.CurrentPoint;
end

function windowLevelCallback(src, ~, wcText)
    src.UserData.CurrentPoint = get(src, 'CurrentPoint');
    deltaY = src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2);
    deltaX = src.UserData.CurrentPoint(1) - src.UserData.InitialPoint(1);
    
    scaleFactor = src.UserData.scaleFactor;
    windowLevel = src.UserData.WindowLevel + deltaY * scaleFactor;
    windowWidth = src.UserData.WindowWidth + deltaX * scaleFactor;
    

    if windowWidth <= 0
        windowWidth = 1;
    end
    caxisLimits = [windowLevel - windowWidth/2, windowLevel + windowWidth/2];

    clim(src.UserData.img.Parent, caxisLimits);

    set(wcText, 'String', sprintf('W: %.1e, C: %.1e', windowWidth, windowLevel));

    src.UserData.windowWidth = windowWidth;
    src.UserData.windowLevel = windowLevel;
end

function mouseReleaseCallback(~, ~)
    % Disable the motion and up callbacks when the mouse button is released
    src = gcbf; % Get current figure handle
    set(src, 'WindowButtonMotionFcn', '');
    set(src, 'WindowButtonUpFcn', '');

    src.UserData.WindowWidth = src.UserData.windowWidth;
    src.UserData.WindowLevel = src.UserData.windowLevel;
end

function mouseReleaseLeftCallback(~, ~)
    % Disable the motion and up callbacks when the mouse button is released
    src = gcbf; % Get current figure handle
    src.UserData.CurrentPoint = get(src, 'CurrentPoint');
    sizeZ = size(src.UserData.data, 3);
    
    shiftFactor = sizeZ * 0.001;
    % Calculate the displacement
    % deltaY = round((src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2))*shiftFactor);
    deltaY = (src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2));
    deltaX = src.UserData.CurrentPoint(1) - src.UserData.InitialPoint(1);
    delta = round((deltaX+deltaY)*shiftFactor);

    % Update the Z position based on the displacement
    zPos = src.UserData.zPos + delta; % Adjust scaling factor if needed
    src.UserData.zPos = max(1, min(sizeZ, zPos)); % Ensure zPos stays within bounds

    src.UserData.img.CData = squeeze(src.UserData.data(:, :, src.UserData.zPos));

    set(src, 'WindowButtonMotionFcn', '');
    set(src, 'WindowButtonUpFcn', '');
end