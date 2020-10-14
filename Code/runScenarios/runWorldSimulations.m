% RUNWORLDSIMULATIONS Simulate an HPS and LED greenhouse in different
% climate scenarios around the world
% Used to generate the data in: 
%   Katzin, Marcelis, Van Mourik, "Energy savings in greenhouses by
%   transition from HPS to LED lighting" (submitted)
% Note that the simulations in this file take a long time. You can split
% them across multiple machines by commenting out sections and only running
% some sections on each machine

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

locations = {'cal','win','bei','sha','che','uru',...
    'ven','ams','tok','ark','mos','stp','sam','kir','anc'};
firstDay = 270; % Day of year where season starts (default is 270)
seasonLength = 350; % Length of season (days) (default is 350)

% Set directories for loading data and saving output
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
dataFolder = strrep(currentFolder, '\GreenLight\Code\runScenarios', ...
    '\GreenLight\Code\inputs\energyPlus\data\');
outputFolder = strrep(currentFolder, '\GreenLight\Code\runScenarios', ...
    '\GreenLight\Output\');
    
% %% Reference setting
% fileLabel = 'referenceSetting';
% for k=length(locations):-1:1
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
% %     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel]);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel]);
% end

% %% Heat adjustment under LEDs
% fileLabel = 'heatAdjustment';
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     paramNames = "heatCorrection";
%     paramVals = 1;
%     
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end
% 
% %% more light hours
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'moreLightHours';
% paramNames = ["lampsOffSun" "lampRadSumLimit"];
% paramVals = [600 14];  
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramVals);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end
% 
% %% Colder
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'colder';
% paramNames = ["tSpNight" "tSpDay"];
% paramVals = [16.5 17.5];
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramVals);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end
% 
% %% Warmer
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'warmer';
% paramNames = ["tSpNight" "tSpDay"];
% paramVals = [20.5 21.5];
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramVals);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end
% 
%% Low insulation
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'lowInsulation';
% paramNames = ["cLeakage" "hRf"];
% paramVals = [2e-4 2e-3];
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramVals);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end

% %% High insulation
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'highInsulation';
% paramNames = ["cLeakage" "hRf"];
% paramVals = [0.5e-4 8e-3];
% 
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramVals);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramVals);
% end

% %% PPFD 100
% locations = {'cal', 'ams', 'che'};
% fileLabel = 'ppfd100';
% paramNames = ["tauLampPar" "tauLampNir" "tauLampFir" "aLamp" "thetaLampMax" "capLamp" "cHecLampAir"];
% paramValsHps = [0.99 0.99 0.99 0.01 100/1.8 50 0.045];
% paramValsLed = [0.99 0.99 0.99 0.01 100/3 5 1.15];
% for k=1:length(locations)
%     % load climate data and cut it to requested season size
%     season = cutEnergyPlusData(firstDay, seasonLength, ...
%         [dataFolder locations{k} 'EnergyPlus.mat']);
%     
%     runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
%         paramNames, paramValsHps);
%     runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
%         paramNames, paramValsLed);
% end
% 
%% PPFD 400
locations = {'che', 'ams', 'cal'};
fileLabel = 'ppfd400';
paramNames = ["tauLampPar" "tauLampNir" "tauLampFir" "aLamp" "thetaLampMax" "capLamp" "cHecLampAir"];
paramValsHps = [0.96 0.96 0.96 0.04 400/1.8 200 0.18];
paramValsLed = [0.96 0.96 0.96 0.04 400/3 20 4.6];
for k=1:length(locations)
    % load climate data and cut it to requested season size
    season = cutEnergyPlusData(firstDay, seasonLength, ...
        [dataFolder locations{k} 'EnergyPlus.mat']);
    
    runGreenLight('hps', season, [outputFolder locations{k} '_hps_' fileLabel],...
        paramNames, paramValsHps);
    runGreenLight('led', season, [outputFolder locations{k} '_led_' fileLabel],...
        paramNames, paramValsLed);
end