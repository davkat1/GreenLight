function setParamsBleiswijk2010(gl)
%SETPARAMSBLEISWIJK2010 Modify parameters for a GreenLight model to fit a trial in Bleiswijk, 2010 
% Used in: 
%   Katzin, D., van Mourik, S., Kempkes, F., & 
%       van Henten, E. J. (2020). GreenLight – An open source model for 
%       greenhouses with supplemental lighting: Evaluation of heat requirements 
%       under LED and HPS lamps. Biosystems Engineering, 194, 61–81. 
%       https://doi.org/10.1016/j.biosystemseng.2020.03.010
% Inputs:
%   gl   - a DynamicModel object to be used as a GreenLight model
%
% Based on:
%   [1] Dueck, T., Janse, J., Schapendonk, A. H. C. M., Kempkes, F., 
%       Eveleens, B., Scheffers, K., [...] Marcelis, L. F. M. (2010). 
%       Lichtbenuttig van tomaat onder LED en SON-T belichting. Wageningen.
%   [2] Dueck, T., Janse, J., Eveleens, B. A., Kempkes, F. L. K., 
%       & Marcelis, L. F. M. (2012). Growth of Tomatoes under Hybrid LED 
%       and HPS Lighting. Acta Horticulturae, 1(952), 335–342. 
%       Retrieved from http://edepot.wur.nl/216929

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
                                                % Parameter                                                                                     unit                    Value and reference
                                                
    setParam(gl, 'psi', 23); 					% Mean greenhouse cover slope 																	° 						23 [4]
    setParam(gl, 'aFlr', 144);                  % Floor area of greenhouse 																		m^{2} 					144 [1]
    setParam(gl, 'aCov', 216.6);                % Surface of the cover including side walls                                                     m^{2} 					216.6, taking into account only the parts of the that face the corridor or the outside air (not the neighbouring compartment) [4]
    setParam(gl, 'hAir', 5.7);                  % Height of the main compartment 																m 						5.7 [4]
    setParam(gl, 'hGh', 6.2);                   % Mean height of the greenhouse 																m 						6.2 [4]
    
    setParam(gl, 'aRoof', 52.2);                % Maximum roof ventilation area 																- 						52.2 [4]
    setParam(gl, 'hVent', 0.87);                % Vertical dimension of single ventilation opening 												m 						0.87 [4]
    setParam(gl, 'cLeakage', 0.3e-4); 			% Leakage coefficient 																			- 						0.3e-4 (estimated)
    setParam(gl, 'cDgh', 0.35);                 % Ventilation discharge coefficient 															-                               0.75 [1]
    setParam(gl, 'cWgh', 0.02);                 % Ventilation global wind pressure coefficient 													-                               0.09 [1]
    
    setParam(gl, 'tauRfNir', 0.57); 			% NIR transmission coefficient of the roof 														- 						0.57 [4]
    setParam(gl, 'tauRfPar', 0.57);  			% PAR transmission coefficient of the roof 														- 						0.57 [4]
    setParam(gl, 'tauThScrPar', 0.75); 			% PAR transmission coefficient of thermal screen 												- 						0.75 (estimated)
    setParam(gl, 'kBlScr',5e-4);                % Blackout screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1}    
    setParam(gl, 'kThScr',5e-4);                % Thermal screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1}    5e-5 [1]
    setParam(gl, 'phiPipeI', (51e-3)-(2.25e-3));% Internal diameter of pipes 																	m 						(51-2.25)e-3 [1,4]
    setParam(gl, 'lPipe', 1.3375); 				% Length of heating pipes per gh floor area 													m m^{-2} 				1.3375 [4],  using 1.25 but correcting for extra pipes on the side wall
    setParam(gl, 'pBoil', 44*gl.p.aFlr.val);    % Capacity of the heating system                                                                W                       44*p.aFlr (Assumed to be 88 W m^{-2} for the entire heating system [1])
    setParam(gl, 'phiExtCo2', 720);             % Capacity of external CO2 source 																mg s^{-1} 				720 [1]
    
    setParam(gl, 'epsGroPipe', 0.88);           % Emissivity of grow pipes                                                                  	[-]                     0.88 (same as pipes)
    setParam(gl, 'lGroPipe', 1.655); 			% Length of grow pipes per gh floor area                                                    	m m^{-2}                1.655 [4], using 0.73 but correcting for extra rubber pipes from the roof to the growpipes
    setParam(gl, 'phiGroPipeE', 35e-3); 		% External diameter of grow pipes 																m                       35e-3 [1]
    setParam(gl, 'phiGroPipeI', (35e-3)-(1.2e-3));% Internal diameter of grow pipes 															m                       (35-1.2)e-3 [1,4]
    setParam(gl, 'pBoilGro', 44*gl.p.aFlr.val); % Capacity of the grow pipe heating system                                                      W                       44*p.aFlr (Assumed to be 88 W m^{-2} for the entire heating system [1])
    
    setParam(gl, 'cLeakTop', 0.9);               % Fraction of leakage ventilation going from the top                                            [-]                     
    
    
    setParam(gl, 'cHecIn', 3.5);                % Convective heat exchange between cover and outdoor air 										W m^{-2} K^{-1}                 1.86 [1]
    
    % Reset other parameters that may depend on parameters changed above
    setDepParams(gl);    
end