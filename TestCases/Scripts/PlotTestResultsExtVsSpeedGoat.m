function PlotTestResultsExtVsSpeedGoat(C2000,Speedgoat,StpTimeCalc,TstName,isHil,StpLegnd,folder)
close all
Names = string(C2000.getElementNames);
LocAdc = find(Names == 'AdcMeas');
LocPll = find(Names == 'PLL');
LocCPU = find(Names == 'CPU_Load');
LocMod = find(Names == 'ModAct');
LocCC = find(Names == 'CC');
PlotHil = ~isempty(Speedgoat);

if PlotHil
    Names2 = string(Speedgoat.getElementNames);
   if isHil
        Loc2CPU = find(Names2 == 'C2000_CpuLoad');
        Tshift = align_signals_rms(C2000{LocCPU}.Values.Time, C2000{LocCPU}.Values.Data, Speedgoat{Loc2CPU}.Values.Time, Speedgoat{Loc2CPU}.Values.Data*100, 0);
    else
        Tshift = 0;
    end
    Loc2PQ = find(Names2 == 'HIL_PQ');
    Loc2w = find(Names2 == 'HIL_w');
    Loc2wt = find(Names2 == 'HIL_wt');
    Loc2Vabc = find(Names2 == 'HIL_Vg_abc_Sec');
    Loc2Iabc = find(Names2 == 'HIL_Iabc');
    Loc2Vdc = find(Names2 == 'HIL_Vdc');
    
end

%% ADC Measurment
fig = figure;
t = tiledlayout(2,3);
title(t, join([TstName, " - ","ADC Measurments"]))
subtitle(t, 'Whole Test');


