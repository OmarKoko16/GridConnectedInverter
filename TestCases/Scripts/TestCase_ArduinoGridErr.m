TstName         = 'ArduinoGridErr';
StpNames        = [1    2.1     2.2     3.1];
if Extrn == 1
    set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'connect');
    pause(15)
    InitTime        = get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime');   
    % pause(15)
    StpTime         = [5    5       14      1];  
else
    StpTime         = [1    1       14      1];
    InitTime        = 1;
end
StpTimeCalc     = cumsum(StpTime) + InitTime;
Step = 0;
disp('Test Start');
%% Set initial value
Hil.HVDC_V      = 400;
Var.Transformer_N = single(1);
ModReq          = boolean(0);
FrcPwr          = boolean(false);
Test            = boolean(false);
EnableMonitors  = boolean(false);
PorISel         = boolean(0);
IdSp            = single(0);
IqSp            = single(0);
PSp             = single(0);
QSp             = single(0);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');
if Extrn == 1
    set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationMode', 'external');
else
    set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationMode', 'accelerator');
    set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'start');
end


ExcuteStep('Init',InitTime)
%% Step 1
Test =  boolean(false);

Step = Step +1;
ExcuteStep(StpNames(Step ),StpTimeCalc(Step ))
%% Step 2.1
PSp             = single(0);

Step = Step +1;
ExcuteStep(StpNames(Step ),StpTimeCalc(Step ))
%% Step 2.2
Test =  boolean(true);
FrcPwr = boolean(true);

Step = Step +1;
ExcuteStep(StpNames(Step ),StpTimeCalc(Step ))
%% Step 3.1
Test =  boolean(false);
FrcPwr = boolean(false);
PSp             = single(0);

Step = Step +1;
ExcuteStep(StpNames(Step ),StpTimeCalc(Step ))
%% Step Last
ModReq = boolean(0);


Step = Step +1;
ExcuteStep('Last Step',StpTimeCalc(end)+1)
set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'stop');
%%
% Get all SDI run IDs
runIDs = Simulink.sdi.getAllRunIDs;
runID = runIDs(end);
run = Simulink.sdi.getRun(runID);
run.Name = [TstName ' - ' datestr(now, 'yyyy-mm-dd HH:MM:SS')];
% StpTimeCalc = 1:StpTimeCalc(end);
StpTimeCalc = [StpTimeCalc(1),StpTimeCalc(1)+1:1:StpTimeCalc(2)+12,StpTimeCalc(end)];
if Extrn == 1
    pause(2)
    PlotTestResultsExt;
else
    PlotTestResults;
end