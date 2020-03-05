function setDepParams(gl)
%SETDEPPARAMS Set the dependent parameters for the GreenLight (2011) model
% Dependent parameters are parameters that depend on the setting of another
% parameter. In prinicpal this doesn't have to be done, but better to do it
% just to be safe.
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

% David Katzin, Wageningen University
% david.katzin@wur.nl

	% Heat capacity of heating pipes [J K^{-1} m^{-2}]
    % Equation 21 [1]
    gl.p.capPipe = 0.25*pi*gl.p.lPipe*((gl.p.phiPipeE^2-gl.p.phiPipeI^2)*gl.p.rhoSteel*...
        gl.p.cPSteel+gl.p.phiPipeI^2*gl.p.rhoWater*gl.p.cPWater);
    
	% Density of the air [kg m^{-3}]
	% Equation 23 [1]
    gl.p.rhoAir = gl.p.rhoAir0*exp(gl.p.g*gl.p.mAir*gl.p.hElevation/(293.15*gl.p.R));
    
	% Heat capacity of greenhouse objects [J K^{-1} m^{-2}]
	% Equation 22 [1]
    gl.p.capAir = gl.p.hAir*gl.p.rhoAir*gl.p.cPAir;             % air in main compartment
    gl.p.capFlr = gl.p.hFlr*gl.p.rhoFlr*gl.p.cPFlr;             % floor
    gl.p.capSo1 = gl.p.hSo1*gl.p.rhoCpSo;                       % soil layer 1
    gl.p.capSo2 = gl.p.hSo2*gl.p.rhoCpSo;                       % soil layer 2
    gl.p.capSo3 = gl.p.hSo3*gl.p.rhoCpSo;                       % soil layer 3
    gl.p.capSo4 = gl.p.hSo4*gl.p.rhoCpSo;                       % soil layer 4
    gl.p.capSo5 = gl.p.hSo5*gl.p.rhoCpSo;                       % soil layer 5
    gl.p.capThScr = gl.p.hThScr*gl.p.rhoThScr*gl.p.cPThScr;     % thermal screen
    gl.p.capTop = (gl.p.hGh-gl.p.hAir)*gl.p.rhoAir*gl.p.cPAir;  % air in top compartments
    
    gl.p.capBlScr = gl.p.hBlScr*gl.p.rhoBlScr*gl.p.cPBlScr;     % blackout screen

    
	% Capacity for CO2 [m]
	gl.p.capCo2Air = gl.p.hAir;
    gl.p.capCo2Top = gl.p.hGh-gl.p.hAir;
	
	% Surface of pipes for floor area [-]
	% Table 3 [1]
    gl.p.aPipe = pi*gl.p.lPipe*gl.p.phiPipeE;
	
	% View factor from canopy to floor
	% Table 3 [1]
    gl.p.fCanFlr = 1-0.49*pi*gl.p.lPipe*gl.p.phiPipeE;
    
    % Absolute air pressure at given elevation [Pa]
	% See https://www.engineeringtoolbox.com/air-altitude-pressure-d_462.html
    gl.p.pressure = 101325*(1-2.5577e-5*gl.p.hElevation)^5.25588;

    gl.p.cLeafMax = gl.p.laiMax./gl.p.sla;      % maximum leaf size                                                                             mg{leaf} m^{-2}
    
    gl.p.aGroPipe = pi*gl.p.lGroPipe*gl.p.phiGroPipeE; % Surface area of pipes for floor area                                                   m^{2}{pipe} m^{-2}{floor}
    
    % Heat capacity of grow pipes [J K^{-1} m^{-2}]
    % Equation 21 [1]
    gl.p.capGroPipe = 0.25*pi*gl.p.lGroPipe*((gl.p.phiGroPipeE^2-gl.p.phiGroPipeI^2)*gl.p.rhoSteel*...
        gl.p.cPSteel+gl.p.phiGroPipeI^2*gl.p.rhoWater*gl.p.cPWater);
end

