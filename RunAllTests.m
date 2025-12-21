clear;clc;close all

Root = 'C:\Users\The Professionals\MATLAB\Projects\GridInverter\';
ModelName = 'GCI_Ctrl_PLL_C2000';

run([ Root '\Parameters.mlx'])
run([ Root '\HilParameters.mlx'])
run([ Root '\CntrlPanel.mlx'])
load_system([ Root ModelName '.slx'])

set_param(ModelName, 'SimulationCommand', 'stop');

Extrn           = 0;

if Extrn == 1
    set_param(ModelName, 'SimulationMode', 'external');
    set_param(ModelName, 'SimulationCommand', 'start');
else
    set_param(ModelName, 'SimulationMode', 'accelerator');
end

set_param(ModelName, 'StopTime', 'inf');

% run([ Root 'TestCases\Scripts\' 'TestCase_ArduinoGridErr.m'])
run([ Root 'TestCases\Scripts\' 'TestCase_IdIqSpMax.m'])
run([ Root 'TestCases\Scripts\' 'TestCase_IdIqSpMaxGridErr.m'])
run([ Root 'TestCases\Scripts\' 'TestCase_PQSpMax.m'])
run([ Root 'TestCases\Scripts\' 'TestCase_PQSpMaxGridErr.m'])
run([ Root 'TestCases\Scripts\' 'TestCase_OCP.m'])
