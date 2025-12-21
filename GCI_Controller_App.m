function GCI_Controller_Monitor
    % 1. Create the main UI Figure
    fig = uifigure('Name', 'GCI Controller Interface', 'Position', [100 100 780 550]);
    
    % Setup Cleanup to stop timer when app closes
    fig.CloseRequestFcn = @(src, event) appCloseRequest(src);

    % MAIN LAYOUT: 2 Rows (Content, Button)
    mainGrid = uigridlayout(fig, [2, 1]);
    mainGrid.RowHeight = {'1x', 60}; 
    mainGrid.Padding = [10 10 10 10];

    % --- CONTENT AREA (Row 1): 3 COLUMNS ---
    contentGrid = uigridlayout(mainGrid, [1, 3]);
    contentGrid.ColumnWidth = {'1x', '1x', '1.2x'}; 
    
    % --- SHARED STATE ---
    committedState = struct('ModReq',true, 'FrcPwr',true, 'Test',false, 'EnableMonitors',false, 'PorISel',false, ...
                            'IdSp',0, 'IqSp',0, 'PSp',0, 'QSp',0);

    % ---------------------------------------------------------
    % PANEL 1: LOGIC CONTROLS (Left)
    % ---------------------------------------------------------
    pnlLeft = uipanel(contentGrid, 'Title', 'Logic Control');
    pnlLeft.Layout.Column = 1;
    layoutLeft = uigridlayout(pnlLeft, [5, 2]);
    layoutLeft.ColumnWidth = {'1x', 'fit'};

    sw_ModReq = addSwitch(layoutLeft, 'ModReq', 'ModReq');
    sw_FrcPwr = addSwitch(layoutLeft, 'FrcPwr', 'FrcPwr');
    sw_Test   = addSwitch(layoutLeft, 'Test Mode', 'Test');
    sw_Mon    = addSwitch(layoutLeft, 'Enable Monitors', 'EnableMonitors');
    sw_PorI   = addSwitch(layoutLeft, 'PorISel', 'PorISel');

    % ---------------------------------------------------------
    % PANEL 2: SIGNAL SETPOINTS (Middle)
    % ---------------------------------------------------------
    pnlMid = uipanel(contentGrid, 'Title', 'Signal Setpoints');
    pnlMid.Layout.Column = 2;
    layoutMid = uigridlayout(pnlMid, [4, 1]);
    layoutMid.RowHeight = {'fit', 'fit', 'fit', 'fit'};

    ef_IdSp = addNumeric(layoutMid, 'Id Setpoint (IdSp)', 'IdSp');
    ef_IqSp = addNumeric(layoutMid, 'Iq Setpoint (IqSp)', 'IqSp');
    ef_PSp  = addNumeric(layoutMid, 'Active Power (PSp)', 'PSp');
    ef_QSp  = addNumeric(layoutMid, 'Reactive Power (QSp)', 'QSp');

    % ---------------------------------------------------------
    % PANEL 3: LIVE MONITOR (Right)
    % ---------------------------------------------------------
    pnlRight = uipanel(contentGrid, 'Title', 'System Status (Outputs)');
    pnlRight.Layout.Column = 3;
    pnlRight.BackgroundColor = [0.95 0.95 0.95];
    
    layoutRight = uigridlayout(pnlRight, [8, 2]);
    layoutRight.ColumnWidth = {'2x', '1x'};
    layoutRight.RowHeight = {'fit','fit','fit', '1x', 'fit','fit','fit','fit'};

    % -- SECTION A: Measurements --
    addHeader(layoutRight, 'Measurements');
    disp_Irms = addDisplay(layoutRight, 'Irms (A)');
    disp_Vdc  = addDisplay(layoutRight, 'Vdc (V)');
    disp_Vrms = addDisplay(layoutRight, 'Vrms (V)');
    
    % -- SECTION B: Error Codes --
    addHeader(layoutRight, 'Error Codes');
    disp_FailSw = addDisplay(layoutRight, 'FailSw (uint16)');
    disp_FailHw = addDisplay(layoutRight, 'FailHw (uint8)');

    % -- SECTION C: Flags --
    addHeader(layoutRight, 'Flags');
    lamp_Fail    = addLamp(layoutRight, 'System Fail', [0.8 0 0]); 
    lamp_SafeSt  = addLamp(layoutRight, 'Safe State', [0 0.8 0]); 
    lamp_CtrlEn  = addLamp(layoutRight, 'Control Enabled', [0 0.8 0]);
    lamp_PllEnFb = addLamp(layoutRight, 'PLL Feedback', [0 0.8 0]);
    lamp_Synch   = addLamp(layoutRight, 'Synchronized', [0 0.8 0]);

    % ---------------------------------------------------------
    % BOTTOM AREA: UPDATE BUTTON
    % ---------------------------------------------------------
    btnLayout = uigridlayout(mainGrid, [1, 1]); 
    btnLayout.Layout.Row = 2;
    
    btnUpdate = uibutton(btnLayout, 'push', ...
        'Text', 'No Changes to Update', ...
        'FontSize', 14, ...
        'FontWeight', 'bold', ...
        'Enable', 'off', ... 
        'BackgroundColor', [0.8 0.8 0.8], ... 
        'ButtonPushedFcn', @(btn,event) pushToSimulink());

    % ---------------------------------------------------------
    % TIMER SETUP
    % ---------------------------------------------------------
    t = timer;
    t.Period = 1; 
    t.ExecutionMode = 'fixedRate';
    t.TimerFcn = @(~,~) refreshMonitors();
    start(t);

    % =========================================================
    % NESTED FUNCTIONS
    % =========================================================
    
    function refreshMonitors()
        try
            % Update Displays
            disp_Irms.Value = double(getVar('Irms'));
            disp_Vdc.Value  = double(getVar('Vdc'));
            disp_Vrms.Value = double(getVar('Vrms'));
            disp_FailSw.Value = double(getVar('FailSw'));
            disp_FailHw.Value = double(getVar('FailHw'));

            % Update Lamps
            updateLamp(lamp_Fail,   getVar('Fail'));
            updateLamp(lamp_SafeSt, getVar('SafeSt'));
            updateLamp(lamp_CtrlEn, getVar('CtrlEn'));
            updateLamp(lamp_PllEnFb,getVar('PllEnFb'));
            updateLamp(lamp_Synch,  getVar('Synch'));
        catch
            % Suppress errors during refresh
        end
    end

    function val = getVar(name)
        % Helper to safely get value from Base Workspace
        try
            val = evalin('base', name);
            if numel(val) > 1, val = val(end); end
        catch
            val = 0; 
        end
    end

    function updateLamp(lampHandle, value)
        if value
            lampHandle.Color = lampHandle.UserData; 
        else
            lampHandle.Color = [0.9 0.9 0.9]; 
        end
    end

    function checkForChanges()
        currentUI.ModReq = strcmp(sw_ModReq.Value, 'True');
        currentUI.FrcPwr = strcmp(sw_FrcPwr.Value, 'True');
        currentUI.Test   = strcmp(sw_Test.Value, 'True');
        currentUI.EnableMonitors = strcmp(sw_Mon.Value, 'True');
        currentUI.PorISel = strcmp(sw_PorI.Value, 'True');
        
        currentUI.IdSp = ef_IdSp.Value;
        currentUI.IqSp = ef_IqSp.Value;
        currentUI.PSp  = ef_PSp.Value;
        currentUI.QSp  = ef_QSp.Value;
        
        if ~isequal(currentUI, committedState)
            btnUpdate.Enable = 'on';
            btnUpdate.BackgroundColor = [0 0.45 0.74]; 
            btnUpdate.FontColor = 'white';
            btnUpdate.Text = 'UPDATE MODEL';
        else
            btnUpdate.Enable = 'off';
            btnUpdate.BackgroundColor = [0.8 0.8 0.8]; 
            btnUpdate.FontColor = [0.4 0.4 0.4];
            btnUpdate.Text = 'No Changes to Update';
        end
    end

    function pushToSimulink()
        try
            % 1. Get Values from UI
            val_ModReq = strcmp(sw_ModReq.Value, 'True');
            val_FrcPwr = strcmp(sw_FrcPwr.Value, 'True');
            val_Test   = strcmp(sw_Test.Value, 'True');
            val_Mon    = strcmp(sw_Mon.Value, 'True');
            val_PorI   = strcmp(sw_PorI.Value, 'True');

            val_IdSp = single(ef_IdSp.Value);
            val_IqSp = single(ef_IqSp.Value);
            val_PSp  = single(ef_PSp.Value);
            val_QSp  = single(ef_QSp.Value);

            % 2. Push to Base Workspace
            assignin('base', 'ModReq', val_ModReq);
            assignin('base', 'FrcPwr', val_FrcPwr);
            assignin('base', 'Test', val_Test);
            assignin('base', 'EnableMonitors', val_Mon);
            assignin('base', 'PorISel', val_PorI);

            assignin('base', 'IdSp', val_IdSp);
            assignin('base', 'IqSp', val_IqSp);
            assignin('base', 'PSp', val_PSp);
            assignin('base', 'QSp', val_QSp);

            % 3. Update Model Command
            modelName = 'GCI_Ctrl_PLL_C2000';
            if bdIsLoaded(modelName)
                 set_param(modelName, 'SimulationCommand', 'update');
            end

            % 4. Update committed state
            committedState.ModReq = val_ModReq;
            committedState.FrcPwr = val_FrcPwr;
            committedState.Test   = val_Test;
            committedState.EnableMonitors = val_Mon;
            committedState.PorISel = val_PorI;
            committedState.IdSp = double(val_IdSp);
            committedState.IqSp = double(val_IqSp);
            committedState.PSp  = double(val_PSp);
            committedState.QSp  = double(val_QSp);

            checkForChanges();
            
        catch ME
             uialert(fig, ME.message, 'Update Failed', 'Icon', 'error');
        end
    end

    function appCloseRequest(fig)
        stop(t);
        delete(t);
        delete(fig);
    end

    % --- UI CREATION HELPERS ---
    function h = addSwitch(parent, labelText, fieldName)
        uilabel(parent, 'Text', labelText, 'HorizontalAlignment', 'right');
        h = uiswitch(parent, 'Items', {'False', 'True'});
        % Fix for Case Sensitivity: explicitly map logical to 'True'/'False'
        if committedState.(fieldName)
            h.Value = 'True';
        else
            h.Value = 'False';
        end
        h.ValueChangedFcn = @(src, event) checkForChanges();
    end

    function ef = addNumeric(parent, labelText, fieldName)
        subGrid = uigridlayout(parent, [2,1]);
        subGrid.RowHeight = {'fit', 'fit'};
        subGrid.Padding = [0 5 0 5];
        uilabel(subGrid, 'Text', labelText, 'FontWeight', 'bold');
        ef = uieditfield(subGrid, 'numeric');
        ef.Value = committedState.(fieldName); 
        ef.ValueDisplayFormat = '%.2f';
        ef.ValueChangedFcn = @(src, event) checkForChanges();
    end

    function ef = addDisplay(parent, labelText)
        uilabel(parent, 'Text', labelText, 'HorizontalAlignment', 'right');
        ef = uieditfield(parent, 'numeric', 'Editable', 'off'); 
        ef.ValueDisplayFormat = '%.2f';
        ef.BackgroundColor = [0.9 0.9 0.9];
    end

    function lamp = addLamp(parent, labelText, activeColor)
        uilabel(parent, 'Text', labelText, 'HorizontalAlignment', 'right');
        lamp = uilamp(parent);
        lamp.Color = [0.9 0.9 0.9]; 
        lamp.UserData = activeColor;
    end

    function addHeader(parent, text)
        lbl = uilabel(parent, 'Text', text, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        lbl.Layout.Column = [1 2]; 
    end

end