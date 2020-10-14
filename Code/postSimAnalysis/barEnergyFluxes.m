load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_hps_27-Sep-1995_350days.mat')
hps = gl;
load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_led_27-Sep-1995_350days.mat')
led = gl;

%% year
plotBars(hps,led,50,0);

%% Winter and summer
hpsWin = cutTime(hps, datenum(hps.t.label)+116-1/24,86400);
ledWin = cutTime(led, datenum(led.t.label)+116-1/24,86400);

hpsSum = cutTime(hps, datenum(hps.t.label)+292-1/24,86400);
ledSum = cutTime(led, datenum(led.t.label)+292-1/24,86400);

figure;
subplot(2,1,1)
plotBars(hpsWin,ledWin,0.1,1)

subplot(2,1,2)
plotBars(hpsSum,ledSum,0.1,1)

subplot(2,1,1)
axis([0 16 0 5])
xlabel('Energy flux (MJ m^{-2} day^{-1})');
title('Daily energy fluxes in HPS and LED greenhouses in winter (AMS)')

subplot(2,1,2)
axis([0 16 0 5])
xlabel('Energy flux (MJ m^{-2} day^{-1})');
title('Daily energy fluxes in HPS and LED greenhouses in summer (AMS)')



function plotBars(hps,led, offset, precision)
    [inHps,outHps] = energyAnalysis(hps);
    [inLed,outLed] = energyAnalysis(led);
    % in = [sunIn heatIn lampIn];
    % out = [transp soilOut ventOut convOut firOut lampCool];

    outHps = outHps([2 5 4 3 1]); 
    outLed = outLed([2 5 4 3 1]);
    % in = [sunIn heatIn lampIn];
    % out = [soilOut firOut convOut ventOut transp];

    inHps = [inHps zeros(1,5)];
    inLed = [inLed zeros(1,5)];
    outHps = [zeros(1,3) outHps];
    outLed = [zeros(1,3) outLed];

    b = barh(1:4, [-outLed; -outHps; inLed; inHps],'stacked');
    yticklabels({'LED outgoing', 'HPS outgoing', 'LED incoming', 'HPS incoming'})
    legend('Solar radiation', 'Heating', 'Lighting', ...
        'Convection to soil', 'Radiation to the sky', ...
        'Convection to outside air', 'Ventilation', ...
        'Conversion to latent heat', 'Location', 'nw')

    numFormat = ['%.' num2str(precision) 'f'];
    
    barSum = zeros(length(b(1).XData),1);
    for j=1:length(b)
        for k=1:length(b(j).XData)
            if b(j).YData(k) > 0
                text(barSum(k)+b(j).YData(k)/2-offset,b(j).XData(k),num2str(b(j).YData(k),numFormat),'FontSize', 14);
                barSum(k) = barSum(k)+b(j).YData(k);
            end
        end
    end

    grid
    title('Yearly energy fluxes in HPS and LED greenhouses (AMS)')
    xlabel('Energy flux (MJ m^{-2} year^{-1})');
end

