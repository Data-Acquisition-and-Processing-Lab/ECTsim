% This example shows how to solve forward and inverse problem for
% a 16-electrode sensor filled with materials having different values of
% permittivity and conductivity

clear all;
close all;

addpath fwdp/ % Folder containing files required for model preparation and forward problem computation
addpath invp/ % Folder containing files required for image reconstuction
addpath visualization/ % Folder containing files required for visualization of the results

%% Defining parameters of the model

model=defineWorkspace(108,108); %Size of workspace in mm Order of specifying values: (x-axis, y-axis)
model=defineMesh(model,512,512); % The number of pixels can vary across different axes but must each be a power of two

%% Creating objects that will be used in the simulation

model=newSimpleElement(model,'rectangle','all',[0,0],0,[108,108]); % Whole workspace
model=newSimpleElement(model,'ellipse','sensor',[0,0],0,[54,54]); % Sensor with outer radius mm
model=newComplexElement(model,'outside','all-sensor'); % Area outside of the sensor

model=newSimpleElement(model,'ellipse','inner',[0,0],0,[50,50]); % Inner border of the sensor wall with radius 52 mm
model=newComplexElement(model,'sensorWall','sensor - inner'); % The wall of the sensor

model=newSimpleElement(model,'ellipse','fov0',[0,0],0,[47,47]); % Field of view, where image will be reconstructed
% Inner border of the insulation in which electrodes are mounted with radius 48 mm
model=newComplexElement(model,'insulation0','inner - fov0'); % The insulation

model=newSimpleElement(model,'ellipse','fovcenter',[0,0],0,[44,44]);
model=newSimpleElement(model,'ellipse','denseMeshArea',[0,0],0,[50,50],[0,360],6); % Area where mesh will be denser

 % Test objects: 
model=newSimpleElement(model,'ellipse','object1',[0,24],0,[13.44/2,13.44/2]);
model=newSimpleElement(model,'ellipse','object3',[0,-24],0,[13.44/2,13.44/2]);
model=newSimpleElement(model,'ellipse','object2',[24,0],0,[13.44/2,13.44/2]); 
model=newComplexElement(model,'fov','fov0-object1-object2-object3'); % FOV beside objects

model=specifyFOV(model,'fov0');

%% Creating a list of the elements representing the electrodes (parts of rings)

numElectrodes = 16; % Number of electrodes in the sensor
widthEle = 16; % Degrees
model.Electrodes.height = 50; % Height of electrodes [mm]
radEle = 47.8; % Outer radius of electrode ring [mm]
tEle = 0.8; % Thicknes of electrode [mm]

str = 'insulation0';
for i = 1:numElectrodes
    model=newSimpleElement(model,'ellipse', ['electrode' num2str(i)], [0, 0], -(i-1)*360/numElectrodes, [radEle,radEle],[0,widthEle],tEle);
    str=[str '-electrode' int2str(i)];
end
model=newComplexElement(model,'insulation',str);

%% Permittivity and conductivity values of materials

metal_eps = 1; % Relative permittivity of the material     
metal_sigma=1e7; % Absolut conductivity of the material
air_eps = 1;
air_sigma = 1e-15;
pmma_eps = 4.9;       
pmma_sigma = 1e-16;
pvc_eps = 4;
pvc_sigma = 1e-6;
water_eps = 80;
water_sigma =1e-3; 

model.f = 1e5; % Frequency of the excitation signal used in the measurement
model.voltage_range = 10; % Amplitude of excitation signal [V]
model.measurements_all = 1;
% 1-> numElectrodes*(numElectrodes-1)
% 0-> numElectrodes*(numElectrodes-1)/2

%% Adding objects to the model
% numerical model construction; adding elements to the model (except the FOV); 
% the boundary conditions (voltage) are set on selected elements; 

model=addElement(model,'outside',metal_eps,metal_sigma,0);
model=addElement(model,'sensorWall',pvc_eps,pvc_sigma);
model=addElement(model,'insulation',pvc_eps,pvc_sigma);

for i = 1:numElectrodes
    model=addElement(model, ['electrode' num2str(i)], metal_eps, metal_sigma, 0, 10);
end  
model=setElectrodes(model);

%% Preparing three models: for an empty sensor (min), a full sensor (max), and a sensor with a test object (obj)

modelMin=model;
% modelMin=addElement(modelMin,'fov0',pmma_eps,pmma_sigma);
modelMin=addElement(modelMin,'fov0',air_eps,air_sigma);

modelMax=model;
% modelMax=addElement(modelMax,'fov0',water_eps,water_sigma);
modelMax=addElement(modelMax,'fov0',pvc_eps,pvc_sigma);

modelObj=model;
modelObj=addElement(modelObj, 'object1', pvc_eps ,pvc_sigma);
modelObj=addElement(modelObj, 'object2', pvc_eps, pvc_sigma);
modelObj=addElement(modelObj, 'object3', pvc_eps, pvc_sigma);
% modelObj=addElement(modelObj,'fov',water_eps,water_sigma);
modelObj=addElement(modelObj,'fov',air_eps,air_sigma);

