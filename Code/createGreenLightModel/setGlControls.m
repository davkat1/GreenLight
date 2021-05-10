function u = setGlControls(gl)
%SETGLCONTROLS Set controls for the GreenLight greenhouse model

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % Boiler valve [-] 
    % 0-1, where 1 is full capacity and 0 is off
    u.boil = DynamicElement('u.boil');
    
    % External CO2 source valve [-]
    % 0-1, where 1 is full capacity and 0 is off
    u.extCo2 = DynamicElement('u.extCo2');
    
    % Closure of shading screen [-]
    % 0 is open (folded screen), 1 is closed (spread out screen)
    u.shScr = DynamicElement('u.shScr');
    
    % Closure of semi permanent shading screen [-]
    % 0 is open (folded screen), 1 is closed (spread out screen)
    u.shScrPer = DynamicElement('u.shScrPer');
    
    % Closure of thermal screen [-]
    % 0 is open (folded screen), 1 is closed (spread out screen)
    u.thScr = DynamicElement('u.thScr');
    
    % Roof ventilation aperture [-]
    % 0 is closed (no ventilation), 1 is open (maximal ventilation)
    u.roof = DynamicElement('u.roof');
    
    % Side ventilation aperture [-]
    % 0 is closed (no ventilation), 1 is open (maximal ventilation)
    u.side = DynamicElement('u.side');
    
    % Lamp status [-, 0 is off, 1 is on]
    u.lamp = DynamicElement('u.lamp');
    
    % Interlights status [-, 0 is off, 1 is on]
    u.intLamp = DynamicElement('u.intLamp');
    
    % Boiler grow pipes valve [-] 
    % 0-1, where 1 is full capacity and 0 is off
    u.boilGro = DynamicElement('u.boilGro');    
    
    % Closure of blackout screen [-]
    % 0 is open (folded screen), 1 is closed (spread out screen)
    u.blScr = DynamicElement('u.blScr');
    
	gl.u = u;
end

