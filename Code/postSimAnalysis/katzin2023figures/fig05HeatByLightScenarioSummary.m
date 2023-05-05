% fig05HeatByLightScenarioSummary Present energy use, PAR light, yield, and energy efficiency of heating by light scenarios.
% Used to generate Figure 5 in:
%   Katzin, Marcelis, Van Henten, Van Mourik,
%   "Heating greenhouses by light: A novel concept for intensive greenhouse
%   production", Biosystems Engineering, 2023

% David Katzin, Wageningen University and Research, May 2023
% david.katzin@wur.nl
% david.katzin1@gmail.com

%% Collect data

% Folder where simulation outputs are stored
outputFolder = ['C:\Users\katzi001\OneDrive - Wageningen University & Research' ...
    '\git\gitwur\greenlight-new-led-opportunities\Output\20210415\'];

if outputFolder(end) ~= '\'
    outputFolder = [outputFolder '\'];
end

% List of files in outputFolder
files = dir(outputFolder);
files = files(3:end);

% coldHoursSummary has the following columns:
% filename, minTemp, coldHours
heatByLightSummary = {};

for k=1:length(files)
    fprintf('%d of %d... ',k, length(files));
    fileName = files(k).name;
    load([outputFolder fileName],'gl');
    [lampIn, boilIn, hhIn, parSun, parLamps, yield, efficiency] = energyYieldAnalysis(gl);
    heatByLightSummary{k,1} = fileName;
    heatByLightSummary{k,2} = lampIn;
    heatByLightSummary{k,3} = boilIn;
    heatByLightSummary{k,4} = hhIn;
    heatByLightSummary{k,5} = parSun; % mol m^{-2} year^{-1}
    heatByLightSummary{k,6} = parLamps; % mol m^{-2} year^{-1}
    heatByLightSummary{k,7} = yield; % (kg m^{-2} year^{-1})
    heatByLightSummary{k,8} = efficiency;
    
    labelEnd = strfind(fileName, '_ams_');
    label = fileName(1:(labelEnd-1));
    label = strrep(label, '-', ' ');
    label = strrep(label, 'LL', 'L/L');
    label = strrep(label, 'HL', 'H/L');
    heatByLightSummary{k,9} = label;

    heatByLightSummary{k,10} = mean(gl.a.co2InPpm);
end
fprintf('\n');

% Reorder table
heatByLightSummary = heatByLightSummary([16 15 5 12 14 10 9 7 8 11 6 13 2 1 4 3],:);

%% Draw figure
cc = lines();
labels=heatByLightSummary(:,9);
labels{2} = 'N HS';


% Energy inputs
figure
bar(cell2mat(heatByLightSummary(:,2:4)),'stacked');
legend('Lamp input', 'Boiler input', 'Electricity input for heat harvesting','Location','nw');
ylabel('Energy input (MJ m^{-2} year^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 4000])
title('A')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';


% PAR above the canopy
figure
bar(cell2mat(heatByLightSummary(:,5:6)),'stacked');
legend('PAR from the sun', 'PAR from lamps','Location','nw');
ylabel('PAR above the canopy (mol m^{-2} year^{-1})')
xticklabels([])
xlim([0 17])
ylim([0 18000])
xticks(1:16)
xticklabels(labels)
title('B')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';

% Yield 
figure
bar(cell2mat(heatByLightSummary(:,7)),'stacked');
legend('Yield','Location','nw');
ylabel('Yield (kg m^{-2} year^{-1})');
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 180])
title('C')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';

% Energy efficiency 
figure
bar(cell2mat(heatByLightSummary(:,8)),'stacked');
legend('Energy input per product','Location','nw');
ylabel('Energy input per product (MJ kg^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 25])
title('D')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';