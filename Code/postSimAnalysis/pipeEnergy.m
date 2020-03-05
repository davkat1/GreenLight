function energy = pipeEnergy(dT)
%PIPEENERGY Calculate the energy input to the pipe rails in a compartment in Wageningen Greenhouse Horticulture, Bleiswijk
% Based on the lengths and diameters of the pipes in the network for the 
% pipe rail in the 144 m2 compartment:
%   166.8 m of 51mm diameter pipes
%   6 m of 29mm diameter pipes
%   19.2 m of 58mm diameter pipes
%
% input:
%   dT - difference between air and pipe rail temperature (°C)
% output:
%   energy - energy input from the pipe (W m^{-2})
% Constants used below are only relevant for a 144 m^{2} compartment in 
% Wageningen Greenhouse Horticulture, Bleiswijk

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    energy = 1/144*(pipeT2EnergyIn(51,dT,166.8)+pipeT2EnergyIn(29,dT,6)+...
        pipeT2EnergyIn(58,dT,19.2));
end
