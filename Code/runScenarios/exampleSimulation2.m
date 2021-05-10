% EXAMPLESIMULATION2 Run the GreenLight simulation using predefined inputs and settings

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Set directories for loading data and saving output
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
dataFolder = strrep(currentFolder, '\Code\runScenarios', ...
    '\Code\inputs\energyPlus\data\');
outputFolder = strrep(currentFolder, '\Code\runScenarios', ...
    '\Output\');

%% Weather input settings
weatherInput = 'bei'; % Choose name of location, see folder inputs\energyPlus\data\
seasonLength = 1;   % season length in days
firstDay = 1;       % Beginning of season (days since January 1)

%% Crop settings
isMature = true; % Start with a mature crop, use false to start with a small crop

%% Choice of lamp
lampType = 'led'; % 'led', 'hps', or 'none'

%% Greenhouse structure settings
% More settings available in setGlParams
p.psi = 22;                     % Mean greenhouse cover slope [°]
p.aFlr = 4e4;                   % Floor area of  [m^{2}]
p.aCov = 4.84e4;                % Surface of the cover including side walls [m^{2}]
p.hAir = 6.3;                   % Height of the main compartment [m] (the ridge height is 6.5, screen is 20 cm below it)
p.hGh = 6.905;                  % Mean height of the greenhouse [m]
p.aRoof = 0.1169*4e4;           % Maximum roof ventilation area 
p.hVent = 1.3;                  % Vertical dimension of single ventilation opening [m]
p.cDgh = 0.75;                  % Ventilation discharge coefficient [-]          
p.lPipe = 1.25;                 % Length of pipe rail system [m m^{-2}]
p.phiExtCo2 = 7.2e4*4e4/1.4e4;  % Capacity of CO2 injection for the entire greenhouse [mg s^{-1}] 
p.pBoil = 300*p.aFlr;           % Capacity of boiler for the entire greenhouse [W]

%% Control settings
% More settings available in setGlParams
p.co2SpDay = 1000;          % CO2 setpoint during the light period [ppm]
p.tSpNight = 18.5;          % temperature set point dark period [°C]
p.tSpDay = 19.5;            % temperature set point light period [°C]
p.rhMax = 87;               % maximum relative humidity [%]
p.ventHeatPband = 4;        % P-band for ventilation due to high temperature [°C]
p.ventRhPband = 50;         % P-band for ventilation due to high relative humidity [% humidity]
p.thScrRhPband = 10;        % P-band for screen opening due to high relative humidity [% humidity]
p.lampsOn = 0;              % time of day (in morning) to switch on lamps [h]
p.lampsOff = 18;            % time of day (in evening) to switch off lamps 	[h]
p.lampsOffSun = 400;        % lamps are switched off if global radiation is above this value [W m^{-2}]
p.lampRadSumLimit = 10;     % Predicted daily radiation sum from the sun where lamps are not used that day [MJ m^{-2} day^{-1}]

%% Run simulation
% Modify parameters based on the sections above
if exist('p', 'var') && ~isempty(p)
    paramNames = string(fieldnames(p));
    paramVals = zeros(size(paramNames));
    for k=1:length(paramVals)
        paramVals(k) = p.(paramNames{k});
    end
else
    paramNames = [];
    paramVals = [];
end 

tic;
filename = ''; % add file name for saving file

if ~isempty(filename)
    filename = [outputFolder filename];
end
season = cutEnergyPlusData(firstDay, seasonLength, [dataFolder weatherInput 'EnergyPlus.mat']);
gl = runGreenLight(lampType, season, filename, paramNames, paramVals, isMature);
toc;

%% Plot some outputs 
% see setGlAux, setGlStates, setGlInput to see more options

dateFormat = 'HH:00'; 
% This format can be changed, see help file for MATLAB function datestr

subplot(3,4,1)
plot(gl.x.tAir)
hold on
plot(gl.d.tOut)
ylabel('Temperature (°C)')
legend('Indoor','Outdoor')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,2)
plot(gl.x.vpAir)
hold on
plot(gl.d.vpOut)
ylabel('Vapor pressure (Pa)')
legend('Indoor','Outdoor')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,3)
plot(gl.a.rhIn)
hold on
plot(100*vp2dens(gl.d.tOut,gl.d.vpOut)./rh2vaporDens(gl.d.tOut,100));
ylabel('Relative humidity (%)')
legend('Indoor','Outdoor')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,4)
plot(gl.x.co2Air)
hold on
plot(gl.d.co2Out)
ylabel('CO2 concentration (mg m^{-3})')
legend('Indoor','Outdoor')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,5)
plot(gl.a.co2InPpm)
hold on
plot(co2dens2ppm(gl.d.tOut,1e-6*gl.d.co2Out))
ylabel('CO2 concentration (ppm)')
legend('Indoor','Outdoor')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,6)
plot(gl.d.iGlob)
hold on
plot(gl.a.rParGhSun+gl.a.rParGhLamp)
plot(gl.a.qLampIn)
plot(gl.a.rParGhSun)
plot(gl.a.rParGhLamp)
legend('Outdoor global solar radiation','PAR above the canopy (sun+lamp)',...
'Lamp electric input','PAR above the canopy (sun)', 'PAR above the canopy (lamp)')
ylabel('W m^{-2}')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,7)
plot(gl.p.parJtoUmolSun*gl.a.rParGhSun)
hold on
plot(gl.p.zetaLampPar*gl.a.rParGhLamp)
legend('PPFD from the sun','PPFD from the lamp')
ylabel('umol (PAR) m^{-2} s^{-1}')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,9)
plot(gl.a.mcAirCan)
hold on
plot(gl.a.mcAirBuf)
plot(gl.a.mcBufAir)
plot(gl.a.mcOrgAir)
ylabel('mg m^{-2} s^{-1}')
legend('Net assimilation (CO_2)', 'Net photosynthesis (gross photosynthesis minus photorespirattion, CH_2O)',...
'Growth respiration (CH_2O)','Maintenance respiration (CH_2O)')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,10)
plot(gl.x.cFruit)
hold on
plot(gl.x.cStem)
plot(gl.x.cLeaf)
plot(gl.x.cBuf)
ylabel('mg (CH_2O) m^{-2}')
yyaxis right
plot(gl.a.lai)
ylabel('m^2 m^{-2}')
legend('Fruit dry weight','Stem dry weight','Leaf dry weight','Buffer content','LAI')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(3,4,11)
plot(gl.x.cFruit)
ylabel('mg (CH_2O) m^{-2}')
yyaxis right
plot(gl.a.mcFruitHar)
ylabel('mg (CH_2O) m^{-2} s^{-1}')
legend('Fruit dry weight','Fruit harvest')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);