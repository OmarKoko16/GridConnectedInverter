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

% Check if Meas2 needs loading (Only if Meas1 exists)
if exist('Meas1', 'var') && (~exist('Meas2', 'var') || isempty(Meas2))
    fprintf('Meas2 not found. Select file (Optional)...\n');
    % Default path to where Meas1 was found if available, else current
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
            Meas2 = data2.Meas1; % Common case: loading a saved "Meas1" as the comparison
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
% Assumes 'convertDatasetToStruct' is in your path
fprintf('Converting datasets...\n');
S1 = convertDatasetToStruct(Meas1);
hasMeas2 = ~isempty(Meas2);

if hasMeas2
    S2 = convertDatasetToStruct(Meas2);
end

%% 3. Signal Selection GUI
% Get list of signals from Meas1 (The primary dataset)
availableSignals = fieldnames(S1);



% Open Selection Dialog
[indx, tf] = listdlg('PromptString', {'Select signals to plot:', '(Multiselect allowed)'}, ...
                     'SelectionMode', 'multiple', ...
                     'ListString', availableSignals, ...
                     'ListSize', [300, 400]);

if tf == 0
    disp('Selection cancelled.');
else
    selectedSignals = availableSignals(indx);
    
    %% 4. Plotting
    % Create a new figure for the plots
 %% 4. Plotting
    figure('Name', 'Signal Comparison', 'Color', 'w');
    
    numPlots = length(selectedSignals);
    ax = gobjects(numPlots, 1); % Pre-allocate array for axes handles
    
    for i = 1:numPlots
        sigName = selectedSignals{i};
        
        % Create subplot and save the handle to 'ax' array
        ax(i) = subplot(numPlots, 1, i);
        hold on;
        
        % --- Plot Meas1 ---
        p1 = plot(S1.(sigName).time, S1.(sigName).data, 'LineWidth', 1.5);
        displayName1 = ['Meas1: ', S1.(sigName).name];
        
        % --- Plot Meas2 ---
        if hasMeas2 && isfield(S2, sigName)
             p2 = plot(S2.(sigName).time, S2.(sigName).data, 'LineWidth', 1.5);
             displayName2 = ['Meas2: ', S2.(sigName).name];
             legend([p1, p2], {displayName1, displayName2}, 'Interpreter', 'none');
        else
             legend(p1, {displayName1}, 'Interpreter', 'none');
        end
        
        grid on;
        title(sigName, 'Interpreter', 'none');
        % Remove x-labels for all but the bottom plot for a cleaner look
        if i < numPlots
            xticklabels([]);
        else
            xlabel('Time (s)');
        end
        hold off;
    end
    
    % --- LINK AXES HERE ---
    linkaxes(ax, 'x');
end
