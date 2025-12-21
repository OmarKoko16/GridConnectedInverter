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
            ModReq          = boolean(1);
            PorISel         = boolean(1);
            EnableMonitors  = boolean(true);            
        case 2
            IdSp            = single(CurStp);
        case 3
            IqSp            = single(CurStp);
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),ModelName)
end
%% Step Last
TestEnd
