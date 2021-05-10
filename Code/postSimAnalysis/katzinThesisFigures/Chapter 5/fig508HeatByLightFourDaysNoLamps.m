% FIG508HEATBYLIGHTFOURDAYSNOLAMPS Present four days of scenarios without lamps, used to find methods for heating a greenhouse by light.
% Used to generate Figure 5.8 in:
%   Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%   a process-based modelling approach (Phd Thesis, Wageningen University). 
%   https://doi.org/10.18174/544434

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\John\OneDrive - Wageningen University & Research\PhD\gitwur\greenlight-new-led-opportunities\Output\20210415\';

load([outputFolder 'N-HH_ams_noLamp_hHarvest_day350_length350.mat'], 'gl')
nlhh=gl;
load([outputFolder 'N_ams_noLamp_day350_length350.mat'], 'gl')
nl=gl;

cc=lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);
purple = cc(4,:);
green= cc(5,:);

%% Indoor temperature
subplot(3,1,1)
plotMeans(nl.x.tAir,12,'LineWidth',0.5);
hold on
plotMeans(nlhh.x.tAir,12,'--');
plotMeans(nlhh.a.heatSetPoint-1,12);
xlim([83*86400 87*86400]-3600)
xticks((83*86400:86400:87*86400)-3600)
xticklabels(datestr(350+(83:87),'dd/mm'))
ylim([17 24])
yticks(18:2:26)
legend('Indoor temperature N','Indoor temperature N HH',...
    'Desired setpoint','numColumns',3)
ylabel('Temperature (°C)')
xlabel('Date')

%% Thermal screen and cooling
subplot(3,1,2)
plot(100*nl.u.thScr,'LineWidth',0.5);
hold on
plot(100*nlhh.u.thScr,'--');
ylim([0 150])
ylabel('Thermal screen closure (%)')
yyaxis right
plot(nlhh.a.hAirMech+nlhh.a.lAirMech);
legend('Thermal screen N','Thermal screen N HH',...
    'Cooling N HH','numColumns',2);
ylim([0 80])
ylabel('Cooling N HH (W m^{-2})')
xlim([83*86400 87*86400]-3600)
xticks((83*86400:86400:87*86400)-3600)
xticklabels(datestr(350+(83:87),'dd/mm'))
xlabel('Date')

%% Outdoor temperature and solar radiation
subplot(3,1,3)
plot(nl.d.tOut,'Color',blue)
hold on
plot([83*86400 87*86400]-3600,[5 5],'--','Color',blue)
ylabel('Outdoor temperature (°C)')
ylim([-2 12])
yyaxis right
plot(nl.d.iGlob,'Color',red)
hold on
plot([83*86400 87*86400]-3600,[50 50],'--','Color',red)
ylim([0 550])
ylabel('Solar radiation (W m^{-2})')
xlim([83*86400 87*86400]-3600)
xticks((83*86400:86400:87*86400)-3600)
xticklabels(datestr(350+(83:87),'dd/mm'))
legend('Outdoor temperature',...
    'Temperature threshold for thermal screen',...
    'Solar radiation',...
    'Radiation threshold for thermal screen','numColumns',2)
xlabel('Date')
