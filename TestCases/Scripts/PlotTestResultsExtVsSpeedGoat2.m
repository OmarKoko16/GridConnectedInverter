function PlotTestResultsExtVsSpeedGoat2(C2000,Speedgoat,StpTimeCalc,TstName,isHil,StpLegnd,folder,ModelParam)
filename = saveTestResults(C2000, 'C2000', TstName, folder, isHil,ModelParam);

close all

PlotAll(1).Titles = "ADC Measurments";
PlotAll(1).Plots =...
["C2000_AdcMeas_VaActMeas"  "(V)" "V_a"         "HIL_Vg_abc_Sec_1"
"C2000_AdcMeas_VbActMeas"   "(V)" "V_b"         "HIL_Vg_abc_Sec_2"
"C2000_AdcMeas_VdcActMeas"  "(V)" "V_{DC}"      "HIL_Vdc"
"C2000_AdcMeas_IaActMeas"   "(A)" "I_a"         "HIL_Iabc_1"
"C2000_AdcMeas_IbActMeas"   "(A)" "I_b"         "HIL_Iabc_2"
"C2000_AdcMeas_IcActMeas"   "(A)" "I_c"         "HIL_Iabc_3"] ;

PlotAll(2).Titles = "PLL Measurments";
PlotAll(2).Plots = ...
["C2000_PLL_w"              "(rad/s)" "\omega"          "HIL_w"     "C2000_PLL_w_Filt_30rad_s" 
"C2000_PLL_wtCur"           "(rad)"   "\omegat"         "HIL_wt"    ""
"C2000_PLL_Vdqz_2"          "(V)"     "V_q"             "-"         ""
"C2000_PLL_VgQSynch"        "(-)"     "Sync Flag"       "-"         ""];

PlotAll(3).Titles = "Current Controller Measurments";
PlotAll(3).Plots = ...
["C2000_ModAct"             "(-)"    "Mode"             "-"         ""
"C2000_CC_IdqzRef_1"        "(A)"    "I_{d}"            "-"         "C2000_PLL_Idqz_1" 
"C2000_CC_IdqzRef_2"        "(A)"    "I_{q}"            "-"         "C2000_PLL_Idqz_2"
"C2000_CC_PQRef_1"          "(W)"    "Power"            "HIL_PQ_1"  "C2000_PLL_PQ_1"     
"C2000_CC_PQRef_2"          "(VAR)"  "Reactive Power"   "HIL_PQ_2"  "C2000_PLL_PQ_2" ];


S1 = convertDatasetToStruct(C2000);
PlotHil = ~isempty(Speedgoat);
for i = 1:length(PlotAll)
    Plots1 = PlotAll(i).Plots;
    if PlotHil
        S2 = convertDatasetToStruct(Speedgoat);
        [fig,ax] = plotSignalList(Plots1, S1, S2,StpTimeCalc, PlotAll(i).Titles);
        exportgraphics(fig, filename, 'Append', true);
        for j = 1:length(StpTimeCalc)
            xlim(ax,[StpTimeCalc(j)-0.5 StpTimeCalc(j)+.6]);ylim (ax,"auto");  sgtitle({PlotAll(i).Titles, StpLegnd(j)});
            exportgraphics(fig, filename, 'Append', true);
        end
    else
        [fig,ax] = plotSignalList(Plots1, S1, {},StpTimeCalc, PlotAll(i).Titles);
        exportgraphics(fig, filename, 'Append', true);
        for j = 1:length(StpTimeCalc)
            xlim(ax,[StpTimeCalc(j)-0.5 StpTimeCalc(j)+.6]);ylim (ax,"auto"); sgtitle({PlotAll(i).Titles, StpLegnd(j)});
            exportgraphics(fig, filename, 'Append', true);
        end
    end
end
end

