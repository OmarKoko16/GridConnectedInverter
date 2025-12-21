function ExcuteStep(StepNr,Time,ModelName)

set_param(ModelName, 'SimulationCommand', 'update');

if ischar(StepNr) || isstring(StepNr)
    Name = StepNr;
else
    Name = ['Step ' num2str(StepNr)];
end
disp(join([Name "--> Ongoing"]));

while true     
    runtime = get_param(ModelName, 'SimulationTime');
    pause(0.1);  % Avoid hammering the CPU end
    if runtime >= Time         
        break;     
    end     
end
disp(join([Name "--> Done"]))
disp('----------------------------');

end