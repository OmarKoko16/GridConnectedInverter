ModReq          = boolean(0);
FrcPwr          = boolean(false);
Test            = boolean(false);
PorISel         = boolean(0);
IdSp            = single(0);
IqSp            = single(0);
PSp             = single(0);
QSp             = single(0);
EnableMonitors = boolean( false);

ExcuteStep('Last Step',StpTimeCalc(end)+1,ModelName)
set_param(ModelName, 'SimulationCommand', 'stop');
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
    PlotTestResultsExtVsSpeedGoat(logsout,[],StpTimeAxes,TstName,1,StpLegnd,PathTestResult)

else
    % PlotTestResults;
    PlotTestResultsExtVsSpeedGoat(out.logsout,out.logsout,StpTimeAxes,TstName,0,StpLegnd,PathTestResult)
end