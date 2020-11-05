% PLOTWINTERSUMMERDAYTRAJECTORY Plot the time course of a winter and summer day of a greenhouse simulation
% Creates a plot of these two days, including greenhouse controls, CO2
% concentration, temperatures, and solar radiation.
% Used to create Figure 11 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Set directories for loading data 
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
outputFolder = strrep(currentFolder, '\GreenLight\Code\postSimAnalysis', ...
    '\GreenLight\Output\referenceSetting\');
    % The last line may need to be modified, depending where the model 
    % output is saved
    % The path should include simulation results, with the following format
    % for the file names: <location>_<lampType>_<optionalMoreInfo>
    % Each location should have both HPS and LED lamp type
    
% Modify this to correct file name with a simulation output
load([outputFolder 'ams_hps_referenceSetting.mat'],'gl');
hps = gl;
load([outputFolder 'ams_led_referenceSetting.mat'],'gl');
led = gl;

% Choose dates for the winter and summer days. Dates are represented by
% "days since Sept 27 (the beginning of the growing season)". 
% 116 - January 21; 292 - July 15 (used in Paper).
% Other examples:
% 65 - December 1
% 96 - January 1
% 156 - March 1
% 248 - June 1
% 340 - September 1
winterDay = 116;
summerDay = 292;

hpsWin = cutTime(hps, datenum(hps.t.label)+winterDay-1/24,86400);
ledWin = cutTime(led, datenum(led.t.label)+winterDay-1/24,86400);

hpsSum = cutTime(hps, datenum(hps.t.label)+summerDay-1/24,86400);
ledSum = cutTime(led, datenum(led.t.label)+summerDay-1/24,86400);

cc = lines(100);
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);
purple = cc(4,:);
green = cc(5,:);
cyan = cc(6,:);
black = [0 0 0];

smoothFactor = 24;
xStart = 1200;
xEnd = 86400-xStart;

%% Winter
subplot(3,2,1)
plot(smooth(hpsWin.a.qLampIn,smoothFactor),'LineWidth',1,'Color',red);
hold on
plot(smooth(ledWin.a.qLampIn,smoothFactor),'LineWidth',1.5,'Color',blue);
plot(smooth(hpsWin.a.hBoilPipe,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledWin.a.hBoilPipe,smoothFactor),':','LineWidth',2,'Color',blue);
yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 7;
plot(smooth(100*hpsWin.u.roof,smoothFactor),'--','LineWidth',1,'Color',red);
plot(smooth(100*ledWin.u.roof,smoothFactor),'--','LineWidth',1,'Color',blue);
axis([xStart xEnd 0 20]);
ylabel('Roof opening (%)');

yyaxis left
legend('HPS lighting','LED lighting','HPS heating','LED heating','HPS ventilation','LED ventilation','Location','nw')
axis([xStart xEnd 0 250]);
yticks(0:50:250);
title('A. Greenhouse controls winter')

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
ylabel('Lighting and heating (W m^{-2})')
xlabel('Time of day (h)'); 
grid

%% Summer
subplot(3,2,2)
plot(smooth(hpsSum.a.qLampIn,smoothFactor),'LineWidth',1,'Color',red);
hold on
plot(smooth(ledSum.a.qLampIn,smoothFactor),'LineWidth',1.5,'Color',blue);
plot(smooth(hpsSum.a.hBoilPipe,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledSum.a.hBoilPipe,smoothFactor),':','LineWidth',2,'Color',blue);
yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 7;
plot(smooth(100*hpsSum.u.roof,smoothFactor),'--','LineWidth',1,'Color',red);
plot(smooth(100*ledSum.u.roof,smoothFactor),'--','LineWidth',1,'Color',blue);
axis([xStart xEnd 0 20]);
ylabel('Roof opening (%)');

yyaxis left
legend('HPS lighting','LED lighting','HPS heating','LED heating','HPS ventilation','LED ventilation','Location','nw')
axis([xStart xEnd 0 250]);
yticks(0:50:250);
title('B. Greenhouse controls summer')

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
ylabel('Lighting and heating (W m^{-2})')
xlabel('Time of day (h)'); 
grid

