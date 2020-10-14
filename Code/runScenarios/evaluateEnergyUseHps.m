% evaluateEnergyUseHps Evaluate the GreenLight energy use model under HPS
% Runs the model with parameter values representing an HPS compartment in
% Bleiswijk, The Netherlands in 2010. Data is loaded from this trial and
% the heating
% Used in: 
%   Katzin, D., van Mourik, S., Kempkes, F., & 
%       van Henten, E. J. (2020). GreenLight – An open source model for 
%       greenhouses with supplemental lighting: Evaluation of heat requirements 
%       under LED and HPS lamps. Biosystems Engineering, 194, 61–81. 
%       https://doi.org/10.1016/j.biosystemseng.2020.03.010

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

tic;

%% Set up the model
setPointAdd = 0.5; % Addition to the set point to make sure the proportional controller really achieves the desired temperature
simType = 'hps';

seasonLength = 112; % season length in days (data length is 112 days)
firstDay = 1; %15*ones(1,numSim); % days since beginning of data        

[outdoor, indoor, controls, startTime] = loadGreenhouseData(firstDay, seasonLength, simType);

indoor(:,3) = vaporDens2pres(indoor(:,2), indoor(:,3));
        % convert vapor density to vapor pressure

indoor(:,4) = 1e6*co2ppm2dens(indoor(:,2),indoor(:,4));
        % convert co2 from ppm to mg m^{-3}

secsInYear = seconds(startTime-datetime(year(startTime),1,1,0,0,0));
    % number of seconds since beginning of year to startTime

outdoor(:,7) = skyTempRdam(outdoor(:,3), datenum(startTime)+outdoor(:,1)/86400); % add sky temperature
outdoor(:,8) = soilTempNl(secsInYear+outdoor(:,1)); % add soil temperature

hps = createGreenLightModel('none', outdoor, startTime, controls, indoor);
setParamsBleiswijk2010(hps);
setBleiswijk2010HpsParams(hps); % set lamp params

% don't load pipe temperature data
hps.d.tPipe.val(:,2) = zeros(size(hps.d.tPipe.val(:,2)));
hps.d.tGroPipe.val(:,2) = zeros(size(hps.d.tGroPipe.val(:,2)));

% instead use the measured temperature as a setpoint
hps.d.heatSetPoint = DynamicElement('d.heatSetPoint', indoor(:,1:2));

% dummy variable to ensure the definition of u.boil is correct
x.tAir = DynamicElement('x.tAir',hps.x.tAir.val);

% Heating from boiler [0 is no heating, 1 is full heating]
addControl(hps, 'boil', proportionalControl(x.tAir, hps.d.heatSetPoint+setPointAdd, hps.p.tHeatBand, 0, 1));
setVal(hps.u.boil, []);

% Control of grow pipes is same as control of pipe rail
addControl(hps, 'boilGro', proportionalControl(x.tAir, hps.d.heatSetPoint+setPointAdd, hps.p.tHeatBand, 0, 1));
setVal(hps.u.boilGro, []);

hps.p.pBoil.val = 125*hps.p.aFlr.val;
hps.p.pBoilGro.val = 125*hps.p.aFlr.val;

% Initial values for the crop
hps.x.cLeaf.val = 0.7*6240*10;
hps.x.cStem.val = 0.25*6240*10;
hps.x.cFruit.val = 0.05*6240*10;

%% Solve
solveFromFile(hps, 'ode15s');
hps = changeRes(hps,300); % set resolution of trajectories at 5 minutes

%% Compare simulation to measured data

% Set pipe temperatures as inputs
hps.d.tPipe.val(:,2) = controls(:,5);
hps.d.tGroPipe.val(:,2) = controls(:,6);

% calculate energy input from data
% uPipe is the measured energy input to the pipe rail in W/m2
hps.d.uPipe = DynamicElement('d.uPipe', ...
    [hps.d.tPipe.val(:,1), pipeEnergy(controls(:,5)-indoor(:,2))]);

% uGroPipe is the measured energy input to the grow pipes in W/m2
hps.d.uGroPipe = DynamicElement('d.uGroPipe', ...
    [hps.d.tPipe.val(:,1), groPipeEnergy(controls(:,6)-indoor(:,2))]);

%% Plot
plot(cumsum(hps.a.hBoilPipe+hps.a.hBoilGroPipe)); % simulated heat input
hold on
plot(cumsum(hps.d.uPipe+hps.d.uGroPipe)); % measured heat input
legend('simulated','calculated from data');

%% Calculate relative error ratio
eMeas = 1e-6*trapz(hps.d.uPipe+hps.d.uGroPipe);
eSim = 1e-6*trapz(hps.a.hBoilPipe+hps.a.hBoilGroPipe);
errorRatio = eSim./eMeas;

toc;

save hpsEnergy