% fig06DailyLightIntegral print out the daily light integral above the crop from the sun and from the lamps. 
% Used to generate Figure 6 in:
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

% Get daily light sums from sun and lamps
% No lamps
gl = nlhh;
parSunNlHh = gl.p.parJtoUmolSun*gl.a.rParGhSun;
parSunNlHh = parSunNlHh.val(:,2);
parSunDayNlHh = 300e-6*sum(reshape(parSunNlHh,288,350));
parLampsNlHh = gl.p.zetaLampPar*gl.a.rParGhLamp+gl.p.zetaIntLampPar*gl.a.rParGhIntLamp;
parLampsNlHh = parLampsNlHh.val(:,2);
parLampsDayNlHh = 300e-6*sum(reshape(parLampsNlHh,288,350));

% LED 200 µmol
gl = p200;
parSunL200 = gl.p.parJtoUmolSun*gl.a.rParGhSun;
parSunL200= parSunL200.val(:,2);
parSunDayL200 = 300e-6*sum(reshape(parSunL200,288,350));
parLampsL200  = gl.p.zetaLampPar*gl.a.rParGhLamp+gl.p.zetaIntLampPar*gl.a.rParGhIntLamp;
parLampsL200  = parLampsL200 .val(:,2);
parLampsDayL200  = 300e-6*sum(reshape(parLampsL200 ,288,350));

% LED 450 µmol
gl = p450;
parSunL450 = gl.p.parJtoUmolSun*gl.a.rParGhSun;
parSunL450= parSunL450.val(:,2);
parSunDayL450 = 300e-6*sum(reshape(parSunL450,288,350));
parLampsL450  = gl.p.zetaLampPar*gl.a.rParGhLamp+gl.p.zetaIntLampPar*gl.a.rParGhIntLamp;
parLampsL450  = parLampsL450 .val(:,2);
parLampsDayL450  = 300e-6*sum(reshape(parLampsL450 ,288,350));

%% Plot 
% Shift nlhh so that its days correspond to the other simulations
% plot(0:(seasonLength+nlhhShift-365),parSunDayNlHh((365-nlhhShift):end));
% hold on
% plot((nlhhShift+1):seasonLength,parSunDayNlHh(1:firstDay),'HandleVisibility','off','Color',blue);
% The above is not needed, since radiation from the sun is practically
% equal for all scenarios

plot(parSunDayL200,'LineWidth',1.5);
hold on
plot(parLampsDayL200+parSunDayL200);
plot(parLampsDayL450+parSunDayL450);

% Add dates to x axis
xticks(0:seasonLength);
xticklabels(datestr(firstDay+1+(0:seasonLength),'dd/mm'))
xticks(0:25:seasonLength);
xticklabels(datestr(firstDay+1+(0:25:seasonLength),'dd/mm'))

% Add other plot elements
legend('DLI from sun', 'Total DLI (L200)', 'Total DLI (L450)', ...
    'Location', 'nw');
ylim([0 60])
xlabel('Date')
ylabel('Daily light integral (mol PAR m^{-2} d^{-1})')