%% Obtaining maps of electrical parameter distributions in each model
% model.eps_map & model.sigma_map - maps of permittivity & conductivity distrubutions
% model.boundary - vector of boundary conditions
% model.patternImage - map of all elements added to the model

modelMin = prepareMaps(modelMin);
modelMax = prepareMaps(modelMax);
modelObj = prepareMaps(modelObj);

drawMap(modelObj,'pattern','mm'); % [px] or [mm] for 2D

ixFwdp = findIndex(model, 'fovcenter'); % Determine the indices of the area of interest inside the sensor
drawMap(modelObj,'permittivity', 'px', ixFwdp); % fov image without sensor and electrodes

%% Setting up the discretization grid

modelMin = fineMesh(modelMin,'denseMeshArea',1);
modelMin = meshing(modelMin, 1, 4);
modelMax = fineMesh(modelMax,'denseMeshArea',1);
modelMax = meshing(modelMax, 1, 4);
modelObj = fineMesh(modelObj,'denseMeshArea',1);
modelObj = meshing(modelObj, 1, 4);

%% Calculating potential and electric field distributions in each model

modelMin = calculateElectricField(modelMin);
modelMax = calculateElectricField(modelMax);
modelObj = calculateElectricField(modelObj);

drawMap(modelObj, 'V', 'mm', 'real', 16);
drawMap(modelObj, 'Em', 'mm', 'real', 8); % or Ex, Ey

%% Calculating sensitivity matrices for each model

modelMin = calculateSensitivityMaps(modelMin);
modelMax = calculateSensitivityMaps(modelMax);
modelObj = calculateSensitivityMaps(modelObj);

drawMap(modelObj, 'S', 'px', 'real', [8 16]);

%% Simulating measured capacitances and conductances
% model.G - conductance; model.C - capacitance; model.Y complex admitance

modelMin = calculateMeasurement(modelMin);
modelMin = addNoise(modelMin,40); % value if SNR in dB
modelMax = calculateMeasurement(modelMax);
modelMax = addNoise(modelMax,40); % value if SNR in dB
modelObj = calculateMeasurement(modelObj);
modelObj = addNoise(modelObj,40); % value if SNR in dB

plotMeasurement('log', 'C', 1:31, {modelMin, modelMax, modelObj}, {'min','max','obj'});
% plotMeasurement('log', 'G', 1:31, {modelMin, modelMax, modelObj}, {'min','max','obj'});

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inverse problem - image reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Defining the inverse problem model and downscaling

modelInvp = defineMeshInvp(modelMin, 64, 64); % size of image matrix at reconstruction

modelInvp.min = downscaleModel(modelInvp, modelMin);
modelInvp.max = downscaleModel(modelInvp, modelMax);
modelInvp.obj = downscaleModel(modelInvp, modelObj);

modelInvp=withoutRepetition(modelInvp, {'min','max','obj'});
% mutual capacitance between electrodes 1-2 is the same as 2-1
% dont use two equations; they are a linear combination; take average:

%% Display permittivity and conductivity distribution in FOV (invp mesh)

ixInvp = findIndexInvp(modelInvp, 'fovcenter'); % finds indices of fovcenter in invp matrix
drawInvpMap(modelInvp, 'obj', 'permittivity', 'mm', ixInvp); % reconstructed image without electrodes
drawInvpMap(modelInvp, 'obj', 'conductivity', 'mm', ixInvp); %

%% Image reconstruction using Linear back-projection (LBP)

modelInvp.LBP = LBP(modelInvp);
drawInvpMap(modelInvp, 'LBP', 'permittivity', 'mm', ixInvp); % reconstructed image without electrodes
drawInvpMap(modelInvp, 'LBP', 'conductivity', 'mm', ixInvp); %

%% Image reconstruction using Moore–Penrose pseudoinverse (PINV)

modelInvp.PINV = PINV(modelInvp,1e-1); % invp, tolerance
drawInvpMap(modelInvp, 'PINV', 'permittivity', 'mm', ixInvp); % 
drawInvpMap(modelInvp, 'PINV', 'conductivity', 'mm', ixInvp); %

%% Image reconstruction using Landweber method

modelInvp.Landweber = Landweber(modelInvp, 1000, 1e+4); % invp, no. of iterations, alpha
drawInvpMap(modelInvp, 'Landweber', 'permittivity', 'mm', ixInvp); 

%% Image reconstruction using semilinear Levenberg Marquardt method

modelInvp.LM = semiLM(modelInvp, 1000, 1e+1, 1e-2, 1); % invp, no. of iterations, alpha, lambda, no. of S updates
drawInvpMap(modelInvp, 'LM', 'permittivity', 'mm', ixInvp); 

%% Comparison of achieved norms in successive iterations in the Landweber algorithm and the semi-linear Levenberg-Marquardt algorithm

plotNorm('residue', modelInvp, {'Landweber','LM'});
plotNorm('error', modelInvp, {'Landweber','LM'})

