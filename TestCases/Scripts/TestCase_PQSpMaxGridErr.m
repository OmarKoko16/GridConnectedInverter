%% Test Settings
TstName         = 'PQSpMaxGridErr';
StpNames        = ["1. Power Mode"    ...
                   "2. Power Setpoint"   ...
                   "3.Inject Failure" ...
                   "4.Recover"];
Fails = ["Phase Jump" "Phase Jump Recover"...
    "Harmonics" "Harmonics Recover"...
    "Unbalance" "Unbalance Recover"...
    "Undervoltage" "Undervoltage Recover"...
    "Freq -Start"...
    "Freq -4Hz"...
    "Freq +10Hz"...
    "Freq Recover"];
StpLegnd        = [StpNames(1:2) Fails StpNames(4)  "End" ];

PwrStp          = 2500;

if Extrn == 1
    StpTime         = [10    10       12      10];  
    PlotAx = cumsum([10    10       ones(1,12)      10]);
else
    StpTime         = [1    1       12      1];
    PlotAx = cumsum([1    1       ones(1,12)      1]);
end

%% Initialize
TestInit
%% Steps
for i = 1:length(StpTimeCalc)

    switch i
        case 1
            ModReq          = boolean(1);
            PorISel         = boolean(0);
        case 2
            PSp             = single(PwrStp);
        case 3
            Test            = boolean(true);
            FrcPwr          = boolean(true);
        case 4
            Test            = boolean(false);
            FrcPwr          = boolean(false);
            PSp             = single(0);
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),ModelName)
end
%% Step Last
TestEnd