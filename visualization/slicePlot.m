% app to display a 3d volume as 3 ortogonal slices
classdef slicePlot < handle
    properties
        %% data
        V
        min_V
        max_V

        mesh_x
        mesh_y
        mesh_z
        
        axis_scale
        
        % slice positions
        pos_x
        pos_y
        pos_z
        % viewpoint 
        az
        el

        %% figures 
        app_figure
    
        %% axes
        main
        layout
        slice_display
        cbar
        
        %% automatic colorbar limits
        caxis_checkbox
        caxis_on
        remember_slider_caxis
    
        %% sliders
        % slice control
        sld_x
        sld_y
        sld_z
        
        plot_title
        colorbar_label
    end

    methods
        function app = slicePlot(patternImage, mesh, varargin)
            if isscalar(varargin)
                app.plot_title = varargin;
            elseif numel(varargin) == 2
                app.plot_title = varargin{1};
                app.colorbar_label = varargin{2};
            else
                app.plot_title = '';
                app.colorbar_label = '';
            end
                
            % these are the values to be displayed
            app.V = patternImage;
            app.min_V = min(app.V(:));
            app.max_V = max(app.V(:));
               
            % this is the grid to display values on
            app.mesh_x = mesh.X;
            app.mesh_y = mesh.Y;
            app.mesh_z = mesh.Z;
            
            % positions of slices
            app.pos_x = 0;
            app.pos_y = 0;
            app.pos_z = 0;

            app.az = -45;
            app.el = 45;
            
            % window and layout config
            app.app_figure = uifigure('Position',[100 100 700 700]);
            app.app_figure.Name = "Slice plot";
            app.layout = uigridlayout(app.app_figure, [4, 1]);
            app.layout.RowHeight = {'6x', '1x','1x', '1x'};
            app.main = uiaxes(app.layout);
            title(app.main, app.plot_title);

            % sliders config 
            app.sld_x = uislider(app.layout);
            app.sld_x.Limits = [min(app.mesh_x(:)) max(app.mesh_x(:))];
            app.sld_x.ValueChangingFcn = @(src,event) app.update_x(src, event);

            app.sld_y = uislider(app.layout);
            app.sld_y.Limits = [min(app.mesh_y(:)) max(app.mesh_y(:))];
            app.sld_y.ValueChangingFcn = @(src,event) app.update_y(src, event);

            app.sld_z = uislider(app.layout);
            app.sld_z.Limits = [min(app.mesh_z(:)) max(app.mesh_z(:))];
            app.sld_z.ValueChangingFcn = @(src,event) app.update_z(src, event);

            view(app.main,[app.az app.el]); % set initial view angle
            app.redraw();
        end

        % slider x callback
        function update_x(app, src, event)
            app.pos_x = event.Value;
            app.redraw();
        end
        
        % slider y callback
        function update_y(app, src, event)
            app.pos_y = event.Value;
            app.redraw();
        end
        
        % slider z callback
        function update_z(app, src, event)
            app.pos_z = event.Value;
            app.redraw();
        end
        
        % call this after every change to redraw plot
        function app = redraw(app)
            [app.az,app.el] = view(app.main);
            app.slice_display = slice(app.main, app.mesh_x,app.mesh_y,app.mesh_z,app.V,app.pos_x,app.pos_y,app.pos_z); 
            app.cbar = colorbar(app.main);
            app.cbar.Label.String = app.colorbar_label;
            for i = 1:length(app.slice_display)
                app.slice_display(i).EdgeColor = 'none';
            end
            view(app.main,[app.az app.el]);
        end
    end
end