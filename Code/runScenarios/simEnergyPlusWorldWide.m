% Run all the locations for simEnergyPlus

% Reference setting
%% hps

locations = {'ams','cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
fileLabel = 'newParams4ha';
for k=1:1
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false);%, paramNames, paramVals);
end

%% led
locations = {'cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
fileLabel = 'newParams4ha';
for k=1:15
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false);%, paramNames, paramVals);
end

%% more light hours
locations = {'cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
fileLabel = 'moreLightHours';
paramNames = ["lampsOffSun" "lampRadSumLimit"];
paramVals = [600 14];   
for k=1:7
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

%% LED heat adjustment
locations = {'cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
fileLabel = 'heatAdj';
paramNames = "heatCorrection";
paramVals = 1;   
for k=1:15
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

%% Higher RH
locations = {'cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
fileLabel = 'highRh';
paramNames = "rhMax";
paramVals = 92;   
for k=1:15
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

% Edge cases
% Colder
locations = {'cal', 'ams', 'che'};
fileLabel = 'colder';
paramNames = ["tSpNight" "tSpDay"];
paramVals = [16.5 17.5];

for k=1:3
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

%% Warmer
locations = {'cal', 'ams', 'che'};
fileLabel = 'warmer';
paramNames = ["tSpNight" "tSpDay"];
paramVals = [20.5 21.5];

for k=1:3
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end


% Low insulation
locations = {'cal', 'ams', 'che'};
fileLabel = 'lowInsulation';
paramNames = ["cLeakage" "hRf"];
paramVals = [2e-4 2e-3];

for k=1:3
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

% High insulation
locations = {'cal', 'ams', 'che'};
fileLabel = 'highInsulation';
paramNames = ["cLeakage" "hRf"];
paramVals = [0.5e-4 8e-3];

for k=1:3
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramVals);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramVals);
end

%% PPFD 100
locations = {'cal', 'ams', 'che'};
fileLabel = 'ppfd100';
paramNames = ["tauLampPar" "tauLampNir" "tauLampFir" "aLamp" "thetaLampMax" "capLamp" "cHecLampAir"];
paramValsHps = [0.99 0.99 0.99 0.01 100/1.8 50 0.045];
paramValsLed = [0.99 0.99 0.99 0.01 100/3 5 1.15];
for k=1:length(locations)
   simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramValsHps);
   simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramValsLed);
end

% PPFD 400
locations = {'che', 'ams', 'cal'};
fileLabel = 'ppfd400';
paramNames = ["tauLampPar" "tauLampNir" "tauLampFir" "aLamp" "thetaLampMax" "capLamp" "cHecLampAir"];
paramValsHps = [0.96 0.96 0.96 0.04 400/1.8 200 0.18];
paramValsLed = [0.96 0.96 0.96 0.04 400/3 20 4.6];
for k=2:length(locations)
    simEnergyPlus(locations{k}, 'hps', 350, 270, fileLabel, false, paramNames, paramValsHps);
    simEnergyPlus(locations{k}, 'led', 350, 270, fileLabel, false, paramNames, paramValsLed);
end
