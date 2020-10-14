function setWorldParams(gl)
%SETWORLDPARAMS Set parameters for running worldwide greenhouse
%   Detailed explanation goes here
    
    setParam(gl, 'psi', 22); 					% Mean greenhouse cover slope 																	° 						25 [1]
    setParam(gl, 'aFlr', 4e4);                  % Floor area of greenhouse 																		m^{2} 					1.4e4 [1]          
    setParam(gl, 'aCov', 4.84e4);                % Surface of the cover including side walls 													m^{2} 					1.8e4 [1]
    setParam(gl, 'hAir', 6.3);                  % Height of the main compartment 																m 						3.8 [1]
    % the ridge height is 6.5, screen is 20 cm below it
    setParam(gl, 'hGh', 6.905);      

    setParam(gl, 'aRoof', 0.1169*4e4);               % Maximum roof ventilation area 																- 						0.1*aFlr [1]
                % can also try 0.18*4e4 (Texas greenhouse in Vanthoor)
    setParam(gl, 'hVent', 1.3);                % Vertical dimension of single ventilation opening 												m 						0.68 [1]
                % this is a lot higher than the gh's in vanthoor
                % but the opening is 60° where in the past it was 30°
    setParam(gl, 'cDgh', 0.75); 				% Ventilation discharge coefficient 															- 						0.75 [1]
                % Texas Vanthoor is 0.65
	
    setParam(gl, 'lPipe', 1.25); % Frank
    
    setParam(gl, 'phiExtCo2', 7.2e4*4e4/1.4e4); % Vanthoor, adjusted to 4 ha
                        % this is 185 kg/ha/hour
    setParam(gl, 'co2SpDay', 1000);
       
    % KWIN says 17.5 night, 18.5 day, the values here are used to get
    % approximately that value
    setParam(gl, 'tSpNight', 18.5); 
    setParam(gl, 'tSpDay', 19.5);
    
    setParam(gl, 'rhMax', 87);
    
    setParam(gl, 'ventHeatPband', 4);
    setParam(gl, 'ventRhPband', 50); 
    
    setParam(gl, 'thScrRhPband', 10);
    
    setParam(gl, 'lampsOn', 0);                 % time of day (in morning) to switch on lamps 													[hours since midnight] 					2
    setParam(gl, 'lampsOff', 18);              	% time of day (in evening) to switch off lamps 													[hours since midnight] 					18
    setParam(gl, 'lampsOffSun', 400);       	% lamps are switched off if global radiation is above this value 								[W m^{-2}]   							200
    setParam(gl, 'lampRadSumLimit', 10);        % Predicted daily radiation sum from the sun where lamps are not used that day                  [MJ m^{-2} day^{-1}]                    10
    
    % big boiler
    setParam(gl, 'pBoil', 300*gl.p.aFlr.val);

end