function [fig,ax] = plotSignalList(plotConfig, S1, S2, StpTimeCalc, MainTitle)
% PLOTSIGNALLIST Plots a list of signals defined in plotConfig
%
% Inputs:
%   plotConfig  : Nx3, Nx4, or Nx5 String Array 
%                 Col 1: "SignalName_S1" (Required)
%                 Col 2: "Unit" (Required)
%                 Col 3: "Title" (Required)
%                 Col 4: "SignalName_S2" (Optional - defaults to S1 name)
%                 Col 5: "SignalName_S1_Secondary" (Optional - 2nd signal from S1)
%   S1          : Primary Data Structure (from convertDatasetToStruct)
%   S2          : (Optional) Secondary Data Structure for comparison
%   StpTimeCalc : (Optional) Time(s) to draw vertical dashed lines
%   MainTitle   : (Optional) String for the main figure title

    if nargin < 5
        MainTitle = [];
    end

    if nargin < 4
        StpTimeCalc = [];
    end

    if nargin < 3
        S2 = [];
    end

    % Check if S2 is valid for plotting
    plotSecondary = ~isempty(S2);

    % Get available field names from S1
    availableSignals = fieldnames(S1);
    availableSignalsStr = string(availableSignals);

    % Extract signal names from the first column of the config
    targetSignals = plotConfig(:, 1);
    numReq = length(targetSignals);
    
    % Arrays to store valid signals found
    validIndices = [];
    validConfigRows = [];

    for i = 1:numReq
        sigName = targetSignals(i);
        
        % Find match in available signals
        idx = find(availableSignalsStr == sigName, 1);
        
        if ~isempty(idx)
            validIndices(end+1) = idx;
            validConfigRows(end+1) = i;
        else
            warning('Signal "%s" not found in S1. Skipping.', sigName);
        end
    end

    if isempty(validIndices)
        warning('No valid signals found to plot for this set.');
        return;
    end

    selectedSignals = availableSignals(validIndices);

    % Create Figure
    % Use the MainTitle if provided, otherwise default to the first signal group
    if ~isempty(MainTitle)
        figName = MainTitle;
    else
        figName = sprintf('Group: %s ...', plotConfig(validConfigRows(1), 3));
    end
    
    fig = figure('Name', figName, 'Color', 'w');

    numPlots = length(selectedSignals);
    ax = gobjects(numPlots, 1); 

    for i = 1:numPlots
        sigName = selectedSignals{i};
        configRow = validConfigRows(i);
        
        % Extract metadata
        plotUnit  = plotConfig(configRow, 2);
        plotTitle = plotConfig(configRow, 3);
        
        % 1. Determine S2 Signal Name (Column 4)
        sigNameS2 = sigName; % Default to S1 name
        if size(plotConfig, 2) >= 4
            val = plotConfig(configRow, 4);
            if ~ismissing(val) && val ~= ""
                sigNameS2 = val;
            end
        end

        % 2. Determine Secondary S1 Signal Name (Column 5)
        sigNameS1_Sec = "";
        if size(plotConfig, 2) >= 5
            val = plotConfig(configRow, 5);
            if ~ismissing(val) && val ~= ""
                sigNameS1_Sec = val;
            end
        end

        % Create subplot
        ax(i) = subplot(numPlots, 1, i);
        hold on;
        
        % Initialize Legend containers
        legendHandles = [];
        legendText = {};
        
        % --- Plot Meas1 (Primary) ---
         if ~isempty(S1.(sigName).data)
            p1 = plot(S1.(sigName).time, S1.(sigName).data, 'LineWidth', 1.5);
            legendHandles(end+1) = p1;
            legendText{end+1} = sigName;
         end
        
        % --- Plot Meas1 (Secondary Signal from Col 5) ---
        if sigNameS1_Sec ~= "" && isfield(S1, sigNameS1_Sec)
             % Plotting with a different line style or color cycle
             p1_sec = plot(S1.(sigNameS1_Sec).time, S1.(sigNameS1_Sec).data, '-.', 'LineWidth', 1.5);
             legendHandles(end+1) = p1_sec;
             legendText{end+1} = sigNameS1_Sec;
        end
        
        % --- Plot Meas2 ---
        if plotSecondary && isfield(S2, sigNameS2)
             p2 = plot(S2.(sigNameS2).time, S2.(sigNameS2).data, '--', 'LineWidth', 1.5);
             legendHandles(end+1) = p2;
             legendText{end+1} = sigNameS2;
        end
        % --- Add Vertical Lines if requested ---
        if ~isempty(StpTimeCalc)
            xline(StpTimeCalc, '--');
        end

        % Apply Legend
        if ~isempty(legendHandles)
            legend(legendHandles, legendText, 'Interpreter', 'none');
        end
        
        grid on;
        title(plotTitle);

        % --- Special Formatting for Mode Action ---
        if strcmp(sigName, 'C2000_ModAct')
            ylim([-0.1 3.1]);
            yticks([0 1 2 3]);
            yticklabels(["NA" "Standby" "Power" "Failure"]);
        else
            ylabel(plotUnit);
        end
        

        % X-axis label only on bottom plot
        if i == numPlots
            xlabel('Time (s)');
        end
        
        hold off;
    end

    % Link x-axes for zooming
    linkaxes(ax, 'x');
    set(fig, 'WindowState', 'maximized');
    
    % Add Main Title and Subtitle if provided
    if ~isempty(MainTitle)
        sgtitle({MainTitle, 'Whole Measurement'});
    end
