% fig12HeatByCostsAndFootprint Present energy use, PAR light, yield, and energy efficiency of heating by light scenarios.
% Used to generate Figure 12 in:
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
    heatByLightSummary{k,2} = lampIn; % MJ m^{-2} year^{-1}
    heatByLightSummary{k,3} = boilIn; % MJ m^{-2} year^{-1}
    heatByLightSummary{k,4} = hhIn; % MJ m^{-2} year^{-1}
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

%%
% Constants - assumptions about carbon footprint and costs
costGas = 0.006; % Cost of natural gas, €/MJ
costElec = 0.024; % Cost of electricity, €/MJ
fpGas = 0.06; % Carbon footprint of gas, kgCO2eq/MJ
fpElec = 0.18; % Carbon footprint of electricity, kgCO2eq/MJ

lampIn = cell2mat(heatByLightSummary(:,2)); % MJ m^{-2} year^{-1}
boilIn = cell2mat(heatByLightSummary(:,3)); % MJ m^{-2} year^{-1}
hhIn = cell2mat(heatByLightSummary(:,4)); % MJ m^{-2} year^{-1}
yield = cell2mat(heatByLightSummary(:,7)); % kg m^{-2} year^{-1}

lampCosts = lampIn*costElec;
gasCosts = boilIn*costGas;
hhCosts = hhIn*costElec;
lampFp = lampIn*fpElec;
gasFp = boilIn*fpGas;
hhFp = hhIn*fpElec;

lampCostsPerProduct = lampCosts./yield;
gasCostsPerProduct = gasCosts./yield;
hhCostsPerProduct = hhCosts./yield;
lampFpPerProduct = lampFp./yield;
gasFpPerProduct = gasFp./yield;
hhFpPerProduct = hhFp./yield;

%% Draw figure
cc = lines();
labels=heatByLightSummary(:,9);
labels{2} = 'N HS';

% Energy costs per m2
figure;
bar([lampCosts gasCosts hhCosts],'stacked');
legend('Lamp costs per m^2', 'Boiler costs per m^2', 'Heat storage costs per m^2','Location','nw');
ylabel('Energy costs (€ m^{-2} year^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 100])
title('A')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';

% Carbon footprint per m2
figure;
bar([lampFp gasFp hhFp],'stacked');
legend('Lamp carbon footprint per m^2', 'Boiler carbon footprint per m^2', 'Heat storage carbon footprint per m^2','Location','nw');
ylabel('Energy carbon footprint (kgCO_2eq m^{-2} year^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 750])
title('B')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';

% Energy costs per kg product
figure;
bar([lampCostsPerProduct gasCostsPerProduct hhCostsPerProduct],'stacked');
legend('Lamp costs per kg product', 'Boiler costs per kg product', 'Heat storage costs per kg product','Location','nw');
ylabel('Energy costs (€ kg^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 0.7])
title('C')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';

% Carbon footprint per kg product
figure;
bar([lampFpPerProduct gasFpPerProduct hhFpPerProduct],'stacked');
legend('Lamp carbon footprint per kg product', 'Boiler carbon footrpint per kg product', 'Heat storage carbon footprint per kg product','Location','nw');
ylabel('Energy carbon footprint (kgCO_2eq kg^{-1})')
xticks(1:16)
xticklabels(labels)
xlim([0 17])
ylim([0 5])
title('D')
g = gca;
g.XTickLabel{1} = 'N B';
g.XTickLabel{2} = 'N B HS';
g.XTickLabel{3} = 'L B 200';