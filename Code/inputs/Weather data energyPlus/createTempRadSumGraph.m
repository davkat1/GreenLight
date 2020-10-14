load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\amsEnergyPlus.mat', 'weather')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'AMS');
hold on

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\ancEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'ANC');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\kirEnergyPlus.mat')
temp = sum(weather(:,3)); 
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'KIR');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\cheEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'CHE');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\shaEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'SHA');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\uruEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'URU');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\beiEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'BEI');

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\calEnergyPlus.mat')
temp = sum(weather(:,3));
rad = sum(weather(:,2));
scatter(temp,rad,'filled')
text(temp+1,rad-1,'CAL');

grid

xlabel('Temperature (°C h)')
ylabel('Radiation (Wh m^{-2})');
title('Yearly sum of temperature and radiation')