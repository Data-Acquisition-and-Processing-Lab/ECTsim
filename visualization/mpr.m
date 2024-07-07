function mpr(data, varargin)
    % Create a new figure with tiled layout

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

    fig = figure('Name', 'MPR', 'NumberTitle', 'off');
    t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    % Initial crosshair position
    crosshairPosReal = [round(size(data, 1) / 2), round(size(data, 2) / 2), round(size(data, 3) / 2)];
    crosshairPos = [floor((max(xm(1,:,1))+min(xm(1,:,1)))/2), floor((max(ym(:,1,1))+min(ym(:,1,1)))/2), floor((max(zm(1,1,:))+min(zm(1,1,:)))/2)];
    fig.UserData.crosshairPos = crosshairPosReal;
    fig.UserData.crosshairPosReal = crosshairPos;
    
    fig.UserData.WindowLevel = (max(data(:)) + min(data(:))) / 2; % mean value
    fig.UserData.WindowWidth = max(data(:)) - min(data(:)); % amplitude
    fig.UserData.scaleFactor = 0.001 * fig.UserData.WindowWidth;
    
    % Display slices
    hXY = nexttile(t, 1);
    hXYImg = imagesc(xm(1,:,1), ym(:,1,1),squeeze(data(:, :, crosshairPosReal(3))));
    axis image;
    ylabel(['y [', unit, ']']);
    xlabel(['x [', unit, ']']);
    hold on;

    hXZ = nexttile(t, 2);
    hXZImg = imagesc(xm(1,:,1), squeeze(zm(1,1,:)),squeeze(data(crosshairPosReal(1), :, :))');
    axis image;
    ylabel(['z [', unit, ']']);
    xlabel(['x [', unit, ']']);
    hold on;

    hYZ = nexttile(t, 3);
    hYZImg = imagesc(ym(:,1,1), squeeze(zm(1,1,:)),squeeze(data(:, crosshairPosReal(2), :))');
    axis image;
    ylabel(['z [', unit, ']']);
    xlabel(['y [', unit, ']']);
    hold on;

	fig.UserData.hXY = hXY;
    fig.UserData.hXZ = hXZ;
    fig.UserData.hYZ = hYZ;

    % Set colormap and color limits
    colormap(fig, 'jet');

    caxisLimits = [fig.UserData.WindowLevel - fig.UserData.WindowWidth/2, fig.UserData.WindowLevel + fig.UserData.WindowWidth/2];
    if caxisLimits(1) == caxisLimits(2)
        caxisLimits(1) = caxisLimits(1) - 1;
    end

    clim(hXY, caxisLimits);
    clim(hXZ, caxisLimits);
    clim(hYZ, caxisLimits);

    % Add colorbar and adjust its position
    cb = colorbar;
    cb.Layout.Tile = 'east';
    cb.Position = [0.85, 0.1, 0.02, 0.25]; % Adjusted position for colorbar

    % Add crosshair lines
    hXYCrossX = plot(hXY, [crosshairPos(1), crosshairPos(1)], hXY.YLim, 'w');
    hXYCrossY = plot(hXY, hXY.XLim, [crosshairPos(2), crosshairPos(2)], 'w');

    hXZCrossX = plot(hXZ, [crosshairPos(1), crosshairPos(1)], hXZ.YLim, 'w');
    hXZCrossZ = plot(hXZ, hXZ.XLim, [crosshairPos(3), crosshairPos(3)], 'w');

    hYZCrossY = plot(hYZ, [crosshairPos(2), crosshairPos(2)], hYZ.YLim, 'w');
    hYZCrossZ = plot(hYZ, hYZ.XLim, [crosshairPos(3), crosshairPos(3)], 'w');


    % Add text annotation for crosshair position and windowing
    posText = annotation('textbox', [0.55, 0.3, 0.3, 0.05], ...
        'String', sprintf('X: %d, Y: %d, Z: %d', crosshairPos(1), crosshairPos(2), crosshairPos(3)), ...
        'FitBoxToText', 'on', 'HorizontalAlignment', 'center');
    wcText = annotation('textbox', [0.55, 0.2, 0.3, 0.05], ...
    'String', sprintf('W: %.1e, C: %.1e', fig.UserData.WindowWidth, fig.UserData.WindowLevel), ...
    'FitBoxToText', 'on', 'HorizontalAlignment', 'center');

    % Add mouse click callback
    set(fig, 'WindowButtonDownFcn', @(src, event) mouseButtonCallback(src, event, data, ...
        hXY, hXZ, hYZ, hXYImg, hXZImg, hYZImg, ...
        hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ, posText, wcText, xm, ym, zm));

    % Initial crosshair display
    refreshCrosshair(hXY, hXZ, hYZ, crosshairPos, ...
        hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ);
    
end

function mouseButtonCallback(src, event, data, ...
    hXY, hXZ, hYZ, hXYImg, hXZImg, hYZImg, ...
    hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ, posText, wcText, xm, ym, zm)

    % Sprawdzenie typu kliknięcia
    clickType = get(src, 'SelectionType');
    
    switch clickType
        case 'normal' % Kliknięcie lewym przyciskiem myszy
            mouseClick(src, event, data, ...
                hXY, hXZ, hYZ, hXYImg, hXZImg, hYZImg, ...
                hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ, posText, xm, ym, zm);
        case 'alt' % Kliknięcie prawym przyciskiem myszy
            set(src, 'WindowButtonMotionFcn', @(src, event) mouseMotionCallback(src, event, wcText));
            set(src, 'WindowButtonUpFcn',  @(src, event) mouseReleaseCallback(src, event, wcText));
            
            src.UserData.InitialPoint = get(src, 'CurrentPoint');
    end
end

function mouseMotionCallback(src, ~, wcText)
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

    clim(src.UserData.hXY, caxisLimits);
    clim(src.UserData.hXZ, caxisLimits);
    clim(src.UserData.hYZ, caxisLimits);

    set(wcText, 'String', sprintf('W: %.1e, C: %.1e', windowWidth, windowLevel));

end

function mouseReleaseCallback(src, ~, wcText)
    set(src, 'WindowButtonMotionFcn', '');
    set(src, 'WindowButtonUpFcn', '');

    src.UserData.CurrentPoint = get(src, 'CurrentPoint');

    deltaY = src.UserData.CurrentPoint(2) - src.UserData.InitialPoint(2);
    deltaX = src.UserData.CurrentPoint(1) - src.UserData.InitialPoint(1);
    
    scaleFactor = src.UserData.scaleFactor;
    src.UserData.WindowLevel = src.UserData.WindowLevel + deltaY * scaleFactor;
    src.UserData.WindowWidth = src.UserData.WindowWidth + deltaX * scaleFactor;
    set(wcText, 'String', sprintf('W: %.1e, C: %.1e', src.UserData.WindowWidth, src.UserData.WindowLevel));
    
end

function mouseClick(src, ~, data, hXY, hXZ, hYZ, hXYImg, hXZImg, hYZImg, ...
        hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ, posText, xm, ym, zm)
    % Get the current point of the click
    ax = gca;
    clickPoint = get(ax, 'CurrentPoint');

    crosshairPos = src.UserData.crosshairPos;
    crosshairPosReal = src.UserData.crosshairPosReal;
    
    % Check if the click was within the bounds of any axes
    if ax == hXY
        differences = abs(xm(1,:,1) - clickPoint(1,1));
        [~, xClick] = min(differences);
        differences = abs(ym(:,1,1) - clickPoint(1,2));
        [~, yClick] = min(differences);
        if xClick >= 1 && xClick <= size(data, 2) && yClick >= 1 && yClick <= size(data, 1)
            if clickPoint(1,1)<min(xm(1,:,1))
                clickPoint(1,1) = min(xm(1,:,1));
            elseif clickPoint(1,1)>max(xm(1,:,1))
                clickPoint(1,1) = max(xm(1,:,1));
            end
            if clickPoint(1,2)<min(ym(:,1,1))
                clickPoint(1,2) = min(ym(:,1,1));
            elseif clickPoint(1,2)>max(ym(:,1,1))
                clickPoint(1,2) = max(ym(:,1,1));
            end
            crosshairPosReal(1:2) = [round(clickPoint(1,1)), round(clickPoint(1,2))];
            crosshairPos(1:2) = [xClick, yClick];
            hXZImg.CData = squeeze(data(crosshairPos(2), :, :))';
            hYZImg.CData = squeeze(data(:, crosshairPos(1), :))';
        end
    elseif ax == hXZ
        differences = abs(xm(1,:,1) - clickPoint(1,1));
        [~, xClick] = min(differences);
        differences = abs(zm(1,1,:) - clickPoint(1,2));
        [~, yClick] = min(differences);
        if xClick >= 1 && xClick <= size(data, 2) && yClick >= 1 && yClick <= size(data, 3)
            if clickPoint(1,1)<min(xm(1,:,1))
                clickPoint(1,1) = min(xm(1,:,1));
            elseif clickPoint(1,1)>max(xm(1,:,1))
                clickPoint(1,1) = max(xm(1,:,1));
            end
            if clickPoint(1,2)<min(zm(1,1,:))
                clickPoint(1,2) = min(zm(1,1,:));
            elseif clickPoint(1,2)>max(zm(1,1,:))
                clickPoint(1,2) = max(zm(1,1,:));
            end
            crosshairPosReal([1, 3]) = [round(clickPoint(1,1)), round(clickPoint(1,2))];
            crosshairPos([1, 3]) = [xClick, yClick];
            hXYImg.CData = squeeze(data(:, :, crosshairPos(3)));
            hYZImg.CData = squeeze(data(:, crosshairPos(1), :))';
        end
    elseif ax == hYZ
        differences = abs(ym(:,1,1) - clickPoint(1,1));
        [~, xClick] = min(differences);
        differences = abs(zm(1,1,:) - clickPoint(1,2));
        [~, yClick] = min(differences);
        if xClick >= 1 && xClick <= size(data, 1) && yClick >= 1 && yClick <= size(data, 3)
            if clickPoint(1,1)<min(ym(:,1,1))
                clickPoint(1,1) = min(ym(:,1,1));
            elseif clickPoint(1,1)>max(ym(:,1,1))
                clickPoint(1,1) = max(ym(:,1,1));
            end
            if clickPoint(1,2)<min(zm(1,1,:))
                clickPoint(1,2) = min(zm(1,1,:));
            elseif clickPoint(1,2)>max(zm(1,1,:))
                clickPoint(1,2) = max(zm(1,1,:));
            end
            crosshairPos(2:3) = [xClick, yClick];
            crosshairPosReal(2:3) = [round(clickPoint(1,1)), round(clickPoint(1,2))];
            hXYImg.CData = squeeze(data(:, :, crosshairPos(3)));
            hXZImg.CData = squeeze(data(crosshairPos(2), :, :))';
        end
    else
        % Ignore clicks outside of the main axes
        return;
    end

    src.UserData.crosshairPos = crosshairPos;
    src.UserData.crosshairPosReal = crosshairPosReal;

    % Update crosshair position text
    set(posText, 'String', sprintf('X: %d, Y: %d, Z: %d', crosshairPosReal(1), crosshairPosReal(2), crosshairPosReal(3)));

    % Refresh crosshairs
    refreshCrosshair(hXY, hXZ, hYZ, crosshairPosReal, hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ);
end

function refreshCrosshair(~, ~, ~, crosshairPos, hXYCrossX, hXYCrossY, hXZCrossX, hXZCrossZ, hYZCrossY, hYZCrossZ)
    % Update XY crosshairs
    set(hXYCrossX, 'XData', [crosshairPos(1), crosshairPos(1)]);
    set(hXYCrossY, 'YData', [crosshairPos(2), crosshairPos(2)]);

    % Update XZ crosshairs
    set(hXZCrossX, 'XData', [crosshairPos(1), crosshairPos(1)]);
    set(hXZCrossZ, 'YData', [crosshairPos(3), crosshairPos(3)]);

    % Update YZ crosshairs
    set(hYZCrossY, 'XData', [crosshairPos(2), crosshairPos(2)]);
    set(hYZCrossZ, 'YData', [crosshairPos(3), crosshairPos(3)]);
end
