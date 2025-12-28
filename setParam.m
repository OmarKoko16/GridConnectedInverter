function setParam(name, value, dataType, unit, desc)
% SETPARAM Creates a Simulink.Parameter in the Base Workspace
% Usage: setParam('VarName', Value, 'DataType', 'Unit', 'Description')

    % Create the parameter object
    p = Simulink.Parameter;
    
    % Assign properties
    p.Value = value;
    p.DataType = dataType; % Examples: 'single', 'uint16', 'boolean'
    p.Unit = unit;         % Examples: 'A', 'rpm', 'V'
    p.Description = desc;
    
    % OPTIONAL: Set Storage Class for C2000 Tuning (ExportedGlobal is common)
    % This ensures the variable appears in the .map file and is tunable via XCP
    p.CoderInfo.StorageClass = 'ExportedGlobal'; 
    
    % Push the object to the Base Workspace
    assignin('base', name, p);
    
    % Print confirmation
    % fprintf('Created Parameter: %s = %g [%s]\n', name, value, unit);
end