ax(1) = nexttile;
p = plot(C2000{LocAdc}.Values.VaActMeas.Time,C2000{LocAdc}.Values.VaActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.VaActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Vabc}.Values.Time+Tshift,Speedgoat{Loc2Vabc}.Values.Data(:,1),'DisplayName',replace(Speedgoat{Loc2Vabc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(V)");title("V_a");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(2) = nexttile;
p = plot(C2000{LocAdc}.Values.VbActMeas.Time,C2000{LocAdc}.Values.VbActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.VbActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Vabc}.Values.Time+Tshift,Speedgoat{Loc2Vabc}.Values.Data(:,2),'DisplayName',replace(Speedgoat{Loc2Vabc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(V)");title("V_b");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(3) = nexttile;
p = plot(C2000{LocAdc}.Values.VdcActMeas.Time,C2000{LocAdc}.Values.VdcActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.VdcActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Vdc}.Values.Time+Tshift,Speedgoat{Loc2Vdc}.Values.Data,'DisplayName',replace(Speedgoat{Loc2Vdc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(V)");title("V_{dc}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(4) = nexttile;
p = plot(C2000{LocAdc}.Values.IaActMeas.Time,C2000{LocAdc}.Values.IaActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.IaActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Iabc}.Values.Time+Tshift,Speedgoat{Loc2Iabc}.Values.Data(:,1),'DisplayName',replace(Speedgoat{Loc2Iabc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(A)");title("I_{a}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(5) = nexttile;
p = plot(C2000{LocAdc}.Values.IbActMeas.Time,C2000{LocAdc}.Values.IbActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.IbActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Iabc}.Values.Time+Tshift,Speedgoat{Loc2Iabc}.Values.Data(:,2),'DisplayName',replace(Speedgoat{Loc2Iabc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(A)");title("I_{b}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(6) = nexttile;
p = plot(C2000{LocAdc}.Values.IcActMeas.Time,C2000{LocAdc}.Values.IcActMeas.Data,'DisplayName',replace(C2000{LocAdc}.Values.IcActMeas.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2Iabc}.Values.Time+Tshift,Speedgoat{Loc2Iabc}.Values.Data(:,3),'DisplayName',replace(Speedgoat{Loc2Iabc}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(A)");title("I_{c}");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(ax,'x')
set(fig, 'WindowState', 'maximized');

%% PLL Measurment
fig2 = figure;
t2 = tiledlayout(4,1);
title(t2,join([TstName, " - ","PLL Measurments"]))
subtitle(t2, 'Whole Test');


ay(1) = nexttile;
p(1) = plot(C2000{LocPll}.Values.w.Time,C2000{LocPll}.Values.w.Data,'DisplayName',replace(C2000{LocPll}.Values.w.Name, "_", "-"));
hold on
p(2) = plot(C2000{LocPll}.Values.w_Filt_30rad_s.Time,C2000{LocPll}.Values.w_Filt_30rad_s.Data,'DisplayName',replace(C2000{LocPll}.Values.w_Filt_30rad_s.Name, "_", "-"));
if PlotHil
    p(3) = plot(Speedgoat{Loc2w}.Values.Time+Tshift,Speedgoat{Loc2w}.Values.Data,'DisplayName',replace(Speedgoat{Loc2w}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(rad/s)");title("\omega");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(2) = nexttile;
p = plot(C2000{LocPll}.Values.wtCur.Time,C2000{LocPll}.Values.wtCur.Data,'DisplayName',replace(C2000{LocPll}.Values.wtCur.Name, "_", "-"));
if PlotHil
    hold on
    p(2) = plot(Speedgoat{Loc2wt}.Values.Time+Tshift,Speedgoat{Loc2wt}.Values.Data,'DisplayName',replace(Speedgoat{Loc2wt}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(rad)");title("\omegat");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(3) = nexttile;
p = plot(C2000{LocPll}.Values.Vdqz_Pll.Time,C2000{LocPll}.Values.Vdqz_Pll.Data(:,2),'DisplayName',replace(C2000{LocPll}.Values.Vdqz_Pll.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("V_q");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(4) = nexttile;
p =plot(C2000{LocPll}.Values.VgQSynch.Time,C2000{LocPll}.Values.VgQSynch.Data,'DisplayName',replace(C2000{LocPll}.Values.VgQSynch.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("Synchronization Flag");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(ay,'x')
set(fig2, 'WindowState', 'maximized');

%% Idq Measurment
fig3 = figure;
t3 = tiledlayout(3,2);
title(t3, join([TstName, " - ","Current Controller Measurments"]))
subtitle(t3, 'Whole Test');

az(1) = nexttile([1 2]);
p = plot(C2000{LocMod}.Values.Time,C2000{LocMod}.Values.Data,'DisplayName',replace(C2000{LocMod}.Values.Name, "_", "-"));
xlabel("(s)");title("Mode");xline(StpTimeCalc,'--');legend(p);clearvars p
ylim([-0.1 3.1]);yticks([0 1 2 3]);yticklabels(["NA" "Standby" "Power" "Failure"])

az(2) = nexttile;
p(1) = plot(C2000{LocCC}.Values.IdqzRef.Time,C2000{LocCC}.Values.IdqzRef.Data(:,1),'DisplayName',replace(C2000{LocCC}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(C2000{LocPll}.Values.Idqz.Time,C2000{LocPll}.Values.Idqz.Data(:,1),'DisplayName',replace(C2000{LocPll}.Values.Idqz.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_d");xline(StpTimeCalc,'--');legend(p);clearvars p

az(3) = nexttile;
p(1) = plot(C2000{LocCC}.Values.IdqzRef.Time,C2000{LocCC}.Values.IdqzRef.Data(:,2),'DisplayName',replace(C2000{LocCC}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(C2000{LocPll}.Values.Idqz.Time,C2000{LocPll}.Values.Idqz.Data(:,2),'DisplayName',replace(C2000{LocPll}.Values.Idqz.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_q");xline(StpTimeCalc,'--');legend(p);clearvars p

az(4) = nexttile;
p(1) = plot(C2000{LocPll}.Values.PQ.Time,C2000{LocPll}.Values.PQ.Data(:,1),'DisplayName',replace(C2000{LocPll}.Values.PQ.Name, "_", "-"));
if PlotHil
hold on
p(2) = plot(Speedgoat{Loc2PQ}.Values.Time+Tshift,Speedgoat{Loc2PQ}.Values.Data(:,1),'DisplayName',replace(Speedgoat{Loc2PQ}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(W)");title("Power");xline(StpTimeCalc,'--');legend(p);clearvars p

az(5) = nexttile;
p(1) = plot(C2000{LocPll}.Values.PQ.Time,C2000{LocPll}.Values.PQ.Data(:,2),'DisplayName',replace(C2000{LocPll}.Values.PQ.Name, "_", "-"));
if PlotHil
hold on
p(2) = plot(Speedgoat{Loc2PQ}.Values.Time+Tshift,Speedgoat{Loc2PQ}.Values.Data(:,2),'DisplayName',replace(Speedgoat{Loc2PQ}.Values.Name, "_", "-"));
end
xlabel("(s)");ylabel("(VA)");title("Reactive Power");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(az,'x')
set(fig3, 'WindowState', 'maximized');
%%
% folder = 'C:\Users\The Professionals\Documents\MATLAB\SW\TestCases\TestResults';

% Get today's date in YYYYMMDD format
todayDate = datestr(now, 'yyyymmdd');

% Create folder name
if isHil
    folderName = [folder '\HIL_' todayDate];
else
    folderName = [folder '\SIM_' todayDate];
end

% Create the folder if it doesn't exist
if ~exist(folderName, 'dir')
    mkdir(folderName);
    fprintf('Folder "%s" created successfully.\n', folderName);
else
    fprintf('Folder "%s" already exists.\n', folderName);
end
folderName2 = [folderName '\' TstName];

% Create the folder if it doesn't exist
if ~exist(folderName2, 'dir')
    mkdir(folderName2);
    fprintf('Folder "%s" created successfully.\n', folderName2);
else
    fprintf('Folder "%s" already exists.\n', folderName2);
end

if isHil
    filename = fullfile(folderName2, ['HIL_' TstName '_' datestr(now, 'yyyy_mm_dd_HH_MM_SS') '.pdf']);
    filenameMat = fullfile(folderName2, ['HIL_' TstName '_' datestr(now, 'yyyy_mm_dd_HH_MM_SS') '.mat']);

else
    filename = fullfile(folderName2, ['SIM_' TstName '_' datestr(now, 'yyyy_mm_dd_HH_MM_SS') '.pdf']);
    filenameMat = fullfile(folderName2, ['SIM_' TstName '_' datestr(now, 'yyyy_mm_dd_HH_MM_SS') '.mat']);
end

save(filenameMat, 'C2000');  % saves the variable 'data' under the same name

% Export to that folder
exportgraphics(fig, filename);
exportgraphics(fig2, filename, 'Append', true);
exportgraphics(fig3, filename, 'Append', true);

for i = 1:length(StpTimeCalc)
    xlim(ax,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (ax,"auto"); subtitle(t, StpLegnd(i));
    xlim(ay,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (ay,"auto"); subtitle(t2, StpLegnd(i));
    xlim(az,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (az,"auto"); subtitle(t3, StpLegnd(i));
    exportgraphics(fig, filename, 'Append', true);
    exportgraphics(fig2, filename, 'Append', true);
    exportgraphics(fig3, filename, 'Append', true);
end


end