function setGlControlRules(gl)
%SETGLCONTROLRULES Set control rules for the GreenLight greenhouse model.
% Must be used after the params, controls, states, and aux states have been
% defined.
% Inputs:
%   gl       a DynamicModel object to be used as a GreenLight model.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    %% set shorthands for easier reading
    p = gl.p; 
    x = gl.x;
    a = gl.a;
    d = gl.d;
    u = gl.u;
	
    % Controls that are excluded by default
    setDef(u.shScr, '0'); % shading screen is always open (doesn't exist)
    setDef(u.shScrPer, '0'); % permanent shading screen is always open (doesn't exist)
    setDef(u.side, '0'); % side ventilation is always closed (doesn't exist)
    
    % Heating from boiler [0 is no heating, 1 is full heating]
    u.boil = proportionalControl(x.tAir, a.heatSetPoint, p.tHeatBand, 0, 1);
        
    % Heating to grow pipes [0 is no heating, 1 is full heating]
    u.boilGro = proportionalControl(x.tAir, a.heatSetPoint, p.tHeatBand, 0, 1);

    % External CO2 supply [0 is no supply, 1 is full supply]
    u.extCo2 = proportionalControl(a.co2InPpm, a.co2SetPoint, p.co2Band, 0, 1);
    
    % Ventilation from the roof [0 is windows fully closed, 1 is fully open]
    u.roof = min(a.ventCold, max(a.ventHeat,a.ventRh));
    
    % Lighting from the top lights [W m^{-2}]
    setDef(u.lamp, 'a.lampOn');
    
    % Lighting from the interlights [W m^{-2}]
    setDef(u.intLamp, 'a.intLampOn');

    % Thermal screen [0 is open, 1 is closed]
    u.thScr = min(a.thScrCold, min(a.thScrHeat, a.thScrRh));

    % Blackout screen: 1 if screen is closed, 0 if open
    % Screen is closed at night when lamp is on, the constraints for the
    % lamps in lampOn and intLampOn ensure that screen opens if there is
    % excess heat or humidity
    u.blScr = p.useBlScr.*(1-gl.d.isDaySmooth).*max(gl.a.lampOn, gl.a.intLampOn);
    
    % set initial values
    u.boil.val = 0;
    u.boilGro.val = 0;
    u.extCo2.val = 0;
    u.shScr.val = 0;
    u.shScrPer.val = 0;
    u.thScr.val = 1;
    u.roof.val = 0;
    u.side.val = 0;
    u.lamp.val = 0;
    u.intLamp.val = 0;
    u.blScr.val = 0;
    
	gl.u = u;
end