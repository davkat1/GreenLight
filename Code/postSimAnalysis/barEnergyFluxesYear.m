% Standard case
% load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_hps_27-Sep-1995_350days.mat')
% hps = gl;
% load('C:\PhD\GreenLight Output 20200427\20200420LoLight\energyPlus_newParamsLoLight_ams_led_27-Sep-1995_350days.mat')
% led = gl;

subplot(3,1,1)
plotBars(hps,led,50,0);
title('Yearly energy fluxes in reference setting (AMS)')
axis([0 6000 0 5])

% No heat adjustment
% load('C:\PhD\GreenLight Output 20200427\20200422LoLightLedHc0\energyPlus_newParamsLoLightHc0_ams_led_27_Sep_1995_350days.mat', 'gl')
% led0 = gl;
subplot(3,1,2)
plotBars(hps,led0,50,0);
title('Yearly energy fluxes without heat adjustment in LED greenhouse (AMS)')
axis([0 6000 0 5])

% Higher RH
load('C:\PhD\GreenLight Output 20200427\20200422edgeCases\rh92\energyPlus_rh92_ams_hps_27_Sep_1995_350days.mat', 'gl')
hps92 = gl;
load('C:\PhD\GreenLight Output 20200427\20200422edgeCases\rh92\energyPlus_rh92_ams_led_27_Sep_1995_350days.mat', 'gl')
led92 = gl;

subplot(3,1,3)
plotBars(hps92,led92,50,0);
title('Yearly energy fluxes with higher relative humidity setpoint (AMS)')


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

