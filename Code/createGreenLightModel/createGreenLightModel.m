function gl = createGreenLightModel(lampType, weather, startTime, controls, indoor)
%CREATEGREENLIGHTMODEL Create a DynamicModel object based on the GreenLight model
% The GreenLight model is based on the model by Vanthoor et al, with the addition
% of toplights, interlights, grow pipes, and a blackout screen.
%
% Literature used:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363-377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378-395 (2011).
% 	In particular note the electronic appendices of these two publications.
% These are also available in
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
% Additionaly:
%   [4] Katzin, D., van Mourik, S., Kempkes, F., & 
%       van Henten, E. J. (2020). GreenLight – An open source model for 
%       greenhouses with supplemental lighting: Evaluation of heat requirements 
%       under LED and HPS lamps. Biosystems Engineering, 194, 61–81. 
%       https://doi.org/10.1016/j.biosystemseng.2020.03.010
%
% Function inputs:
%   lampType        Type of lamps in the greenhouse. Choose between 
%                   'hps', 'led', or 'none' (default is none)
%   weather         A matrix with 8 columns, in the following format:
%       weather(:,1)    timestamps of the input [s] in regular intervals
%       weather(:,2)    radiation     [W m^{-2}]  outdoor global irradiation 
%       weather(:,3)    temperature   [°C]        outdoor air temperature
%       weather(:,4)    humidity      [kg m^{-3}] outdoor vapor concentration
%       weather(:,5)    co2 [kg{CO2} m^{-3}{air}] outdoor CO2 concentration
%       weather(:,6)    wind        [m s^{-1}] outdoor wind speed
%       weather(:,7)    sky temperature [°C]
%       weather(:,8)    temperature of external soil layer [°C]
%       weather(:,9)    daily radiation sum [MJ m^{-2} day^{-1}]
%
%   startTime       date and time of starting point (datetime)
%
%   controls        (optional) A matrix with 8 columns, in the following format:
%       controls(:,1)     timestamps of the input [s] in regular intervals of 300, starting with 0
%       controls(:,2)     Energy screen closure 			0-1 (1 is fully closed)
%       controls(:,3)     Black out screen closure			0-1 (1 is fully closed)
%       controls(:,4)     Average roof ventilation aperture	(average between lee side and wind side)	0-1 (1 is fully open)
%       controls(:,5)     Pipe rail temperature 			°C
%       controls(:,6)     Grow pipes temperature 			°C
%       controls(:,7)     Toplights on/off                  0/1 (1 is on)
%       controls(:,8)     Interlight on/off                 0/1 (1 is on)
%       controls(:,9)     CO2 injection                     0/1 (1 is on)
%
%   indoor          (optional) A 3 column matrix with:
%       indoor(:,1)     timestamps of the input [s] in regular intervals of 300, starting with 0
%       indoor(:,2)     temperature       [°C]             indoor air temperature
%       indoor(:,3)     vapor pressure    [Pa]             indoor vapor concentration
%       indoor(:,4)     co2 concentration [mg m^{-3}]      indoor co2 concentration

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    if ~exist('lampType','var') || isempty(lampType)
        lampType = 'none';
    end
    if ~exist('indoor','var')
        indoor = [];
    end
    if strcmpi(lampType, 'hps')
        lampType = 'hps';
    elseif strcmpi(lampType, 'led')
        lampType = 'led';
    else
        lampType = 'none';
    end

    gl = DynamicModel();
    setTime(gl, datestr(startTime), 0);
    setGlParams(gl); % define parameters and nominal values based on the Vanthoor model
    setGlInput(gl, weather);  % define and set inputs
    setGlTime(gl, startTime); % define time phase
    setGlControls(gl); % define controls
    setGlStates(gl); % define states 
    
    % set parameters according to lamp type
    setDefaultLampParams(gl, lampType); % hps, led, or none
    
    if exist('controls','var') && ~isempty(controls)
        ruleBased = false; % controls are given as inputs
        
        % add control trajectories
        time = controls(:,1);
        addControl(gl, 'thScr', [time controls(:,2)]);
        addControl(gl, 'blScr', [time controls(:,3)]); 
        addControl(gl, 'roof', [time controls(:,4)]);
        
        % The pipe temperatures are defined as inputs
		addInput(gl, 'tPipe', [time controls(:,5)]);
        addInput(gl, 'tGroPipe', [time controls(:,6)]);
        
        % is 1 if pipe is about to be switched off
        addInput(gl, 'pipeSwitchOff', ...
            [time ((controls(:,5)~=0) & (circshift(controls(:,5),-1)==0))]);
        
        % is 1 if grow pipe is about to be switched off
        addInput(gl, 'groPipeSwitchOff', ...
            [time ((controls(:,6)~=0) & (circshift(controls(:,6),-1)==0))]);
        
        addControl(gl, 'lamp', [time controls(:,7)]);
        addControl(gl, 'extCo2', [time controls(:,9)]);
        addControl(gl, 'intLamp', [time controls(:,8)]);

        % controls not considered
        addControl(gl, 'boil', [time zeros(size(time))]);
        addControl(gl, 'shScrPer', [time zeros(size(time))]);
        addControl(gl, 'side', [time zeros(size(time))]);
        addControl(gl, 'boilGro', [time zeros(size(time))]);
        addControl(gl, 'shScr', [time zeros(size(time))]);
    else
        ruleBased = true;
    end
        
    setGlAux(gl); % define auxiliary states
    
    if ruleBased
        setGlControlRules(gl); % define control rules
    end
    
    setGlOdes(gl); % define odes - must be done after the aux states and control rules are set
    setGlInit(gl, indoor); % set initial values for the states
end