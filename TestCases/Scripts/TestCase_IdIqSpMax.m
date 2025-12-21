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
            ModReq          = boolean(1);
            PorISel         = boolean(1);
        case 2
            IdSp = single(CurStp);
        case 3
            IdSp = single(0);
        case 4
            IqSp = single(CurStp);
        case 5
            IqSp = single(0);
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),ModelName)
end
%% Step Last
TestEnd
