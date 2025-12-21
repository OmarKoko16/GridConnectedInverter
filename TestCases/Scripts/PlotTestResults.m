close all
%% ADC Measurment
fig = figure;
t = tiledlayout(2,3);
title(t, "ADC Measurments")

ax(1) = nexttile;
p(1) = plot(out.logsout{1}.Values.VaActMeas.Time,out.logsout{1}.Values.VaActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.VaActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{17}.Values.Time,out.logsout{17}.Values.Data(:,1),'DisplayName',replace(out.logsout{17}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(V)$");title("$V_a$");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(2) = nexttile;
p = plot(out.logsout{1}.Values.VbActMeas.Time,out.logsout{1}.Values.VbActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.VbActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{17}.Values.Time,out.logsout{17}.Values.Data(:,2),'DisplayName',replace(out.logsout{17}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(V)$");title("$V_b$");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(3) = nexttile;
p = plot(out.logsout{1}.Values.VdcActMeas.Time,out.logsout{1}.Values.VdcActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.VdcActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{23}.Values.Time,out.logsout{23}.Values.Data,'DisplayName',replace(out.logsout{23}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(V)$");title("$V_{dc}$");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(4) = nexttile;
p = plot(out.logsout{1}.Values.IaActMeas.Time,out.logsout{1}.Values.IaActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.IaActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{16}.Values.Time,out.logsout{16}.Values.Data(:,1),'DisplayName',replace(out.logsout{16}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(A)$");title("$I_{a}$");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(5) = nexttile;
p = plot(out.logsout{1}.Values.IbActMeas.Time,out.logsout{1}.Values.IbActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.IbActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{16}.Values.Time,out.logsout{16}.Values.Data(:,2),'DisplayName',replace(out.logsout{16}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(A)$");title("$I_{b}$");xline(StpTimeCalc,'--');legend(p);clearvars p

ax(6) = nexttile;
p = plot(out.logsout{1}.Values.IcActMeas.Time,out.logsout{1}.Values.IcActMeas.Data,'DisplayName',replace(out.logsout{1}.Values.IcActMeas.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{16}.Values.Time,out.logsout{16}.Values.Data(:,3),'DisplayName',replace(out.logsout{16}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(A)$");title("$I_{c}$");xline(StpTimeCalc,'--');legend(p);clearvars p

linkaxes(ax,'x')
set(fig, 'WindowState', 'maximized');

%% PLL Measurment
fig2 = figure;
t2 = tiledlayout(5,1);
title(t2, "PLL Measurments")

ay(1) = nexttile;
p(1) = plot(out.logsout{2}.Values.w.Time,out.logsout{2}.Values.w.Data,'DisplayName',replace(out.logsout{2}.Values.w.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{2}.Values.w_Filt_30rad_s.Time,out.logsout{2}.Values.w_Filt_30rad_s.Data,'DisplayName',replace(out.logsout{2}.Values.w_Filt_30rad_s.Name, "_", "-"));
p(3) = plot(out.logsout{25}.Values.Time,out.logsout{25}.Values.Data,'DisplayName',replace(out.logsout{25}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(rad/s)$");title("$\omega$");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(2) = nexttile;
p(1) = plot(out.logsout{2}.Values.wtCur.Time,out.logsout{2}.Values.wtCur.Data,'DisplayName',replace(out.logsout{2}.Values.wtCur.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{24}.Values.Time,mod(out.logsout{24}.Values.Data+30*pi/180,2*pi),'DisplayName',replace(out.logsout{24}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(rad)$");title("$\omega t$");xline(StpTimeCalc,'--');legend(p);clearvars p

thetaHil = interp1(out.logsout{24}.Values.Time,mod(out.logsout{24}.Values.Data+30*pi/180,2*pi),out.logsout{2}.Values.wtCur.Time);
error = atan2(sin(thetaHil  - out.logsout{2}.Values.wtCur.Data), cos(thetaHil - out.logsout{2}.Values.wtCur.Data));
ay(3) = nexttile;
p =plot(out.logsout{2}.Values.wtCur.Time,error,'DisplayName',"Error");
xlabel("$(s)$");ylabel("$(rad)$");title("$\omega t$\,Error");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(4) = nexttile;
p = plot(out.logsout{2}.Values.Vdqz_Pll.Time,out.logsout{2}.Values.Vdqz_Pll.Data(:,2),'DisplayName',replace(out.logsout{2}.Values.Vdqz_Pll.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(V)$");title("$V_q$");xline(StpTimeCalc,'--');legend(p);clearvars p

ay(5) = nexttile;
p =plot(out.logsout{2}.Values.VgQSynch.Time,out.logsout{2}.Values.VgQSynch.Data,'DisplayName',replace(out.logsout{2}.Values.VgQSynch.Name, "_", "-"));
xlabel("$(s)$");title("$Synchronization\,Flag$");xline(StpTimeCalc,'--');legend(p);clearvars p
ylim([-0.1 1.1]);yticks([0 1 ]);yticklabels(["Out of Synch" "Synch"])

linkaxes(ay,'x')
set(fig2, 'WindowState', 'maximized');

%% Idq Measurment
fig3 = figure;
t3 = tiledlayout(3,2);
title(t3, "Current Controller Measurments")

az(1) = nexttile([1 2]);
p = plot(out.logsout{13}.Values.Time,out.logsout{13}.Values.Data,'DisplayName',replace(out.logsout{13}.Values.Name, "_", "-"));
xlabel("$(s)$");title("$Mode$");xline(StpTimeCalc,'--');legend(p);clearvars p
ylim([-0.1 3.1]);yticks([0 1 2 3]);yticklabels(["NA" "Standby" "Power" "Failure"])

az(2) = nexttile;
p(1) = plot(out.logsout{8}.Values.IdqzRef.Time,out.logsout{8}.Values.IdqzRef.Data(:,1),'DisplayName',replace(out.logsout{8}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{2}.Values.Idqz.Time,out.logsout{2}.Values.Idqz.Data(:,1),'DisplayName',replace(out.logsout{2}.Values.Idqz.Name, "_", "-"));
p(3) = plot(out.logsout{19}.Values.Time,out.logsout{19}.Values.Data(:,1)*Var.Transformer_N,'DisplayName',replace(out.logsout{19}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(A)$");title("$I_d$");xline(StpTimeCalc,'--');legend(p);clearvars p

az(3) = nexttile;
p(1) = plot(out.logsout{8}.Values.IdqzRef.Time,out.logsout{8}.Values.IdqzRef.Data(:,2),'DisplayName',replace(out.logsout{8}.Values.IdqzRef.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{2}.Values.Idqz.Time,out.logsout{2}.Values.Idqz.Data(:,2),'DisplayName',replace(out.logsout{2}.Values.Idqz.Name, "_", "-"));
p(3) = plot(out.logsout{19}.Values.Time,out.logsout{19}.Values.Data(:,2)*Var.Transformer_N,'DisplayName',replace(out.logsout{19}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(A)$");title("$I_q$");xline(StpTimeCalc,'--');legend(p);clearvars p

az(4) = nexttile;
p(1) = plot(out.logsout{2}.Values.PQ.Time,out.logsout{2}.Values.PQ.Data(:,1),'DisplayName',replace(out.logsout{2}.Values.PQ.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{21}.Values.Time,out.logsout{21}.Values.Data.*out.logsout{23}.Values.Data,'DisplayName',"HIL-DC-Pwr");
p(3) = plot(out.logsout{29}.Values.Time,out.logsout{29}.Values.Data(:,1),'DisplayName',replace(out.logsout{29}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(W)$");title("$Power$");xline(StpTimeCalc,'--');legend(p);clearvars p

az(5) = nexttile;
p(1) = plot(out.logsout{2}.Values.PQ.Time,out.logsout{2}.Values.PQ.Data(:,2),'DisplayName',replace(out.logsout{2}.Values.PQ.Name, "_", "-"));
hold on
p(2) = plot(out.logsout{29}.Values.Time,out.logsout{29}.Values.Data(:,2),'DisplayName',replace(out.logsout{29}.Values.Name, "_", "-"));
xlabel("$(s)$");ylabel("$(VA)$");title("$Reactive\,Power$");xline(StpTimeCalc,'--');legend(p);clearvars p

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
    xlim(ax,[StpTimeCalc(i)-0.1 StpTimeCalc(i)+.5]);ylim (ax,"auto")
    xlim(ay,[StpTimeCalc(i)-0.1 StpTimeCalc(i)+.5]);ylim (ay,"auto")
    xlim(az,[StpTimeCalc(i)-0.1 StpTimeCalc(i)+.5]);ylim (az,"auto")
    exportgraphics(fig, filename, 'Append', true);
    exportgraphics(fig2, filename, 'Append', true);
    exportgraphics(fig3, filename, 'Append', true);
end


