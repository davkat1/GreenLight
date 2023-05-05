% fig10DailyHeatingLighting print out the daily heating and lighting input of a simulated greenhouse. 
% Used to generate Figure 10 in:
%   Katzin, Marcelis, Van Henten, Van Mourik,
%   "Heating greenhouses by light: A novel concept for intensive greenhouse
%   production", Biosystems Engineering, 2023

% David Katzin, Wageningen University and Research, May 2023
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = ['C:\Users\katzi001\OneDrive - Wageningen University & Research' ...
    '\git\gitwur\greenlight-new-led-opportunities\Output\20210415\'];

% Season length (days) and first day (day of the year) of the simulations
seasonLength = 350;
firstDay = 270;

% Load simulation outputs
load([outputFolder 'N-HH_ams_noLamp_hHarvest_day350_length350.mat'], 'gl');
nlhh=gl;
load([outputFolder 'L-200_ams_led_blScr_hHarvest_day270_length350.mat'], 'gl');
p200=gl;
load([outputFolder 'L-450_ams_led_blScr_hHarvest_noBoil_ppfd450_day270_length350.mat'], 'gl');
p450=gl;

% The simulation without lamps (nlhh) starts on day 350, 
% which is 80 days later than the other simulations (start by default on
% day 270)
nlhhShift = 80;

% Get standard MATLAB color scheme
cc=lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);
purple = cc(4,:);
green= cc(5,:);

% Get daily means of heating and lighting, assumes that outputs are in
% 5-minute intervals (288 data points per day)
% use gl = changeRes(gl, 300) to ensure this (300 seconds == 5 minutes)
[xNl, dayHeatNl] = getMeans(86400e-6*nlhh.a.hBoilPipe,288);
[x200, dayLamp200] = getMeans(86400e-6*p200.a.qLampIn,288);
[~, dayHeat200] = getMeans(86400e-6*p200.a.hBoilPipe,288);
[x450, dayLamp450] = getMeans(86400e-6*p450.a.qLampIn,288);

% Plot means
% Shift nlhh so that its days correspond to the other simulations
plot(0:(seasonLength+nlhhShift-365),dayHeatNl((365-nlhhShift):end));
hold on
plot((nlhhShift+1):seasonLength,dayHeatNl(1:firstDay),'HandleVisibility','off','Color',blue);

% Other simulations
plot(dayLamp200,'Color',red,'LineWidth',1);
plot(dayHeat200+dayLamp200,'Color',yellow);
plot(dayLamp450,'Color',purple);

% Add dates to x axis
xticks(0:seasonLength);
xticklabels(datestr(firstDay+1+(0:seasonLength),'dd/mm'))
xticks(0:25:seasonLength);
xticklabels(datestr(firstDay+1+(0:25:seasonLength),'dd/mm'))

% Add other plot elements
legend('Heating N HH', 'Lighting L 200', 'Heating+lighting L 200',...
    'Lighting L 450');
ylim([0 10.5])
xlabel('Date')
ylabel('Energy input (MJ m^{-2} d^{-1})')