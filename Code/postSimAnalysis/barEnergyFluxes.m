% BARENERGYFLUXES Create a bar graph of the energy fluxes in a simulated greenhouse
% Creates a bar graph for the full year, for a day in winter and a day in summer
% The "winter and summer" figure was used to create Figure 10 in: 
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

%% year
% figure;
% plotBars(hps,led,50,0);

%% Winter and summer
% figure;
offset = 0.15;

% Choose dates for the winter and summer days. Dates are represented by
% "days since Sept 27 (the beginning of the growing season)". 
% 116 - January 21; 292 - July 15 (used in Paper).
% Other examples:
% 65 - December 1
% 96 - January 1
% 156 - March 1
% 248 - June 1
% 340 - September 1
winterDay = 116;
summerDay = 292;

hpsWin = cutTime(hps, datenum(hps.t.label)+winterDay-1/24,86400);
ledWin = cutTime(led, datenum(led.t.label)+winterDay-1/24,86400);

hpsSum = cutTime(hps, datenum(hps.t.label)+summerDay-1/24,86400);
ledSum = cutTime(led, datenum(led.t.label)+summerDay-1/24,86400);

subplot(2,1,1)
plotBars(hpsWin,ledWin,offset,1)

subplot(2,1,2)
plotBars(hpsSum,ledSum,offset,1)

subplot(2,1,1)
axis([0 20 0.25 4.75])
xlabel('Energy flux (MJ m^{-2} day^{-1})');
title('A. Daily energy fluxes in HPS and LED greenhouses in winter (AMS)')

subplot(2,1,2)
axis([0 20 0.25 4.75])
xlabel('Energy flux (MJ m^{-2} day^{-1})');
title('B. Daily energy fluxes in HPS and LED greenhouses in summer (AMS)')



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
        'Convection to soil', 'Radiation to sky', ...
        'Convection through cover', 'Ventilation', ...
        'Latent heat', 'Location', 'ne','FontSize', 7)

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
    title('Yearly energy fluxes in HPS and LED greenhouses (AMS)')
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

