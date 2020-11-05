% PLOTEXAMPLEPROPCONTROL Plot an example of the operation of a smoothed proportional controller
% Used to create Figure 4 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

x.tAir = 0:0.001:40;
a.heatSetPoint = 18.5;
p.tHeatBand = -1;

plot(x.tAir, proportionalControl(x.tAir, a.heatSetPoint, -p.tHeatBand, 0, 1));
grid
axis([18 20 -0.1 1.1])
xticks(18:0.25:20)
xticklabels({'','','x = setPoint','','','','x = setPoint+Pband','',''})
hold on
plot([19.5 19.5], [-1 2], 'LineWidth',0.3,'LineStyle','--',...
    'Color',[0.15 0.15 0.15]);
plot([18.5 18.5], [-1 2], 'LineWidth',0.3,'LineStyle','--',...
    'Color',[0.15 0.15 0.15]);
yticks(-0.2:0.2:1.2)
yticklabels({'','No action', '0.2', '0.4', '0.6','0.8','Full action',''})
plot([10 30], [0 0], 'LineWidth',0.3,'LineStyle','--',...
    'Color',[0.15 0.15 0.15]);
plot([10 30], [1 1], 'LineWidth',0.3,'LineStyle','--',...
    'Color',[0.15 0.15 0.15]);
xlabel('Process variable x','LineWidth',0.3);
ylabel('Controller action','LineWidth',0.3);

