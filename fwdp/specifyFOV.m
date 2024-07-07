function [model] = specifyFOV(model,name)

    model.FOV_name = name;
    model.FOV_full = findIndex(model, name); % Determine the indices of the area of interest inside the sensor

end