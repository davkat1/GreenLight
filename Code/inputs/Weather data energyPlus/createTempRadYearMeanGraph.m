load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\amsEnergyPlus.mat', 'weather')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'AMS');
hold on
k=1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\ancEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'ANC');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\kirEnergyPlus.mat')
temp = mean(weather(:,3)); 
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'KIR');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\cheEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'CHE');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\shaEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'SHA');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\uruEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'URU');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\beiEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'BEI');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\calEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'CAL');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\winEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'WIN');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\tokEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'TOK');
k=k+1;
out(k,1:2) = [temp rad];


load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\mosEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'MOS');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\stpEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'STP');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\samEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'SAM');
k=k+1;
out(k,1:2) = [temp rad];

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\arkEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'ARK');
k=k+1;
out(k,1:2) = [temp rad];


load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\venEnergyPlus.mat')
temp = mean(weather(:,3));
rad = mean(weather(:,2));
scatter(temp,rad*86400*1e-6,200,'filled')
text(temp+0.2,rad*86400*1e-6-0.2,'VEN');
k=k+1;
out(k,1:2) = [temp rad];


grid
xlabel('Temperature (°C)')
ylabel('Radiation (MJ m^{-2} day^{-1})');
title('Yearly average of temperature and radiation')