%% Winter CO2
subplot(3,2,3)
hold on
plot(smooth(hpsWin.a.co2InPpm,smoothFactor),'LineWidth',2,'Color',red)
plot(smooth(ledWin.a.co2InPpm,smoothFactor),'LineWidth',1,'Color',blue)

yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 7;
plot(smooth(hpsWin.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledWin.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',blue);
axis([xStart xEnd 0 10]);
yticks(0:2:10);
ylabel('Injection (mg m^{-2} s^{-1})')

legend('HPS CO_2 concentration','LED CO_2 concentration','HPS CO_2 injection','LED CO_2 injection','Location','nw')
yyaxis left
axis([xStart xEnd 0 1800]);
yticks(0:300:1800);
title('C. Greenhouse CO_2 winter')

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
ylabel('CO_2 concentration (ppm)')
xlabel('Time of day (h)'); 
grid

%% Summer CO2
subplot(3,2,4)
hold on
plot(smooth(hpsSum.a.co2InPpm,smoothFactor),'LineWidth',2,'Color',red)
plot(smooth(ledSum.a.co2InPpm,smoothFactor),'LineWidth',1,'Color',blue)

yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 7;
plot(smooth(hpsSum.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledSum.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',blue);
axis([xStart xEnd 0 10]);
yticks(0:2:10);
ylabel('Injection (mg m^{-2} s^{-1})')

legend('HPS CO_2 concentration','LED CO_2 concentration','HPS CO_2 injection','LED CO_2 injection','Location','nw')
yyaxis left
axis([xStart xEnd 0 1800]);
yticks(0:300:1800);
title('D. Greenhouse CO_2 summer')

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
ylabel('CO_2 concentration (ppm)')
xlabel('Time of day (h)'); 
grid


%% Winter inputs
subplot(3,2,5)
hold on
plot(smooth(hpsWin.x.tAir,smoothFactor),'LineWidth',1,'Color',red)
plot(smooth(ledWin.x.tAir,smoothFactor),'LineWidth',1.5,'Color',blue)

plot(hpsWin.a.heatSetPoint,':','LineWidth',2,'Color',yellow)
plot(hpsWin.a.heatMax,'--','LineWidth',1,'Color',purple)

plot(hpsWin.d.tOut,'LineWidth',1,'Color',green)
axis([xStart xEnd 2 50])
yticks(5:10:50);

yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 7;
plot(hpsWin.d.iGlob,'LineWidth',1.5,'Color',black)
axis([xStart xEnd 0 800])
yticks(0:200:800)

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
xlabel('Time of day (h)'); 
ylabel('Solar radiation (W m^{-2})');
yyaxis left
ylabel('Temperature (°C)');
title('E. Temperatures and solar radiation winter');
legend('HPS indoor temperature','LED indoor temperature',...
    'Heating setpoint','Ventilation setpoint',...
    'Outdoor temperature', 'Solar radiation','Location','nw');
grid

%% Summer inputs
subplot(3,2,6)
hold on
plot(smooth(hpsSum.x.tAir,smoothFactor),'LineWidth',1,'Color',red)
plot(smooth(ledSum.x.tAir,smoothFactor),'LineWidth',1.5,'Color',blue)

plot(hpsSum.a.heatSetPoint,':','LineWidth',2,'Color',yellow)
plot(hpsSum.a.heatMax,'--','LineWidth',1,'Color',purple)

plot(hpsSum.d.tOut,'LineWidth',1,'Color',green)
axis([xStart xEnd 2 50])
yticks(5:10:50);

yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 9;
plot(hpsSum.d.iGlob,'LineWidth',1.5,'Color',black)
axis([xStart xEnd 0 800])
yticks(0:200:800)

xticks([xStart (86400/24)*(3:3:21) xEnd]);
xticklabels({'0','3','6','9','12','15','18','21','24'}); 
xlabel('Time of day (h)'); 
ylabel('Solar radiation (W m^{-2})');
yyaxis left
ylabel('Temperature (°C)');
title('F. Temperatures and solar radiation summer');
legend('HPS indoor temperature','LED indoor temperature',...
    'Heating setpoint','Ventilation setpoint',...
    'Outdoor temperature', 'Solar radiation','Location','nw');
grid
