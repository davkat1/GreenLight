function energyIn = pipeT2EnergyIn(diam,deltaT,pipeLength)
%PIPET2ENERGYIN Calculate energy input to the greenhouse according to pipe temperaure
% Based on Verveer, J.B. (1995). Handboek Verwarming Glastuinbouw (Poeldijk: Nutsbedrijf Westland N.V.).
% Note that currently evaluation for deltaT<12 is pretty bad
% Requires the file 'verveer.mat' which contains a table with the pipe
% diameter, the deltaT, and the resulting energy input
% Inputs:
%   diam        Pipe diameter (mm)
%   deltaT      Difference between air and pipt temperature (°C)
%   pipeLength  Length of pipe in greenhouse (m m^{-2})
% Output:
%   energyIn    Amount of energy given through the pipes to the greenhouse (W m^{-2})

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    load('verveer.mat', 'verveer');

    % Find the closest rows, from above and below, to the given diameter
    diamIndex = interp1(verveer(2:end,1),2:length(verveer(1:end,1)),diam);
    diamFloor = floor(diamIndex);
    diamCeil = ceil(diamIndex);

    % calculate the energy for the chosen 2 rows (W m^{-1})
    energyFloor = interp1(verveer(1,2:end),verveer(diamFloor,2:end),deltaT);
    energyCeil = interp1(verveer(1,2:end),verveer(diamCeil,2:end),deltaT);

    % distance from diamIndex to diamFloor
    d = diamIndex-diamFloor;

    % interpolate the values from between the 2 rows
    % and multiply by the pipe length m m^{-2} to get W m^{-2}
    energyIn = pipeLength*(d*energyCeil + (1-d)*energyFloor);  
    
    % if deltaT is not positive, no energy is coming in
    energyIn(deltaT<=0) = 0;    
end