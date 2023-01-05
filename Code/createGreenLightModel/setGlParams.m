function setGlParams(gl)
%SETGLPARAMS Set parameters for a GreenLight model. Use that parameters from Vanthoor (2011)
% Inputs:
%   gl   - a DynamicModel object to be used as a GreenLight model
%
% Based on the electronic appendices (the case of a Dutch greenhouse) of:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378-395 (2011).
% These are also available as Chapters 8 and 9, respecitvely, of
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
% Control decisions are based on:
% 	[4] Vanthoor, B., van Henten, E.J., Stanghellini, C., and de Visser, P.H.B. (2011). 
% 		A methodology for model-based greenhouse design: Part 3, sensitivity 
% 		analysis of a combined greenhouse climate-crop yield model. 
% 		Biosyst. Eng. 110, 396-412.
% 	[5] Vermeulen, P.C.M. (2016). Kwantitatieve informatie voor de glastuinbouw 
% 		2016-2017 (Bleiswijk), page V56-V58 Vine tomato
%   [6] Dueck, T., Elings, A., Kempkes, F., Knies, P., Garcia, N., Heij, G., 
% 		Janse, J., Kaarsemaker, R., Korsten, P., Maaswinkel, R., et al. (2004). 
% 		Energie in kengetallen : op zoek naar een nieuwe balans.
% Several other parameters are based on:
%   [7] Dueck, T., De Gelder, A., Janse, J., Kempkes, F., Baar, P.H., and 
%       Valstar, W. (2014). Het nieuwe belichten onder diffuus glas (Wageningen).
%   [8] Katzin, D., van Mourik, S., Kempkes, F., & Van Henten, E. J. (2020). 
%       GreenLight - An open source model for greenhouses with supplemental 
%       lighting: Evaluation of heat requirements under LED and HPS lamps. 
%       Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
%   [9] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434
%   [10] Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%        Energy savings in greenhouses by transition from high-pressure sodium 
%        to LED lighting. Applied Energy, 281, 116019. 
%        https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com


	%% Table 1 [1]
	% General model parameters

	%% Pg. 39 [1]

	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'alfaLeafAir',5); 				% Convective heat exchange coefficient from the canopy leaf to the greenhouse air 				W m^{-2} K^{-1} 		5 [1]
	addParam(gl, 'L', 2.45e6); 					% Latent heat of evaporation 																	J kg^{-1}{water} 		2.45e6 [1]			
    addParam(gl, 'sigma', 5.67e-8); 			% Stefan-Boltzmann constant 																	W m^{-2} K^{-4} 		5.67e-8 [1]
	addParam(gl, 'epsCan', 1); 					% FIR emission coefficient of canopy 															-   					1 [1]
	addParam(gl, 'epsSky', 1); 					% FIR emission coefficient of the sky 															- 						1 [1]
	addParam(gl, 'etaGlobNir', 0.5); 			% Ratio of NIR in global radiation 																-	 					0.5 [1]
	addParam(gl, 'etaGlobPar', 0.5); 			% Ratio of PAR in global radiation 																-	 					0.5 [1]
	
	%% pg. 40 [1]
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'etaMgPpm', 0.554); 			% CO2 conversion factor from mg m^{-3} to ppm 													ppm mg^{-1} m^{3} 		0.554 [1]
	addParam(gl, 'etaRoofThr', 0.9); 			% Ratio between roof vent area and total vent area where no chimney effects is assumed 			- 						0.9 [1]
	addParam(gl, 'rhoAir0', 1.2); 				% Density of air at sea level 																	kg m^{-3} 				1.2 [1]
	addParam(gl, 'rhoCanPar', 0.07); 			% PAR reflection coefficient 																	- 						0.07 [1]
	addParam(gl, 'rhoCanNir', 0.35);  			% NIR reflection coefficient of the top of the canopy 											- 						0.35 [1]
	addParam(gl, 'rhoSteel', 7850); 			% Density of steel 																				kg m^{-3} 				7850 [1]
	addParam(gl, 'rhoWater', 1e3); 				% Density of water 																				kg m^{-3} 				1e3 [1]
	addParam(gl, 'gamma', 65.8); 				% Psychrometric constant 																		Pa K^{-1} 				65.8 [1]
	addParam(gl, 'omega', 1.99e-7); 			% Yearly frequency to calculate soil temperature 												s^{-1} 					1.99e7 [1]
	addParam(gl, 'capLeaf', 1.2e3); 			% Heat capacity of canopy leaves 																J K^{-1} m^{-2}{leaf} 	1.2e3 [1]
	addParam(gl, 'cEvap1', 4.3); 				% Coefficient for radiation effect on stomatal resistance 										W m^{-2} 				4.3 [1]
	addParam(gl, 'cEvap2', 0.54); 				% Coefficient for radiation effect on stomatal resistance 										W m^{-2} 				0.54 [1]
	
	%% pg. 41 [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'cEvap3Day', 6.1e-7); 			% Coefficient for co2 effect on stomatal resistance (day) 										ppm^{-2} 				6.1e-7 [1]
	addParam(gl, 'cEvap3Night', 1.1e-11);		% Coefficient for co2 effect on stomatal resistance (night) 									ppm^{-2} 				1.1e-11 [1]
	addParam(gl, 'cEvap4Day', 4.3e-6); 			% Coefficient for vapor pressure effect on stomatal resistance (day) 							Pa^{-2} 				4.3e-6 [1]
	addParam(gl, 'cEvap4Night', 5.2e-6);		% Coefficient for vapor pressure effect on stomatal resistance (night) 							Pa^{-2} 				5.2e-6 [1]
	addParam(gl, 'cPAir', 1e3); 				% Specific heat capacity of air 																J K^{-1} kg^{-1} 		1e3 [1]
	addParam(gl, 'cPSteel', 0.64e3); 			% Specific heat capacity of steel 																J K^{-1} kg^{-1} 		0.64e3 [1]
	addParam(gl, 'cPWater', 4.18e3); 			% Specific heat capacity of water 																J K^{-1} kg^{-1} 		4.18e3 [1]
	addParam(gl, 'g', 9.81);                    % Acceleration of gravity 																		m s^{-2} 				9.81 [1]
	addParam(gl, 'hSo1', 0.04); 				% Thickness of soil layer 1 																	m 						0.04 [1]
	addParam(gl, 'hSo2', 0.08); 				% Thickness of soil layer 2 																	m 						0.08 [1]
	addParam(gl, 'hSo3', 0.16); 				% Thickness of soil layer 3 																	m 						0.16 [1]
	addParam(gl, 'hSo4', 0.32); 				% Thickness of soil layer 4 																	m 						0.32 [1]
	addParam(gl, 'hSo5', 0.64); 				% Thickness of soil layer 5 																	m 						0.64 [1]
	addParam(gl, 'k1Par', 0.7); 				% PAR extinction coefficient of the canopy 														- 						0.7 [1]
	addParam(gl, 'k2Par', 0.7); 				% PAR extinction coefficient of the canopy for light reflected from the floor 					- 						0.7 [1]
    addParam(gl, 'kNir', 0.27); 				% NIR extinction coefficient of the canopy 														- 						0.27 [1]
	addParam(gl, 'kFir', 0.94); 				% FIR extinction coefficient of the canopy 														- 						0.94 [1]
	addParam(gl, 'mAir', 28.96); 				% Molar mass of air 																			kg kmol^{-1} 			28.96 [1]
	addParam(gl, 'hSoOut', 1.28);               % Thickness of the external soil layer                                                          m                       1.28 (assumed)
    
	%% pg. 42 [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'mWater', 18); 				% Molar mass of water 																			kg kmol^{-1} 			18 [1]
	addParam(gl, 'R', 8314); 					% Molar gas constant 																			J kmol^{-1} K^{-1} 		8314 [1]
	addParam(gl, 'rCanSp', 5); 					% Radiation value above the canopy when night becomes day 										W m^{-2} 				5 [1]
	addParam(gl, 'rB', 275); 					% Boundary layer resistance of the canopy for transpiration 									s m^{-1} 				275 [1]
	addParam(gl, 'rSMin', 82); 					% Minimum canopy resistance for transpiration 													s m^{-1} 				82 [1]
	addParam(gl, 'sRs', -1); 					% Slope of smoothed stomatal resistance model 													m W^{-2} 				-1 [1]
	
	%% Table 2 [1]
	% Location specific parameters - The Netherlands
	
	%% Construction properties [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'etaGlobAir', 0.1); 			% Ratio of global radiation absorbed by the greenhouse construction 							- 						0.1 [1]
    addParam(gl, 'psi', 25); 					% Mean greenhouse cover slope 																	° 						25 [1]
    addParam(gl, 'aFlr', 1.4e4);                % Floor area of greenhouse 																		m^{2} 					1.4e4 [1]          
    addParam(gl, 'aCov', 1.8e4);                % Surface of the cover including side walls 													m^{2} 					1.8e4 [1]
    addParam(gl, 'hAir', 3.8);                  % Height of the main compartment 																m 						3.8 [1]
    addParam(gl, 'hGh', 4.2);                   % Mean height of the greenhouse 																m 						4.2 [1] 
    addParam(gl, 'cHecIn', 1.86); 				% Convective heat exchange between cover and outdoor air 										W m^{-2} K^{-1} 		1.86 [1]
	addParam(gl, 'cHecOut1', 2.8); 				% Convective heat exchange parameter between cover and outdoor air 								W m^{-2}{cover} K^{-1} 	2.8 [1]
	addParam(gl, 'cHecOut2', 1.2); 				% Convective heat exchange parameter between cover and outdoor air 								J m^{-3} K^{-1} 		1.2 [1]
	addParam(gl, 'cHecOut3', 1);	 			% Convective heat exchange parameter between cover and outdoor air 								- 					 	1 [1]
    addParam(gl, 'hElevation', 0);				% Altitude of greenhouse 																		m above sea level		0 [1]
	
	%% Ventilation properties [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'aRoof', 1.4e3);               % Maximum roof ventilation area 																- 						0.1*aFlr [1]
    addParam(gl, 'hVent', 0.68);                % Vertical dimension of single ventilation opening 												m 						0.68 [1]
    addParam(gl, 'etaInsScr', 1); 				% Porosity of the insect screen 																- 						1 [1]
    addParam(gl, 'aSide', 0); 					% Side ventilation area 																		- 						0 [1]
	addParam(gl, 'cDgh', 0.75); 				% Ventilation discharge coefficient 															- 						0.75 [1]
    addParam(gl, 'cLeakage', 1e-4); 			% Greenhouse leakage coefficient 																- 						1e-4 [1]
	addParam(gl, 'cWgh', 0.09); 				% Ventilation global wind pressure coefficient 													- 						0.09 [1]
	addParam(gl, 'hSideRoof', 0);               % Vertical distance between mid points of side wall and roof ventilation opening                m                       0 (no side ventilation)
    
	%% Roof [1]
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'epsRfFir', 0.85); 			% FIR emission coefficient of the roof 															- 						0.85 [1]
	addParam(gl, 'rhoRf', 2.6e3); 				% Density of the roof layer 																	kg m^{-3} 				2.6e3 [1]
	addParam(gl, 'rhoRfNir', 0.13); 			% NIR reflection coefficient of the roof 														- 						0.13 [1]
	addParam(gl, 'rhoRfPar', 0.13);  			% PAR reflection coefficient of the roof 														- 						0.13 [1]
	addParam(gl, 'rhoRfFir', 0.15);  			% FIR reflection coefficient of the roof 														- 						0.15 [1]
    addParam(gl, 'tauRfNir', 0.85); 			% NIR transmission coefficient of the roof 														- 						0.85 [1]
    addParam(gl, 'tauRfPar', 0.85);  			% PAR transmission coefficient of the roof 														- 						0.85 [1]
	addParam(gl, 'tauRfFir', 0);                % FIR transmission coefficient of the roof 														- 						0 [1]
	addParam(gl, 'lambdaRf', 1.05); 			% Thermal heat conductivity of the roof 														W m^{-1} K^{-1} 		1.05 [1]
	addParam(gl, 'cPRf', 0.84e3); 				% Specific heat capacity of roof layer 															J K^{-1} kg^{-1} 		0.84e3 [1]
    addParam(gl, 'hRf', 4e-3); 					% Thickness of roof layer 																		m 						4e-3 [1]
	
    
    %% Whitewash
    addParam(gl, 'epsShScrPerFir', 0);       	% FIR emission coefficient of the whitewash                                                     -                       0 (no whitewash)
    addParam(gl, 'rhoShScrPer', 0);             % Density of the whitewash                                                                      -                       0 (no whitewash)
    addParam(gl, 'rhoShScrPerNir', 0);       	% NIR reflection coefficient of whitewash                                                       -                       0 (no whitewash)
    addParam(gl, 'rhoShScrPerPar', 0);       	% PAR reflection coefficient of whitewash                                                       -                       0 (no whitewash)
    addParam(gl, 'rhoShScrPerFir', 0);       	% FIR reflection coefficient of whitewash                                                       -                       0 (no whitewash)
    addParam(gl, 'tauShScrPerNir', 1);       	% NIR transmission coefficient of whitewash                                                     -                       1 (no whitewash)
    addParam(gl, 'tauShScrPerPar', 1);       	% PAR transmission coefficient of whitewash                                                     -                       1 (no whitewash)
    addParam(gl, 'tauShScrPerFir', 1);       	% FIR transmission coefficient of whitewash                                                     -                       1 (no whitewash)
    addParam(gl, 'lambdaShScrPer', Inf);     	% Thermal heat conductivity of the whitewash                                                    W m^{-1} K^{-1}         Inf (no whitewash)
    addParam(gl, 'cPShScrPer', 0);              % Specific heat capacity of the whitewash                                                       J K^{-1} kg^{-1}        0 (no whitewash)
    addParam(gl, 'hShScrPer', 0);               % Thickness of the whitewash                                                                    m                       0 (no whitewash)
    
    %% Shadow screen 
    addParam(gl, 'rhoShScrNir', 0);     		% NIR reflection coefficient of shadow screen                                                   -                       0 (no shadow screen)
    addParam(gl, 'rhoShScrPar', 0);             % PAR reflection coefficient of shadow screen                                                   -                       0 (no shadow screen)
    addParam(gl, 'rhoShScrFir', 0);     		% FIR reflection coefficient of shadow screen                                                   -                       0 (no shadow screen)
    addParam(gl, 'tauShScrNir', 1);     		% NIR transmission coefficient of shadow screen                                                 -                       1 (no shadow screen)
    addParam(gl, 'tauShScrPar', 1);             % PAR transmission coefficient of shadow screen                                                 -                       1 (no shadow screen)
    addParam(gl, 'tauShScrFir', 1);     		% FIR transmission coefficient of shadow screen                                                 -                       1 (no shadow screen)
	addParam(gl, 'etaShScrCd', 0);      		% Effect of shadow screen on discharge coefficient                                              -                       0 (no shadow screen)
    addParam(gl, 'etaShScrCw', 0);      		% Effect of shadow screen on wind pressure coefficient                                          -                       0 (no shadow screen)
    addParam(gl, 'kShScr', 0);                  % Shadow screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1} 0 (no shadow screen)

    
    %% Thermal screen [1]
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'epsThScrFir', 0.67); 			% FIR emissions coefficient of the thermal screen 												- 						0.67 [1]
	addParam(gl, 'rhoThScr', 0.2e3); 			% Density of thermal screen 																	kg m^{-3} 				0.2e3 [1]
	addParam(gl, 'rhoThScrNir', 0.35); 			% NIR reflection coefficient of thermal screen 													- 						0.35 [1]
	addParam(gl, 'rhoThScrPar', 0.35); 			% PAR reflection coefficient of thermal screen 													- 						0.35 [1]
	addParam(gl, 'rhoThScrFir', 0.18); 			% FIR reflection coefficient of thermal screen 													- 						0.18 [1]
	addParam(gl, 'tauThScrNir', 0.6); 			% NIR transmission coefficient of thermal screen 												- 						0.6 [1]
    addParam(gl, 'tauThScrPar', 0.6); 			% PAR transmission coefficient of thermal screen 												- 						0.6 [1]
    addParam(gl, 'tauThScrFir', 0.15); 			% FIR transmission coefficient of thermal screen 												- 						0.15 [1]
	addParam(gl, 'cPThScr', 1.8e3); 			% Specific heat capacity of thermal screen 														J kg^{-1} K^{-1} 		1.8e3 [1]
    addParam(gl, 'hThScr', 0.35e-3); 			% Thickness of thermal screen 																	m 						0.35e-3 [1]
    addParam(gl, 'kThScr', 0.05e-3); 			% Thermal screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1} 0.05e-3 [1]
	
    %% Blackout screen
	% Assumed to be the same as the thermal screen, except 1% transmissivity
	% and a higher FIR transmission
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'epsBlScrFir', 0.67); 			% FIR emissions coefficient of the blackout screen 												- 						
	addParam(gl, 'rhoBlScr', 0.2e3); 			% Density of blackout screen 																	kg m^{-3} 				
	addParam(gl, 'rhoBlScrNir', 0.35); 			% NIR reflection coefficient of blackout screen 												- 						
	addParam(gl, 'rhoBlScrPar', 0.35); 			% PAR reflection coefficient of blackout screen 												- 						
	addParam(gl, 'tauBlScrNir', 0.01); 			% NIR transmission coefficient of blackout screen 												- 						
	addParam(gl, 'tauBlScrPar', 0.01); 			% PAR transmission coefficient of blackout screen 												- 						
	addParam(gl, 'tauBlScrFir', 0.7); 			% FIR transmission coefficient of blackout screen 												- 						
	addParam(gl, 'cPBlScr', 1.8e3); 			% Specific heat capacity of blackout screen 													J kg^{-1} K^{-1} 		
    addParam(gl, 'hBlScr', 0.35e-3); 			% Thickness of blackout screen 																	m 						
    addParam(gl, 'kBlScr', 0.05e-3); 			% Blackout screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1} 
	
    
	%% Floor [1]
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'epsFlr', 1);			 		% FIR emission coefficient of the floor 														- 						1 [1]
	addParam(gl, 'rhoFlr', 2300); 				% Density of the floor 																			kg m^{-3} 				2300 [1]
	addParam(gl, 'rhoFlrNir', 0.5); 			% NIR reflection coefficient of the floor 														- 						0.5 [1]
	addParam(gl, 'rhoFlrPar', 0.65); 			% PAR reflection coefficient of the floor 														- 						0.65 [1]
	addParam(gl, 'lambdaFlr', 1.7);				% Thermal heat conductivity of the floor 														W m^{-1} K^{-1} 		1.7 [1]
	addParam(gl, 'cPFlr', 0.88e3); 				% Specific heat capacity of the floor 															J kg^{-1} K^{-1} 		0.88e3 [1]
	addParam(gl, 'hFlr', 0.02); 				% Thickness of floor 																			m 						0.02 [1]
	
	%% Soil [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'rhoCpSo', 1.73e6); 			% Volumetric heat capacity of the soil 															J m^{-3} K^{-1} 		1.73e6 [1]
	addParam(gl, 'lambdaSo', 0.85); 			% Thermal heat conductivity of the soil layers 													W m^{-1} K^{-1} 		0.85 [1]
	
	%% Heating system [1]
	% parameter 					            description 																					unit 					nominal value (source)
	addParam(gl, 'epsPipe', 0.88); 				% FIR emission coefficient of the heating pipes 												- 						0.88 [1]
	addParam(gl, 'phiPipeE', 51e-3); 			% External diameter of pipes 																	m 						51e-3 [1]
    addParam(gl, 'phiPipeI', 47e-3);            % Internal diameter of pipes 																	m 						47e-3 [1]
    addParam(gl, 'lPipe', 1.875);               % Length of heating pipes per gh floor area 													m m^{-2} 				1.875 [1]
    addParam(gl, 'pBoil', 130*gl.p.aFlr.val);   % Capacity of the heating system                                                                W                       130*p.aFlr (Assumed to be 150 m3/h/ha = 130 W m^{-2} [5])
    
	%% Active climate control [1]
	% parameter 					            description 																					unit 					nominal value (source)
    addParam(gl, 'phiExtCo2', 7.2e4);           % Capacity of external CO2 source 																mg s^{-1} 				7.2e4 [1] 
	
	%% Other parameters that depend on previously defined parameters
	    
	% Heat capacity of heating pipes [J K^{-1} m^{-2}]
    % Equation 21 [1]
    addParam(gl, 'capPipe', 0.25*pi*gl.p.lPipe*((gl.p.phiPipeE^2-gl.p.phiPipeI^2)*gl.p.rhoSteel*...
        gl.p.cPSteel+gl.p.phiPipeI^2*gl.p.rhoWater*gl.p.cPWater));
    
	% Density of the air [kg m^{-3}]
	% Equation 23 [1]
    addParam(gl, 'rhoAir', gl.p.rhoAir0*exp(gl.p.g*gl.p.mAir*gl.p.hElevation/(293.15*gl.p.R)));
    
	% Heat capacity of greenhouse objects [J K^{-1} m^{-2}]
	% Equation 22 [1]
    addParam(gl, 'capAir', gl.p.hAir*gl.p.rhoAir*gl.p.cPAir);             % air in main compartment
    addParam(gl, 'capFlr', gl.p.hFlr*gl.p.rhoFlr*gl.p.cPFlr);             % floor
    addParam(gl, 'capSo1', gl.p.hSo1*gl.p.rhoCpSo);                       % soil layer 1
    addParam(gl, 'capSo2', gl.p.hSo2*gl.p.rhoCpSo);                       % soil layer 2
    addParam(gl, 'capSo3', gl.p.hSo3*gl.p.rhoCpSo);                       % soil layer 3
    addParam(gl, 'capSo4', gl.p.hSo4*gl.p.rhoCpSo);                       % soil layer 4
    addParam(gl, 'capSo5', gl.p.hSo5*gl.p.rhoCpSo);                       % soil layer 5
    addParam(gl, 'capThScr', gl.p.hThScr*gl.p.rhoThScr*gl.p.cPThScr);     % thermal screen
    addParam(gl, 'capTop', (gl.p.hGh-gl.p.hAir)*gl.p.rhoAir*gl.p.cPAir);  % air in top compartments
    
    addParam(gl, 'capBlScr', gl.p.hBlScr*gl.p.rhoBlScr*gl.p.cPBlScr);     % blackout screen

    
	% Capacity for CO2 [m]
	addParam(gl, 'capCo2Air', gl.p.hAir);
    addParam(gl, 'capCo2Top', gl.p.hGh-gl.p.hAir);
	
	% Surface of pipes for floor area [-]
	% Table 3 [1]
    addParam(gl, 'aPipe', pi*gl.p.lPipe*gl.p.phiPipeE);
	
	% View factor from canopy to floor
	% Table 3 [1]
    addParam(gl, 'fCanFlr', 1-0.49*pi*gl.p.lPipe*gl.p.phiPipeE);
    
    % Absolute air pressure at given elevation [Pa]
	% See https://www.engineeringtoolbox.com/air-altitude-pressure-d_462.html
    addParam(gl, 'pressure', 101325*(1-2.5577e-5*gl.p.hElevation)^5.25588);

	
	%% Canopy photosynthesis [2]
	% parameter 					            description 																					unit 									nominal value (source)
	addParam(gl, 'globJtoUmol', 2.3); 			% Conversion factor from global radiation to PAR (etaGlobPar in [2], but that name has another meaning in [1]) umol{photons} J^{-1} 	2.3 [2]
	addParam(gl, 'j25LeafMax', 210); 			% Maximal rate of electron transport at 25°C of the leaf 										umol{e-} m^{-2}{leaf} s^{-1} 			210 [2]
	addParam(gl, 'cGamma', 1.7); 				% Effect of canopy temperature on CO2 compensation point 										umol{co2} mol^{-1}{air} K^{-1} 			1.7 [2]
	addParam(gl, 'etaCo2AirStom', 0.67); 		% Conversion from greenhouse air co2 concentration and stomatal co2 concentration 				umol{co2} mol^{-1}{air} 				0.67 [2]
	addParam(gl, 'eJ', 37e3); 					% Activation energy for Jpot calcualtion 														J mol^{-1} 								37e3 [2]
	addParam(gl, 't25k', 298.15); 				% Reference temperature for Jpot calculation 													K 										298.15 [2]
	addParam(gl, 'S', 710); 					% Enthropy term for Jpot calculation 															J mol^{-1} K^{-1} 						710 [2]
	addParam(gl, 'H', 22e4); 					% Deactivation energy for Jpot calculation 														J mol^{-1} 								22e4 [2]
	addParam(gl, 'theta', 0.7); 				% Degree of curvature of the electron transport rate 											- 										0.7 [2]
	addParam(gl, 'alpha', 0.385); 				% Conversion factor from photons to electrons including efficiency term 						umol{e-} umol^{-1}{photons} 			0.385 [2]
	addParam(gl, 'mCh2o', 30e-3); 				% Molar mass of CH2O 																			mg umol^{-1} 							30e-3
    addParam(gl, 'mCo2', 44e-3);                % Molar mass of CO2                                                                             mg umol^{-1}                            44e-3 
	
    addParam(gl, 'parJtoUmolSun', 4.6); 		% Conversion factor of sun's PAR from J to  													umol{photons} J^{-1}                    4.6 [2]
    
	addParam(gl, 'laiMax', 3); 					% leaf area index 																				(m^{2}{leaf} m^{-2}{floor}) 			3 [2]
	addParam(gl, 'sla', 2.66e-5); 				% specific leaf area 																			(m^{2}{leaf} mg^{-1}{leaf}				2.66e-5 [2]
    addParam(gl, 'rgr', 3e-6); 					% relative growth rate 																			{kg{dw grown} kg^{-1}{existing dw} s^{-1}} Assumed

    addParam(gl, 'cLeafMax', gl.p.laiMax./gl.p.sla);      % maximum leaf size                                                                             mg{leaf} m^{-2}
    
    % cLeafMax is 112e3 mg/m2, the total crop max should be about 450e3 mg/m2
    addParam(gl, 'cFruitMax', 300e3);           % maximum fruit size                                                                            mg{fruit} m^{-2}
        
    addParam(gl, 'cFruitG', 0.27); 				% Fruit growth respiration coefficient 															- 										0.27 [1]
	addParam(gl, 'cLeafG', 0.28); 				% Leaf growth respiration coefficient 															- 										0.28 [1]
	addParam(gl, 'cStemG', 0.3); 				% Stem growth respiration coefficient 															- 										0.3 [1]
	addParam(gl, 'cRgr', 2.85e6); 				% Regression coefficient in maintenance respiration function 									s^{-1} 									2.85e6 [1]
	addParam(gl, 'q10m', 2); 					% Q10 value of temperature effect on maintenance respiration 									- 										2 [1]
	addParam(gl, 'cFruitM', 1.16e-7); 			% Fruit maintenance respiration coefficient 													mg mg^{-1} s^{-1} 						1.16e-7 [1]
	addParam(gl, 'cLeafM', 3.47e-7); 			% Leaf maintenance respiration coefficient 														mg mg^{-1} s^{-1} 						3.47e-7 [1]
	addParam(gl, 'cStemM', 1.47e-7); 			% Stem maintenance respiration coefficient 														mg mg^{-1} s^{-1} 						1.47e-7 [1]
    
    addParam(gl, 'rgFruit', 0.328); 			% Potential fruit growth coefficient                                                            mg m^{-2} s^{-1} 						0.328 [2]
	addParam(gl, 'rgLeaf', 0.095);              % Potential leaf growth coefficient                                                             mg m^{-2} s^{-1} 						0.095 [2]
	addParam(gl, 'rgStem', 0.074);              % Potential stem growth coefficient                                                             mg m^{-2} s^{-1} 						0.074 [2]
    
    %% Carbohydrates buffer
    addParam(gl, 'cBufMax', 20e3);              % Maximum capacity of carbohydrate buffer                                                       mg m^{-2}                               20e3 [2]
    addParam(gl, 'cBufMin', 1e3);               % Minimum capacity of carbohydrate buffer                                                       mg m^{-2}                               1e3 [2]
    addParam(gl, 'tCan24Max', 24.5);            % Inhibition of carbohydrate flow because of high temperatures                                  °C                                      24.5 [2]
    addParam(gl, 'tCan24Min', 15);              % Inhibition of carbohydrate flow because of low temperatures                                   °C                                      15 [2]
    addParam(gl, 'tCanMax', 34);              % Inhibition of carbohydrate flow because of high instantenous temperatures                       °C                                      34 [2]
    addParam(gl, 'tCanMin', 10);              % Inhibition of carbohydrate flow because of low instantenous temperatures                      	°C                                      10 [2]
    
    %% Crop development
    addParam(gl, 'tEndSum', 1035);              % Temperature sum where crop is fully generative                                                °C day                                  1035 [2]
    
    %% Control parameters
    addParam(gl, 'rhMax', 90);                  % upper bound on relative humidity              												[%]                     				90 [4]
	addParam(gl, 'dayThresh', 20); 				% threshold to consider switch from night to day 												[W m^{-2}]								20
    addParam(gl, 'tSpDay', 19.5);               % Heat is on below this point in day           													[°C]                                    19.5 [5]
    addParam(gl, 'tSpNight', 16.5);            	% Heat is on below this point in night           												[°C]                   					16.5 [5]
    addParam(gl, 'tHeatBand', -1);           	% P-band for heating                              												[°C]                   					-1 [6]
    addParam(gl, 'tVentOff', 1); 				% distance from heating setpoint where ventilation stops (even if humidity is too high) 		[°C]                   					1 [4]
    addParam(gl, 'tScreenOn', 2); 				% distance from screen setpoint where screen is on (even if humidity is too high)				[°C]                   					2 
    addParam(gl, 'thScrSpDay', 5);           	% Screen is closed at day when outdoor is below this temperature 								[°C]           							5 [5]
    addParam(gl, 'thScrSpNight', 10);      		% Screen is closed at night when outdoor is below this temperature 								[°C]           							10 [5]
    addParam(gl, 'thScrPband', -1);          	% P-band for thermal screen 																	[°C] 									-1           
    addParam(gl, 'co2SpDay', 800);            	% Co2 is supplied if co2 is below this point during day 										[ppm]       							800 [4]
    addParam(gl, 'co2Band', -100);              % P-band for co2 supply                                 										[ppm]    								-100   
    addParam(gl, 'heatDeadZone', 5);       		% zone between heating setpoint and ventilation setpoint 										[°C]     								5 [4]
    addParam(gl, 'ventHeatPband', 4);     		% P-band for ventilation due to excess heat 													[°C] 									4
    addParam(gl, 'ventColdPband', -1);     		% P-band for ventilation due to low indoor temperature 											[°C] 									4
    addParam(gl, 'ventRhPband', 5);         	% P-band for ventilation due to relative humidity 												[%] 									5
    addParam(gl, 'thScrRh', -2);                % Relative humidity where thermal screen is forced to open, with respect to rhMax				[%] 									80
    addParam(gl, 'thScrRhPband', 2);            % P-band for thermal screen opening due to excess relative humidity 							[%] 									2
    addParam(gl, 'thScrDeadZone', 4);           % Zone between heating setpoint and point where screen opens
    
    addParam(gl, 'lampsOn', 0);                 % time of day to switch on lamps                                                                [hours since midnight] 					0 (no lamps)
    addParam(gl, 'lampsOff', 0);              	% time of day to switch off lamps                                                               [hours since midnight] 					0 (no lamps)
    % if p.lampsOn < p.lampsOff, lamps are on from p.lampsOn to p.lampsOff each day
    % if p.lampsOn > p.lampsOff, lamps are on from p.lampsOn until p.lampsOff the next day
    % if p.lampsOn == p.lampsOff, lamps are always off
    % for continuous light, set p.lampsOn = -1, p.lampsOff = 25
    
    addParam(gl, 'dayLampStart', -1);           % Day of year when lamps start                                                                  [day of year]                           -1 (no influence of doy)
    addParam(gl, 'dayLampStop', 400);           % Day of year when lamps stop                                                                   [day of year]                           400 (no influence of doy)
    % if p.dayLampStart < p.dayLampStop, lamps are on from p.dayLampStart to p.dayLampStop
    % if p.dayLampStart > p.dayLampStop, lamps are on from p.lampsOn until p.lampsOff the next year
    % if p.dayLampStart == p.dayLampStop, lamps are always off
    % for no influence of day of year, set p.dayLampStart = -1, p.dayLampStop > 366
    
    addParam(gl, 'lampsOffSun', 400);       	% lamps are switched off if global radiation is above this value 								[W m^{-2}]   							400 [10]
    addParam(gl, 'lampRadSumLimit', 10);        % Predicted daily radiation sum from the sun where lamps are not used that day                  [MJ m^{-2} day^{-1}]                    10 [10]   
    addParam(gl, 'lampExtraHeat', 2);           % Control for lamps due to too much heat - switched off if indoor temperature is above setpoint+heatDeadZone+lampExtraHeat [°C]         2 [Chapter 5 Section 2.4 [9]]
    addParam(gl, 'blScrExtraRh', 100);          % Control for blackout screen due to humidity - screens open if relative humidity exceeds rhMax+blScrExtraRh [%]                        100 (no blackout screen), 3 (with blackout screen) [Chapter 5 Section 2.4 [9]]
    addParam(gl, 'useBlScr', 0);                % Determines whether a blackout screen is used (1 if used, 0 otherwise)                         [-]                                     0 (no blackout screen), 1 (with blackout screen)
    
    addParam(gl, 'mechCoolPband', 1);           % P-band for mechanical cooling                                                                 [°C]                                    1 [Chapter 5 Section 2.4 [9]]
    addParam(gl, 'mechDehumidPband', 2);        % P-band for mechanical dehumidification                                                        [%]                                     2 [Chapter 5 Section 2.4 [9]]
    addParam(gl, 'heatBufPband', -1);           % P-band for heating from the buffer                                                            [°C]                                    -1 [Chapter 5 Section 2.4 [9]]
    addParam(gl, 'mechCoolDeadZone', 2);        % zone between heating setpoint and mechanical cooling setpoint                                 [°C]                                    2 [Chapter 5 Section 2.4 [9]]
    
    %% Grow pipe parameters
    addParam(gl, 'epsGroPipe', 0);              % Emissivity of grow pipes                                                                  	[-]                                     0 (no grow pipes)
    
    % There are no grow pipes so these parameters are not important, but
    % they cannot be 0 because the ODE for the grow pipe still exists
    addParam(gl, 'lGroPipe', 1.655); 			% Length of grow pipes per gh floor area                                                    	m m^{-2}                                1.25 
    addParam(gl, 'phiGroPipeE', 35e-3); 		% External diameter of grow pipes 																m                                       28e-3 [7]
    addParam(gl, 'phiGroPipeI', (35e-3)-(1.2e-3));% Internal diameter of grow pipes 															m                                       24e-3 
       
    addParam(gl, 'aGroPipe', pi*gl.p.lGroPipe*gl.p.phiGroPipeE); % Surface area of pipes for floor area                                         m^{2}{pipe} m^{-2}{floor}
    addParam(gl, 'pBoilGro', 0);                % Capacity of the grow pipe heating system                                                      W                                       0 (no grow pipes) 
    
    % Heat capacity of grow pipes [J K^{-1} m^{-2}]
    % Equation 21 [1]
    addParam(gl, 'capGroPipe', 0.25*pi*gl.p.lGroPipe*((gl.p.phiGroPipeE^2-gl.p.phiGroPipeI^2)*gl.p.rhoSteel*...
        gl.p.cPSteel+gl.p.phiGroPipeI^2*gl.p.rhoWater*gl.p.cPWater));
    
	%% Lamp parameters - no lamps
    addParam(gl, 'thetaLampMax', 0);            % Maximum intensity of lamps																	[W m^{-2}]
	addParam(gl, 'heatCorrection', 0);   		% correction for temperature setpoint when lamps are on 										[C]   									 0
    addParam(gl, 'etaLampPar', 0);  			% fraction of lamp input converted to PAR 														[-]                                      0
    addParam(gl, 'etaLampNir', 0);				% fraction of lamp input converted to NIR 														[-]                                      0
	addParam(gl, 'tauLampPar', 1);				% transmissivity of lamp layer to PAR															[-]                                      1
	addParam(gl, 'rhoLampPar', 0);				% reflectivity of lamp layer to PAR 															[-]                                      0
	addParam(gl, 'tauLampNir', 1);				% transmissivity of lamp layer to NIR 															[-]                                      1
	addParam(gl, 'rhoLampNir', 0);				% reflectivity of lamp later to NIR 															[-]                                      0
	addParam(gl, 'tauLampFir', 1);				% transmissivity of lamp later to FIR 															[-]                                      1
	addParam(gl, 'aLamp', 0);					% lamp area 																					[m^{2}{lamp} m^{-2}{floor}]              0
	addParam(gl, 'epsLampTop', 0); 				% emissivity of top side of lamp 																[-]                                      0
	addParam(gl, 'epsLampBottom', 0);			% emissivity of bottom side of lamp 															[-]                                      0
	addParam(gl, 'capLamp', 350);				% heat capacity of lamp 																		[J K^{-1} m^{-2}]                        350
    addParam(gl, 'cHecLampAir', 0);				% heat exchange coefficient of lamp                                                             [W m^{-2} K^{-1}]                        0
    addParam(gl, 'etaLampCool', 0);             % fraction of lamp input removed by cooling                                                     [-]                                      0
    addParam(gl, 'zetaLampPar', 0);             % J to umol conversion of PAR output of lamp                                                    [J{PAR} umol{PAR}^{-1}]                  0                  
    
    % Interlight parameters - no lamps
    addParam(gl, 'vIntLampPos', 0.5);           % Vertical position of the interlights within the canopy [0-1, 0 is above canopy and 1 is below][-]                                      0.5 [Chapter 7 Section 4.12 [9]]
    addParam(gl, 'fIntLampDown', 0.5);          % Fraction of interlight light output (PAR and NIR) that goes downwards                         [-]                                      0.5 [Chapter 7 Section 4.12 [9]]
    addParam(gl, 'capIntLamp', 10);             % heat capacity of lamp                                                                         [J K^{-1} m^{-2}]                        10 [Assumed to be the same as top LEDs [8]]            
    addParam(gl, 'etaIntLampPar', 0);           % fraction of lamp input converted to PAR 														[-]                                      0
    addParam(gl, 'etaIntLampNir', 0);           % fraction of lamp input converted to NIR 														[-]                                      0                                     
    addParam(gl, 'aIntLamp', 0);                % interlight lamp area 																			[m^{2}{lamp} m^{-2}{floor}]              0        
    addParam(gl, 'epsIntLamp', 0);              % emissivity of interlight                                                                      [-]                                      0.88 Assumed that lamps act the same as heating pipes [8]
    addParam(gl, 'thetaIntLampMax', 0);         % Maximum intensity of lamps																	[W m^{-2}]                               0
	addParam(gl, 'zetaIntLampPar', 0);          % conversion from Joules to umol photons within the PAR output of the interlight                [J{PAR} umol{PAR}^{-1}]                  0
    addParam(gl, 'cHecIntLampAir', 0);			% heat exchange coefficient of interlights                                                      [W m^{-2} K^{-1}]                        0
    addParam(gl, 'tauIntLampFir', 1);			% transmissivity of FIR through the interlights                                                 [-]                                      1
    addParam(gl, 'k1IntPar', 1.4); 				% PAR extinction coefficient of the canopy for light coming from the interlights                [-]                                      1.4 [Chapter 7 Section 4.12 [9]]
    addParam(gl, 'k2IntPar', 1.4); 				% PAR extinction coefficient of the canopy for light coming from the interlights through the floor [-]                                   1.4 [Chapter 7 Section 4.12 [9]]
    addParam(gl, 'kIntNir', 0.54); 				% NIR extinction coefficient of the canopy for light coming from the interlights                [-]                                      0.54 [Chapter 7 Section 4.12 [9]]
    addParam(gl, 'kIntFir', 1.88); 				% FIR extinction coefficient of the canopy for light coming from the interlights                [-]                                      1.88 [Chapter 7 Section 4.12 [9]]
	
    
    %% Other parameters
    addParam(gl, 'cLeakTop', 0.5);              % Fraction of leakage ventilation going from the top                                            [-]                                      0.5 [1]
    addParam(gl, 'minWind', 0.25);              % wind speed where the effect of wind on leakage begins                                         [m s^{-1}]                               0.25 [1]
    
end


