% evaluateClimateModelHps Evaluate the GreenLight climate model under HPS
% Runs the model with parameter values representing an HPS compartment in
% Bleiswijk, The Netherlands in 2010. Data is loaded from this trial and
% compared to the simulated data

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com


%% Set up the model
simType = 'hps';

seasonLength = 112; % season length in days (data length is 112 days)
firstDay = 1; % 46 or 78 or 80.2 days since beginning of data        

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

hps = createGreenLightModel(outdoor, startTime, controls, indoor);
setParamsBleiswijk2010(hps);
feval(['set' upper(simType(1)) simType(2:end) 'Params'], hps); % set lamp params

% Set initial values for crop
hps.x.cLeaf.val = 0.7*6240*10;
hps.x.cStem.val = 0.25*6240*10;
hps.x.cFruit.val = 0.05*6240*10;

%% test
setParam(hps, 'cHecIn', 5);

%% Solve
solveFromFile(hps, 'ode15s');

hps = changeRes(hps,300); % set resolution of trajectories at 5 minutes

%% Get RRMSEs between simulation and measurements
rrmseTair = sqrt(mean((hps.x.tAir.val(:,2)-v.tAir.val(:,2)).^2))./mean(v.tAir.val(:,2));
rrmseVpair = sqrt(mean((hps.x.vpAir.val(:,2)-v.vpAir.val(:,2)).^2))./mean(v.vpAir.val(:,2));
rrmseCo2air  = sqrt(mean((hps.x.co2Air.val(:,2)-v.co2Air.val(:,2)).^2))./mean(v.co2Air.val(:,2));

save hpsClimate