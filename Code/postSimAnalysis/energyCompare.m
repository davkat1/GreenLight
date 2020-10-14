function energyCompare(gl1, gl2)
% ENERGYCOMPARE  ---TO DO---
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

    sunIn = 1e-6*trapz(gl1.a.rGlobSunAir+gl1.a.rParSunCan+gl1.a.rNirSunCan+gl1.a.rParSunFlr+gl1.a.rNirSunFlr+gl1.a.rGlobSunCovE) ...
        -1e-6*trapz(gl2.a.rGlobSunAir+gl2.a.rParSunCan+gl2.a.rNirSunCan+gl2.a.rParSunFlr+gl2.a.rNirSunFlr+gl2.a.rGlobSunCovE);
    heatIn = 1e-6*trapz(gl1.a.hBoilPipe+gl1.a.hBoilGroPipe)-1e-6*trapz(gl2.a.hBoilPipe+gl2.a.hBoilGroPipe);
    transp = -1e-6*trapz(gl1.a.lAirThScr+gl1.a.lTopCovIn-gl1.a.lCanAir)+1e-6*trapz(gl2.a.lAirThScr+gl2.a.lTopCovIn-gl2.a.lCanAir);
    soilOut = 1e-6*trapz(gl1.a.hSo5SoOut)-1e-6*trapz(gl2.a.hSo5SoOut);
    ventOut = 1e-6*trapz(gl1.a.hAirOut+gl1.a.hTopOut)-1e-6*trapz(gl2.a.hAirOut+gl2.a.hTopOut);
    convOut = 1e-6*trapz(gl1.a.hCovEOut)-1e-6*trapz(gl2.a.hCovEOut);
    firOut = 1e-6*trapz(gl1.a.rCovESky+gl1.a.rThScrSky+gl1.a.rCanSky+gl1.a.rPipeSky+gl1.a.rFlrSky) ...
        -1e-6*trapz(gl2.a.rCovESky+gl2.a.rThScrSky+gl2.a.rCanSky+gl2.a.rPipeSky+gl2.a.rFlrSky);
    lampIn = 1e-6*trapz(gl1.a.qLampIn)-1e-6*trapz(gl2.a.qLampIn);
    lampCool = 1e-6*trapz(gl1.a.hLampCool)-1e-6*trapz(gl2.a.hLampCool);
    
    balance = sunIn+heatIn-transp-soilOut-ventOut-firOut+lampIn-convOut-lampCool;
    
    fprintf(['Incoming energy:\nSunIn: %f\nheatIn: %f\nlampIn: %f\ntotal: %f' ...
        '\n--------\nOutgoing energy:\ntranspiration: %f\nsoilOut: %f\n' ...
        'ventOut: %f\nconvOut: %f\nfirOut: %f\nlampCool: %f\ntotal: %f\n------\ntotal balance: %f\n'], ...
        sunIn,heatIn,lampIn,sunIn+heatIn+lampIn,...
        transp,soilOut,ventOut,convOut,firOut,lampCool,...
        transp+soilOut+ventOut+convOut+firOut+lampCool,balance);

end