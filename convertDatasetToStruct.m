function flatStruct = convertDatasetToStruct(ds)
% CONVERTDATASETTOSTRUCT Converts Simulink Dataset or Struct to flat struct
%
%   myStruct = convertDatasetToStruct(data)
%
%   Supported Inputs:
%   1. Simulink.SimulationData.Dataset (e.g. logsout)
%   2. Standard Struct containing timeseries (e.g. loaded .mat file)
%   3. Single timeseries object
%
%   Output Structure Format:
%   myStruct.SignalName.time  -> [N x 1] vector
%   myStruct.SignalName.data  -> [N x 1] vector
%   myStruct.SignalName.name  -> "SignalName" (String)

    flatStruct = struct();

    % --- CASE 1: Input is a Simulink Dataset (logsout) ---
    if isa(ds, 'Simulink.SimulationData.Dataset')
        numElements = ds.numElements;
        elementNames = ds.getElementNames;
        
        for i = 1:numElements
            % Extract the element.
            % Note: ds{i} returns the element, which might be a timeseries, 
            % a struct, or a wrapper object (Simulink.SimulationData.Signal).
            rawEl = ds{i};
            
            % Intelligent Unwrap: Check if the element is a wrapper object
            % (like Simulink.SimulationData.Signal) that holds the actual 
            % data in a 'Values' property.
            if isobject(rawEl) && isprop(rawEl, 'Values')
                val = rawEl.Values;
            else
                val = rawEl;
            end
            
            name = elementNames{i};
            
            % Generate a valid field name
            if isempty(name)
                name = sprintf('Element_%d', i);
            end
            cleanName = matlab.lang.makeValidName(name);
            
            flatStruct = processValue(flatStruct, val, cleanName);
        end

    % --- CASE 2: Input is a standard Struct (e.g. Meas1 directly) ---
    elseif isstruct(ds)
        fields = fieldnames(ds);
        for k = 1:length(fields)
            val = ds.(fields{k});
            
            % Use the struct field name as the signal name
            cleanName = matlab.lang.makeValidName(fields{k});
            
            flatStruct = processValue(flatStruct, val, cleanName);
        end

    % --- CASE 3: Input is a single TimeSeries or Array ---
    else
        flatStruct = processValue(flatStruct, ds, 'Signal');
    end
end

%% Helper Function: Recursive Processor
function s = processValue(s, val, currentName)
    
    if isa(val, 'timeseries')
        % --- PROCESSING TIMESERIES ---
        rawData = squeeze(val.Data);
        time = val.Time;
        
        [rows, cols] = size(rawData);
        lenTime = length(time);
        
        % Orientation correction: ensure Time matches rows
        % If Data is 1xN and Time is N, we transpose Data
        if rows ~= lenTime && cols == lenTime
            rawData = rawData';
            [rows, cols] = size(rawData);
        end
        
        % If multiple columns exist, split them (e.g. Iabc -> Iabc_1, Iabc_2, Iabc_3)
        if cols > 1
            for k = 1:cols
                subName = sprintf('%s_%d', currentName, k);
                
                s.(subName).time = time;
                s.(subName).data = rawData(:, k);
                s.(subName).name = subName; 
            end
        else
            % Single column data
            s.(currentName).time = time;
            s.(currentName).data = rawData;
            s.(currentName).name = currentName;
        end
        
    elseif isstruct(val)
        % --- PROCESSING NESTED STRUCTS (BUSES) ---
        fields = fieldnames(val);
        for k = 1:length(fields)
            subVal = val.(fields{k});
            % Flatten hierarchy: Parent_Child
            childName = matlab.lang.makeValidName([currentName, '_', fields{k}]);
            s = processValue(s, subVal, childName);
        end
        
    else
        % --- SKIP UNKNOWN TYPES ---
        % This handles cases like empty signals or generic datastores
        % warning('Skipping "%s": Type %s not supported.', currentName, class(val));
    end
end