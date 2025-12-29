TstName         = 'ArduinoGridErr';
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
            setParam('ModReq',      uint16(1), 'uint16', '1', 'State Space Mode Request')
            setParam('PorISel',     uint16(0), 'uint16', '1', 'Controller Selector (Power Control or Current Control)')
        case 2
            setParam('PSp',         0, 'single', 'W', 'Power Setpoint')
        case 3
            setParam('Test',        uint16(true), 'uint16', '1', 'Enable Test Mode')
            setParam('FrcPwr',      uint16(true), 'uint16', '1', 'Force Power Mode')
        case 4
            setParam('Test',        uint16(false), 'uint16', '1', 'Enable Test Mode')
            setParam('FrcPwr',      uint16(false), 'uint16', '1', 'Force Power Mode')
            setParam('PSp',         0, 'single', 'W', 'Power Setpoint')
    end
ExcuteStep(StpNames(i),StpTimeCalc(i),Sim.ModelName)
end
%% Step Last
TestEnd
