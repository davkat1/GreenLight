function vaporDens = vp2dens(temp, vp)
% vp2dens Convert vapor pressure [Pa] to vapor density [kg{H2O} m^{-3}]
%
% Usage:
%   vaporDens = vp2dens(temp, vp)
% Inputs:
%   temp        given temperatures [°C] (numeric vector)
%   vp          vapor pressure [Pa] (numeric vector)
%   Inputs should have identical dimensions
% Outputs:
%   vaporDens   vapor density [kg{H2O} m^{-3}] (numeric vector)
%
% Calculation based on 
%   http://www.conservationphysics.org/atmcalc/atmoclc2.pdf

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
    
    % parameters used in the conversion
    p = [610.78 238.3 17.2694 -6140.4 273 28.916];
        % default value is [610.78 238.3 17.2694 -6140.4 273 28.916]

    satP = p(1)*exp(p(3)*temp./(temp+p(2))); 
        % Saturation vapor pressure of air in given temperature [Pa]
    
    rh = 100*vp./satP; % relative humidity
        
    vaporDens = rh2vaporDens(temp, rh);
end