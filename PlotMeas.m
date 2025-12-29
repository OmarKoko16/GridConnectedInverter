%% Signal Comparison and Alignment Script
% Loads two datasets, allows specific signal alignment using estimate_time_shift, 
% and offers a UI to map signals for plotting.
clc; close all;

%% 1. Conditional Loading (Only if variables don't exist)
% Check if Meas1 needs loading
if ~exist('Meas1', 'var') || isempty(Meas1)
    fprintf('Meas1 not found. Select file...\n');
    [file1, path1] = uigetfile(fullfile('TestCases', 'TestResults', '*.mat'), 'Select Data File for Meas1');
    if isequal(file1, 0)
        warning('Meas1 file selection cancelled. Aborting.');
        return;
    end
    data1 = load(fullfile(path1, file1));
    
    % Intelligent variable extraction
    if isfield(data1, 'Meas1')
        Meas1 = data1.Meas1;
    else
        vars = fieldnames(data1);
        if isempty(vars)
            error('Selected file contains no variables.');
        end
        Meas1 = data1.(vars{1});
        fprintf('Loaded variable ''%s'' as Meas1.\n', vars{1});
    end
end

% Check if Meas2 needs loading
if exist('Meas1', 'var') && (~exist('Meas2', 'var') || isempty(Meas2))
    fprintf('Meas2 not found. Select file (Optional)...\n');
    startPath = '.';
    if exist('path1', 'var'), startPath = path1; end
    
    [file2, path2] = uigetfile(fullfile(startPath, '*.mat'), 'Select Data File for Meas2 (Cancel to skip)');
    if isequal(file2, 0)
        Meas2 = [];
        fprintf('Meas2 selection skipped.\n');
    else
        data2 = load(fullfile(path2, file2));
        if isfield(data2, 'Meas2')
            Meas2 = data2.Meas2;
        elseif isfield(data2, 'Meas1')
            Meas2 = data2.Meas1; 
        else
            vars = fieldnames(data2);
            if isempty(vars)
                 Meas2 = [];
                 warning('Selected file for Meas2 contains no variables. Treating as empty.');
            else
                Meas2 = data2.(vars{1});
                fprintf('Loaded variable ''%s'' as Meas2.\n', vars{1});
            end
        end
    end
end

%% 2. Convert Data to Structs
fprintf('Converting datasets...\n');
% Helper check for conversion function
if exist('convertDatasetToStruct', 'file')
    S1 = convertDatasetToStruct(Meas1);
    hasMeas2 = ~isempty(Meas2);
    if hasMeas2
        S2 = convertDatasetToStruct(Meas2);
    end
else
    % Fallback: assume data is already a struct
    warning('convertDatasetToStruct not found. Assuming data is already a struct.');
    S1 = Meas1;
    if ~isempty(Meas2)
        S2 = Meas2;
        hasMeas2 = true;
    else
        hasMeas2 = false;
    end
end

%% 3. Alignment Logic (User Selection)
if hasMeas2
    % Ask user if they want to perform alignment
    choice = questdlg('Do you want to align Meas2 to Meas1?', ...
        'Alignment Request', 'Yes', 'No', 'No');
    
    if strcmp(choice, 'Yes')
        fields1 = fieldnames(S1);
        fields2 = fieldnames(S2);
        
        % --- Step A: Select Reference Signal from S1 ---
        [indx1, tf1] = listdlg('PromptString', 'Select REFERENCE signal from Meas1 (S1):', ...
                               'SelectionMode', 'single', ...
                               'ListString', fields1, ...
                               'ListSize', [300, 400]);
        if tf1 == 0
            warning('Alignment cancelled.');
        else
            refSigName = fields1{indx1};
            
            % --- Step B: Select Target Signal from S2 ---
            [indx2, tf2] = listdlg('PromptString', {'Select signal from Meas2 (S2)', ['to align against ' refSigName ':']}, ...
                                   'SelectionMode', 'single', ...
                                   'ListString', fields2, ...
                                   'ListSize', [300, 400]);
             
            if tf2 == 0
                warning('Alignment cancelled.');
            else
                targetSigName = fields2{indx2};
                
                fprintf('Aligning S2.%s to S1.%s ...\n', targetSigName, refSigName);
                
                % Extract vectors
                t1_ref = S1.(refSigName).time;
                x1_ref = S1.(refSigName).data;
                t2_ref = S2.(targetSigName).time;
                x2_ref = S2.(targetSigName).data;
                
                % --- Step C: Calculate Shift using estimate_time_shift ---
                maxLagSec = 10005; % Adjust max lag as needed
                doPlotCalc = false; 
                
                try
                    [time_shift, t_grid, x1_grid, x2_shifted, debug_info] = ...
                        estimate_time_shift(t1_ref, x1_ref, t2_ref, x2_ref, doPlotCalc, maxLagSec);
                    
                    fprintf('Estimated Time Shift: %.4f seconds.\n', time_shift);
                    
                    % --- Step D: Apply Shift to ALL S2 Signals ---
                    % Applying the calculated shift to the time vectors of Meas2
                    for k = 1:length(fields2)
                        currSig = fields2{k};
                        if isfield(S2.(currSig), 'time')
                            S2.(currSig).time = S2.(currSig).time + time_shift;
                        end
                    end
                    fprintf('Alignment applied to all signals in Meas2.\n');
                    
                catch ME
                    warning('Alignment failed: %s. Proceeding without alignment.', ME.message);
                    if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
                         warning('Ensure "estimate_time_shift" is in your MATLAB path.');
                    end
                end
            end
        end
    end
end

%% 4. UI for Plot Selection & Layout
% Launch custom UI function defined at bottom of script
[plotConfig, userCancelled] = openPlottingUI(S1, S2, hasMeas2);

if userCancelled
    disp('Plotting cancelled by user.');
    return;
end

%% 5. Plotting Execution
figure('Name', 'Signal Comparison Result', 'Color', 'w');

% Create Tiled Layout based on user input
numPlots = height(plotConfig);
numCols = plotConfig.LayoutCols(1); % Stored in table, same for all rows
t = tiledlayout(ceil(numPlots/numCols), numCols, 'TileSpacing', 'compact', 'Padding', 'compact');
axHandles = [];

for i = 1:numPlots
    ax = nexttile(t);
    hold on;
    axHandles = [axHandles; ax]; %#ok<AGROW>
    
    sig1Name = plotConfig.S1_Signal{i};
    sig2Name = plotConfig.S2_Signal{i};
    
    legends = {};
    
    % Plot S1
    if ~strcmp(sig1Name, 'None')
        plot(S1.(sig1Name).time, S1.(sig1Name).data, 'LineWidth', 1.5, 'DisplayName', ['S1: ' sig1Name]);
        legends{end+1} = ['S1: ' sig1Name];
    end
    
    % Plot S2
    if hasMeas2 && ~strcmp(sig2Name, 'None')
        plot(S2.(sig2Name).time, S2.(sig2Name).data, 'LineWidth', 1.5, 'LineStyle', '--', 'DisplayName', ['S2: ' sig2Name]);
        legends{end+1} = ['S2: ' sig2Name];
    end
    
    grid on;
    ylabel('Amplitude');
    title([sig1Name ' vs ' sig2Name], 'Interpreter', 'none');
    legend('show', 'Interpreter', 'none');
    hold off;
end

% Link axes for zooming
linkaxes(axHandles, 'x');
xlabel(t, 'Time (s)');


%% ---------------------------------------------------------
%  LOCAL FUNCTIONS (Must be at the end of the file)
%  ---------------------------------------------------------

function [configTable, cancelled] = openPlottingUI(S1, S2, hasMeas2)
    % Creates a UI Figure to map signals and define layout
    
    % Get Signal Lists
    list1 = fieldnames(S1);
    if hasMeas2
        list2 = [{'None'}; fieldnames(S2)];
    else
        list2 = {'None'};
    end
    
    % Create UI Figure
    fig = uifigure('Name', 'Plot Configuration', 'Position', [100 100 650 500]);
    
    % Layout Grid
    g = uigridlayout(fig, [5, 2]); % 5 Rows
    g.RowHeight = {'1x', 25, 30, 10, 30}; % Table, Info, Settings, Spacer, Buttons
    g.ColumnWidth = {'1x', '1x'};
    
    % Table for mapping
    % Init Data: [Checkbox(false), S1 Name, S2 Name]
    initData = cell(length(list1), 3);
    for i = 1:length(list1)
        initData{i,1} = false; % Initially NOT selected
        initData{i,2} = list1{i};
        % Auto-match logic
        if hasMeas2 && isfield(S2, list1{i})
            initData{i,3} = list1{i};
        else
            initData{i,3} = 'None';
        end
    end
    
    t = uitable(g);
    t.Layout.Row = 1;
    t.Layout.Column = [1 2];
    t.ColumnName = {'Plot?', 'Meas1 Signal (S1)', 'Meas2 Signal (S2)'};
    t.ColumnEditable = [true, false, true]; % Checkbox editable, S1 fixed
    t.ColumnWidth = {50, 'auto', 'auto'};
    t.Data = initData;
    
    % Try setting Dropdowns (Works in newer MATLAB versions)
    try
        t.ColumnFormat = {'logical', 'char', list2'};
    catch
        % Fallback for older versions
    end

    % Instructions
    lbl = uilabel(g, 'Text', 'Check the box for signals you want to plot.');
    lbl.Layout.Row = 2;
    lbl.Layout.Column = [1 2];
    lbl.FontWeight = 'bold';
    
    % Layout Settings
    lbl2 = uilabel(g, 'Text', 'Number of Columns in Plot:');
    lbl2.HorizontalAlignment = 'right';
    lbl2.Layout.Row = 3; 
    lbl2.Layout.Column = 1;
    
    efCols = uieditfield(g, 'numeric');
    efCols.Layout.Row = 3;
    efCols.Layout.Column = 2;
    efCols.Value = 1; % Default 1 column

    % Buttons
    btnPlot = uibutton(g, 'Text', 'Generate Plots', ...
        'ButtonPushedFcn', @(btn,event) uiresume(fig));
    btnPlot.Layout.Row = 5;
    btnPlot.Layout.Column = 2;
    
    btnCancel = uibutton(g, 'Text', 'Cancel', ...
        'ButtonPushedFcn', @(btn,event) delete(fig));
    btnCancel.Layout.Row = 5;
    btnCancel.Layout.Column = 1;
    
    % Wait for user interaction
    uiwait(fig);
    
    if ~isvalid(fig)
        cancelled = true;
        configTable = [];
    else
        % Extract Data
        rawData = t.Data;
        nCols = efCols.Value;
        delete(fig);
        
        % Filter rows where 'Plot?' (Column 1) is true
        selectedIdx = [rawData{:,1}]'; % Convert logical cell col to logical array
        
        if ~any(selectedIdx)
            cancelled = true;
            configTable = [];
        else
            cancelled = false;
            % Get S1 and S2 columns (2 and 3) for selected rows
            selectedData = rawData(selectedIdx, 2:3);
            configTable = cell2table(selectedData, 'VariableNames', {'S1_Signal', 'S2_Signal'});
            configTable.LayoutCols = repmat(nCols, height(configTable), 1);
        end
    end
end