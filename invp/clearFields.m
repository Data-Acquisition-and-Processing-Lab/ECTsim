function model = clearFields(model, nestedFieldsToRemove)
    % clearFields: Function to remove specified fields from structures to reduce their memory usage.
    % models: cell array containing model names as strings (e.g., {'model1', 'model2'})
    % nestedFieldsToRemove: cell array containing nested field names to be removed (e.g., {'qt.vt', 'dd'})
    
    for j = 1:length(nestedFieldsToRemove)
        fieldPath = nestedFieldsToRemove{j};
        % Split the fieldPath by '.' to handle nested fields
        fieldParts = strsplit(fieldPath, '.');
        
        % Check if the nested field exists
        if isNestedField(model, fieldParts)
            % Remove the nested field
            model = removeNestedField(model, fieldParts);
        end
    end
end

function exists = isNestedField(structure, fieldParts)
    % Check if the nested field exists
    exists = true;
    for i = 1:length(fieldParts)
        if isfield(structure, fieldParts{i})
            structure = structure.(fieldParts{i});
        else
            exists = false;
            break;
        end
    end
end

function structure = removeNestedField(structure, fieldParts)
    % Remove the nested field
    if isscalar(fieldParts)
        structure = rmfield(structure, fieldParts{1});
    else
        field = fieldParts{1};
        remainingParts = fieldParts(2:end);
        structure.(field) = removeNestedField(structure.(field), remainingParts);
    end
end