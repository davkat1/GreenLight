% PLOTDAILYENERGYFULLYEAR Plot the daily energy use of an HPS and LED greenhouse 
% The daily heating and lighting use is plotted as it evolves throughout
% the season. Additionaly the outdoor radiation and temperature is plotted.
% Used to create Figure 9 in: 
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

day = 1;
hpsLight = [];
ledLight = [];
hpsHeat = [];
ledHeat = [];
sun = [];
temp = [];

cc = lines(100);
blue = cc(1,:);
red = cc(2,:);

for k=1:288:length(hps.d.iGlob.val(:,2))
    m = min(k+287, length(hps.d.iGlob.val(:,2)));
    hpsLight(day) = 1e-6*300*sum(hps.a.qLampIn.val(k:m,2));
    ledLight(day) = 1e-6*300*sum(led.a.qLampIn.val(k:m,2));
    hpsHeat(day) = 1e-6*300*sum(hps.a.hBoilPipe.val(k:m,2));
    ledHeat(day) = 1e-6*300*sum(led.a.hBoilPipe.val(k:m,2));
    sun(day) = 1e-6*300*sum(hps.d.iGlob.val(k:m,2));
    temp(day) = mean(hps.d.tOut.val(k:m,2));    
    day = day+1;
end

subplot(2,1,1)
plot(hpsLight,'LineWidth',1,'Color',red)
hold on
plot(hpsHeat,':','LineWidth',2.5,'Color',red)
plot(ledLight,'LineWidth',1.5,'Color',blue)
plot(ledHeat,'--','LineWidth',1.5,'Color',blue)
title('A. Daily energy use in HPS and LED greenhouse (AMS)')
ylabel('Daily energy input (MJ m^{-2} d^{-1})');
xlabel('Days after planting (d)')
grid
legend('HPS lighting', 'HPS heating', 'LED lighting', 'LED heating', 'Location', 'nw');
xticks(0:25:350)
 
subplot(2,1,2)
hold on
plot(-10,-10,'HandleVisibility','Off')
plot(-10,-10,'HandleVisibility','Off')
plot(-10,-10,'HandleVisibility','Off')


plot(temp,'LineWidth',1)
axis([0 350 0 30])

yyaxis right
plot(sun,'LineWidth',1.5)

title('B. Daily radiation and outdoor temperature (AMS)')
ylabel('Daily solar radiation (MJ m^{-2} d^{-1})');
xlabel('Days after planting (d)')
yyaxis left
ylabel('Outdoor temperature (°C)');
legend('Outdoor temperature','Solar radiation','Location','nw');
xticks(0:25:350)
grid