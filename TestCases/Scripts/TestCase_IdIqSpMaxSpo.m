disp(['Test Start']);
%% Set initial value
ModReq = boolean(0);
FrcPwr = boolean(false);
Test =  boolean(false);
EnableMonitors = boolean( true);
PorISel = boolean(1);
IdSp = single(0);
IqSp = single( 0);
set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');
set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationMode', 'accelerator');
set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'start');

disp(['Step Init']);

while true     
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 1         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end
disp(['Step Init Done']);
%% Step 1
ModReq = boolean(1);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step 1']);

while true
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 2
        break;
    end
    pause(0.01);  % Avoid hammering the CPU
end
disp(['Step 1 Done']);
%% Step 2.1
IdSp = single(50);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step 2.1']);
 
while true     
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 3         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end
disp(['Step 2.1 Done']);
%% Step 2.2
ModReq = boolean(0);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step 2.2']);

while true     
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 4         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end
disp(['Step 2.2 Done']);
%% Step 3.1
ModReq = boolean(1);
IdSp = single(0);
IqSp = single(50);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step 3.1']);

while true     
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 5         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end
disp(['Step 3.1 Done']);    
%% Step 3.2
ModReq = boolean(0);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step 3.2']);
while true     
   if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 6         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end
disp(['Step 3.2 Done']);
%% Step Last
ModReq = boolean(0);
IqSp = single(0);

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'update');

disp(['Step Last']);

while true     
    if get_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationTime') >= 7         
        break;     
    end     
    pause(0.01);  % Avoid hammering the CPU end
end

set_param('GCI_Ctrl_PLL_C2000_V1_1', 'SimulationCommand', 'stop');

disp(['Test Done']);