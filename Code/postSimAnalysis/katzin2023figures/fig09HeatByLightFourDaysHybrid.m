% fig09HeatByLightFourDaysHybrid Present four days of the hybrid lighting scenario of heating by a greenhouse with light
% Used to generate Figure 9 in:
%   Katzin, Marcelis, Van Henten, Van Mourik,
%   "Heating greenhouses by light: A novel concept for intensive greenhouse
%   production", Biosystems Engineering, 2023

% David Katzin, Wageningen University and Research, May 2023
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\katzi001\OneDrive - Wageningen University & Research\git\gitwur\greenlight-new-led-opportunities\Output\20210415\';

load([outputFolder 'HL-320_ams_hps_blScr_hHarvest_noBoil_intLamp120_day270_length350.mat'],'gl');
h320scr=gl;
load([outputFolder 'HL-370_ams_hps_blScr_hHarvest_noBoil_intLamp170_day270_length350.mat'],'gl')
h370scr=gl;
load([outputFolder 'HL-320-NBO_ams_hps_hHarvest_noBoil_intLamp120_day270_length350.mat'],'gl')
h320=gl;
load([outputFolder 'HL-370-NBO_ams_hps_hHarvest_noBoil_intLamp170_day270_length350.mat'],'gl')
h370=gl;
load([outputFolder 'L-450_ams_led_blScr_hHarvest_noBoil_ppfd450_day270_length350.mat'],'gl')
p450=gl;

cc=lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);
purple = cc(4,:);

firstDay=100;
lastDay=104;

%% Indoor air temperature
subplot(3,1,1)
plotMeans(p450.x.tAir,12,'LineWidth',1);
hold on
plotMeans(h320scr.x.tAir,12);
plotMeans(h320.x.tAir,12,'--');
plotMeans(h370scr.x.tAir,12);
plotMeans(h370.x.tAir,12);

plotMeans(h320scr.a.heatSetPoint-1,12,'--');

xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
ylim([10 28])
yticks(10:4:28)
legend('L 450','H/L 320','H/L 320 NBO',...
    'H/L 370','H/L 370 NBO',...
    'Desired setpoint',...
    'numColumns',3,'Location','ne')
ylabel('Temperature (°C)')
xlabel('Date')

%% Control of the lamps
subplot(3,1,2)
plot(smooth(p450.a.qLampIn+p450.a.qIntLampIn,12),'LineWidth',1);
hold on
plot(smooth(h320scr.a.qLampIn+h320scr.a.qIntLampIn,12));
plot(smooth(h320.a.qLampIn+h320.a.qIntLampIn,12),'--');
plot(smooth(h370scr.a.qLampIn+h370scr.a.qIntLampIn,12));
plot(smooth(h370.a.qLampIn+h370.a.qIntLampIn,12));

xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
xlabel('Date')

legend('L 450','H/L 320','H/L 320 NBO',...
    'H/L 370','H/L 370 NBO',...
    'numColumns',5,'Location','ne')
ylim([0 200])
yticks(0:50:200)
ylabel('Lamp input (W m^{-2})')

%% Energy content in the heat buffers
subplot(3,1,3)
plot(p450.x.eBufCold+p450.x.eBufHot,'LineWidth',1);
hold on
plot(h320scr.x.eBufCold+h320scr.x.eBufHot);
plot(h320.x.eBufCold+h320.x.eBufHot,'--');
plot(h370scr.x.eBufCold+h370scr.x.eBufHot);
plot(h370.x.eBufCold+h370.x.eBufHot);

xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
ylim([0 2.5])
yticks(0:0.5:3)
legend('L 450','H/L 320','H/L 320 NBO',...
    'H/L 370','H/L 370 NBO',...
    'numColumns',5,'Location','ne')

ylabel('Heat buffers content (MJ m^{-2})')
xlabel('Date')
