function lampOutput(gl)
% LAMPOUTPUT Prints out the toplight output of a simulated GreenLight model
% Prints out the relative value (trapz) of the following:
%   Lamp input 
%   Lamp PAR output to the canopy and floor
%   Lamp NIR output to the canopy and floor
%   Lamp shortwave output (PAR and NIR) to the air
%   Lamp FIR output
%   Lamp convective output
%   Lamp cooling

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

	lampIn = trapz(gl.a.qLampIn); % total

    lampParCanFlr = trapz(gl.a.rParLampCan+gl.a.rParLampFlr)./lampIn;
	lampNirCanFlr = trapz(gl.a.rNirLampCan+gl.a.rNirLampFlr)./lampIn;
    lampParFrac = gl.p.etaLampPar;
    lampNirFrac = gl.p.etaLampNir;
    lampSwAir = trapz(g1.a.rLampAir)./lampIn; % NIR and PAR to the air
	lampFir = trapz(gl.a.rLampSky+gl.a.rLampCovIn+gl.a.rLampThScr+gl.a.rLampPipe+ ...
		gl.a.rFirLampFlr+gl.a.rLampBlScr+gl.a.rFirLampCan)/lampIn; % FIR

	lampConv = trapz(gl.a.hLampAir)/lampIn; % Convection
	lampCool = trapz(gl.a.hLampCool)/lampIn; % cooling
    
    fprintf(['Total lamp input: %f\nfraction to PAR (canopy and floor): %f\n'...
        'fraction to NIR (canopy and floor): %f\nShortwave to air (PAR and NIR): %f\n'...
        'fraction to PAR (lamp setting): %f\nfraction to NIR (lamp setting): %f\n' ...
        'Fraction to FIR %f\nFraction to cooling: %f\n'], ...
        lampIn, lampParCanFlr, lampNirCanFlr, lampSwAir, lampParFrac, lampNirFrac, ...
        lampFir, lampConv, lampCool);
end