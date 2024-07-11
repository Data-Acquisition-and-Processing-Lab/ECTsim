%% ccalculateSensitivityMaps - Calculates sensitivity at nonuniform mesh points.
%
% This function calculates the sensitivity at points of a nonuniform mesh stored in the
% qt structure using a scalar product with the conjugate. The sensitivity is stored in
% sparse vectors S(elem,pair), where the number of rows equals the number of leaves
% and the number of columns equals the number of electrode pairs. The calculated
% sensitivity depends on the size of the pixel and requires normalization before
% interpolation to a uniform mesh.
%
% Usage:
%   model = calculateSensitivityMaps(model)
%
% Inputs:
%   model - Structure with a numerical model description.
%
% Outputs:
%   model - Updated model structure with calculated sensitivity maps.
%
% Example:
%   % Assume model is already initialized
%   model = calculateSensitivityMaps(model);
%   % This will calculate and store the sensitivity maps in the model.
%
% See also: calculateElectricField and calculatePotential
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------


function [model] = calculateSensitivityMaps(model)
    
    % calculate sensitivity in quadtree mesh
    fprintf('Calculating sensitivity maps ...... '); tic;

    % size of the smallest element in [m] 
    pixelSizeHorizontal=model.Mesh.pixelSizeHorizontal*1e-3;  % [m];
    pixelSizeVertical=model.Mesh.pixelSizeVertical*1e-3;  % [m];
    pairs = numel(model.Electrodes.app_el);
    model.qt.Sens = zeros(model.qt.length, pairs);
    
    if model.qt.dim == 2
        height = model.Electrodes.height*1e-3;
        
        % electric field components   Ev = [dVx/dx, dVy/dy]
        % for all electrodes at once
        for i=1:pairs
            el_a = model.Electrodes.app_el(i);
            el_r = model.Electrodes.rec_el(i);
            U = model.Electrodes.app_v(i) - model.Electrodes.rec_v(i);
            model.qt.Sens(:,i) = -(1/(U^2))* ... 
            (model.qt.Ex(:,el_a).*conj(model.qt.Ex(:,el_r)) + model.qt.Ey(:,el_a).*conj(model.qt.Ey(:,el_r))) ...
                 * pixelSizeHorizontal*pixelSizeVertical*height .* model.qt.elSize(:).^2;   % sensitivity integrated over pixel
        end
    elseif model.qt.dim == 3
        pixelSizeDiagonal=model.Mesh.pixelSizeDiagonal*1e-3;  % [m];
        
        % electric field components   Ev = [dVx/dx, dVy/dy , dVz,dz]
        % for all electrodes at once
        for i=1:pairs
            el_a = model.Electrodes.app_el(i);
            el_r = model.Electrodes.rec_el(i);
            U = model.Electrodes.app_v(i) - model.Electrodes.rec_v(i);
            model.qt.Sens(:,i) = -(1/(U^2))* ... 
            (model.qt.Ex(:,el_a).*conj(model.qt.Ex(:,el_r)) + model.qt.Ey(:,el_a).*conj(model.qt.Ey(:,el_r))+ model.qt.Ez(:,el_a).*conj(model.qt.Ez(:,el_r))) ...
                 * pixelSizeHorizontal*pixelSizeVertical*pixelSizeDiagonal .* model.qt.elSize(:).^3;   % sensitivity integrated over voxel  ??? ^3
        end
    else
        fprintf('model.Workspace should have 2 or 3 fields corresponding to 2D or 3D space');
        return
    end

    model.qt.Sens(model.qt.edge==-1,:) = 0;    %...
    
    fprintf(' . Done. '); toc
end