% evaluateClimateModelHps Evaluate the GreenLight climate model under HPS
% Runs the model with parameter values representing an HPS compartment in
% Bleiswijk, The Netherlands in 2010. Data is loaded from this trial and
% compared to the simulated data
% Used in: 
%   Katzin, D., van Mourik, S., Kempkes, F., & 
%       van Henten, E. J. (2020). GreenLight – An open source model for 
%       greenhouses with supplemental lighting: Evaluation of heat requirements 
%       under LED and HPS lamps. Biosystems Engineering, 194, 61–81. 
%       https://doi.org/10.1016/j.biosystemseng.2020.03.010

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com


%% Set up the model
simType = 'hps';

seasonLength = 112; % season length in days (data length is 112 days)
firstDay = 1; % days since beginning of data

[outdoor, indoor, controls, startTime, filtInd] = loadGreenhouseData(firstDay, seasonLength, simType);

indoor(:,3) = vaporDens2pres(indoor(:,2), indoor(:,3));
        % convert vapor density to vapor pressure

indoor(:,4) = 1e6*co2ppm2dens(indoor(:,2),indoor(:,4));
        % convert co2 from ppm to mg m^{-3}
 
% DynamicElements for the measured data
v.tAir = DynamicElement('v.tAir', [floor(indoor(:,1)) indoor(:,2)]);
v.vpAir = DynamicElement('v.vpAir', [floor(indoor(:,1)) indoor(:,3)]);
v.co2Air = DynamicElement('v.co2Air', [floor(indoor(:,1)) indoor(:,4)]);
	
secsInYear = seconds(startTime-datetime(year(startTime),1,1,0,0,0));
    % number of seconds since beginning of year to startTime

outdoor(:,7) = skyTempRdam(outdoor(:,3), datenum(startTime)+outdoor(:,1)/86400); % add sky temperature
outdoor(:,8) = soilTempNl(secsInYear+outdoor(:,1)); % add soil temperature

hps = createGreenLightModel('none', outdoor, startTime, controls, indoor);
setParamsBleiswijk2010(hps);
setBleiswijk2010HpsParams(hps); % set lamp params

% Set initial values for crop
hps.x.cLeaf.val = 0.7*6240*10;
hps.x.cStem.val = 0.25*6240*10;
hps.x.cFruit.val = 0.05*6240*10;

%% Solve
solveFromFile(hps, 'ode15s');

mesInterval = v.tAir.val(2,1)-v.tAir.val(1,1); % the interval (seconds) of the measurement data
hps = changeRes(hps,mesInterval); % set resolution of trajectories equal to that of the measurement data

%% Get RRMSEs between simulation and measurements
% Check that the measured data and the simulations have the same size. 
% If one of them is bigger, some data points of the longer dataset will be
% discarded
mesLength = length(v.tAir.val(:,1)); % the length (array size) of the measurement data
simLength = length(hps.x.tAir.val(:,1)); % the length (array size) of the simulated data
compareLength = min(mesLength, simLength);

rrmseTair = sqrt(mean((hps.x.tAir.val(1:compareLength,2)-v.tAir.val(:,2)).^2))./mean(v.tAir.val(1:compareLength,2));
rrmseVpair = sqrt(mean((hps.x.vpAir.val(1:compareLength,2)-v.vpAir.val(1:compareLength,2)).^2))./mean(v.vpAir.val(1:compareLength,2));
rrmseCo2air  = sqrt(mean((hps.x.co2Air.val(1:compareLength,2)-v.co2Air.val(1:compareLength,2)).^2))./mean(v.co2Air.val(:,2));

save hpsClimate