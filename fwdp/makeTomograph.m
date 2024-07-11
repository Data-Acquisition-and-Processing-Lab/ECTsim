%% makeTomograph - Optionally prepares the entire body of a cylindrical sensor quickly.
%
% This function prepares the entire body of a cylindrical sensor for tomographic
% applications. It constructs the sensor with specified dimensions and properties.
%
% Usage:
%   model = makeTomograph(model, radius, height, wallWidth, insulationWidth, numElectrodes, ringPositions, ringRadius, electrodeHeight, electrodeWidthDeg, electrodeThickness, const)
%
% Inputs:
%   model             - Structure with numerical model definition (post-defineWorkspace and defineMesh).
%   radius            - Inner radius of the cylindrical sensor.
%   height            - Height of the cylindrical sensor.
%   wallWidth         - Thickness of the cylinder wall.
%   insulationWidth   - Thickness of inner insulation.
%   numElectrodes     - Number of electrodes.
%   ringPositions     - Z-position of the center of electrode rings.
%   ringRadius        - Radius of electrode rings.
%   electrodeHeight   - Height of the electrodes.
%   electrodeWidthDeg - Angular width of a single electrode in degrees.
%   electrodeThickness- Thickness of electrodes.
%   const             - Structure containing lists of electrical permittivities and conductivities
%                       of the materials used in the sensor construction.
%
% Outputs:
%   model - Updated model structure with the constructed cylindrical sensor.
%
% Example:
%   % Assume model is already initialized and other parameters are defined
%   const.metal_eps = 1;
%   const.metal_sigma = 1e7;
%   const.pvc_eps = 2.8;
%   const.pvc_sigma = 1e-15;
%   model = makeTomograph(model, 50, 100, 5, 2, 16, [10, 30, 50], 45, 10, 20, 1, const);
%   % This will prepare a cylindrical sensor with the specified dimensions and properties.
%
% See also: defineWorkspace, defineMesh
%
% ------------------------------------------------------------------------
% This is part of the ECTsim toolbox.
% Questions? Contact us at damian.wanta@pw.edu.pl
% Visit our homepage: https://ectsim.ire.pw.edu.pl/
% ------------------------------------------------------------------------

function model = makeTomograph(model, radius, height, wallWidth, insulationWidth, numElectrodes, ringPositions, ringRadius, electrodeHeight, electrodeWidthDeg, electrodeThickness, const)
    %% create main cylinder body
    model=newSimpleElement(model,'cylinder','sensor',[0,0,0],[0,0,0],[radius,radius,height]); % Sensor with outer radius mm
    model=newComplexElement(model,'outside','all-sensor'); % Area outside of the sensor
    
    model=newSimpleElement(model,'cylinder','inner',[0,0,0],[0,0,0],[radius-wallWidth,radius-wallWidth,height]); % Inner border of the sensor wall with radius 52 mm
    model=newComplexElement(model,'sensorWall','sensor - inner'); % The wall of the sensor
    
    model=newSimpleElement(model,'cylinder','inside',[0,0,0],[0,0,0],[radius-wallWidth-insulationWidth,radius-wallWidth-insulationWidth,height]); % Inner border of the insulation in which electrodes are mounted with radius 48 mm
    model=newComplexElement(model,'insulation0','inner - inside'); % The insulation
    
    model=newSimpleElement(model,'cylinder','fov0',[0,0,0],[0,0,0],[radius-wallWidth-insulationWidth,radius-wallWidth-insulationWidth,height]); % Field of view, where image will be reconstructed
    
    model=newSimpleElement(model,'cylinder','denseMeshArea',[0,0,0],[0,0,0],[radius-wallWidth,radius-wallWidth,height],[0,360],5); % Area where mesh will be denser


    %% Creating a list of the elements representing the electrodes (parts of rings)
    model.Electrodes.height = electrodeHeight; % Height of electrodes [mm]
    str = 'insulation0';

    for ringNum = 1:length(ringPositions)
        ringPosition = ringPositions(ringNum);
        for i = 1+(numElectrodes/length(ringPositions)*(ringNum-1)):(numElectrodes/length(ringPositions)*(ringNum))
            model=newSimpleElement(model,'cylinder', ['electrode' num2str(i)], [0, 0, ringPosition], [0, 0, (i-1)*22.5], [ringRadius,ringRadius,model.Electrodes.height],[0,electrodeWidthDeg],electrodeThickness);
            str=[str '-electrode' int2str(i)];
        end
    end
    model=newComplexElement(model,'insulation',str);

    %% Adding objects to the model
    % numerical model construction; adding elements to the model (except the FOV); 
    % the boundary conditions (voltage) are set on selected elements; 

    model=addElement(model,'outside',const.metal_eps,const.metal_sigma,0);
    model=addElement(model,'sensorWall',const.pvc_eps,const.pvc_sigma);
    model=addElement(model,'insulation',const.pvc_eps,const.pvc_sigma);

    for i = 1:numElectrodes
        model=addElement(model, ['electrode' num2str(i)], const.metal_eps, const.metal_sigma, 0, 10);
    end  
    model=setElectrodes(model);
end
