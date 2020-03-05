function setGlStates(gl)
%SETGLSTATES Set states for the GreenLight greenhouse model

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % CO2 concentration in main compartment [mg m^{-3}]
    x.co2Air = DynamicElement('x.co2Air');
    
    % CO2 concentration in top compartment [mg m^{-3}]
    x.co2Top = DynamicElement('x.co2Top');
    
    % Air temperature in main compartment [°C]
    x.tAir = DynamicElement('x.tAir');
    
    % Air temperature in top compartment [°C]
    x.tTop = DynamicElement('x.tTop');
    
    % Canopy temperature [°C]
    x.tCan = DynamicElement('x.tCan');
    
    % Indoor cover temperature [°C]
    x.tCovIn = DynamicElement('x.tCovIn');
     
    % Thermal screen temperature [°C]
    x.tThScr = DynamicElement('x.tThScr');
    
    % Floor temperature [°C]
    x.tFlr = DynamicElement('x.tFlr');
    
    % Pipe temperature [°C]
    x.tPipe = DynamicElement('x.tPipe');
    
    % Outdoor cover temperature [°C]
    x.tCovE = DynamicElement('x.tCovE');
    
    % Soil layers temperature [°C]
    x.tSo1 = DynamicElement('x.tSo1');
    x.tSo2 = DynamicElement('x.tSo2');
    x.tSo3 = DynamicElement('x.tSo3');
    x.tSo4 = DynamicElement('x.tSo4');
    x.tSo5 = DynamicElement('x.tSo5');
    
    % Vapor pressure in main compartment [Pa]
    x.vpAir = DynamicElement('x.vpAir');
   
    % Vapor pressure in top compartment [Pa]
    x.vpTop = DynamicElement('x.vpTop');
    
    % Average canopy temperature in last 24 hours [°C]
    x.tCan24 = DynamicElement('x.tCan24');
    
    % Time since beginning simulation [s]
    x.time = DynamicElement('x.time');
    
    % Lamp temperature [°C]
    x.tLamp = DynamicElement('x.tLamp');
    
    % Growpipes temperature [°C]
    x.tGroPipe = DynamicElement('x.tGroPipe');
    
    % Interlights temperature [°C]
    x.tIntLamp = DynamicElement('x.tIntLamp');
    
    % Blackout screen temperature [°C]
    x.tBlScr = DynamicElement('x.tBlScr');
    
    %% Crop model
    
    % Carbohydrates in buffer [mg{CH2O} m^{-2}]
    x.cBuf = DynamicElement('x.cBuf');
    
    % Carbohydrates in leaves [mg{CH2O} m^{-2}]
    x.cLeaf = DynamicElement('x.cLeaf');
    
    % Carbohydrates in stem [mg{CH2O} m^{-2}]
    x.cStem = DynamicElement('x.cStem');
    
    % Carbohydrates in fruit [mg{CH2O} m^{-2}]
    x.cFruit = DynamicElement('x.cFruit');
    
    % Crop development stage [°C day]
    x.tCanSum = DynamicElement('x.tCanSum');
	
	gl.x = x;
end

