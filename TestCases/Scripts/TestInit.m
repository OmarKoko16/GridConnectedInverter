%%
if Extrn == 1
    set_param(Sim.ModelName, 'SimulationCommand', 'connect');
    pause(20)
    InitTime        = get_param(Sim.ModelName, 'SimulationTime');   
else
    InitTime        = 0;
end

StpTimeCalc     = cumsum(StpTime) + InitTime;
StpTimeAxes     = [ InitTime PlotAx];

Step = 0;

disp('--------------------------------------------------');
disp(['Test Start - ' TstName] );
disp('----------------------------');
%% Set initial value
setParam('ModReq',          uint16(0), 'uint16', '1', 'State Space Mode Request')
setParam('FrcPwr',          uint16(false), 'uint16', '1', 'Force Power Mode')
setParam('Test',            uint16(false), 'uint16', '1', 'Enable Test Mode')
setParam('EnableMonitors',  uint16(false), 'uint16', '1', 'Enable Monitoring')
setParam('PorISel',         uint16(1), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')

setParam('IdSp',            0, 'single', 'A', 'Id Setpoint')
setParam('IqSp',            0, 'single', 'A', 'Iq Setpoint')
setParam('PSp',             0, 'single', 'W', 'Power Setpoint')
setParam('QSp',             0, 'single', 'W', 'Reactive Power Setpoint')

set_param(Sim.ModelName, 'SimulationCommand', 'update');
if Extrn == 1
    set_param(Sim.ModelName, 'SimulationMode', 'external');
else
    set_param(Sim.ModelName, 'SimulationMode', 'accelerator');
    set_param(Sim.ModelName, 'SimulationCommand', 'start');
end

ExcuteStep('Init',InitTime,Sim.ModelName)