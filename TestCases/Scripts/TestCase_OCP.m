TstName         = 'OCP';
StpNames        = ["1. Power Mode"    ...
                   "2. Id = Setpoint"   ...
                   "3. Iq = Setpoint"];
StpLegnd        = [StpNames "End" ];
CurStp          = 50;

if Extrn == 1
    StpTime         = [1    1       1]*10; 
    PlotAx = cumsum(StpTime);
else
    StpTime         = [1    1       3];
    PlotAx = cumsum(StpTime);
end
%% Initialize
TestInit
%% Steps
for i = 1:length(StpTimeCalc)

    switch i
        case 1 
            setParam('ModReq',          uint16(1), 'uint16', '1', 'State Space Mode Request')
            setParam('PorISel',         uint16(1), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')
            setParam('EnableMonitors',  uint16(true), 'uint16', '1', 'Enable Monitoring')    
        case 2
            setParam('IdSp',            CurStp, 'single', 'A', 'Id Setpoint')

        case 3
            setParam('IqSp',            CurStp, 'single', 'A', 'Iq Setpoint')
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),Sim.ModelName)
end
%% Step Last
TestEnd
