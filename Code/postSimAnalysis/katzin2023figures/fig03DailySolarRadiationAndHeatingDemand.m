% fig03DailySolarRadiationAndHeatingDemand Present the daily outdoor solar radiation and heat demand for a greenhouse without lamps.
% Used to generate Figure 3 in:
%   Katzin, Marcelis, Van Henten, Van Mourik,
%   "Heating greenhouses by light: A novel concept for intensive greenhouse
%   production", Biosystems Engineering, 2023

% David Katzin, Wageningen University and Research, May 2023
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\katzi001\OneDrive - Wageningen University & Research\git\gitwur\greenlight-new-led-opportunities\Output\20210415\';

% File where simulation with lamps and without heat harvesting is stored
load([outputFolder 'N-HH_ams_noLamp_hHarvest_day350_length350.mat'],'gl');

cc=lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);
purple = cc(4,:);
green= cc(5,:);

figure
firstDay = 350;
plotMeans(86400e-6*gl.d.iGlob,288);
hold on
plotMeans(86400e-6*gl.a.hBoilPipe,288);
xticks(0:86400:86400*350);
xticklabels(datestr(firstDay+1+(0:350),'dd/mm'))
xticks(0:25*86400:350*86400);
xticklabels(datestr(firstDay+1+(0:25:350),'dd/mm'))
plot([158*86400 158*86400],[0 30],'--','Color',red,'HandleVisibility','off')
plot([(158+111)*86400 (158+111)*86400],[0 30],'--','Color',red,'HandleVisibility','off')
plot([0 350*86400],[10 10],'--','Color',blue,'HandleVisibility','off')
grid
legend('Solar radiation','Heating demand','location','nw')
xlabel('Date')
ylabel('MJ m^{-2} d^{-1}')
xlim([0 86400*350]);