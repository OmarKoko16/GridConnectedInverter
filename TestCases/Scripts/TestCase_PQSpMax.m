TstName         = 'PQSpMax';
StpNames        = ["1. Power Mode"    ...
                   "2. Power = Setpoint"   ...
                   "3. Power = 0"   ...
                   "4. Reactive Power  = Setpoint"   ...
                   "5. Reactive Power  = 0"];
StpLegnd        = [StpNames "End" ];
PwrStp          = 5000;

if Extrn == 1
    StpTime         = [1    1       1       1       1]*10;
    PlotAx = cumsum(StpTime);
else
    StpTime         = [1    1       1       1       1];
    PlotAx = cumsum(StpTime);
end
%% Initialize
TestInit
%% Steps
for i = 1:length(StpTimeCalc)

    switch i
        case 1
            setParam('ModReq',          uint16(1), 'uint16', '1', 'State Space Mode Request')
            setParam('PorISel',         uint16(0), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')
            setParam('EnableMonitors',  uint16(1), 'uint16', '1', 'Enable Monitoring')                      
        case 2
            setParam('PSp',             PwrStp, 'single', 'W', 'Power Setpoint')
        case 3
            setParam('PSp',             0, 'single', 'W', 'Power Setpoint')
        case 4
            setParam('QSp',             PwrStp, 'single', 'W', 'Reactive Power Setpoint')
        case 5
            setParam('QSp',             0, 'single', 'W', 'Reactive Power Setpoint')
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),Sim.ModelName)
end
%% Step Last
TestEnd