end

function [pdfPath, matPath] = saveTestResults(data, dataName, TstName, baseFolder, isHil,ModelParam)
% SAVETESTRESULTS Saves test data to a timestamped folder structure
%
% Usage:
%   saveTestResults(C2000, 'C2000', 'Test1_GridTie', 'C:\Data', true);
%
% Inputs:
%   data       : The data variable to save (e.g., the struct or object)
%   dataName   : String name for the variable inside the .mat file (e.g., 'C2000')
%   TstName    : String name of the specific test case
%   baseFolder : Root folder path where results should be stored
%   isHil      : Boolean (true for HIL, false for SIM)
%
% Outputs:
%   pdfPath    : Full path to the generated PDF filename (for printing plots later)
%   matPath    : Full path to the generated MAT file

    % Get today's date in YYYYMMDD format
    todayDate = datestr(now, 'yyyymmdd');
    timestamp = datestr(now, 'yyyy_mm_dd_HH_MM_SS');

    % 1. Determine Main Folder Name based on HIL/SIM status
    if isHil
        typePrefix = 'HIL';
    else
        typePrefix = 'SIM';
    end
    
    % Construct first level folder: e.g., "Folder\HIL_20231027"
    folderName = fullfile(baseFolder, [typePrefix, '_', todayDate]);

    % Create the folder if it doesn't exist
    if ~exist(folderName, 'dir')
        mkdir(folderName);
        fprintf('Folder created: %s\n', folderName);
    else
        % fprintf('Folder exists: %s\n', folderName);
    end

    % 2. Construct Second Level Folder: e.g., "Folder\HIL_20231027\TestName"
    folderName2 = fullfile(folderName, TstName);

    % Create the sub-folder if it doesn't exist
    if ~exist(folderName2, 'dir')
        mkdir(folderName2);
        fprintf('Sub-folder created: %s\n', folderName2);
    else
        % fprintf('Sub-folder exists: %s\n', folderName2);
    end

    % 3. Construct File Names
    baseFileName = sprintf('%s_%s_%s', typePrefix, TstName, timestamp);
    
    pdfPath = fullfile(folderName2, [baseFileName, '.pdf']);
    matPath = fullfile(folderName2, [baseFileName, '.mat']);

    % 4. Save Data
    % We use a temporary struct 'S' to ensure the variable in the .mat file 
    % has the specific name requested (e.g., 'C2000') rather than just 'data'.
    S.(dataName) = data;
    S.ModelParam = ModelParam;
    
    try
        save(matPath, '-struct', 'S');
        fprintf('Data saved successfully to:\n  %s\n', matPath);
        fprintf('PDF path reserved at:\n  %s\n', pdfPath);
    catch ME
        warning('Failed to save .mat file: %s', ME.message);
    end
end