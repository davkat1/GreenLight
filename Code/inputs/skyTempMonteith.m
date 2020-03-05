function skyTemp = skyTempMonteith(airTemp, cloud)
%SKYTEMPMONTEITH Estimate the sky temperature based on Monteith & Unsworth (2013)
% See:
% Monteith, J., and Unsworth, M. (2013). Principles of environmental physics: 
% plants, animals, and the atmosphere (Academic Press) pp. 71-74. See also
% Exercise 5.4, with the included answer.
% Usage:
% skyTemp = skyTempMonteith(airTemp, cloud)
%   airTemp - air temperture [°C]
%   cloud - degree of cloud cover [0-1, 0 is clear sky]
%   skyTemp - estimated sky temperature [°C]

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    SIGMA = 5.67e-8; % Stefan-Boltzmann constant
    C2K = 273.15;    % Conversion of °C to K

    LdClear = 213+5.5*airTemp;                      % Equation 5.26
    epsClear = LdClear./(SIGMA*(airTemp+C2K).^4);   % Equation 5.22
    epsCloud = (1-0.84*cloud).*epsClear+0.84*cloud; % Equation 5.32
    LdCloud = epsCloud.*SIGMA.*(airTemp+C2K).^4;    % Equation 5.22
    skyTemp = (LdCloud/SIGMA).^(0.25)-C2K;          % Equation 5.22, but here assuming eps=1

end

