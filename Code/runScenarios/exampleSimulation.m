% EXAMPLESIMULATION Run the GreenLight simulation under different lamp settings

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

tic;

seasonLength = 10; % season length in days 
firstDay = 1; % days since beginning of data (01-01-2000)

[weather, startTime] = loadSelYearHiRes(firstDay, seasonLength);

secsInYear = seconds(startTime-datetime(year(startTime),1,1,0,0,0));
    % number of seconds since beginning of year to startTime

weather(:,8) = soilTempNl(secsInYear+weather(:,1)); % add soil temperature

% Create an instance of GreenLight with the default Vanthoor parameters
hps = createGreenLightModel('hps', weather, startTime);

led = createGreenLightModel('led', weather, startTime);

ledCool = DynamicModel(led);
setParam(ledCool, 'etaLampCool', 0.4); % LED with cooling

%% Run simulation
solveFromFile(hps, 'ode15s');
solveFromFile(led, 'ode15s');
solveFromFile(ledCool, 'ode15s');

hps = changeRes(hps,300); % set data to a fixed step size (5 minutes)
led = changeRes(led,300);
ledCool = changeRes(ledCool,300);

%% Plot
plot(hps.x.tAir);
hold on
plot(hps.x.tLamp);
plot(led.x.tLamp);
plot(ledCool.x.tLamp);
title('Temperature (°C)');
legend('Air', 'HPS', 'LED', 'LED cooling');
toc;