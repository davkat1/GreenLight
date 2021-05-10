function de = cond(hec, vp1, vp2)
%COND Vapor flux from the air to an object by condensation in the Vanthoor model
% The vapor flux is measured in kg m^{-2} s^{-1}.
% Based on Equation 43 in the electronic appendix of 
%   Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
%
% Usage:
%   de = cond(hec, vp1, vp2)
%
% Inputs:
%   hec     the heat exchange coefficienct between object1 (air) and object2 (a surface) [W m^{-2} K^{-1}]
%   vp1     the vapor pressure of the air
%   vp2     the saturation vapor pressure at the temperature of the object
%
% Outputs:
%   de      a DynamicElement representing the condensation between object1 and object2

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com    

	sMV12 = -0.1; % Slope of smoothed condensation model (Pa^{-1}, see [1])
    de = 1./(1+exp(sMV12.*(vp1-vp2))).*6.4e-9.*hec.*(vp1-vp2);
    
end

