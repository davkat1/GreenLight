% load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_hps_27-Sep-1995_350days.mat', 'gl')
% hps = gl;
% load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_led_27-Sep-1995_350days.mat', 'gl')
% led = gl;

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
xlabel('Days after planting')
grid
legend('HPS lighting', 'HPS heating', 'LED lighting', 'LED heating', 'Location', 'nw');

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
xlabel('Days after planting')
yyaxis left
ylabel('Outdoor temperature (°C)');
legend('Outdoor temperature','Solar radiation','Location','nw');
grid