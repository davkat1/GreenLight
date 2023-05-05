function [lampIn, boilIn, hhIn, parSun, parLamps, yield, efficiency] = energyYieldAnalysis(gl)
% ENERGYYIELDANALYSIS Return the resulting energy use, light above the canopy, yield, and efficiency of a GreenLight simulation
% Usage:
%   [lampIn, boilerIn, hhIn, parSun, parLamps, yield, efficiency] = energyYieldAnalysis(gl)
%
% Input:
%   gl -    a GreenLight model instance, after simulating
% Outputs:
%   lampIn -        Energy consumption of the lamps [MJ m^{-2}]
%   boilIn -        Energy consumption of the boiler [MJ m^{-2}]
%   hhIn -          Energy consumption of the heat harvesting system [MJ m^{-2}]
%   parSun -        PAR light from the sun reaching above the canopy [mol m^{-2}]
%   parLamps -      PAR light from the lamps reaching outside the canopy [mol m^{-2}]
%   yield -         Fresh weight tomato yield [kg m^{-2}]
%   efficiency -    Energy input needed per tomato yield [MJ kg^{-1}]
%
% For more information, see 
%   [1] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD Thesis, Wageningen University). 
%       https://doi.org/10.18174/544434
%   [2] Katzin, Marcelis, Van Henten, Van Mourik (2023). Heating
%       greenhouses by light: A novel concept for intensive greenhouse
%       production (Biosystems Engineering).

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

    %% If the model did not have heat harvesting, set these values as 0
    if ~isfield(gl.u, 'mech') || ~isa(gl.u.mech, 'DynamicElement')
        gl.u.mech = 0;
    end
    if ~isfield(gl.u, 'heatPump') || ~isa(gl.u.heatPump, 'DynamicElement')
        gl.u.heatPump = 0;
    end
    if ~isfield(gl.p, 'pMech') || ~isa(gl.p.pMech, 'DynamicElement')
        gl.p.pMech = 0;
    end
    if ~isfield(gl.p, 'etaMech') || ~isa(gl.p.etaMech, 'DynamicElement')
        gl.p.etaMech = 0.25;
    end
    if ~isfield(gl.p, 'pHeatPump') || ~isa(gl.p.pHeatPump, 'DynamicElement')
        gl.p.pHeatPump = 0;
    end
    
    % Dry matter content, see Chapter 5 Section 2.3.3 [1]
    dmc = 0.06;
    
    % Energy consumption of the lamps [MJ m^{-2}]
    lampIn = 1e-6*trapz(gl.a.qLampIn+gl.a.qIntLampIn); 

    % Energy consumption of the boiler [MJ m^{-2}]
    boilIn = 1e-6*trapz(gl.a.hBoilPipe+gl.a.hBoilGroPipe);

    % Energy consumption of the heat harvesting system [MJ m^{-2}]
    % See Equation 1 [2]
    hhIn = 1e-6*trapz(gl.p.pHeatPump*gl.u.heatPump+(1+gl.p.etaMech)*gl.p.pMech.*gl.u.mech);
    
    % PAR light from the sun reaching above the canopy [mol m^{-2}]
    parSun = 1e-6*trapz(gl.p.parJtoUmolSun*gl.a.rParGhSun);
    
    % PAR light from the lamps reaching outside the canopy [mol m^{-2}]
    parLamps = 1e-6*trapz(gl.p.zetaLampPar*gl.a.rParGhLamp+gl.p.zetaIntLampPar*gl.a.rParGhIntLamp);
    
    % Fresh weight tomato yield [kg m^{-2}]
    yield = 1e-6*trapz(gl.a.mcFruitHar)/dmc;
    
    % Energy input needed per tomato yield [MJ kg^{-1}]
    efficiency = (lampIn+boilIn+hhIn)/yield;

end