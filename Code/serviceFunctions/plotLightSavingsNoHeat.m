% PLOTLIGHTSAVINGSNOHEAT Display savings in lighting input as fraction of total energy input, assuming no change in heating demand
% Used to create Figure 5 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

x = 0:100; % percent of energy input that goes to lighting

hps = 1.8; % Assumed efficacy of HPS lamps (umol{PAR} J^{-1}{electricity})
led1 = 3; % Typical efficacy of modern LED
led2 = 4.1; % Predicted maximal efficacy of horticultural LED
led3 = Inf; % Infinitely efficient lamp

figure; hold on
plot(x, (1-hps/led1)*x);
plot(x, (1-hps/led2)*x);
plot(x, (1-hps/led3)*x);

ylabel('Energy saving (%)');
xlabel('Fraction of energy used for lighting in current system (%)');
legend('LED 3 ?mol J^{-1}', ...
    'LED 4.1 ?mol J^{-1}',...
    'Infinitely efficient lamp', ...
    'Location','nw')
grid
