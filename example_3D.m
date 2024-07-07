% This example shows how to solve the forward problem and the inverse problem 
% in a three-dimensional numerical model. 
% A 3D sensor with 32 electrodes arranged in two rings of 16 electrodes each is used.

clear all;
close all;

addpath fwdp/ % Folder containing files required for model preparation and forward problem computation
addpath invp/ % Folder containing files required for image reconstuction
addpath visualization/ % Folder containing files required for visualization of the results

%% Defining parameters of the model

model=defineWorkspace(160,160,160); % Size of workspace in mm (x-axis, y-axis, z-axis)
model=defineMesh(model,256,256,256); % The number of pixels can vary across different axes but must each be a power of two

%% Creating objects that will be used in the simulation

model=newSimpleElement(model,'cuboid','all',[0,0,0],[0,0,0],[160,160,160]); % Whole workspace
model=newSimpleElement(model,'cylinder','sensor',[0,0,0],[0,0,0],[80,80,160]); % Sensor with outer radius mm
model=newComplexElement(model,'outside','all-sensor'); % Area outside of the sensor

model=newSimpleElement(model,'cylinder','inner',[0,0,0],[0,0,0],[78,78,160]); % Inner border of the sensor wall with radius 52 mm
model=newComplexElement(model,'sensorWall','sensor - inner'); % The wall of the sensor

model=newSimpleElement(model,'cylinder','inside',[0,0,0],[0,0,0],[76,76,160]); % Inner border of the insulation in which electrodes are mounted with radius 48 mm
model=newComplexElement(model,'insulation0','inner - inside'); % The insulation

model=newSimpleElement(model,'cylinder','fov0',[0,0,0],[0,0,0],[76,76,160]); % Field of view, where image will be reconstructed

model=newSimpleElement(model,'cylinder','fovcenter',[0,0,0],[0,0,0],[73,73,120]);
model=newSimpleElement(model,'cylinder','denseMeshArea',[0,0,0],[0,0,0],[78,78,160],[0,360],5); % Area where mesh will be denser

% Test objects: 
model=newSimpleElement(model,'ellipsoid','object1',[0,30,-30],[0,0,0],[20,20,20]);
model=newSimpleElement(model,'ellipsoid','object3',[0,-30,0],[0,0,0],[20,20,20]);
model=newSimpleElement(model,'ellipsoid','object2',[30,0,30],[0,0,0],[20,20,20]); 

model=newComplexElement(model,'fov','fov0-object1-object2-object3'); % FOV beside objects

model=specifyFOV(model,'fov0');

%% Creating a list of the elements representing the electrodes (parts of rings)

numElectrodes = 32; % Number of electrodes in the sensor
widthEle = 16; % Degrees
model.Electrodes.height = 50; % Height of electrodes [mm]
radEle = 77.5; % Outer radius of electrode ring [mm]
tEle = 1.6; % Thicknes of electrode [mm]

ringPosition = 35; % First ring of 16 electrodes
str = 'insulation0';
for i = 1:numElectrodes/2
    model=newSimpleElement(model,'cylinder', ['electrode' num2str(i)], [0, 0, ringPosition], [0, 0, (i-1)*22.5], [radEle,radEle,model.Electrodes.height],[0,widthEle],tEle);
    str=[str '-electrode' int2str(i)];
end

ringPosition = -35; % Second ring of 16 electrodes
for i = numElectrodes/2+1:numElectrodes
    model=newSimpleElement(model,'cylinder', ['electrode' num2str(i)], [0, 0, ringPosition], [0, 0, (i-1)*22.5], [radEle,radEle,model.Electrodes.height],[0,widthEle],tEle);
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

drawMap(modelObj,'pattern', 'mm', 'surf'); % [mpr] or [slice] or [surf] for 3D

ixFwdp = findIndex(model, 'fovcenter'); % Determine the indices of the area of interest inside the sensor
drawMap(modelObj,'permittivity', 'mm', ixFwdp); % fov image without sensor and electrodes

%% Setting up the discretization grid

modelMin = fineMesh(modelMin,'denseMeshArea',1);
modelMin = meshing(modelMin, 1, 4);
modelMax = fineMesh(modelMax,'denseMeshArea',1);
modelMax = meshing(modelMax, 1, 4);
modelObj = fineMesh(modelObj,'denseMeshArea',1);
modelObj = meshing(modelObj, 1, 4);

%% Calculating potential and electric field distributions in each model

