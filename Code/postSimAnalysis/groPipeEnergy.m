function energy = groPipeEnergy(dT)
%GROPIPEENERGY Calculate the energy input to the grow pipes in a compartment in Wageningen Greenhouse Horticulture, Bleiswijk
% Based on the lengths and diameters of the pipes in the network for grow
% pipes in the 144 m2 compartment:
%   94.5 m of 35mm diameter pipes
%   70 m of 29mm diameter pipes
%   9.4 m of 64mm diameter pipes
%   37 m of 51mm diameter pipes
%
% input:
%   dT - difference between air and grow pipe temperature (°C)
% output:
%   energy - energy input from the pipe (W m^{-2})
% Constants used below are only relevant for a 144 m^{2} compartment in 
% Wageningen Greenhouse Horticulture, Bleiswijk

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    energy = 1/144*(pipeT2EnergyIn(35,dT,94.5)+pipeT2EnergyIn(29,dT,70)+...
        pipeT2EnergyIn(64,dT,9.4)+pipeT2EnergyIn(51,dT,37));
end