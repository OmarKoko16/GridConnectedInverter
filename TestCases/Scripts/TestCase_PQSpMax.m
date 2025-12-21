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
            ModReq          = boolean(1);
            PorISel         = boolean(0);
            EnableMonitors  = boolean(true);                          
        case 2
            PSp             = single(PwrStp);
        case 3
            PSp             = single(0);
        case 4
            QSp             = single(PwrStp);
        case 5
            QSp             = single(0);
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),ModelName)
end
%% Step Last
TestEnd