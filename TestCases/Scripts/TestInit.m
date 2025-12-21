%%
if Extrn == 1
    set_param(ModelName, 'SimulationCommand', 'connect');
    pause(20)
    InitTime        = get_param(ModelName, 'SimulationTime');   
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

ModReq          = boolean(0);
FrcPwr          = boolean(false);
Test            = boolean(false);
IdSp            = single(0);
IqSp            = single(0);
PSp             = single(0);
QSp             = single(0);
EnableMonitors = boolean( false);
PorISel         = boolean(1);

set_param(ModelName, 'SimulationCommand', 'update');
if Extrn == 1
    set_param(ModelName, 'SimulationMode', 'external');
else
    set_param(ModelName, 'SimulationMode', 'accelerator');
    set_param(ModelName, 'SimulationCommand', 'start');
end

ExcuteStep('Init',InitTime,ModelName)