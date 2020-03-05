function co2Dens = co2ppm2dens(temp, ppm)
% CO2PPM2DENS Convert CO2 molar concetration [ppm] to density [kg m^{-3}]
%
% Usage:
%   co2Dens = co2ppm2dens(temp, ppm) 
% Inputs:
%   temp        given temperatures [°C] (numeric vector)
%   ppm         CO2 concetration in air (ppm) (numeric vector)
%   Inputs should have identical dimensions
% Outputs:
%   co2Dens     CO2 concentration in air [kg m^{-3}] (numeric vector)
%
% Calculation based on ideal gas law pV=nRT, with pressure at 1 atm

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    R = 8.3144598; % molar gas constant [J mol^{-1} K^{-1}]
    C2K = 273.15; % conversion from Celsius to Kelvin [K]
    M_CO2 = 44.01e-3; % molar mass of CO2 [kg mol^-{1}]
    P = 101325; % pressure (assumed to be 1 atm) [Pa]
    
    % number of moles n=m/M_CO2 where m is the mass [kg] and M_CO2 is the
    % molar mass [kg mol^{-1}]. So m=p*V*M_CO2*P/RT where V is 10^-6*ppm    
    co2Dens = P*10^-6*ppm*M_CO2./(R*(temp+C2K));
end