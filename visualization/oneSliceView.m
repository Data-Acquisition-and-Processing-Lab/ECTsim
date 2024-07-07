function oneSliceView(data, varargin)
    % Create a new figure with a single axis
    
    sz = size(data);
    if numel(varargin)
        mesh = varargin{1};
        xm = mesh.X;
        ym = mesh.Y;
        unit = 'mm';
    else
        [xm, ym] = meshgrid(1:sz(2), 1:sz(1)); 
        unit = 'px';
    end

    fig = figure('Name', 'Slice View', 'NumberTitle', 'off');
    ax = axes('Parent', fig);
    
    % Display the initial slice
    img = imagesc(ax, xm(1,:), ym(:,1), flipud(data));
    axis image;
    ylabel(['y [', unit, ']']);
    xlabel(['x [', unit, ']']);
    colormap(ax, 'jet'); % Set colormap to jet
    clim([min(data(:)), max(data(:))]);
    
    % Initial window level and window width
    initialWindowLevel = (max(data(:)) + min(data(:))) / 2;
    initialWindowWidth = max(data(:)) - min(data(:));
    userData.scaleFactor = 0.001 * initialWindowWidth;

    wcText = annotation('textbox', [0.01, 0.01, 0.3, 0.05], ...
    'String', sprintf('W: %.1e, C: %.1e', initialWindowWidth, initialWindowLevel), ...
    'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    
    % Add colorbar and adjust its position
    colorbar;

    userData.data = data;
    userData.img = img;
    userData.WindowLevel = initialWindowLevel;
    userData.WindowWidth = initialWindowWidth;
    fig.UserData = userData;
    
    % Add mouse button callbacks
    set(fig, 'WindowButtonDownFcn', @(src, event) mouseButtonCallback(src, event, wcText));
end

function mouseButtonCallback(src, ~, wcText)
    % Check the type of mouse click
    clickType = get(src, 'SelectionType');
    
    if strcmp(clickType, 'alt') % Right mouse button click
        set(src, 'WindowButtonMotionFcn', @(s, e) windowLevelCallback(s, e, wcText));
        set(src, 'WindowButtonUpFcn', @(s, e) mouseReleaseCallback(s, e));        
    end
        % Store the initial point of the cursor
        src.UserData.InitialPoint = get(src, 'CurrentPoint');    
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
    src.UserData.WindowWidth = src.UserData.windowWidth;
    src.UserData.WindowLevel = src.UserData.windowLevel;
    set(src, 'WindowButtonMotionFcn', '');
    set(src, 'WindowButtonUpFcn', '');
end