function [pdfPath, matPath] = saveTestResults(data, dataName, TstName, baseFolder, isHil, ModelParam)
% SAVETESTRESULTS Saves test data to a timestamped folder structure
%
% Usage:
%   saveTestResults(out, 'Speedgoat', 'Meas', 'C:\Data', true, HilStruct);

    % Get today's date in YYYYMMDD format
    todayDate = datestr(now, 'yyyymmdd');
    timestamp = datestr(now, 'yyyy_mm_dd_HH_MM_SS');

    % 1. Determine Main Folder Name based on HIL/SIM status
    if isHil
        typePrefix = 'HIL';
    else
        typePrefix = 'SIM';
    end
    
    % Construct first level folder: e.g., "Folder\HIL_20231027"
    % Using fullfile for cross-platform compatibility (Windows/Linux paths)
    folderName = fullfile(baseFolder, [typePrefix, '_', todayDate]);

    % Create the folder if it doesn't exist
    if ~exist(folderName, 'dir')
        mkdir(folderName);
        fprintf('Folder created: %s\n', folderName);
    end

    % 2. Construct Second Level Folder: e.g., "Folder\HIL_20231027\TestName"
    folderName2 = fullfile(folderName, TstName);

    % Create the sub-folder if it doesn't exist
    if ~exist(folderName2, 'dir')
        mkdir(folderName2);
        fprintf('Sub-folder created: %s\n', folderName2);
    end

    % 3. Construct File Names
    baseFileName = sprintf('%s_%s_%s', typePrefix, TstName, timestamp);
    
    matPath = fullfile(folderName2, [baseFileName, '.mat']);

    % 4. Save Data
    % We use a temporary struct 'S' to ensure the variable in the .mat file 
    % has the specific name requested (e.g., 'C2000') rather than just 'data'.
    S.(dataName) = data;
    S.ModelParam = ModelParam;
    
    try
        save(matPath, '-struct', 'S');
        fprintf('--------------------------------------------------\n');
        fprintf('Data saved successfully to:\n  %s\n', matPath);
        fprintf('--------------------------------------------------\n');
    catch ME
        warning('Failed to save .mat file: %s', ME.message);
    end
end