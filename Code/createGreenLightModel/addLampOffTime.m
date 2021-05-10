function addLampOffTime(gl, lampOffTime)
%ADDLAMPOFFTIME Add a constraint of lamp cool down time to a GreenLight model instance
% Usage:
%   addLampCoolDown(gl, lampOffTime)
% Inputs:
%   gl - a GreenLight model instance
%   coolDownTime - length of time to wait from the moment the lamp has been
%                  switched off until it is allowed to switch back on [s]
%
% For more information, see
%   [1] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % Add parameter for length of time to wait from the moment the lamp has been
    % switched off until it is allowed to switch back on [s]
    addParam(gl, 'cLampOffTime', lampOffTime);
    
    %% Add states for setting lamp off time (Chapter 7 Section 4.11 [1])
    % Trigger for when lamps are switched off [s]
    addState(gl, 'sLampOffTrigger');
    
    % Time since lamps have been last switch off [s]
    addState(gl, 'sSecsSinceLampOff');
    
    %% Set gl.a.lampOn to include constraint on lamp off time
    gl.a.lampOn = (gl.x.sSecsSinceLampOff>=gl.p.cLampOffTime).*gl.a.lampOn;
    
    %% Set ODEs for lamp off time states 
    % Trigger for when lamps are switched off [s]
    % Equation 7.66 [1]
    setOde(gl, 'sLampOffTrigger', ifElse(gl.u.lamp < 0.8, 1, -gl.x.sLampOffTrigger-1));
        % If the lamp is off, sLampOffTrigger is the time since the lamp has been switched off
        % If the lamp is on, sLampOffTrigger is around -1
    
    % Time since lamps have been last switch off [s]
    % Equation 7.67 [1]
    setOde(gl, 'sSecsSinceLampOff', '1');
        % sSecsSinceLampOff is the time since the lamp has been switched off
    
    %% Set initial values for lamp off time states
    % Assume that at the start of the simulation the lamps are allowed to switch on
    setVal(gl.x.sLampOffTrigger, gl.p.cLampOffTime.val);
    setVal(gl.x.sSecsSinceLampOff, gl.p.cLampOffTime.val);
        
    %% Set event for lamp switch off (Chapter 7 Section 2.3.1 [1])
    % Event is trigerred when gl.x.sLampOffTrigger reaches 0 from below
    gl.e(1).condition = gl.x.sLampOffTrigger;
    gl.e(1).direction = 1; 
    
    % When an event is triggered, sLampOffTrigger is set to 1 
    %   and sSecsSinceLampOff is set to 0
    gl.e(1).resetVars = [gl.x.sLampOffTrigger gl.x.sSecsSinceLampOff];
    gl.e(1).resetVals = [1 0];    
end