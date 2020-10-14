% load('M:\PhD\Models\git\gitwur\GreenLight\Output\20200420LoLight\energyPlus_newParamsLoLight_ams_hps_27-Sep-1995_350days.mat','gl')
% hps = gl;
% load('M:\PhD\Models\git\gitwur\GreenLight\Output\20200420LoLight\energyPlus_newParamsLoLight_ams_led_27-Sep-1995_350days.mat','gl')
% led = gl;

hpsWin = cutTime(hps, datenum(hps.t.label)+116-1/24,86400);
ledWin = cutTime(led, datenum(led.t.label)+116-1/24,86400);

hpsSum = cutTime(hps, datenum(hps.t.label)+292-1/24,86400);
ledSum = cutTime(led, datenum(led.t.label)+292-1/24,86400);

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
% plot(smooth(ledWin.a.lCanAir,smoothFactor),'--','LineWidth',1.5,'Color',blue);
yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 9;
plot(smooth(100*hpsWin.u.roof,smoothFactor),'--','LineWidth',1,'Color',red);
plot(smooth(100*ledWin.u.roof,smoothFactor),'--','LineWidth',1,'Color',blue);
axis([xStart xEnd 0 20]);
ylabel('Roof opening (%)');

yyaxis left
legend('HPS lighting','LED lighting','HPS heating','LED heating','HPS ventilation','LED ventilation')
axis([xStart xEnd 0 200]);
yticks(0:50:200);
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
% plot(smooth(ledSum.a.lCanAir,smoothFactor),'--','LineWidth',1.5,'Color',blue);
yyaxis right
ax = gca;
ax.YColor = [0 0 0];
ax.FontSize = 9;
plot(smooth(100*hpsSum.u.roof,smoothFactor),'--','LineWidth',1,'Color',red);
plot(smooth(100*ledSum.u.roof,smoothFactor),'--','LineWidth',1,'Color',blue);
axis([xStart xEnd 0 20]);
ylabel('Roof opening (%)');

yyaxis left
legend('HPS lighting','LED lighting','HPS heating','LED heating','HPS ventilation','LED ventilation')
axis([xStart xEnd 0 200]);
yticks(0:50:200);
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
ax.FontSize = 9;
plot(smooth(hpsWin.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledWin.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',blue);
axis([xStart xEnd 0 10]);
yticks(0:2:10);
ylabel('Injection (mg m^{-2} s^{-1})')

legend('HPS CO_2 concentration','LED CO_2 concentration','HPS CO_2 injection','LED CO_2 injection')
yyaxis left
axis([xStart xEnd 0 1500]);
yticks(0:300:1500);
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
ax.FontSize = 9;
plot(smooth(hpsSum.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',red);
plot(smooth(ledSum.a.mcExtAir,smoothFactor),':','LineWidth',2,'Color',blue);
axis([xStart xEnd 0 10]);
yticks(0:2:10);
ylabel('Injection (mg m^{-2} s^{-1})')

legend('HPS CO_2 concentration','LED CO_2 concentration','HPS CO_2 injection','LED CO_2 injection')
yyaxis left
axis([xStart xEnd 0 1500]);
yticks(0:300:1500);
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
ax.FontSize = 9;
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
    'Outdoor temperature', 'Solar radiation');
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
    'Outdoor temperature', 'Solar radiation');
grid
