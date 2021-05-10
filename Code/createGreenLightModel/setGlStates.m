function setGlStates(gl)
%SETGLSTATES Set states for the GreenLight greenhouse model
% See setGlOdes for equations and references

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % CO2 concentration in main compartment [mg m^{-3}]
    addState(gl, 'co2Air');
    
    % CO2 concentration in top compartment [mg m^{-3}]
    addState(gl, 'co2Top');
    
    % Air temperature in main compartment [°C]
    addState(gl, 'tAir');
    
    % Air temperature in top compartment [°C]
    addState(gl, 'tTop');
    
    % Canopy temperature [°C]
    addState(gl, 'tCan');
    
    % Indoor cover temperature [°C]
    addState(gl, 'tCovIn');
     
    % Thermal screen temperature [°C]
    addState(gl, 'tThScr');
    
    % Floor temperature [°C]
    addState(gl, 'tFlr');
    
    % Pipe temperature [°C]
    addState(gl, 'tPipe');
    
    % Outdoor cover temperature [°C]
    addState(gl, 'tCovE');
    
    % Soil layers temperature [°C]
    addState(gl, 'tSo1');
    addState(gl, 'tSo2');
    addState(gl, 'tSo3');
    addState(gl, 'tSo4');
    addState(gl, 'tSo5');
    
    % Vapor pressure in main compartment [Pa]
    addState(gl, 'vpAir');
   
    % Vapor pressure in top compartment [Pa]
    addState(gl, 'vpTop');
    
    % Average canopy temperature in last 24 hours [°C]
    addState(gl, 'tCan24');
    
    % Time since beginning simulation [s]
    addState(gl, 'time');
    
    % Lamp temperature [°C]
    addState(gl, 'tLamp');
    
    % Growpipes temperature [°C]
    addState(gl, 'tGroPipe');
    
    % Interlights temperature [°C]
    addState(gl, 'tIntLamp');
    
    % Blackout screen temperature [°C]
    addState(gl, 'tBlScr');
        
    %% Crop model
    
    % Carbohydrates in buffer [mg{CH2O} m^{-2}]
    addState(gl, 'cBuf');
    
    % Carbohydrates in leaves [mg{CH2O} m^{-2}]
    addState(gl, 'cLeaf');
    
    % Carbohydrates in stem [mg{CH2O} m^{-2}]
    addState(gl, 'cStem');
    
    % Carbohydrates in fruit [mg{CH2O} m^{-2}]
    addState(gl, 'cFruit');
    
    % Crop development stage [°C day]
    addState(gl, 'tCanSum');
end