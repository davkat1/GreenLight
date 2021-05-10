function setHeatByLightParams(gl, lampType, ppfd, intPpfd)
%SETHATBYLIGHTPARAMS Set parameters for running simulations testing heating by light
% Usage: 
%   setHeatByLightParams(gl, lampType, ppfd)
% Inputs:
%   gl - an instance of a GreenLight model
%   lampType - 'led', 'hps', or 'none'
%   ppfd - intensity of the lamp [µmol {PAR} m^{-2} s^{-1}]
%
% Used to generate simulations in Chapter 5 of:
%   [1] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % Double sink strength (Section Chapter 5 Section 2.3.3, Table 7.6 [1])
    setParam(gl, 'rgFruit', 0.328*2);
    setParam(gl, 'rgLeaf', 0.095*2);
    setParam(gl, 'rgStem', 0.074*2);

    % Capapcity of the heating pipes (W per greenhouse) 
    setParam(gl, 'pBoil', 150*4e4); % The greenhouse  floor area is 4e4, 
                                    % so this is equivalent to 150 W m^{-2})
    
    % Size of the cold water energy buffer (MJ m^{-2})
    addParam(gl, 'cBufSizeCold', 2/3);
    
    % Size of the hot water energy buffer (MJ m^{-2})
    addParam(gl, 'cBufSizeHot', 4/3);
    
    % Day of year when lamps start (days since December 31)
    setParam(gl, 'dayLampStart', 260); % Lamps are allowed to start before the beginning of the season
    
    % Day of year when lamps stop (days since December 31)
    setParam(gl, 'dayLampStop', 144); % Lamps go off on May 24 
    
    % Daily radiation sum when lamps switch off (MJ m^{-2} day^{-1})
    setParam(gl, 'lampRadSumLimit', 1000); % This is high enough to remove influence of daily radiation sum
    
    % Lamp parameters
    % See Table 4.3, Table 5.1, Table 7.6 [1] 
    % The heat capacity and heat exchange coefficient of the lamps are
    % adjusted so that even if the lamps' intensity is changed, their
    % thermal behaviour remains equivalent
    if strcmp(lampType, 'led') % LEDs
        % Lamp efficacy [µmol{PAR} J^{-1}{input}]
        efficacy = 3; 
        
        % Fraction of input going to PAR [-]
        setParam(gl, 'etaLampPar', efficacy/5.41);
        
        % Heat capacity of lamp [J K^{-1} m^{-2}]
        setParam(gl, 'capLamp', ppfd/200*10);
        
        % Heat exchange coefficient of lamp [W K^{-1} m^{-2}]
        setParam(gl, 'cHecLampAir', ppfd/200*2.3);
        
    else % HPS lamp
        
        % Lamp efficacy [µmol{PAR} J^{-1}{input}]
        efficacy = 1.8;
        
        % Fraction of input going to PAR [-]
        setParam(gl, 'etaLampPar', efficacy/4.9);
        
        % Heat capacity of lamp [J K^{-1} m^{-2}]
        setParam(gl, 'capLamp', ppfd/200*100);
        
        % Heat exchange coefficient of lamp [W K^{-1} m^{-2}]
        setParam(gl, 'cHecLampAir', ppfd/200*0.09);
    end
    
    % Maximum energy consumption of the lamp (W m^{-2})
    setParam(gl, 'thetaLampMax', ppfd/efficacy);

    % Lamp area - assumes that changes in intensity are due to adding or
    % removing lamps
    setParam(gl, 'aLamp', ppfd/200*0.02);
    
    % No lamps
    if strcmp(lampType, 'none')
        setParam(gl, 'lampsOn', 0);
        setParam(gl, 'lampsOff', 0);
        setParam(gl, 'thetaLampMax', 0);
        setParam(gl, 'dayLampStart', -1);
        setParam(gl, 'dayLampStop', 400);
        setParam(gl, 'aLamp', 0);
    end
    
    % PAR transmissivity of the lamp layer - depends on area
    setParam(gl, 'tauLampPar', 1-gl.p.aLamp.val);
    
    % NIR transmissivity of the lamp layer - depends on area
    setParam(gl, 'tauLampNir', 1-gl.p.aLamp.val);
    
    % FIR transmissivity of the lamp layer - depends on area
    setParam(gl, 'tauLampFir', 1-gl.p.aLamp.val);
    
    %% Interlights
    if intPpfd > 0
        % Interlight parameters
        setParam(gl, 'capIntLamp', intPpfd/200*10);        % heat capacity of lamp 														[J K^{-1} m^{-2}]                       
        setParam(gl, 'etaIntLampPar', 3/5.41);                  % fraction of lamp input converted to PAR 														[-]                                     
        setParam(gl, 'etaIntLampNir', 0.02);                    % fraction of lamp input converted to NIR 														[-]                                     
        setParam(gl, 'aIntLamp', 0.02);                         % interlight lamp area from above and below																			[m^{2}{lamp} m^{-2}{floor}]             
        setParam(gl, 'epsIntLamp', 0.88);                       % emissivity of interlight [-]                                                                  assumed that lamps act the same as heating pipes
        setParam(gl, 'thetaIntLampMax', intPpfd/3);        % Maximum intensity of lamps																	[W m^{-2}]    
        setParam(gl, 'zetaIntLampPar', 5.41);                   % conversion from Joules to umol photons within the PAR output of the interlight
        setParam(gl, 'cHecIntLampAir', intPpfd/200*2.3);   % heat exchange coefficient of interlights                                                      [W m^{-2} K^{-1}]
        setParam(gl, 'tauIntLampFir', 0.98);                    % transmissivity of FIR through the interlights                                                 [-]                                           1
    end
    
end