modelMin = calculateElectricField(modelMin,'bicgstab',1e-4);
modelMax = calculateElectricField(modelMax,'bicgstab',1e-4);
modelObj = calculateElectricField(modelObj,'bicgstab',1e-4);

drawMap(modelObj, 'V', 'mpr', 'mm', 'real', 16);
drawMap(modelObj, 'Em', 'slice', 'mm','real', 8); % or Ex, Ey

%% Calculating sensitivity matrices for each model
% Simulating measured capacitances
% Defining the inverse problem model, downscaling and cleaning the model

modelInvp = defineMeshInvp(modelMin, 32, 32, 32); % size of image matrix at reconstruction

%% modelMin - an empty sensor

modelMin = calculateSensitivityMaps(modelMin);
modelMin = calculateMeasurement(modelMin);
modelMin = addNoise(modelMin,40); % value if SNR in dB
modelInvp.min = downscaleModel(modelInvp, modelMin);
modelMin = clearFields(modelMin, {'qt.Sens'}); 
% Removes specified field from model to reduce memory usage - this is important for 3D

%% modelMax - a full sensor

modelMax = calculateSensitivityMaps(modelMax);
modelMax = calculateMeasurement(modelMax);
modelMax = addNoise(modelMax,40); % value if SNR in dB
modelInvp.max = downscaleModel(modelInvp, modelMax);
modelMax = clearFields(modelMax, {'qt.Sens'}); 

%% modelObj - a sensor with a test object

modelObj = calculateSensitivityMaps(modelObj);
modelObj = calculateMeasurement(modelObj);
modelObj = addNoise(modelObj,40); % value if SNR in dB
modelInvp.obj = downscaleModel(modelInvp, modelObj);

drawMap(modelObj, 'S', 'mpr', 'real', [3 27]);
modelObj = clearFields(modelObj, {'qt.Sens'}); 

%% Displaying Simulated Values of Capacitance and Conductance

plotMeasurement('log', 'C', 1:31, {modelMin, modelMax, modelObj}, {'min','max','obj'});
plotMeasurement('log', 'G', 1:31, {modelMin, modelMax, modelObj}, {'min','max','obj'});

% mutual capacitance between electrodes 1-2 is the same as 2-1
% dont use two equations for reconstruction; they are a linear combination; take average:
modelInvp=withoutRepetition(modelInvp, {'min','max','obj'});

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Inverse problem - image reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Display permittivity and conductivity distribution in FOV (invp mesh)

ixInvp = findIndexInvp(modelInvp, 'fovcenter'); %finds indices of fovcenter in invp matrix
drawInvpMap(modelInvp, 'obj', 'permittivity', 'mm', 'surf', ixInvp); % reconstructed image without electrodes
drawInvpMap(modelInvp, 'obj', 'conductivity', 'mm', 'surf', ixInvp); 

%% Image reconstruction using Linear back-projection (LBP)

modelInvp.LBP = LBP(modelInvp);
drawInvpMap(modelInvp, 'LBP', 'permittivity', 'mm', 'mpr', ixInvp); % reconstructed image without electrodes
drawInvpMap(modelInvp, 'LBP', 'conductivity', 'mm', 'mpr', ixInvp); %

%% Image reconstruction using Moore–Penrose pseudoinverse (PINV)

modelInvp.PINV = PINV(modelInvp,5e-2); % invp, tolerance
drawInvpMap(modelInvp, 'PINV', 'permittivity', 'mm', 'slice', ixInvp); % reconstructed image without electrodes
drawInvpMap(modelInvp, 'PINV', 'conductivity', 'mm', 'slice', ixInvp); %

%% Image reconstruction using Landweber method

modelInvp.Landweber = Landweber(modelInvp, 1000, 5e+2); % invp, no. of iterations, alpha
drawInvpMap(modelInvp, 'Landweber', 'permittivity', 'mm', ixInvp); 

%% Image reconstruction using semilinear Levenberg Marquardt method

modelInvp.LM = semiLM(modelInvp, 1000, 1e+1, 1e-2, 1); % invp, no. of iterations, alpha, lambda, no. of S updates
drawInvpMap(modelInvp, 'LM', 'permittivity', 'mm', ixInvp); 

%% Comparison of achieved norms in successive iterations in the Landweber algorithm and the semi-linear Levenberg-Marquardt algorithm
plotNorm('residue', modelInvp, {'Landweber','LM'});
plotNorm('error', modelInvp, {'Landweber','LM'})
