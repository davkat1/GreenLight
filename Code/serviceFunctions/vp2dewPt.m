function dewPt = vp2dewPt(vp)
% VP2DEWPT Convert vapor pressure [Pa] to dew point [°C]
%
% Usage:
%   dewPt = vp2dewPt(vp)
% Inputs:
%   vp          Partial vapor pressure in air [Pa] (numeric vector)
% Outputs:
%   dewPt       Dew point [°C] (numeric vector)
%
% Calculation based on 
%   http://www.conservationphysics.org/atmcalc/atmoclc2.pdf

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % parameters used in the conversion
    p = [610.78 238.3 17.2694 -6140.4 273 28.916];
        % default value is [610.78 238.3 17.2694 -6140.4 273 28.916]
    
    w = log(vp/p(1));
        
    dewPt = w*p(2)./(p(3)-w);
end