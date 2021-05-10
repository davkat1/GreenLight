% FIG503CUMULATIVEFREQUENCYCURVES Print out the cumulative frequency curve for hourly and daily heating demand of a greenhouse without heat harvesting.
% Used to generate Figure 5.3 in:
%   Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%   a process-based modelling approach (Phd Thesis, Wageningen University). 
%   https://doi.org/10.18174/544434

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\John\OneDrive - Wageningen University & Research\PhD\gitwur\greenlight-new-led-opportunities\Output\20210415\';

% File where simulation with lamps and without heat harvesting is stored
load([outputFolder 'N_ams_noLamp_day350_length350.mat'],'gl');

cc = lines();
blue = cc(1,:);
red = cc(2,:);
yellow = cc(3,:);

[dayHeating, dayHeat18toMidnight, hourHeating, hourHeat18toMidnight] = getDailyHourlyHeating(gl);

figure
subplot(1,2,2)
hold on
plot(sort(hourHeating,'descend'));
plot(sort(hourHeat18toMidnight,'descend'));
legend('Hour heating','Hour heating 18 to 24')

xlabel('Number of hours');
ylabel('Heat demand (W m^{-2})')
grid
ylim([0 150])
yticks(0:25:150)
xlim([0 8400])

subplot(1,2,1)
hold on
plot(sort(dayHeating,'descend'));
plot(sort(dayHeat18toMidnight,'descend'));
legend('Daily heating','Heating 18 to 24')
xlabel('Number of days');
ylabel('Heat demand (MJ m^{-2} d^{-1})')
grid