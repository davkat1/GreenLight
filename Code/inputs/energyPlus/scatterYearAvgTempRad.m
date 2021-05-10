% SCATTERYEARAVGTEMPRAD Plot the yearly average for temperature and
% radiation of the data used in a scatter plot
% Goes through the 15 locations in this folder and plots dots with caption
% Used to create Figure 2 in: 
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

% Give names to colors so they can be consistent with Figure 1 
% see plotYearlyCycleTempRad
cc = lines(100);
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

% load data one by one and plot
load([dataFolder 'amsEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,AMS,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'AMS','Color',AMS);
hold on
k=1;
out(k,1:2) = [temp rad];

load([dataFolder 'ancEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,ANC,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'ANC','Color',ANC);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'arkEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,ARK,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'ARK','Color',ARK);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'beiEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,BEI,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'BEI','Color',BEI);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'calEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,CAL,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'CAL','Color',CAL);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'cheEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,CHE,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'CHE','Color',CHE);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'kirEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3)); 
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,KIR,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'KIR','Color',KIR);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'mosEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,MOS,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'MOS','Color',MOS);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'samEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,SAM,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'SAM','Color',SAM);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'shaEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,SHA,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'SHA','Color',SHA);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'stpEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,STP,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'STP','Color',STP);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'tokEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,TOK,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'TOK','Color',TOK);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'uruEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,URU,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'URU','Color',URU);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'venEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,VEN,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'VEN','Color',VEN);
k=k+1;
out(k,1:2) = [temp rad];

load([dataFolder 'winEnergyPlus.mat'], 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,50,WIN,'filled');
text(temp+0.25,rad*86400*1e-6-0.25,'WIN','Color',WIN);
k=k+1;
out(k,1:2) = [temp rad];


grid
xlabel('Temperature (°C)')
ylabel('Radiation (MJ m^{-2} day^{-1})');
