close all
%% ADC Measurment
fig = figure;
t = tiledlayout(2,3);
title(t, "ADC Measurments")
Names = string(logsout.getElementNames);
LocAdc = find(Names == 'AdcMeas');
ax(1) = nexttile;
p = plot(logsout{LocAdc}.Values.VaActMeas.Time,logsout{LocAdc}.Values.VaActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.VaActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("V_a");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(2) = nexttile;
p = plot(logsout{LocAdc}.Values.VbActMeas.Time,logsout{LocAdc}.Values.VbActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.VbActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("V_b");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(3) = nexttile;
p = plot(logsout{LocAdc}.Values.VdcActMeas.Time,logsout{LocAdc}.Values.VdcActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.VdcActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("V_{dc}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(4) = nexttile;
p = plot(logsout{LocAdc}.Values.IaActMeas.Time,logsout{LocAdc}.Values.IaActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.IaActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_{a}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(5) = nexttile;
p = plot(logsout{LocAdc}.Values.IbActMeas.Time,logsout{LocAdc}.Values.IbActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.IbActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_{b}");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(6) = nexttile;
p = plot(logsout{LocAdc}.Values.IcActMeas.Time,logsout{LocAdc}.Values.IcActMeas.Data,'DisplayName',replace(logsout{LocAdc}.Values.IcActMeas.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_{c}");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(ax,'x')
set(fig, 'WindowState', 'maximized');

%% PLL Measurment
fig2 = figure;
t2 = tiledlayout(4,1);
title(t2, "PLL Measurments")
LocPll = find(Names == 'PLL');
ay(1) = nexttile;
p(1) = plot(logsout{LocPll}.Values.w.Time,logsout{LocPll}.Values.w.Data,'DisplayName',replace(logsout{LocPll}.Values.w.Name, "_", "-"));
hold on
p(2) = plot(logsout{LocPll}.Values.w_Filt_30rad_s.Time,logsout{LocPll}.Values.w_Filt_30rad_s.Data,'DisplayName',replace(logsout{LocPll}.Values.w_Filt_30rad_s.Name, "_", "-"));
xlabel("(s)");ylabel("(rad/s)");title("\omega");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(2) = nexttile;
p = plot(logsout{LocPll}.Values.wtCur.Time,logsout{LocPll}.Values.wtCur.Data,'DisplayName',replace(logsout{LocPll}.Values.wtCur.Name, "_", "-"));
xlabel("(s)");ylabel("(rad)");title("\omegat");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(3) = nexttile;
p = plot(logsout{LocPll}.Values.Vdqz_Pll.Time,logsout{LocPll}.Values.Vdqz_Pll.Data(:,2),'DisplayName',replace(logsout{LocPll}.Values.Vdqz_Pll.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("V_q");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(4) = nexttile;
p =plot(logsout{LocPll}.Values.VgQSynch.Time,logsout{LocPll}.Values.VgQSynch.Data,'DisplayName',replace(logsout{LocPll}.Values.VgQSynch.Name, "_", "-"));
xlabel("(s)");ylabel("(V)");title("Synchronization Flag");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(ay,'x')
set(fig2, 'WindowState', 'maximized');

%% Idq Measurment
fig3 = figure;
t3 = tiledlayout(3,2);
title(t3, "Current Controller Measurments")
LocMod = find(Names == 'ModAct');
LocCC = find(Names == 'CC');
az(1) = nexttile([1 2]);
p = plot(logsout{LocMod}.Values.Time,logsout{LocMod}.Values.Data,'DisplayName',replace(logsout{LocMod}.Values.Name, "_", "-"));
xlabel("(s)");title("Mode");xline(StpTimeCalc,'--');legend(p);clearvars p
ylim([-0.1 3.1]);yticks([0 1 2 3]);yticklabels(["NA" "Standby" "Power" "Failure"])

az(2) = nexttile;
p(1) = plot(logsout{LocCC}.Values.IdqzRef.Time,logsout{LocCC}.Values.IdqzRef.Data(:,1),'DisplayName',replace(logsout{LocCC}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(logsout{LocPll}.Values.Idqz.Time,logsout{LocPll}.Values.Idqz.Data(:,1),'DisplayName',replace(logsout{LocPll}.Values.Idqz.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_d");xline(StpTimeCalc,'--');legend(p);clearvars p

az(3) = nexttile;
p(1) = plot(logsout{LocCC}.Values.IdqzRef.Time,logsout{LocCC}.Values.IdqzRef.Data(:,2),'DisplayName',replace(logsout{LocCC}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(logsout{LocPll}.Values.Idqz.Time,logsout{LocPll}.Values.Idqz.Data(:,2),'DisplayName',replace(logsout{LocPll}.Values.Idqz.Name, "_", "-"));
xlabel("(s)");ylabel("(A)");title("I_q");xline(StpTimeCalc,'--');legend(p);clearvars p

az(4) = nexttile;
p(1) = plot(logsout{LocPll}.Values.PQ.Time,logsout{LocPll}.Values.PQ.Data(:,1),'DisplayName',replace(logsout{LocPll}.Values.PQ.Name, "_", "-"));
xlabel("(s)");ylabel("(W)");title("Power");xline(StpTimeCalc,'--');legend(p);clearvars p

az(5) = nexttile;
p(1) = plot(logsout{LocPll}.Values.PQ.Time,logsout{LocPll}.Values.PQ.Data(:,2),'DisplayName',replace(logsout{LocPll}.Values.PQ.Name, "_", "-"));
xlabel("(s)");ylabel("(VA)");title("Reactive Power");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(az,'x')
set(fig3, 'WindowState', 'maximized');
%%
folder = 'C:\Users\The Professionals\Documents\MATLAB\SW\TestCases\TestResults';
filename = fullfile(folder, [TstName '_' datestr(now, 'yyyy_mm_dd_HH_MM_SS') '.pdf']);

% Export to that folder
exportgraphics(fig, filename);
exportgraphics(fig2, filename, 'Append', true);
exportgraphics(fig3, filename, 'Append', true);

for i = 1:length(StpTimeCalc)
    xlim(ax,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (ax,"auto")
    xlim(ay,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (ay,"auto")
    xlim(az,[StpTimeCalc(i)-0.5 StpTimeCalc(i)+.6]);ylim (az,"auto")
    exportgraphics(fig, filename, 'Append', true);
    exportgraphics(fig2, filename, 'Append', true);
    exportgraphics(fig3, filename, 'Append', true);
end


