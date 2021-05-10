function addHeatHarvesting(gl)
%ADDHEATHARVESTING Add heat harvesting to a GreenLight model instance
% Usage:
%   addHeatHarvesting(gl)
% Inputs:
%   gl - a GreenLight model instance
%
% For more information, see Chapter 5 Section 2.3.1, Chapter 7 Section 4.10 of:
%   [1] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434
% The model is based on 
%   [2] Righini, I., Vanthoor, B., Verheul, M. J., Naseer, M., Maessen, H., 
%       Persson, T., & Stanghellini, C. (2020). A greenhouse climate-yield 
%       model focussing on additional light, heat harvesting and its validation. 
%       Biosystems Engineering, (194), 1–15. https://doi.org/10.1016/j.biosystemseng.2020.03.009
% and the electronic appendix of
%   [3] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
% Some parameters are based on:
%   [4] Van Beveren, P. J. M., Bontsema, J., Van ’t Ooster, A., 
%        Van Straten, G., & Van Henten, E. J. (2020). 
%        Optimal utilization of energy equipment in a semi-closed greenhouse. 
%        Computers and Electronics in Agriculture, 179, 105800. 
%        https://doi.org/10.1016/j.compag.2020.105800
%   [5] Vanthoor, B., Stigter, J. D., van Henten, E. J., Stanghellini, C., 
%        de Visser, P. H. B., & Hemming, S. (2012). A methodology for 
%        model-based greenhouse design: Part 5, greenhouse design optimisation 
%        for southern-Spanish and Dutch conditions. Biosystems Engineering, 
%        111(4), 350–368. https://doi.org/10.1016/j.biosystemseng.2012.01.005

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com    

    %% Add heat harvesting parameters
    addParam(gl, 'copMech', 4);                 % Coefficient of performance of the mechanical cooling system                                       [-]                                     4 [Chapter 7 Section 4.12 [1]]
    addParam(gl, 'pMech', 50);                  % Electrical capacity of the mechanical cooling system                                              [W m^{-2}]]                             50-200 [5]
    addParam(gl, 'tMech', 10);                  % Temperature of the cooling surface of the mechanical cooling (assumed constant)                   [°C]                                    10 [Chapter 7 Section 4.12 [1]]
    addParam(gl, 'copHeatPump', 5.5);           % Coefficient of performance of the heat pump                                                       [-]                                     5.5 [4]
    addParam(gl, 'pHeatPump', 62.5/5.5);        % Maximum electrical consumption of the heat pump                                                   [W m^{-2}]                              62.5/5.5 [4]
    addParam(gl, 'pBufHot', 150);               % Maximum heat flux from the hot water buffer to the heating pipes                                  [W m^{-2}]                              150 [4]
    addParam(gl, 'cBufSizeCold', 0.4184);       % Size of the cold water buffer                                                                     [MJ m^{-2}]                             0.4184 = 0.01 m3/m2 [2] *1e3 kg(water)/m3*10K temperature difference in buffer [2]*4184 J/kg/K (specific heat of water)*1e-6 MJ/J
    addParam(gl, 'cBufSizeHot', 0.8368);        % Size of the hot water buffer                                                                      [MJ m^{-2}]                             0.8368 = 0.01 m3/m2 [2] *1e3 kg(water)/m3*20K temperature difference in buffer [2]*4184 J/kg/K (specific heat of water)*1e-6 MJ/J
    addParam(gl, 'etaMech', 0.25);              % Added fraction of electricity required to run the water pump of mechanical cooling                [-]                                     0.25 [5]

    addParam(gl, 'mechCoolPband', 1);           % P-band for mechanical cooling                                                                     [°C]                                    1 [Chapter 5 Section 2.4 [1]]
    addParam(gl, 'mechDehumidPband', 2);        % P-band for mechanical dehumidification                                                            [%]                                     2 [Chapter 5 Section 2.4 [1]]
    addParam(gl, 'heatBufPband', -1);           % P-band for heating from the buffer                                                                [°C]                                    -1 [Chapter 5 Section 2.4 [1]]
    addParam(gl, 'mechCoolDeadZone', 2);        % zone between heating setpoint and mechanical cooling setpoint                                     [°C]                                    2 [Chapter 5 Section 2.4 [1]]
   
    %% Add heat harvesting states
    % Energy content of cold water buffer [MJ m^{-2}]
    addState(gl, 'eBufCold');
    
    % Energy content of hot water buffer [MJ m^{-2}]
    addState(gl, 'eBufHot');
    
    %% Add heat harvesting controls
    % Mechanical cooling and dehumidification (MCD)
    % [0-1, 0 no MCD, 1 is MCD at full capacity)
    addControl(gl, 'mech');
    
    % Heat pump between hot and cold energy buffers
    % [0-1, 0 heat pump is off , 1 heat pump is at full capacity)
    addControl(gl, 'heatPump');

    % Control of the valve between the hot energy buffer and the heating pipes
    % [0-1, 0 no heating from hot buffer, 1 full heating from hot buffer)
    addControl(gl, 'bufHot');
    
    %% Add or modify auxiliary states related to heat harvesting
    % Shorthands for easier reading
    u = gl.u;
    p = gl.p;
    
    %% Set dummy variables for states
    % Some states, gl.x.tAir and gl.x.vpAir, are already defined:
    % gl.x.tAir.def is the ODE for gl.x.tAir, and not simply 'x.tAir'.
    % This means that using gl.x.tAir or gl.x.vpAir for defininig other variables
    % will make a mess. Instead, we set a dummy variable: 
    % x instead of gl.x.
    % eBufCold and eBufHot are added to the dummy variable x so that it can
    % be used throughout this function
    x.tAir = DynamicElement('x.tAir');
    x.vpAir = DynamicElement('x.vpAir');
    x.eBufCold = DynamicElement('x.eBufCold');
    x.eBufHot = DynamicElement('x.eBufHot');
    
    % Heat exchange coefficient between surface of mechanical cooling and
    % air [W m^{-2} K^{-1}]
    % Equation 62 [3], Equation 7.54-7.55 [1]
    addAux(gl, 'hecMechAir', (u.mech*p.copMech*p.pMech)./...
        (x.tAir-p.tMech+6.4e-9*p.L*(x.vpAir-satVp(p.tMech))));
    
    % Heat flux from the mechanical cooling to the greenhouse air [W m^{-2}]
    % Equation 39 [3], Equation 7.51 [1]
    addAux(gl, 'hAirMech', abs(gl.a.hecMechAir).*(x.tAir-p.tMech));

    % Vapor flux from the greenhouse air to the surface of the mechanical
    % cooling system 
    % Equation 42 [3], Equation 7.52 [1]
    addAux(gl, 'mvAirMech', cond(abs(gl.a.hecMechAir), x.vpAir, satVp(p.tMech)));
    
    %% Heat harvesting [1,2]
    % Latent heat harvest by the heat exchanger [W m^{-2}]
    % Equation 7.53 [1]
    addAux(gl, 'lAirMech', p.L*gl.a.mvAirMech);
    
    % Heat flux from cold buffer to heat pump [W m^{-2}]
    % Equation 30 [2], Equation 7.62 [1]
    addAux(gl, 'hBufColdHeatPump', (p.copHeatPump-1)*u.heatPump*p.pHeatPump);
    
    % Heat flux from heat pump to hot buffer [W m^{-2}]
    % Equation 31 [2], Equation 7.63 [1]
    addAux(gl, 'hHeatPumpBufHot', p.copHeatPump*u.heatPump*p.pHeatPump);
    
    % Heat flux from hot buffer to pipes [W m^{-2}]
    % Equation 32 [2], Equation 7.65 [1]
    addAux(gl, 'hBufHotPipe', u.bufHot*p.pBufHot);
    
    % Decision on whether mechanical cooling and dehumidification is allowed to work
    % Chapter 5, Section 2.4, point 7 [1]
    % (0 - not allowed, 1 - allowed)
    addAux(gl, 'mechAllowed', ...
        proportionalControl(x.eBufCold, p.cBufSizeCold-0.03, -0.1*p.cBufSizeCold, 0, 1).* ...
        ... % if the cold buffer is full the mechanical cooling cannot run
        ... % because it doesn't have a cold surface
        ... % (0.03 is a correction that prevents overshoot)
        proportionalControl(x.tAir, p.tMech, 1, 0, 1).* ...
        ... % mechanical cooling doesn't work if air is colder than
        ... % the cold sheet of the mechanical cooler
        proportionalControl(x.vpAir, satVp(p.tMech), 50, 0, 1));
            % mechanical cooling doesn't work if air is dryer than the
            % saturation vapor pressure at the cold sheet
    
    % Decision on whether heating from buffer is allowed to run
    % Chapter 5, Section 2.4, point 6 [1]
    % (0 - not allowed, 1 - allowed)
    addAux(gl, 'hotBufAllowed', ...
        proportionalControl(x.eBufHot, 0, 0.1*gl.p.cBufSizeHot, 0, 1));
        % Only runs if the hot buffer is not empty 
        
    %% Add heat harvesting controls
    % Valve for the heat pump [0-1, 0 the heat pump is off, 1 the heat pump is at full capacity]
    gl.u.heatPump = proportionalControl(x.eBufHot, gl.p.cBufSizeHot-0.03, -0.1*gl.p.cBufSizeHot, 0, 1).*...
        ... % Only runs if hot buffer is not full 
        ... % (0.03 is a correction that prevents overshoot)
        proportionalControl(x.eBufCold, 0, 0.1*gl.p.cBufSizeCold, 0, 1);
            % And the cold buffer is not empty
            
    gl.u.heatPump.val = 0; % initial value for the heat pump control
    
    % Valve for mechanical cooling and dehumidification (MCD)
    % [0-1, 0 the MCD is off, 1 the MCD is at full capacity] 
    gl.u.mech = min(gl.a.ventCold, ... % don't run if it's too cold inside
        gl.a.mechAllowed.* ...
        ... % mechanical cooling can technically work
        max( ... % and there is need for it
        proportionalControl(x.tAir, gl.a.heatSetPoint+gl.p.mechCoolDeadZone, gl.p.mechCoolPband, 0, 1),...
        ... % need to cool
        proportionalControl(gl.a.rhIn, gl.p.rhMax, gl.p.mechDehumidPband, 0, 1)));
            % or need to dehumidify
            
    gl.u.mech.val = 0; % initial value for mechanical heating and cooling
    
    % Valve from hot buffer to heating pipes
    %[0-1, 0 no heating from hot buffer to pipes, 1 heating from hot buffer is at full capacity]
    gl.u.bufHot = gl.a.hotBufAllowed.* ...
        ... % hot buffer is not empty 
        proportionalControl(x.tAir, gl.a.heatSetPoint, gl.p.heatBufPband, 0, 1);
            % and there is need for heating
            
    gl.u.bufHot.val = 0; % initial value for the valve from the hot buffer to heating pipes
        
    % Modification of heating from boiler [0 is no heating, 1 is full heating]
    gl.u.boil = proportionalControl(x.tAir, ...
        gl.a.heatSetPoint+gl.a.hotBufAllowed.*2*gl.p.heatBufPband, ...
        gl.p.tHeatBand, 0, 1);
        % the setpoint on when to start heating depends on the hot buffer:
        % if it is on (a.hotBufAllowed == 1), start heating only when buffer
        % reached full capacity. If it is off (a.hotBufAllowed == 0)
        % start at the normal setpoint.
        % If no buffer exists, hotBufAllowed is always 0
        
    gl.u.boil.val = 0; % initial value for heating from boiler
    
    % Modificatinon of heating to grow pipes [0 is no heating, 1 is full heating]
    gl.u.boilGro = proportionalControl(x.tAir, ...
        gl.a.heatSetPoint+gl.a.hotBufAllowed.*2*gl.p.heatBufPband, ...
        gl.p.tHeatBand, 0, 1);
        % the setpoint of when to start heating depends on the hot buffer:
        % if it is on (a.hotBufAllowed == 1), start heating only when buffer
        % reached full capacity. If it is off (a.hotBufAllowed == 0)
        % start at the normal setpoint.
        % If no buffer exists, hotBufAllowed is always 0
        
    gl.u.boilGro.val = 0; % initial value for heating from boiler to grow pipes
    
    %% Define ODEs for heat harvesting states
    a = gl.a; % shorthand for easier reading
    
    % Energy content of cold water buffer [MJ m^{-2}]
    % Equation 8 [2], Equation 7.60 [1]
    setOde(gl, 'eBufCold', 1e-6*(a.hAirMech+a.lAirMech-a.hBufColdHeatPump));
    
    % Energy content of hot water buffer [MJ m^{-2}]
    % Equation 9 [2], Equation 7.61 [1]
    setOde(gl, 'eBufHot', 1e-6*(a.hHeatPumpBufHot-a.hBufHotPipe)); 
    
    %% Set initial values for heat harvesting states
    % Assume the buffers are full at the beginning of the simulation
    gl.x.eBufHot.val = gl.p.cBufSizeHot.val;
    gl.x.eBufCold.val = gl.p.cBufSizeCold.val;