%% calculateElectricField_qt
% Calculates electric field vectros in the points of
% nonuniform mesh stored in qt structure;
%
% *usage:*     |[model] = calculateElectricField_qt(model)|
%  
% _model_     - structure with a numerical model description
%
% Electric field components [Ex,Ey] stored in 2 matrices qt.Ex and qt.Ey 
% number of rows equals a number of leafs, 
% number of columns equals a number of excitations;
%
% footer$$

function [model] = calculateElectricField(model,varargin)
    dimension = length(fieldnames(model.Workspace));
    % potential in nonuniform grid

    if numel(varargin)
        mode = varargin{1};
        if numel(varargin) > 1
            tol = varargin{2};
        else
            tol = 1e-3;
        end
    else
        mode = 'mldivide';
        tol = 1e-3;
    end
    model = calculatePotential(model,mode,tol);
    
    % calculate field in quadtree mesh
    fprintf('Calculating electric field ...... '); tic;
    
    % [qt.Ex,qt.Ey] for each element of the mesh
    % TODO: verification
    qt = model.qt;
    % size of the smallest element in [m] 
    pixelSizeHorizontal=model.Mesh.pixelSizeHorizontal*1e-3;  % [m];
    pixelSizeVertical=model.Mesh.pixelSizeVertical*1e-3;  % [m];

    [~, Electrodes] = size(qt.V);
    % electric field components   Ev = [dVx/dx, dVy/dy]m
    % calculated from Green-Gauss thoeorem; distance weighted mean on the face (edge) of
    % an element; integral of voltage on the edges
    % for all electrodes at once
    qt.Ex = zeros(qt.length, Electrodes);
    qt.Ey = zeros(qt.length, Electrodes);
    qt.Em = zeros(qt.length, Electrodes); 
    
    if dimension == 2
        for e = 1:qt.length
            if ~qt.isBoundary(e) 
                if qt.edge(e) == -1
                    qt.Ex(e,:) = 0;    
                    qt.Ey(e,:) = 0;
                else
                    % voltage component calculated on the right face (ExE (Est)):  normal vector positive
                    ExE = zeros(1,Electrodes);

                    for a = 1:size(qt.nE{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e) + qt.vt(qt.nE{e}(a),:)./qt.elSize(qt.nE{e}(a))) ./ (1/qt.elSize(e) + 1/qt.elSize(qt.nE{e}(a)));
                        ExE = ExE + vf * min(qt.elSize(e),qt.elSize(qt.nE{e}(a))) * pixelSizeHorizontal;  % [Vm]
                    end
                    
                    % voltage component calculated on the left face (ExW (West)): normal vector negative
                    ExW = zeros(1,Electrodes);
                    
                    for b = 1:size(qt.nW{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e) + qt.vt(qt.nW{e}(b),:)./qt.elSize(qt.nW{e}(b))) ./ (1/qt.elSize(e) + 1/qt.elSize(qt.nW{e}(b)));
                        ExW = ExW - vf * min(qt.elSize(e),qt.elSize(qt.nW{e}(b))) * pixelSizeHorizontal;  % [Vm]
                    end
                    
                    qt.Ex(e,:) = -(ExE + ExW)/((qt.elSize(e)*pixelSizeHorizontal)^2); % [V/m]

                    % voltage component calculated on the top face (ExN (North)):  normal vector positive 
                    EyN = zeros(1,Electrodes);
                    
                    for a = 1:size(qt.nN{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e) + qt.vt(qt.nN{e}(a),:)./qt.elSize(qt.nN{e}(a))) ./ (1/qt.elSize(e) + 1/qt.elSize(qt.nN{e}(a)));
                        EyN = EyN + vf * min(qt.elSize(e),qt.elSize(qt.nN{e}(a))) * pixelSizeVertical;  % [V/m]
                    end
                    
                    % voltage component calculated on the bottom face (ExS (South)): normal vector negative
                    EyS = zeros(1,Electrodes);
                    
                    for b = 1:size(qt.nS{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e) + qt.vt(qt.nS{e}(b),:)./qt.elSize(qt.nS{e}(b))) ./ (1/qt.elSize(e) + 1/qt.elSize(qt.nS{e}(b)));
                        EyS = EyS - vf * min(qt.elSize(e),qt.elSize(qt.nS{e}(b))) * pixelSizeVertical;  % [V/m]
                    end
                    
                    qt.Ey(e,:) = -(EyN + EyS)/((qt.elSize(e)*pixelSizeVertical)^2);
                end
            else
                qt.Ex(e,:) = 0;    % na krawêdzi siatki nale¿y ustawiæ wartoœæ z s¹siedniego punktu
                qt.Ey(e,:) = 0;
            end
        end

        qt.Em(:,:) = (abs(qt.Ex(:,:))  +  abs(qt.Ey(:,:)));
    elseif dimension == 3
        pixelSizeDiagonal=model.Mesh.pixelSizeDiagonal*1e-3;  % [m];
        qt.Ez = zeros(qt.length, Electrodes);
        
        for e = 1:qt.length
            if ~qt.isBoundary(e)  % TOOD: pole liczymy wszêdzie: wyrzuciæ?
                if qt.edge(e) == -1
                    qt.Ex(e,:) = 0;    % na krawêdzi siatki nale¿y ustawiæ wartoœæ z s¹siedniego punktu
                    qt.Ey(e,:) = 0;
                    qt.Ez(e,:) = 0;
                else
                    % voltage component calculated on the right face (ExE (Est)):  normal vector positive
                    ExE = zeros(1,Electrodes);
                    
                    for a = 1:size(qt.nE{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nE{e}(a),:)./qt.elSize(qt.nE{e}(a))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nE{e}(a))^2);
                        ExE = ExE + vf * min(qt.elSize(e),qt.elSize(qt.nE{e}(a)))^2 * pixelSizeHorizontal^2;  % [Vm]
                    end
                    
                    % voltage component calculated on the left face (ExW (West)): normal vector negative
                    
                    ExW = zeros(1,Electrodes);
                    
                    for b = 1:size(qt.nW{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nW{e}(b),:)./qt.elSize(qt.nW{e}(b))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nW{e}(b))^2);
                        ExW = ExW - vf * min(qt.elSize(e),qt.elSize(qt.nW{e}(b)))^2 * pixelSizeHorizontal^2;  % [Vm]
                    end
                    
                    qt.Ex(e,:) = (ExE + ExW)/((qt.elSize(e)*pixelSizeHorizontal)^3); % [V/m]

                    % voltage component calculated on the top face (ExN (North)):  normal vector positive 
                    EyN = zeros(1,Electrodes);
                    
                    for a = 1:size(qt.nN{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nN{e}(a),:)./qt.elSize(qt.nN{e}(a))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nN{e}(a))^2);
                        EyN = EyN + vf * min(qt.elSize(e),qt.elSize(qt.nN{e}(a)))^2 * pixelSizeVertical^2;  % [V/m]
                    end
                    
                    % voltage component calculated on the bottom face (ExS (South)): normal vector negative
                    EyS = zeros(1,Electrodes);
                    
                    for b = 1:size(qt.nS{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nS{e}(b),:)./qt.elSize(qt.nS{e}(b))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nS{e}(b))^2);
                        EyS = EyS - vf * min(qt.elSize(e),qt.elSize(qt.nS{e}(b)))^2 * pixelSizeVertical^2;  % [V/m]
                    end
                    
                    qt.Ey(e,:) = (EyN + EyS)/((qt.elSize(e)*pixelSizeVertical)^3);

                    % voltage component calculated on the top face (ExB (below)):  normal vector positive 
                    EyB = zeros(1,Electrodes);
                    
                    for a = 1:size(qt.nB{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nB{e}(a),:)./qt.elSize(qt.nB{e}(a))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nB{e}(a))^2);
                        EyB = EyB + vf * min(qt.elSize(e),qt.elSize(qt.nB{e}(a)))^2 * pixelSizeDiagonal^2;  % [V/m]
                    end
                    
                    % voltage component calculated on the bottom face (ExA (above)): normal vector negative
                    EyA = zeros(1,Electrodes);
                    
                    for b = 1:size(qt.nA{e},2)
                        vf = (qt.vt(e,:)./qt.elSize(e)^2 + qt.vt(qt.nA{e}(b),:)./qt.elSize(qt.nA{e}(b))^2) ./ (1/qt.elSize(e)^2 + 1/qt.elSize(qt.nA{e}(b))^2);
                        EyA = EyA - vf * min(qt.elSize(e),qt.elSize(qt.nA{e}(b)))^2 * pixelSizeDiagonal^2;  % [V/m]
                    end
                    
                    % voltage component calculated on the bottom face (ExS (South)): normal vector negative
                    qt.Ez(e,:) = (EyB + EyA)/((qt.elSize(e)*pixelSizeDiagonal)^3);
                end
            else
                qt.Ex(e,:) = 0;    % na krawêdzi siatki nale¿y ustawiæ wartoœæ z s¹siedniego punktu
                qt.Ey(e,:) = 0;
                qt.Ez(e,:) = 0;
            end
        end %for

        % electric field module
        qt.Em(:,:) = sqrt(qt.Ex(:,:).^2 + qt.Ey(:,:).^2 + qt.Ez(:,:).^2);
    else
        fprintf('model.Workspace should have 2 or 3 fields corresponding to 2D or 3D space');
        return
    end
    
    
    model.qt = qt; 
    fprintf(' . Done. '); toc 
end