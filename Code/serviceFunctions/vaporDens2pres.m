function vaporPres = vaporDens2pres(temp, vaporDens)
% VAPORDENS2PRES Convert vapor density [kg{H2O} m^{-3}] to vapor pressure [Pa]
%
% Usage:
%   vaporPres = vaporDens2pres(temp, vaporDens)
% Inputs:
%   temp        given temperatures [°C] (numeric vector)
%   vaporDens   vapor density [kg{H2O} m^{-3}] (numeric vector)
%   Inputs should have identical dimensions
% Outputs:
%   vaporPres   vapor pressure [Pa] (numeric vector)
%
% Calculation based on 
%   http://www.conservationphysics.org/atmcalc/atmoclc2.pdf

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
    
    % parameters used in the conversion
    p = [610.78 238.3 17.2694 -6140.4 273 28.916];
        % default value is [610.78 238.3 17.2694 -6140.4 273 28.916]
    
    rh = vaporDens./rh2vaporDens(temp, 100); % relative humidity [0-1]
        
    satP = p(1)*exp(p(3)*temp./(temp+p(2))); 
        % Saturation vapor pressure of air in given temperature [Pa]
    
    vaporPres = satP.*rh;
end