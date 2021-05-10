% FIG506HEATBYLIGHTCOLDHOURS Present number of cold hours and minimum temperature for scenarios of heating a greenhouse with light
% Used to generate Figure 5.6 in:
%   Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%   a process-based modelling approach (Phd Thesis, Wageningen University). 
%   https://doi.org/10.18174/544434

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

%% Collect data

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\John\OneDrive - Wageningen University & Research\PhD\gitwur\greenlight-new-led-opportunities\Output\20210415';

if outputFolder(end) ~= '\'
    outputFolder = [outputFolder '\'];
end

% List of files in outputFolder
files = dir(outputFolder);
files = files(3:end);

% coldHoursSummary has the following columns:
% filename, minTemp, coldHours
coldHoursSummary = {};

for k=1:length(files)
    fprintf('%d of %d... ',k, length(files));
    fileName = files(k).name;
    load([outputFolder fileName],'gl');
    [minTemp, coldHours] = coldHourAnalysis(gl);
    
    labelEnd = strfind(fileName, '_ams_');
    label = fileName(1:(labelEnd-1));
    label = strrep(label, '-', ' ');
    label = strrep(label, 'LL', 'L/L');
    label = strrep(label, 'HL', 'H/L');
    
    coldHoursSummary{k,1} = fileName;
    coldHoursSummary{k,2} = minTemp;
    coldHoursSummary{k,3} = coldHours;
    coldHoursSummary{k,4} = label;
end
fprintf('\n');

% Reorder table
coldHoursSummary = coldHoursSummary([16 15 5 12 14 10 9 7 8 11 6 13 2 1 4 3],:);

%% Draw figure
cc = lines();

% Plot bars for number of cold hours
figure;
b=bar(cell2mat(coldHoursSummary(:,3)));

% Add labels for number of cold hours
precision = 0;
numFormat = ['%.' num2str(precision) 'f'];
yOffset = 10;
xOffset = -0.2;
for k=1:length(b(1).YData)
    if b(1).YData(k)>0
        text(xOffset+b(1).XData(k),yOffset+b(1).YData(k),num2str(b(1).YData(k),numFormat),'FontSize',7,'Color',cc(1,:));
    end
end
ylabel('Cold hours (h)')
ylim([0 250])

yyaxis right
s = scatter(1:length(files),cell2mat(coldHoursSummary(:,2)),...
    'd','filled','SizeData',100,'MarkerEdgeColor','k');

% Add labels for minimum temperature
precision = 1;
numFormat = ['%.' num2str(precision) 'f'];
yOffset = 0.6;
xOffset = -0.4;
for k=1:length(s(1).YData)
    if s(1).YData(k)>0
        text(xOffset+s(1).XData(k),yOffset+s(1).YData(k),num2str(s(1).YData(k),numFormat),'FontSize',7);
    end
end
ylabel('Minimum indoor temperature (°C)');
ylim([10 20])
labels = coldHoursSummary(:,4);
xticks(1:16)
xticklabels(labels)
xlim([0.5 16.5])
legend('Number of cold hours','Minimum indoor temperature','Location','ne','NumColumns',2)