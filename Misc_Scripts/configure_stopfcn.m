%% Configure Simulink StopFcn
% Run this script once to inject the code into your model's settings.

% ---------------- CONFIGURATION ----------------
modelName = 'SpeedGoat_GridModel'; % <--- REPLACE THIS with your specific model name (no .slx extension)
% -----------------------------------------------

% Check if model is open, if not, load it
if ~bdIsLoaded(modelName)
    try
        load_system(modelName);
        fprintf('Loaded model: %s\n', modelName);
    catch
        error('Could not find model: %s. Make sure it is on the path.', modelName);
    end
end

% Define the code you want to run
% We construct a ModelParam struct containing both Sim and Hil variables
stopCode = [...
    'Root = pwd; ', ...
    'PathTestResult = fullfile(Root, ''TestCases'', ''TestResults''); ', ...
    'ModelParam = struct(); ', ...
    'if exist(''Sim'', ''var''), ModelParam.Sim = Sim; end; ', ...
    'if exist(''Hil'', ''var''), ModelParam.Hil = Hil; end; ', ...
    'if exist(''out'', ''var''), ', ...
    '    saveTestResults(out, ''Speedgoat'', ''Meas'', PathTestResult, 1, ModelParam); ', ...
    'else, ', ...
    '    disp(''Warning: Simulation output "out" not found in workspace after stop.''); ', ...
    'end'];

% Set the StopFcn callback
set_param(modelName, 'StopFcn', stopCode);

fprintf('Success! The StopFcn for %s has been updated.\n', modelName);
fprintf('Current StopFcn:\n%s\n', get_param(modelName, 'StopFcn'));

% Save the model
save_system(modelName);