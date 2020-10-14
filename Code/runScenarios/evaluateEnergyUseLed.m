% evaluateEnergyUseLed Evaluate the GreenLight energy use model under LED
% Runs the model with parameter values representing an LED compartment in
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
simType = 'led';

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

led = createGreenLightModel('none', outdoor, startTime, controls, indoor);
setParamsBleiswijk2010(led);
setBleiswijk2010LedParams(led); % set lamp params


% don't load pipe temperature data
led.d.tPipe.val(:,2) = zeros(size(led.d.tPipe.val(:,2)));
led.d.tGroPipe.val(:,2) = zeros(size(led.d.tGroPipe.val(:,2)));

% instead use the measured temperature as a setpoint
led.d.heatSetPoint = DynamicElement('d.heatSetPoint', indoor(:,1:2));

% dummy variable to ensure the definition of u.boil is correct
x.tAir = DynamicElement('x.tAir',led.x.tAir.val);

% Heating from boiler [0 is no heating, 1 is full heating]
addControl(led, 'boil', proportionalControl(x.tAir, led.d.heatSetPoint+setPointAdd, led.p.tHeatBand, 0, 1));
setVal(led.u.boil, []);

% Control of grow pipes is same as control of pipe rail
addControl(led, 'boilGro', proportionalControl(x.tAir, led.d.heatSetPoint+setPointAdd, led.p.tHeatBand, 0, 1));
setVal(led.u.boilGro, []);

led.p.pBoil.val = 125*led.p.aFlr.val;
led.p.pBoilGro.val = 125*led.p.aFlr.val;

% Initial values for the crop
led.x.cLeaf.val = 0.7*6240*10;
led.x.cStem.val = 0.25*6240*10;
led.x.cFruit.val = 0.05*6240*10;

%% test
setParam(led, 'cHecIn', 5);

%% Solve
solveFromFile(led, 'ode15s');
led = changeRes(led,300); % set resolution of trajectories at 5 minutes

%% Compare simulation to measured data

% Set pipe temperatures as inputs
led.d.tPipe.val(:,2) = controls(:,5);
led.d.tGroPipe.val(:,2) = controls(:,6);

% calculate energy input from data
% uPipe is the measured energy input to the pipe rail in W/m2
led.d.uPipe = DynamicElement('d.uPipe', ...
    [led.d.tPipe.val(:,1), pipeEnergy(controls(:,5)-indoor(:,2))]);

% uGroPipe is the measured energy input to the grow pipes in W/m2
led.d.uGroPipe = DynamicElement('d.uGroPipe', ...
    [led.d.tPipe.val(:,1), groPipeEnergy(controls(:,6)-indoor(:,2))]);

%% Plot
plot(cumsum(led.a.hBoilPipe+led.a.hBoilGroPipe)); % simulated heat input
hold on
plot(cumsum(led.d.uPipe+led.d.uGroPipe)); % measured heat input
legend('simulated','calculated from data');

%% Calculate relative error ratio
eMeas = 1e-6*trapz(led.d.uPipe+led.d.uGroPipe);
eSim = 1e-6*trapz(led.a.hBoilPipe+led.a.hBoilGroPipe);
errorRatio = eSim./eMeas;

toc;

save ledEnergy