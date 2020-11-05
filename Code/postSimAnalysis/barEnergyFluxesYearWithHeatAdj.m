% BARENERGYFLUXESYEARWITHHEATADJ Create a bar graph of the energy fluxes in a simulated greenhouse, including the influence of heat adjustment
% Heat adjustment is the modification of the air temperature setpoint when 
% LEDs are on, used to compensate for low radiative heat of LEDs.
% Used to create Figure 8 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Set directories for loading data 
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
outputFolder = strrep(currentFolder, '\GreenLight\Code\postSimAnalysis', ...
    '\GreenLight\Output\referenceSetting\');
heatAdjFolder = strrep(currentFolder, '\GreenLight\Code\postSimAnalysis', ...
    '\GreenLight\Output\heatAdjustment\');
    % The last line may need to be modified, depending where the model 
    % output is saved
    % The path should include simulation results, with the following format
    % for the file names: <location>_<lampType>_<optionalMoreInfo>
    % Each location should have both HPS and LED lamp type

% Modify this to correct file name with a simulation output
load([outputFolder 'ams_hps_referenceSetting.mat'],'gl');
hps = gl;
load([outputFolder 'ams_led_referenceSetting.mat'],'gl');
led = gl;
load([heatAdjFolder 'ams_led_heatAdjustment.mat'], 'gl');
ledTempAdj = gl;

offset = 70;

plotBars(hps,led,ledTempAdj,offset,0);
axis([0 7000 0.25 6.75])

function plotBars(hps,led,ledHeatAdj, offset, precision)
    [inHps,outHps] = energyAnalysis(hps);
    [inLed,outLed] = energyAnalysis(led);
    [inLedHeatAdj,outLedHeatAdj] = energyAnalysis(ledHeatAdj);
    % in = [sunIn heatIn lampIn];
    % out = [transp soilOut ventOut convOut firOut lampCool];

    outHps = outHps([2 5 4 3 1]); 
    outLed = outLed([2 5 4 3 1]);
    outLedHeatAdj = outLedHeatAdj([2 5 4 3 1]);
    % in = [sunIn heatIn lampIn];
    % out = [soilOut firOut convOut ventOut transp];

    inHps = [inHps zeros(1,5)];
    inLed = [inLed zeros(1,5)];
    inLedHeatAdj = [inLedHeatAdj zeros(1,5)];
    outHps = [zeros(1,3) outHps];
    outLed = [zeros(1,3) outLed];
    outLedHeatAdj = [zeros(1,3) outLedHeatAdj];

    b = barh(1:6, [-outLedHeatAdj; -outLed; -outHps; inLedHeatAdj; inLed; inHps],'stacked');
    yticklabels({'LED TA outgoing', 'LED outgoing', 'HPS outgoing', 'LED TA incoming', 'LED incoming', 'HPS incoming'})
    legend('Solar radiation', 'Heating', 'Lighting', ...
        'Convection to soil', 'Radiation to sky', ...
        'Convection through cover', 'Ventilation', ...
        'Latent heat', 'Location', 'ne', 'FontSize', 7)

    numFormat = ['%.' num2str(precision) 'f'];
    
    barSum = zeros(length(b(1).XData),1);
    for j=1:length(b)
        for k=1:length(b(j).XData)
            if b(j).YData(k) > 0
                text(barSum(k)+b(j).YData(k)/2-offset,b(j).XData(k),num2str(b(j).YData(k),numFormat),'FontSize', 7);
                barSum(k) = barSum(k)+b(j).YData(k);
            end
        end
    end

    grid
    xlabel('Energy flux (MJ m^{-2} year^{-1})');
    
    set(b(1),'DisplayName','Solar radiation');
    set(b(2),'DisplayName','Heating');
    set(b(3),'DisplayName','Lighting');
    set(b(4),'DisplayName','Convection to soil',...
        'FaceColor',[0.466666666666667 0.674509803921569 0.188235294117647]);
    set(b(5),'DisplayName','Radiation to sky',...
        'FaceColor',[0.301960784313725 0.745098039215686 0.933333333333333]);
    set(b(6),'DisplayName','Convection through cover',...
        'FaceColor',[0.635294117647059 0.0784313725490196 0.184313725490196]);
    set(b(7),'DisplayName','Ventilation',...
        'FaceColor',[1 1 0.0666666666666667]);
    set(b(8),'DisplayName','Latent heat',...
        'FaceColor',[0.0745098039215686 0.623529411764706 1]);

end

