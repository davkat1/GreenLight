function energyAnalysis(gl)
% ENERGYANALYSIS Prints out the energy balance of a simulated GreenLight model
% Prints out the total value (trapz) of the following:
%   Radiation from the sun
%   Heat from the boiler
%   Energy converted to latent heat by transpiration
%   Losses to the soil
%   Losses due to ventilation
%   Losses to the outside through convection
%   Losses to the sky through long wave radiation
%   Heat from lamps
%   Heat extracted by lamp cooling

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    sunIn = 1e-6*trapz(gl.a.rGlobSunAir+gl.a.rParSunCan+gl.a.rNirSunCan+gl.a.rParSunFlr+gl.a.rNirSunFlr+gl.a.rGlobSunCovE);
    heatIn = 1e-6*trapz(gl.a.hBoilPipe+gl.a.hBoilGroPipe);
    transp = 1e-6*trapz(gl.a.lAirThScr+gl.a.lTopCovIn-gl.a.lCanAir);
    soilOut = -1e-6*trapz(gl.a.hSo5SoOut);
    ventOut = -1e-6*trapz(gl.a.hAirOut+gl.a.hTopOut);
    convOut = -1e-6*trapz(gl.a.hCovEOut); %
    firOut = -1e-6*trapz(gl.a.rCovESky+gl.a.rThScrSky+gl.a.rCanSky+gl.a.rPipeSky+gl.a.rFlrSky);
    lampIn = 1e-6*trapz(gl.a.qLampIn);
    lampCool = -1e-6*trapz(gl.a.hLampCool);

    balance = sunIn+heatIn+transp+soilOut+ventOut+firOut+lampIn+convOut+lampCool;

    fprintf(['SunIn: %f\nheatIn: %f\ntranspiration: %f\nsoilOut: %f\n' ...
        'ventOut: %f\nconvOut: %f\nfirOut: %f\nlampIn: %f\nlampCool: %f\ntotal balance: %f\n'],sunIn,heatIn,transp,...
        soilOut,ventOut,convOut,firOut,lampIn,lampCool,balance);
end