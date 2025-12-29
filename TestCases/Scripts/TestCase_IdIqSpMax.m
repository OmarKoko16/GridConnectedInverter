TstName         = 'IdIqSpMax';
StpNames        = ["1. Power Mode"    ...
                   "2. Id = Setpoint"   ...
                   "3. Id = 0" ...
                   "4. Iq = Setpoint" ...
                   "5. Iq = 0"];
StpLegnd        = [StpNames "End" ];


CurStp          = 50;

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
            setParam('PorISel',         uint16(1), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')
        case 2
            setParam('IdSp',            CurStp, 'single', 'A', 'Id Setpoint')
        case 3
            setParam('IdSp',            0, 'single', 'A', 'Id Setpoint')
        case 4
            setParam('IqSp',            CurStp, 'single', 'A', 'Iq Setpoint')
        case 5
            setParam('IqSp',            0, 'single', 'A', 'Iq Setpoint')
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),Sim.ModelName)
end
%% Step Last
TestEnd
