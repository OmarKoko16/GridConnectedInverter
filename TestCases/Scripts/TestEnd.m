setParam('ModReq',          uint16(0), 'uint16', '1', 'State Space Mode Request')
setParam('FrcPwr',          uint16(false), 'uint16', '1', 'Force Power Mode')
setParam('Test',            uint16(false), 'uint16', '1', 'Enable Test Mode')
setParam('EnableMonitors',  uint16(false), 'uint16', '1', 'Enable Monitoring')
setParam('PorISel',         uint16(0), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')

setParam('IdSp',            0, 'single', 'A', 'Id Setpoint')
setParam('IqSp',            0, 'single', 'A', 'Iq Setpoint')
setParam('PSp',             0, 'single', 'W', 'Power Setpoint')
setParam('QSp',             0, 'single', 'W', 'Reactive Power Setpoint')

ExcuteStep('Last Step',StpTimeCalc(end)+1,Sim.ModelName)
set_param(Sim.ModelName, 'SimulationCommand', 'stop');
%%
runIDs = Simulink.sdi.getAllRunIDs;
runID = runIDs(end);
runData = Simulink.sdi.getRun(runID);
runData.Name = [TstName ' - ' datestr(now, 'yyyy-mm-dd HH:MM:SS')];
PathTestResult = [Root 'TestCases\TestResults'];
if Extrn == 1
    pause(5)
    StpTimeAxes =StpTimeAxes +1;
    % PlotTestResultsExt;
    % PlotTestResultsExtVsSpeedGoat(logsout,[],StpTimeAxes,TstName,1,StpLegnd,PathTestResult)
    PlotTestResultsExtVsSpeedGoat2(out.logsout,[],StpTimeAxes,TstName,1,StpLegnd,PathTestResult)


else
    % PlotTestResults;
    % PlotTestResultsExtVsSpeedGoat(out.logsout,out.logsout,StpTimeAxes,TstName,0,StpLegnd,PathTestResult)
    PlotTestResultsExtVsSpeedGoat2(out.logsout,out.logsout,StpTimeAxes,TstName,0,StpLegnd,PathTestResult)
end