% EXAMPLESIMULATION Run the GreenLight simulation under different lamp settings

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

tic;

seasonLength = 1; % season length in days 
firstDay = 1; % days since beginning of data (01-01-2000)

[weather, startTime] = loadSelYearHiRes(firstDay, seasonLength);

secsInYear = seconds(startTime-datetime(year(startTime),1,1,0,0,0));
    % number of seconds since beginning of year to startTime

weather(:,8) = soilTempNl(secsInYear+weather(:,1)); % add soil temperature

% Create an instance of GreenLight with the default Vanthoor parameters
hps = createGreenLightModel(weather, startTime);

led = DynamicModel(hps); % make a copy of hps

setHpsParams(hps); % Set up HPS lamps
setLedParams(led); % Set up LED lamps

ledNoCool = DynamicModel(led);
setParam(ledNoCool, 'etaLampCool', 0); % LED with no cooling

%% Run simulation
solveFromFile(hps, 'ode15s');
solveFromFile(led, 'ode15s');
solveFromFile(ledNoCool, 'ode15s');

hps = changeRes(hps,300); % set data to a fixed step size (5 minutes)
led = changeRes(led,300);
ledNoCool = changeRes(ledNoCool,300);

%% Plot
plot(hps.x.tAir);
hold on
plot(hps.x.tLamp);
plot(led.x.tLamp);
plot(ledNoCool.x.tLamp);
title('Temperature (°C)');
legend('Air', 'HPS', 'LED', 'LED no cooling');
toc;