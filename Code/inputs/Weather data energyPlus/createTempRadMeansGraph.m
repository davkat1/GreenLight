


cc = lines(100);
i = 1;
months = {'1', '2','3','4','5','6','7','8','9','10','11','12'};

s1 = subplot(2,2,1); hold on
load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\amsEnergyPlus.mat', 'weather')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 
i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\ancEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\kirEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;


load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\cheEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

grid
legend('AMS','ANC','KIR','CHE','Location','nw')
s1.XLim = [-15 30];
s1.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')


s2 = subplot(2,2,2); hold on 
load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\shaEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\uruEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\beiEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\calEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

grid
legend('SHA','URU','BEI','CAL','Location','nw')
s2.XLim = [-15 30];
s2.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')

s3 = subplot(2,2,3); hold on 
load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\winEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\tokEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\mosEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\stpEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

grid
legend('WIN','TOK','MOS','STP','Location','nw')
s3.XLim = [-15 30];
s3.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')


s4 = subplot(2,2,4); hold on 
load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\samEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\arkEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;

load('M:\PhD\Models\git\gitwur\GreenLight\Code\inputs\Weather data energyPlus\venEnergyPlus.mat')
for k=1:12
temp(k) = mean(weather((k-1)*730+1:k*730,3));
rad(k) = mean(weather((k-1)*730+1:k*730,2));
end
plot(temp,rad*86400*1e-6,'o-','Color',cc(i,:))
text(temp+0.4,rad*86400*1e-6-0.4,months,'Color',cc(i,:)); 

i = i+1;
grid
legend('SAM','ARK','VEN','Location','nw')
s4.XLim = [-15 30];
s4.YLim = [0 25];
ylabel('Radiation (MJ m^{-2} day^{-1})');
xlabel('Temperature (°C)')
