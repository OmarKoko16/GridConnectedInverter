How to Run Code When Simulink Stops

To execute your code automatically whenever the simulation finishes (or is stopped manually), you must use the Model Callbacks.

Method 1: Automatic Setup (Recommended)

Open the file configure_simulink_stop.m generated in the editor.

Change line 5 (modelName = '...') to match your actual Simulink model name.

Run the script.

This will program the StopFcn (Stop Function) of your model automatically.

Method 2: Manual Setup via GUI

If you prefer to do this manually in the Simulink window:

Open your Simulink Model.

Go to the Modeling tab in the top toolstrip.

Click Model Settings (the gear icon) dropdown arrow, or right-click anywhere on the white canvas area.

Select Model Properties.

Click the Callbacks tab.

Select StopFcn from the list on the left.

Paste the following code into the editing pane on the right:

Root = pwd;
PathTestResult = fullfile(Root, 'TestCases', 'TestResults');

% Ensure 'Hil' exists (fail-safe)
if ~exist('Hil', 'var')
    warning('Variable "Hil" not found. Using empty struct.');
    Hil = struct();
end

% Check if 'out' exists (Standard Simulink Output)
if exist('out', 'var')
    saveTestResults(out, 'Speedgoat', 'Meas', PathTestResult, 1, Hil);
else
    disp('Simulation output "out" not found in workspace.');
end


Important Notes on Variables

1. The out Variable

Simulink usually saves simulation results to a variable named out (SimulationOutput object) in the Base Workspace when the simulation ends.

Ensure your model is configured to save single simulation output.

(Model Settings -> Data Import/Export -> Check "Single simulation output").

2. The Hil Variable

Your code passes a variable named Hil as the last argument (ModelParam).

Since the StopFcn runs in the Base Workspace, the variable Hil must exist there before the simulation stops.

You typically define this in your "InitFcn" or "PreLoadFcn" callback, or run a setup script before starting the model.

3. Path Handling

In your original code, you used [Root 'TestCases\TestResults'].

I have updated this to fullfile(Root, 'TestCases', 'TestResults').

fullfile is safer because it automatically adds the correct slashes (\ for Windows, / for Linux) preventing path errors.