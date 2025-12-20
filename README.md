# GridConnectedInverter
MATLAB/Simulink model of a grid-connected inverter with dq-frame control, PLL synchronization, and parameterized power and current control loops.

This repository contains a detailed MATLAB/Simulink model of a three-phase grid-connected voltage source inverter (VSI) with advanced control architecture. The model is intended for research, academic, and industrial applications related to renewable energy systems, microgrids, and power electronics.

The control structure is based on synchronous reference frame (dq) control and includes:

Phase-Locked Loop (PLL) for grid synchronization

Inner current control loop (dq-axis)

Outer power/DC-link voltage control loop

Pulse Width Modulation (PWM) generation

LCL filter modeling and grid interface

The project supports parameterized simulation, making it suitable for controller tuning, stability analysis, and performance comparison between conventional PI control and advanced or adaptive control strategies.

Tools & Technologies

MATLAB / Simulink

Control System Toolbox

Simscape Electrical (optional)

Applications

Renewable energy grid integration

EV charging infrastructure

Power electronics control design

Academic research and teaching
