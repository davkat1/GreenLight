function setGlOdes(gl)
%SETGLODES Define ODEs for the GreenLight greenhouse model
% Should be used after the states, aux states, and control rules have been set.
%
% Based on the electronic appendices (the case of a Dutch greenhouse) of:
%   [1] Vanthoor, B., Stanghellini, C., van Henten, E. J. & de Visser, P. H. B. 
%       A methodology for model-based greenhouse design: Part 1, a greenhouse climate 
%       model for a broad range of designs and climates. Biosyst. Eng. 110, 363–377 (2011).
%   [2] Vanthoor, B., de Visser, P. H. B., Stanghellini, C. & van Henten, E. J. 
%       A methodology for model-based greenhouse design: Part 2, description and 
%       validation of a tomato yield model. Biosyst. Eng. 110, 378–395 (2011).
% These are also available as Chapters 8 and 9, respecitvely, of
%   [3] Vanthoor, B. A model based greenhouse design method. (Wageningen University, 2011).
% Other sources are:
%   [4] De Zwart, H. F. Analyzing energy-saving options in greenhouse cultivation 
%       using a simulation model. (Landbouwuniversiteit Wageningen, 1996).
% The model is described and evaluated in:
%   [5] Katzin, D., van Mourik, S., Kempkes, F., & Van Henten, E. J. (2020). 
%       GreenLight - An open source model for greenhouses with supplemental 
%       lighting: Evaluation of heat requirements under LED and HPS lamps. 
%       Biosystems Engineering, 194, 61–81. https://doi.org/10.1016/j.biosystemseng.2020.03.010
% The model is further described in:
%   [6] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434
%
% Inputs:
%   gl    - a DynamicModel object to be used as a GreenLight model.

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

	x = gl.x;
    p = gl.p;
    a = gl.a;
    u = gl.u;
    d = gl.d;
    
    %% Energy balance 
    
    % Canopy temperature [°C s^{-1}]
    % Equation 1 [1], Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tCan', ...
    (1./a.capCan).*(a.rParSunCan+a.rNirSunCan+a.rPipeCan ...
        -a.hCanAir-a.lCanAir-a.rCanCovIn-a.rCanFlr-a.rCanSky-a.rCanThScr-a.rCanBlScr ...
        +a.rParLampCan+a.rNirLampCan+a.rFirLampCan ...
        +a.rGroPipeCan ... 
        +a.rParIntLampCan+a.rNirIntLampCan+a.rFirIntLampCan)); 
    
    % Greenhouse air temperature [°C s^{-1}]
    % Equation 2 [1], Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tAir', 1/p.capAir*(a.hCanAir+a.hPadAir-a.hAirMech+a.hPipeAir ...
        +a.hPasAir+a.hBlowAir+a.rGlobSunAir-a.hAirFlr-a.hAirThScr-a.hAirOut ...
        -a.hAirTop-a.hAirOutPad-a.lAirFog - a.hAirBlScr ...
        +a.hLampAir+a.rLampAir ...
        +a.hGroPipeAir+a.hIntLampAir+a.rIntLampAir));
	
    % Greenhouse floor temperature [°C s^{-1}]
    % Equation 3 [1], Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tFlr', 1/p.capFlr*(a.hAirFlr+a.rParSunFlr+a.rNirSunFlr ...
        +a.rCanFlr+a.rPipeFlr-a.hFlrSo1-a.rFlrCovIn-a.rFlrSky-a.rFlrThScr...
        +a.rParLampFlr+a.rNirLampFlr+a.rFirLampFlr-a.rFlrBlScr...
        +a.rParIntLampFlr+a.rNirIntLampFlr+a.rFirIntLampFlr));
    
    % Soil temperatures
    % Equation 4 [1]
    
    % Soil layer 1 temperature [°C s^{-1}]
    setOde(gl, 'tSo1', 1/p.capSo1*(a.hFlrSo1-a.hSo1So2));
    
    % Soil layer 2 temperature [°C s^{-1}]
    setOde(gl, 'tSo2', 1/p.capSo2*(a.hSo1So2-a.hSo2So3));
    
    % Soil layer 3 temperature [°C s^{-1}]
    setOde(gl, 'tSo3', 1/p.capSo3*(a.hSo2So3-a.hSo3So4));
    
    % Soil layer 4 temperature [°C s^{-1}]
    setOde(gl, 'tSo4', 1/p.capSo4*(a.hSo3So4-a.hSo4So5));
    
    % Soil layer 5 temperature [°C s^{-1}]
    setOde(gl, 'tSo5', 1/p.capSo5*(a.hSo4So5-a.hSo5SoOut));
    
    % Thermal screen temperature [°C s^{-1}]
    % Equation 5 [1], Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tThScr', (1/p.capThScr)*(a.hAirThScr+a.lAirThScr+a.rCanThScr+ ...
        a.rFlrThScr+a.rPipeThScr-a.hThScrTop-a.rThScrCovIn-a.rThScrSky+a.rBlScrThScr+ ...
        a.rLampThScr+a.rIntLampThScr));
    
    % Blackout screen temperature [°C s^{-1}]
    % Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tBlScr', (1/p.capBlScr)*(a.hAirBlScr+a.lAirBlScr+a.rCanBlScr+ ...
        a.rFlrBlScr+a.rPipeBlScr-a.hBlScrTop-a.rBlScrCovIn-a.rBlScrSky-a.rBlScrThScr+ ...
        a.rLampBlScr+a.rIntLampBlScr));

    % Air above screen temperature [°C s^{-1}]
    % Equation 6 [1]
    setOde(gl, 'tTop', 1/p.capTop*(a.hThScrTop+a.hAirTop-a.hTopCovIn-a.hTopOut+a.hBlScrTop));
    
    % Internal cover temperature [°C s^{-1}]
    % Equation 7 [1], Equation A1 [5], Equation 7.1 [6]
      setOde(gl, 'tCovIn', (1./a.capCovIn).*(a.hTopCovIn+a.lTopCovIn+a.rCanCovIn+ ...
          a.rFlrCovIn+a.rPipeCovIn+a.rThScrCovIn-a.hCovInCovE+ ...
          a.rLampCovIn+a.rBlScrCovIn+a.rIntLampCovIn));
      
    % External cover temperature [°C s^{-1}]
    % Equation 8 [1]
      setOde(gl, 'tCovE', (1./a.capCovE).*(a.rGlobSunCovE+a.hCovInCovE-a.hCovEOut-a.rCovESky));

    % Lamp temperature [°C s^{-1}]
    % Equation A1 [5], Equation 7.1 [6]
    setOde(gl, 'tLamp', 1/p.capLamp*(a.qLampIn-a.hLampAir-a.rLampSky-a.rLampCovIn ...
        -a.rLampThScr-a.rLampPipe-a.rLampAir - a.rLampBlScr ...
        -a.rParLampFlr-a.rNirLampFlr-a.rFirLampFlr ...
        -a.rParLampCan-a.rNirLampCan-a.rFirLampCan-a.hLampCool+a.rIntLampLamp));
    
    % Interlight temperature [°C s^{-1}]
    % Equation 7.1 [6]
    setOde(gl, 'tIntLamp', 1/p.capIntLamp*(a.qIntLampIn-a.hIntLampAir-a.rIntLampSky-a.rIntLampCovIn ...
        -a.rIntLampThScr-a.rIntLampPipe-a.rIntLampAir-a.rIntLampBlScr ...
        -a.rParIntLampFlr-a.rNirIntLampFlr-a.rFirIntLampFlr ...
        -a.rParIntLampCan-a.rNirIntLampCan-a.rFirIntLampCan-a.rIntLampLamp));

    %% Vapor balance
    
    % Vapor pressure of greenhouse air [Pa s^{-1}] = [kg m^{-1} s^{-3}]
    % Equation 10 [1], Equation A40 [5], Equation 7.40, 7.50 [6]
    setOde(gl, 'vpAir', (1./a.capVpAir).*(a.mvCanAir+a.mvPadAir+a.mvFogAir+a.mvBlowAir ...
        -a.mvAirThScr-a.mvAirTop-a.mvAirOut-a.mvAirOutPad-a.mvAirMech-a.mvAirBlScr));
    
    % Vapor pressure of air in top compartment [Pa s^{-1}] = [kg m^{-1} s^{-3}]
    % Equation 11 [1]
    setOde(gl, 'vpTop', (1./a.capVpTop).*(a.mvAirTop-a.mvTopCovIn-a.mvTopOut));
    
    %% Carbon balance
    
    % Carbon concentration of greenhouse air [mg m^{-3} s^{-1}]
    % Equation 12 [1]
    setOde(gl, 'co2Air', 1/p.capCo2Air*(a.mcBlowAir+a.mcExtAir+a.mcPadAir ...
        -a.mcAirCan-a.mcAirTop-a.mcAirOut));
    
    % Carbon concentration of top compartment [mg m^{-3} s^{-1}]
    % Equation 13 [1]
    setOde(gl, 'co2Top', 1/p.capCo2Top*(a.mcAirTop-a.mcTopOut));
    
    % Date and time [datenum, days since 0-0-0000]
    setOde(gl, 'time', '1/86400');
        
    % Average canopy temperature in last 24 hours
    % Equation 9 [2]
    setOde(gl, 'tCan24', 1/86400*(x.tCan-x.tCan24));
       
    %% Pipe temperatures
    
    % Pipe temperature [°C s^{-1}]
    if isfield(gl.d, 'tPipe') 
        % Pipe temperature is given as an input.  In this case x.tPipe 
        % should be equal to d.tPipe, unless d.tPipe == 0, then it should
        % be calculated by using the ODE
        a.tPipeOn = d.tPipe-x.tPipe;
        a.tPipeOff = 1/p.capPipe*(a.hBoilPipe+a.hIndPipe+a.hGeoPipe-a.rPipeSky ...
        -a.rPipeCovIn-a.rPipeCan-a.rPipeFlr-a.rPipeThScr-a.hPipeAir ...
        +a.rLampPipe-a.rPipeBlScr+a.hBufHotPipe+a.rIntLampPipe);
    
        % when d.tPipe == 0 (or just about to), use the ODE for tPipe, otherwise mimic d.tPipe
        setOde(gl, 'tPipe', ifElse('(d.tPipe == 0) || (d.pipeSwitchOff>0)', a.tPipeOff, a.tPipeOn));
    else 
        % Equation 9 [1], Equation A1 [5], Equation 7.1 [6]
        setOde(gl, 'tPipe', 1/p.capPipe*(a.hBoilPipe+a.hIndPipe+a.hGeoPipe-a.rPipeSky ...
            -a.rPipeCovIn-a.rPipeCan-a.rPipeFlr-a.rPipeThScr-a.hPipeAir ...
            +a.rLampPipe-a.rPipeBlScr+a.hBufHotPipe+a.rIntLampPipe));
    end
    
    % Grow pipes temperature [°C s^{-1}]
    if isfield(gl.d, 'tGroPipe') 
        % Growpipe temperature is given as an input.  In this case x.tGroPipe 
        % should be equal to d.tGroPipe, unless d.tGroPipe == 0, then it should
        % be calculated by using the ODE
        a.tGroPipeOn = d.tGroPipe-x.tGroPipe;
        a.tGroPipeOff = 1/p.capGroPipe*(a.hBoilGroPipe-a.rGroPipeCan-a.hGroPipeAir);
    
        % when d.tGroPipe == 0 (or just about to), use the ODE for tGroPipe, otherwise mimic d.tPipe
        setOde(gl, 'tGroPipe', ifElse('(d.tGroPipe == 0) || (d.groPipeSwitchOff>0)', ...
            a.tGroPipeOff, a.tGroPipeOn));
    else
		 % Equation A1 [5], Equation 7.1 [6]
         setOde(gl, 'tGroPipe', 1/p.capGroPipe*(a.hBoilGroPipe-a.rGroPipeCan-a.hGroPipeAir));
    end
    
    %% Crop model [2]
    
    % Carbohydrates in buffer [mg{CH2O} m^{-2} s^{-1}]
    % Equation 1 [2]
    setOde(gl, 'cBuf', a.mcAirBuf-a.mcBufFruit-a.mcBufLeaf-a.mcBufStem-a.mcBufAir);
    
    % Carbohydrates in leaves [mg{CH2O} m^{-2} s^{-1}]
    % Equation 4 [2]
    setOde(gl, 'cLeaf', a.mcBufLeaf - a.mcLeafAir - a.mcLeafHar);
    
    % Carbohydrates in stem [mg{CH2O} m^{-2} s^{-1}]
    % Equation 6 [2]
    setOde(gl, 'cStem', a.mcBufStem - a.mcStemAir);
    
    % Carbohydrates in fruit [mg{CH2O} m^{-2} s^{-1}]
    % Equation 2 [2], Equation A44 [5]
    setOde(gl, 'cFruit', a.mcBufFruit - a.mcFruitAir - a.mcFruitHar);
    
    % Crop development stage [°C day s^{-1}]
    % Equation 8 [2]
    setOde(gl, 'tCanSum', 1/86400*x.tCan);
    
end