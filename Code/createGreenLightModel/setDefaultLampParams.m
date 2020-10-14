function setDefaultLampParams(gl, lampType)
%SETDEFAULTLAMPPARAMS Set default settings for lamp type in the GreenLight model
% Inputs:
%   gl   - a DynamicModel object to be used as a GreenLight model
%   lampType - the lamp type to be used, either 'hps' or 'led' 
%           (other types will be ignored)
%
% Based on:
%   [1] Nelson, J. A., & Bugbee, B. (2014). Economic Analysis of Greenhouse 
%       Lighting: Light Emitting Diodes vs. High Intensity Discharge Fixtures. 
%       PLoS ONE, 9(6), e99010. https://doi.org/10.1371/journal.pone.0099010
%   [2] Nelson, J. A., & Bugbee, B. (2015). Analysis of Environmental Effects 
%       on Leaf Temperature under Sunlight, High Pressure Sodium and Light 
%       Emitting Diodes. PLOS ONE, 10(10), e0138930. 
%       https://doi.org/10.1371/journal.pone.0138930
%   [3] De Zwart, H. F., Baeza, E., Van Breugel, B., Mohammadkhani, V., & 
%       Janssen, H. (2017). De uitstralingmonitor.
%   [4] Katzin, D., van Mourik, S., Kempkes, F., & 
%       van Henten, E. J. (2020). GreenLight – An open source model for 
%       greenhouses with supplemental lighting: Evaluation of heat requirements 
%       under LED and HPS lamps. Biosystems Engineering, 194, 61–81. 
%       https://doi.org/10.1016/j.biosystemseng.2020.03.010
%   [5] Kusuma, P., Pattison, P. M., & Bugbee, B. (2020). From physics to 
%       fixtures to food: current and potential LED efficacy. 
%       Horticulture Research, 7(56). https://doi.org/10.1038/s41438-020-0283-7

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

%% HPS
    if strcmpi(lampType, 'hps')
       % Parameter                                      Description                                                                                    unit                                     Default value and reference
        setParam(gl, 'thetaLampMax', 200/1.8);          % Maximum intensity of lamps																	[W m^{-2}]                              200/1.8, Set to achieve a PPFD of 200 umol (PAR) m^{-2} s^{-1}
        setParam(gl, 'heatCorrection', 0);   			% correction for temperature setpoint when lamps are on 										[°C]   									0
        setParam(gl, 'etaLampPar', 1.8/4.9);            % fraction of lamp input converted to PAR 														[-]                                     1.8/4.9, Set to give a PPE of 1.8 umol (PAR) J^{-1} [1, including comments online]
        setParam(gl, 'etaLampNir', 0.22);               % fraction of lamp input converted to NIR 														[-]                                     0.22 [2]
        setParam(gl, 'tauLampPar', 0.98);               % transmissivity of lamp layer to PAR 															[-]                                     0.98 [3]
        setParam(gl, 'rhoLampPar', 0);                  % reflectivity of lamp layer to PAR 															[-]                                     0 [3, pg. 26]
        setParam(gl, 'tauLampNir', 0.98);               % transmissivity of lamp layer to NIR 															[-]                                     0.98 [3]
        setParam(gl, 'rhoLampNir', 0);                  % reflectivity of lamp layer to NIR 															[-]                                     0 
        setParam(gl, 'tauLampFir', 0.98);               % transmissivity of lamp layer to FIR 															[-]                                     0.98 
        setParam(gl, 'aLamp', 0.02);                    % lamp area 																					[m^{2}{lamp} m^{-2}{floor}]             0.02 [3, pg. 35]
        setParam(gl, 'epsLampTop', 0.1);                % emissivity of top side of lamp 																[-]                                     0.1 [4]
        setParam(gl, 'epsLampBottom', 0.9);             % emissivity of bottom side of lamp 															[-]                                     0.9 [4]
        setParam(gl, 'capLamp', 100);                   % heat capacity of lamp 																		[J K^{-1} m^{-2}]                       100 [4]
        setParam(gl, 'cHecLampAir', 0.09);              % heat exchange coefficient of lamp                                                             [W m^{-2} K^{-1}]                       0.09 [4] 
        setParam(gl, 'etaLampCool', 0);                 % fraction of lamp input removed by cooling                                                     [-]                                     0 (No cooling)
        setParam(gl, 'zetaLampPar', 4.9);           	% J to umol conversion of PAR output of lamp                                                    [umol{PAR} J^{-1}]                 		4.9 [2]
        setParam(gl, 'lampsOn', 0);                     % Time of day when lamps go on                                                                  [hour]                                  0
        setParam(gl, 'lampsOff', 18);                   % Time of day when lamps go off                                                                 [hour]                                  18
        
    %% LED
    elseif strcmpi(lampType, 'led')
        setParam(gl, 'thetaLampMax', 200/3);            % Maximum intensity of lamps																	[W m^{-2}]                              200/3, Set to achieve a PPFD of 200 umol (PAR) m^{-2} s^{-1}
        setParam(gl, 'heatCorrection', 0);   			% correction for temperature setpoint when lamps are on 										[°C]   									0
        setParam(gl, 'etaLampPar', 3/5.41);             % fraction of lamp input converted to PAR 														[-]                                     3/5.41, Set to give a PPE of 3 umol (PAR) J^{-1} [5]
        setParam(gl, 'etaLampNir', 0.02);               % fraction of lamp input converted to NIR 														[-]                                     0.02 [2]
        setParam(gl, 'tauLampPar', 0.98);               % transmissivity of lamp layer to PAR 															[-]                                     0.98 [3]
        setParam(gl, 'rhoLampPar', 0);                  % reflectivity of lamp layer to PAR 															[-]                                     0 [3, pg. 26]
        setParam(gl, 'tauLampNir', 0.98);               % transmissivity of lamp layer to NIR 															[-]                                     0.98 [3]
        setParam(gl, 'rhoLampNir', 0);                  % reflectivity of lamp layer to NIR 															[-]                                     0 
        setParam(gl, 'tauLampFir', 0.98);               % transmissivity of lamp layer to FIR 															[-]                                     0.98 
        setParam(gl, 'aLamp', 0.02);                    % lamp area 																					[m^{2}{lamp} m^{-2}{floor}]             0.02 [3, pg. 35]
        setParam(gl, 'epsLampTop', 0.88);               % emissivity of top side of lamp 																[-]                                     0.88 [4]
        setParam(gl, 'epsLampBottom', 0.88);            % emissivity of bottom side of lamp 															[-]                                     0.88 [4]
        setParam(gl, 'capLamp', 10);                    % heat capacity of lamp 																		[J K^{-1} m^{-2}]                       10 [4]
        setParam(gl, 'cHecLampAir', 2.3);               % heat exchange coefficient of lamp                                                             [W m^{-2} K^{-1}]                       2.3 [4]
        setParam(gl, 'etaLampCool', 0);                 % fraction of lamp input removed by cooling                                                     [-]                                     0
        setParam(gl, 'zetaLampPar', 5.41);              % J to umol conversion of PAR output of lamp                                                    [umol{PAR} J^{-1}]                      5.41, assuming 6% blue (450 nm) and 94% red (660 nm) [5]
        setParam(gl, 'lampsOn', 0);                     % Time of day when lamps go on                                                                  [hour]                                  0
        setParam(gl, 'lampsOff', 18);                   % Time of day when lamps go off                                                                 [hour]                                  18
    end
end