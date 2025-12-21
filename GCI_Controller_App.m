function GCI_Controller_Smart
    % 1. Create the main UI Figure
    fig = uifigure('Name', 'GCI Controller Interface', 'Position', [100 100 500 500]);
    
    % MAIN LAYOUT: 2 Rows (Content, Button), 1 Column
    % This ensures the button sits at the bottom and never overlaps the panels.
    mainGrid = uigridlayout(fig, [2, 1]);
    mainGrid.RowHeight = {'1x', 60}; % Content expands, Button area fixed height
    mainGrid.Padding = [10 10 10 10];

    % --- CONTENT AREA (Row 1) ---
    contentGrid = uigridlayout(mainGrid, [1, 2]);
    contentGrid.ColumnWidth = {'1x', '1x'};
    
    % Initialize "Committed" State (The values currently in the model)
    % We use this to compare against the UI to see if changes occurred.
    committedState = struct(...
        'ModReq', true, ...
        'FrcPwr', true, ...
        'Test', false, ...
        'EnableMonitors', false, ...
        'PorISel', false, ...
        'IdSp', 0, ...
        'IqSp', 0, ...
        'PSp', 0, ...
        'QSp', 0 ...
    );

    % --- LEFT PANEL: SWITCHES ---
    pnlLeft = uipanel(contentGrid, 'Title', 'Logic Control');
    pnlLeft.Layout.Column = 1;
    layoutLeft = uigridlayout(pnlLeft, [5, 2]);
    layoutLeft.ColumnWidth = {'1x', 'fit'};

    % Switch Helper (Adds switch and attaches the change listener)
    function h = addSwitch(parent, labelText, fieldName)
        uilabel(parent, 'Text', labelText, 'HorizontalAlignment', 'right');
        h = uiswitch(parent, 'Items', {'False', 'True'});
        
        % Set initial value based on committed state
        if committedState.(fieldName)
            h.Value = 'True';
        else
            h.Value = 'False';
        end
        
        % When changed, check if we need to enable the update button
        h.ValueChangedFcn = @(src, event) checkForChanges();
    end

    sw_ModReq = addSwitch(layoutLeft, 'ModReq', 'ModReq');
    sw_FrcPwr = addSwitch(layoutLeft, 'FrcPwr', 'FrcPwr');
    sw_Test   = addSwitch(layoutLeft, 'Test Mode', 'Test');
    sw_Mon    = addSwitch(layoutLeft, 'Enable Monitors', 'EnableMonitors');
    sw_PorI   = addSwitch(layoutLeft, 'PorISel', 'PorISel');

    % --- RIGHT PANEL: NUMERIC INPUTS ---
    pnlRight = uipanel(contentGrid, 'Title', 'Signal Setpoints');
    pnlRight.Layout.Column = 2;
    layoutRight = uigridlayout(pnlRight, [4, 1]);
    layoutRight.RowHeight = {'fit', 'fit', 'fit', 'fit'};
    
    % Numeric Helper (Adds field and attaches listener)
    function ef = addNumeric(parent, labelText, fieldName)
        subGrid = uigridlayout(parent, [2,1]);
        subGrid.RowHeight = {'fit', 'fit'};
        subGrid.Padding = [0 5 0 5];
        
        uilabel(subGrid, 'Text', labelText, 'FontWeight', 'bold');
        ef = uieditfield(subGrid, 'numeric');
        ef.Value = committedState.(fieldName); 
        ef.ValueDisplayFormat = '%.2f';
        
        % When changed, check if we need to enable the update button
        ef.ValueChangedFcn = @(src, event) checkForChanges();
    end

    ef_IdSp = addNumeric(layoutRight, 'Id Setpoint (IdSp)', 'IdSp');
    ef_IqSp = addNumeric(layoutRight, 'Iq Setpoint (IqSp)', 'IqSp');
    ef_PSp  = addNumeric(layoutRight, 'Active Power (PSp)', 'PSp');
    ef_QSp  = addNumeric(layoutRight, 'Reactive Power (QSp)', 'QSp');

    % --- BOTTOM AREA: UPDATE BUTTON (Row 2) ---
    % Centered button layout
    btnLayout = uigridlayout(mainGrid, [1, 1]); 
    btnLayout.Layout.Row = 2;
    
    btnUpdate = uibutton(btnLayout, 'push', ...
        'Text', 'No Changes to Update', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'Enable', 'off', ... % Start DISABLED
        'BackgroundColor', [0.8 0.8 0.8], ... % Start GREY
        'ButtonPushedFcn', @(btn,event) pushToSimulink());

    % --- LOGIC: CHECK FOR CHANGES ---
    function checkForChanges()
        % 1. Gather current UI values
        currentUI.ModReq = strcmp(sw_ModReq.Value, 'True');
        currentUI.FrcPwr = strcmp(sw_FrcPwr.Value, 'True');
        currentUI.Test   = strcmp(sw_Test.Value, 'True');
        currentUI.EnableMonitors = strcmp(sw_Mon.Value, 'True');
        currentUI.PorISel = strcmp(sw_PorI.Value, 'True');
        
        currentUI.IdSp = ef_IdSp.Value;
        currentUI.IqSp = ef_IqSp.Value;
        currentUI.PSp  = ef_PSp.Value;
        currentUI.QSp  = ef_QSp.Value;
        
        % 2. Compare UI vs Committed State
        isDirty = ~isequal(currentUI, committedState);
        
        % 3. Update Button Appearance
        if isDirty
            btnUpdate.Enable = 'on';
            btnUpdate.BackgroundColor = [0 0.45 0.74]; % Blue
            btnUpdate.FontColor = 'white';
            btnUpdate.Text = 'UPDATE MODEL';
        else
            btnUpdate.Enable = 'off';
            btnUpdate.BackgroundColor = [0.8 0.8 0.8]; % Grey
            btnUpdate.FontColor = [0.4 0.4 0.4];
            btnUpdate.Text = 'No Changes to Update';
        end
    end

    % --- LOGIC: PUSH TO SIMULINK ---
    function pushToSimulink()
        try
            % 1. Get Values
            val_ModReq = strcmp(sw_ModReq.Value, 'True');
            val_FrcPwr = strcmp(sw_FrcPwr.Value, 'True');
            val_Test   = strcmp(sw_Test.Value, 'True');
            val_Mon    = strcmp(sw_Mon.Value, 'True');
            val_PorI   = strcmp(sw_PorI.Value, 'True');

            val_IdSp = single(ef_IdSp.Value);
            val_IqSp = single(ef_IqSp.Value);
            val_PSp  = single(ef_PSp.Value);
            val_QSp  = single(ef_QSp.Value);

            % 2. Assign to Workspace
            assignin('base', 'ModReq', val_ModReq);
            assignin('base', 'FrcPwr', val_FrcPwr);
            assignin('base', 'Test', val_Test);
            assignin('base', 'EnableMonitors', val_Mon);
            assignin('base', 'PorISel', val_PorI);

            assignin('base', 'IdSp', val_IdSp);
            assignin('base', 'IqSp', val_IqSp);
            assignin('base', 'PSp', val_PSp);
            assignin('base', 'QSp', val_QSp);

            % 3. Update Model
            modelName = 'GCI_Ctrl_PLL_C2000';
            if bdIsLoaded(modelName)
                 set_param(modelName, 'SimulationCommand', 'update');
            end

            % 4. COMMIT THE STATE
            % Now that we pushed, the "committed" state is equal to the current UI
            committedState.ModReq = val_ModReq;
            committedState.FrcPwr = val_FrcPwr;
            committedState.Test   = val_Test;
            committedState.EnableMonitors = val_Mon;
            committedState.PorISel = val_PorI;
            
            committedState.IdSp = double(val_IdSp); % Store as double for UI comparison
            committedState.IqSp = double(val_IqSp);
            committedState.PSp  = double(val_PSp);
            committedState.QSp  = double(val_QSp);

            % 5. Re-check (This will disable the button since states now match)
            checkForChanges();
            
        catch ME
             uialert(fig, ME.message, 'Update Failed', 'Icon', 'error');
        end
    end
end