% fig08HeatByLightFourDaysLampIntensityBufferSize Present four days of heating by light scenarios with various lamp intensities and buffer sizes.
% Used to generate Figure 8 in:
%   Katzin, Marcelis, Van Henten, Van Mourik,
%   "Heating greenhouses by light: A novel concept for intensive greenhouse
%   production", Biosystems Engineering, 2023

% David Katzin, Wageningen University and Research, May 2023
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = ['C:\Users\katzi001\OneDrive - Wageningen University & Research' ...
    '\git\gitwur\greenlight-new-led-opportunities\Output\20210415\'];

load([outputFolder 'L-450-SB_ams_led_blScr_hHarvest_noBoil_ppfd450_day270_length350.mat'], 'gl')
sb=gl;
load([outputFolder 'L-400_ams_led_blScr_hHarvest_noBoil_ppfd400_day270_length350.mat'], 'gl')
p400=gl;
load([outputFolder 'L-450_ams_led_blScr_hHarvest_noBoil_ppfd450_day270_length350.mat'], 'gl')
p450=gl;

cc=lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);

firstDay=72;
lastDay=76;

%% Indoor air temperature
subplot(3,1,1)
plotMeans(p450.x.tAir,12,'LineWidth',1);
hold on
plotMeans(p400.x.tAir,12);
plotMeans(sb.x.tAir,12);
plotMeans(p450.a.heatSetPoint-1,12,'--');
xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
ylim([10 28])
yticks(10:4:26)
legend('L 450','L 400',...
    'L 450 SB', ...
    'Desired setpoint',...
    'numColumns',3,'Location','ne')
ylabel('Temperature (°C)')
xlabel('Date')

%% Heating and lighting input
subplot(3,1,2)
plot(smooth(p450.a.qLampIn,12),'--','Color',blue);
hold on
plot(smooth(p400.a.qLampIn,12),'--','Color',red);

plot(smooth(p450.a.hBufHotPipe,12),'Color',blue,'LineWidth',1);
plot(smooth(p400.a.hBufHotPipe,12),'Color',red);
plot(smooth(sb.a.hBufHotPipe,12),'Color',yellow);

xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
xlabel('Date')

legend('L 450 lighting','L 400 lighting',...
    'L 450 heating from buffer', 'L 400 heating from buffer',...
    'L 450 SB heating from buffer',...
    'numColumns',3,'Location','ne')
ylim([0 200])
ylabel('Energy input (W m^{-2})')

%% Energy buffer content
subplot(3,1,3)
plot(p450.x.eBufCold+p450.x.eBufHot);
hold on
plot(p400.x.eBufCold+p400.x.eBufHot);
plot(sb.x.eBufCold+sb.x.eBufHot);

xlim([firstDay*86400 (lastDay)*86400]-3600)
xticks((firstDay*86400:86400:lastDay*86400)-3600)
xticklabels(datestr(270+(firstDay:lastDay),'dd/mm'))
ylim([0 2.5])
yticks(0:0.5:3)
legend('L 450','L 400',...
    'L 450 SB', ...
    'numColumns',3,'Location','ne')
ylabel('Heat buffers content (MJ m^{-2})')
xlabel('Date')


