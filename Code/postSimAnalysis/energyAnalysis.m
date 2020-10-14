function [in, out] = energyAnalysis(gl, print)
% ENERGYANALYSIS Outputs the energy balance of a simulated GreenLight model
% Gives the total value (trapz) of the following (MJ m^{-2})
%   Incoming fluxes
%       in(1)   Radiation from the sun
%       in(2)   Heat from the boiler (pipe-rail and grow-pipes)
%       in(3)   Energy from lamps (top-lights and inter-lights)
%   Outgoing fluxes
%       out(1)  Net conversion of sensible to latent heat (transpiration-condensation)
%       out(2)  Convection to soil
%       out(3)  Ventilation to the outside
%       out(4)  Convection through the cover
%       out(5)  Thermal radiation towards the sky
%       out(6)  Lamp cooling
% The sum of the ingoing and outgoing fluxes should typically be more or
% less equivalent. If it isn't (difference more than 100 MJ m^{-2}), an
% error is produced.
% If the argument print is true, an output will be printed to the console.
% The default for print is false.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    if ~exist('print','var')
        print = false;
    end
    
    sunIn = 1e-6*trapz(gl.a.rGlobSunAir+gl.a.rParSunCan+gl.a.rNirSunCan+gl.a.rParSunFlr+gl.a.rNirSunFlr+gl.a.rGlobSunCovE);
    heatIn = 1e-6*trapz(gl.a.hBoilPipe+gl.a.hBoilGroPipe);
    transp = 1e-6*trapz(gl.a.lAirThScr+gl.a.lAirBlScr+gl.a.lTopCovIn-gl.a.lCanAir);
    soilOut = -1e-6*trapz(gl.a.hSo5SoOut);
    ventOut = -1e-6*trapz(gl.a.hAirOut+gl.a.hTopOut);
    convOut = -1e-6*trapz(gl.a.hCovEOut); 
    firOut = -1e-6*trapz(gl.a.rCovESky+gl.a.rThScrSky+gl.a.rBlScrSky+gl.a.rCanSky+gl.a.rPipeSky+gl.a.rFlrSky+gl.a.rLampSky);
    lampIn = 1e-6*trapz(gl.a.qLampIn+gl.a.qIntLampIn);
    lampCool = -1e-6*trapz(gl.a.hLampCool);

    balance = sunIn+heatIn+transp+soilOut+ventOut+firOut+lampIn+convOut+lampCool;

    in = [sunIn heatIn lampIn];
    out = [transp soilOut ventOut convOut firOut lampCool];
    
    if print
        fprintf(['SunIn: %f\nheatIn: %f\ntranspiration: %f\nsoilOut: %f\n' ...
            'ventOut: %f\nconvOut: %f\nfirOut: %f\nlampIn: %f\nlampCool: %f\ntotal balance: %f\npurchased inputs: %f\n'],sunIn,heatIn,transp,...
            soilOut,ventOut,convOut,firOut,lampIn,lampCool,balance,lampIn+heatIn);
    end
    
    if abs(balance) > 100
        warning('Absolute value of energy balance greater than 100 MJ m^{-2}')
    end
end