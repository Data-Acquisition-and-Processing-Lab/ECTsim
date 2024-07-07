function  model = loseWeight(model,mode)
%%
%function is important if you use 3D or 4D models
%if mode 1 clears all heavy weight fields (good for modelMax and modelObj)
%if mode 0 fields that are important for reconstruction are saved (for modelMin)
%%
if (mode)
    model = rmfield(model,'qt');
    model = rmfield(model,'boundary_points');
    model = rmfield(model,'electrodes_points');
    model = rmfield(model,'sensor_points');
    model = rmfield(model,'Elements');
    model = rmfield(model,'Mesh');
    model = rmfield(model,'Sensor');
else
    model.qt = rmfield(model.qt,'A');
    model.qt = rmfield(model.qt,'Ex');
    model.qt = rmfield(model.qt,'Ey');
    model.qt = rmfield(model.qt,'Ez');
    model.qt = rmfield(model.qt,'vt');
    model.qt = rmfield(model.qt,'Em');
    model.qt = rmfield(model.qt,'V');
end
    model = rmfield(model,'patternImage');
    model = rmfield(model,'patternImage_sigma');
    model = rmfield(model,'calculate_points');