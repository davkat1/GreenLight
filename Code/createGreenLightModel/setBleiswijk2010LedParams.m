function setBleiswijk2010LedParams(gl)
%SETBLEIWSWIJK2010LEDPARAMS Modify parameters for a GreenLight, according to a dataset with LED toplighting 
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
%   [3] Nelson, J. A., & Bugbee, B. (2015). Analysis of Environmental Effects 
%       on Leaf Temperature under Sunlight, High Pressure Sodium and Light 
%       Emitting Diodes. PLOS ONE, 10(10), e0138930. 
%       https://doi.org/10.1371/journal.pone.0138930
% 	[4] Frank Kempkes, personal communication

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
                                                % Parameter                                                                                     unit                    Value and reference
    %% Lamp parameters
    % LED
    setParam(gl, 'thetaLampMax', 116);                  % Maximum intensity of lamps																	[W m^{-2}]                              Pg. 48 [1] (measured capacity divided by 144 m2)
    setParam(gl, 'heatCorrection', 0);   			% correction for temperature setpoint when lamps are on 										[C]   									0
    setParam(gl, 'etaLampPar', 0.31);               % fraction of lamp input converted to PAR 														[-]                                     [3] gives 0.33 with a lamp of 1.7 umol/J. This lamp is 1.6 umol/J [2], i.e. 6% less efficient as the one in [3]
    setParam(gl, 'etaLampNir', 0.02);               % fraction of lamp input converted to NIR 														[-]                                     [3]
    setParam(gl, 'tauLampPar', 0.95);               % transmissivity of lamp layer to PAR 															[-]                                     Pg. 22 [1] (light loss due to armatures)
    setParam(gl, 'rhoLampPar', 0);                  % reflectivity of lamp layer to PAR 															[-]                                     0
    setParam(gl, 'tauLampNir', 0.95);               % transmissivity of lamp layer to NIR 															[-]                                     Pg. 22 [1] (light loss due to armatures)
    setParam(gl, 'rhoLampNir', 0);                  % reflectivity of lamp layer to NIR 															[-]                                     0
    setParam(gl, 'tauLampFir', 0.95);               % transmissivity of lamp layer to FIR 															[-]                                     Pg. 22 [1] (light loss due to armatures)
    setParam(gl, 'aLamp', 0.05);                    % lamp area 																					[m^{2}{lamp} m^{-2}{floor}]             Pg. 22 [1] (light loss due to armatures)
    setParam(gl, 'epsLampTop', 0.88);               % emissivity of top side of lamp 																[-]                                     assumed that lamps act the same as heating pipes
    setParam(gl, 'epsLampBottom', 0.88);            % emissivity of bottom side of lamp 															[-]                                     assumed that lamps act the same as heating pipes
    setParam(gl, 'capLamp', 10);                    % heat capacity of lamp 																		[J K^{-1} m^{-2}]                       
    setParam(gl, 'cHecLampAir', 2.3);                % heat exchange coefficient of lamp                                                             [W m^{-2} K^{-1}]                       
    setParam(gl, 'etaLampCool', 0.63);                 % fraction of lamp input removed by cooling                                                     [-]                                     Estimate based on pg. 50 [1]
    setParam(gl, 'zetaLampPar', 5.2);            % J to umol conversion of PAR output of lamp                                                    [umol{PAR} J^{-1}]                      Efficacy of 1.6 umol/J [2], divided by 0.31 fraction to PAR (see above)

    % Reset other parameters that may depend on parameters changed above
    setDepParams(gl);    
end

