function setParams4haWorldComparison(gl)
%SETPARAMS4HAWORLDCOMPARISON Set parameters for GreenLight model of a modern 4 ha greenhouse with settings used to compare greenhouses around the world
% Used to generate the data in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019
%
% References:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J., & de Visser, P. H. B. (2011). 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse 
%       climate model for a broad range of designs and climates. 
%       Biosystems Engineering, 110(4), 363–377. https://doi.org/10.1016/j.biosystemseng.2011.06.001
%       (In particular, settings for Dutch greenhouse in electronic appendix)
%   [2] Raaphorst, M., Benninga, J., & Eveleens, B. A. (2019). 
%       Quantitative information on Dutch greenhouse horticulture 2019. Bleiswijk.
%   [3] De Zwart, H. F. (1996). Analyzing energy-saving options in greenhouse 
%       cultivation using a simulation model. Landbouwuniversiteit Wageningen.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % Parameter                                 Meaning                                                                                         Unit                    Value in paper
    setParam(gl, 'psi', 22); 					% Mean greenhouse cover slope 																	° 						22
    setParam(gl, 'aFlr', 4e4);                  % Floor area of greenhouse 																		m^{2} 					4e4
    setParam(gl, 'aCov', 4.84e4);               % Surface of the cover including side walls 													m^{2} 					4.84e4
    setParam(gl, 'hAir', 6.3);                  % Height of the main compartment 																m 						6.3
        % the ridge height is 6.5, screen is 20 cm below it
    setParam(gl, 'hGh', 6.905);                 % Average height of greenhouse                                                                  m                       6.905
        % Each triangle in the greenhouse roof has width 4m, angle 22°, so
        % height of 0.81m. The ridge is 6.5 m high
    setParam(gl, 'aRoof', 0.1169*4e4);          % Maximum roof ventilation area 																- 						0.1169*4e4
        % A greenhouse roof segment is composed of 6 panels of glass
        % measuring 1.67m x 2.16m. This segment totals (1.67x3)x(2.16x2) =
        % 5x4.32 = 21.6 m^2. This segment lies above a floor segment of
        % 5x4 = 20 m^2. 
        % In this segment, one panel has a window sized 1.67m x 1.4m. 
        % This makes the relative roof area 1.4x1.67/20 = 0.1169
    setParam(gl, 'hVent', 1.3);                % Vertical dimension of single ventilation opening 												m 						1.3
        % A length of a roof segment is 1.4m, and the maximum opening angle
        % is 60°
    setParam(gl, 'cDgh', 0.75); 				% Ventilation discharge coefficient 															- 						0.75 [1]
                
    setParam(gl, 'lPipe', 1.25);                % Length of heating pipes per gh floor area 													m m^{-2} 				1.25
        % In an 8m trellis there are 5 paths of 1.6m with two lines of
        % pipes. In a greenhouse segment of 1.6m x 200m, there is a length
        % of 200m x 2 of pipes. 2/1.6 = 1.25
    setParam(gl, 'phiExtCo2', 7.2e4*4e4/1.4e4); % Capacity of external CO2 source 																mg s^{-1} 				7.2e4*4e4/1.4e4
                        % this is 185 kg/ha/hour, based on [1] and adjusted to 4 ha
    setParam(gl, 'co2SpDay', 1000);             % Co2 is supplied if co2 is below this point during day 										[ppm]       							1000 [2]
       
    setParam(gl, 'tSpNight', 18.5);             % Heat is on below this point in night           												[°C]                   					18.5
    setParam(gl, 'tSpDay', 19.5);               % Heat is on below this point in day           													[°C]                                    19.5
        % [2] says 17.5 night, 18.5 day, the values here are used to get
        % approximately that value in practice

    setParam(gl, 'rhMax', 87);                  % upper bound on relative humidity              												[%]                     				87 [2]
    
    setParam(gl, 'ventHeatPband', 4);           % P-band for ventilation due to excess heat 													[°C] 									4
    setParam(gl, 'ventRhPband', 50);            % P-band for ventilation due to relative humidity 												[%] 									50 [3]
    
    setParam(gl, 'thScrRhPband', 10);           % P-band for thermal screen opening due to excess relative humidity 							[%] 									10
    
    setParam(gl, 'lampsOn', 0);                 % time of day (in morning) to switch on lamps 													[hours since midnight] 					0
    setParam(gl, 'lampsOff', 18);              	% time of day (in evening) to switch off lamps 													[hours since midnight] 					18
    setParam(gl, 'lampsOffSun', 400);       	% lamps are switched off if global radiation is above this value 								[W m^{-2}]   							400
    setParam(gl, 'lampRadSumLimit', 10);        % Predicted daily radiation sum from the sun where lamps are not used that day                  [MJ m^{-2} day^{-1}]                    10
    
    % big boiler
    setParam(gl, 'pBoil', 300*gl.p.aFlr.val);   % Capacity of the heating system                                                                W                                       300*p.aFlr

end