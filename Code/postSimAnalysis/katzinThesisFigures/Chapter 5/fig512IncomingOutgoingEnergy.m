% FIG512INCOMINGOUTGOINGENERGY Present the yearly incoming and outgoing energy flows for selected heating by light scenarios.
% Used to generate Figure 5.12 in:
%   Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%   a process-based modelling approach (Phd Thesis, Wageningen University). 
%   https://doi.org/10.18174/544434
%
% Running this file will trigger a warning from energyAnalysis that 
% "Absolute value of energy balance greater than 100 MJ m^{-2}".
% This is not a problem, it is due to the use of heat harvesting

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Folder where simulation outputs are stored
outputFolder = 'C:\Users\John\OneDrive - Wageningen University & Research\PhD\gitwur\greenlight-new-led-opportunities\Output\20210415\';

load([outputFolder 'N-HH_ams_noLamp_hHarvest_day350_length350.mat'], 'gl')
nlhh=gl;
load([outputFolder 'L-450_ams_led_blScr_hHarvest_noBoil_ppfd450_day270_length350.mat'], 'gl')
p450=gl;
load([outputFolder 'L-200_ams_led_blScr_hHarvest_day270_length350.mat'], 'gl')
p200=gl;

offset = 70;

plotBars(nlhh,p200,p450,offset,0);
axis([0 6000 0.25 6.75])

function plotBars(gl1, gl2, gl3, offset, precision)
    [inGl1,outGl1] = energyAnalysis(gl1);
    [inGl2,outGl2] = energyAnalysis(gl2);
    [inGl3,outGl3] = energyAnalysis(gl3);
    
    % in = [sunIn heatIn lampIn];
    % out = [transp soilOut ventOut convOut firOut lampCool];

    outGl1 = outGl1([2 5 4 3 1]); 
    outGl2 = outGl2([2 5 4 3 1]);
    outGl3 = outGl3([2 5 4 3 1]);
    
    inGl1 = [inGl1 1e-6*trapz(gl1.a.hBufHotPipe) zeros(1,7)];
    inGl2 = [inGl2 1e-6*trapz(gl2.a.hBufHotPipe) zeros(1,7)];
    inGl3 = [inGl3 1e-6*trapz(gl3.a.hBufHotPipe) zeros(1,7)];
    outGl1 = [zeros(1,4) outGl1 -1e-6*trapz(gl1.a.hAirMech) -1e-6*trapz(gl1.a.lAirMech)];
    outGl2 = [zeros(1,4) outGl2 -1e-6*trapz(gl2.a.hAirMech) -1e-6*trapz(gl2.a.lAirMech)];
    outGl3 = [zeros(1,4) outGl3 -1e-6*trapz(gl3.a.hAirMech) -1e-6*trapz(gl3.a.lAirMech)];
    
    b = barh(1:6, [-outGl3; -outGl2; -outGl1; inGl3; inGl2; inGl1],'stacked');
    yticks(1:6);
    yticklabels({'L 450 outgoing', 'L 200 outgoing','N HH outgoing', ...
        'L 450 incoming', 'L 200 incoming', 'N HH incoming'});
    
    legend('Solar radiation', 'Heating from boiler', 'Lighting', 'Heating from buffer', ...
        'Convection to soil', 'Radiation to sky', ...
        'Convection through cover', 'Ventilation', ...
        'Latent heat', 'Sensible heat removed', 'Latent heat removed',...
        'Location', 'ne', 'FontSize', 7);

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


    xlabel('Energy flow (MJ m^{-2} year^{-1})');
    
    set(b(1),'DisplayName','Solar radiation');
    set(b(2),'DisplayName','Heating from boiler');
    set(b(3),'DisplayName','Lighting');
    set(b(4),'DisplayName','Heating from buffer',...
        'FaceColor',[0.82 0.43 0.91]);
    set(b(5),'DisplayName','Convection to soil',...
        'FaceColor',[0.466666666666667 0.674509803921569 0.188235294117647]);
    set(b(6),'DisplayName','Radiation to sky',...
        'FaceColor',[0.301960784313725 0.745098039215686 0.933333333333333]);
    set(b(7),'DisplayName','Convection through cover',...
        'FaceColor',[0.635294117647059 0.0784313725490196 0.184313725490196]);
    set(b(8),'DisplayName','Ventilation',...
        'FaceColor',[1 1 0.0666666666666667]);
    set(b(9),'DisplayName','Latent heat',...
        'FaceColor',[0.0745098039215686 0.623529411764706 1]);
    set(b(10),'DisplayName','Sensible heat harvested',...
        'FaceColor',[0.07 0.84 0.84]);
    set(b(11),'DisplayName','Latent heat harvested',...
        'FaceColor',[0.88 0.09 0.58]);

end

