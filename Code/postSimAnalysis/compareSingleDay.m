load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_hps_27-Sep-1995_350days.mat', 'gl')
hps = gl;
load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_led_27-Sep-1995_350days.mat', 'gl')
led = gl;

for k=0:349
    hpsDay = cutTime(hps, datenum(hps.t.label)+k,86400);
    ledDay = cutTime(led, datenum(led.t.label)+k,86400);
    [qIn, qOut] = energyAnalysis(hpsDay);
    hpsDayIn = qIn(2)+qIn(3);
    hpsHeatIn(k+1) = qIn(2);
    hpsLightIn(k+1) = qIn(3);
    lightFrac(k+1) = qIn(3)/(qIn(3)+qIn(2));
    [qIn, qOut] = energyAnalysis(ledDay);
    ledDayIn = qIn(2)+qIn(3);
    ledHeatIn(k+1) = qIn(2);
    ledLightIn(k+1) = qIn(3);
    savings(k+1) = 1-ledDayIn/hpsDayIn;
    globOut(k+1) = 1e-6*trapz(hpsDay.d.iGlob);
    tOut(k+1) = mean(hpsDay.d.tOut);
end

ledWin = cutTime(led, datenum(led.t.label)+116,86400);
hpsWin = cutTime(hps, datenum(hps.t.label)+116,86400);
ledSum = cutTime(led, datenum(led.t.label)+273,86400);
hpsSum = cutTime(hps, datenum(hps.t.label)+273,86400);

subplot(2,1,1)
plot(hpsLightIn)
hold on
plot(ledLightIn)
plot(hpsHeatIn)
plot(ledHeatIn)
legend('HPS light','LED light','HPS heat','LED heat')
% plot(hpsHeatIn+hpsLightIn)
% plot(ledHeatIn+ledLightIn)
ylabel('Daily energy input (MJ m^{-2})')
title('Daily energy use in HPS and LED greenhouse');

subplot(2,1,2)
plot(globOut)
yyaxis right
plot(tOut)
title('Daily radiation and outdoor temperature');
xlabel('Day of season')
ylabel('Outdoor temperature (°C)')
yyaxis left
ylabel('Daily radiation (MJ m^{-2})')

subplot(2,1,2)
plot(globOut)
yyaxis right
plot(tOut)
title('Daily radiation and outdoor temperature');
xlabel('Day of season')
ylabel('Outdoor temperature (°C)')
yyaxis left
ylabel('Daily radiation (MJ m^{-2})')
grid
subplot(2,1,1)
grid
subplot(2,1,2)
legend('Radiation','Temperature')