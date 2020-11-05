%PLOTYEARCYCLETEMPRAD Plot the yearly cycle of temperature and radiation of the data used 
% Goes through the 15 locations in this folder and plots the yearly cycle 
% Used to create Figure 1 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Set directories for loading data and saving output
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
dataFolder = [currentFolder '\data\'];

cc = lines(100);
months = {'1', '2','3','4','5','6','7','8','9','10','11','12'};

% Give names to colors so they can be consistent with Figure 2 
% see scatterYearAvgTempRad
AMS = cc(1,:);
BEI = cc(2,:);
CAL = cc(4,:);
CHE = cc(5,:);

KIR = cc(3,:);
STP = cc(6,:);
TOK = cc(7,:);
URU = cc(12,:);

ANC = cc(8,:);
SAM = cc(3,:);
SHA = cc(4,:);
WIN = cc(12,:);

ARK = cc(13,:);
MOS = cc(14,:);
VEN = cc(5,:);

s1 = subplot(2,2,1); hold on
plotLocation('ams', AMS, months, dataFolder);
plotLocation('bei', BEI, months, dataFolder);
plotLocation('cal', CAL, months, dataFolder);
plotLocation('che', CHE, months, dataFolder);

grid
legend('AMS','BEI','CAL','CHE','Location','nw')
s1.XLim = [-15 30];
s1.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')

s2 = subplot(2,2,2); hold on 
plotLocation('kir', KIR, months, dataFolder);
plotLocation('stp', STP, months, dataFolder);
plotLocation('tok', TOK, months, dataFolder);
plotLocation('uru', URU, months, dataFolder);

grid
legend('KIR','STP','TOK','URU','Location','nw')
s2.XLim = [-15 30];
s2.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')

s3 = subplot(2,2,3); hold on 
plotLocation('anc', ANC, months, dataFolder);
plotLocation('sam', SAM, months, dataFolder);
plotLocation('sha', SHA, months, dataFolder);
plotLocation('win', WIN, months, dataFolder);
grid
legend('ANC','SAM','SHA','WIN','Location','nw')
s3.XLim = [-15 30];
s3.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')

s4 = subplot(2,2,4); hold on 
plotLocation('ark', ARK, months, dataFolder);
plotLocation('mos', MOS, months, dataFolder);
plotLocation('ven', VEN, months, dataFolder);
grid
legend('ARK','MOS','VEN','Location','nw')

s4.XLim = [-15 30];
s4.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')

function plotLocation(location, color, months, dataFolder)
    load([dataFolder location 'EnergyPlus.mat'], 'weather');
    for k=1:12
        temp(k) = mean(weather((k-1)*730+1:k*730,3));
        rad(k) = mean(weather((k-1)*730+1:k*730,2));
    end
    plot(temp,rad*86400*1e-6,'o-','Color',color)
    text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',color);
end

