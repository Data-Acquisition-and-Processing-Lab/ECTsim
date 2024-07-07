%creates tomograph body
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
