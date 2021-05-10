function sat = satVp(temp)
% saturated vapor pressure (Pa) at temperature temp (°C)
% Calculation based on 
%   http://www.conservationphysics.org/atmcalc/atmoclc2.pdf
% See also file atmoclc2.pdf

    % parameters used in the conversion
    p = [610.78 238.3 17.2694 -6140.4 273 28.916];
        % default value is [610.78 238.3 17.2694 -6140.4 273 28.916]
    
    sat = p(1)*exp(p(3)*temp./(temp+p(2))); 
        % Saturation vapor pressure of air in given temperature [Pa]
end