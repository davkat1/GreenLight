function gl = simEnergyPlusBlScr(location, simType, seasonLength, firstDay, fileLabel, mature, paramNames, paramVals, transpFile, intensity)
% simEnergyPlus  --TO DO: DESCRIPTION--
% Runs the model with parameter values representing an HPS compartment in
% Bleiswijk, The Netherlands in 2010. Data is loaded from this trial and
% compared to the simulated data
% transpFile is a string of a mat file containing a variable called mvCanAir

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com


% location = 'ams';
% simType = 'hps';
% 
% seasonLength = 1; % season length in days
% firstDay = 300; % Beginning of season (days since January 1)

    absTol = 1e-4; % default is 1e-6; 1e-5 and even 1e-4 seem to also be ok
    relTol = 1e-2; % default is 1e-3; 1e-2 seems also fine

    disp(datetime('now'))
    tic;
    
    saveFile = true;
    if ~exist('fileLabel', 'var')
        fileLabel = '';
    end
    
    if strcmp(fileLabel,'')
            saveFile = false;
    end
    
    if ~exist('mature', 'var')
        mature = false;
    end
    
    if ~exist('intensity', 'var')
        intensity = 110*1.8/3; % == 66
    end

    [season, startTime] = loadEnergyPlusData(firstDay, seasonLength, location);

    gl = createGreenLightModel(season, startTime);
    feval(['set' upper(simType(1)) simType(2:end) 'Params'], gl); % set lamp params

    
    if strcmp(simType, 'led')
        setParam(gl, 'thetaLampMax', intensity);
        setParam(gl, 'capLamp', 10*1.8/3*intensity/66);
        setParam(gl, 'cHecLampAir', 2.3*1.8/3*intensity/66);
        setParam(gl, 'etaLampPar', 0.5);
        setParam(gl, 'zetaLampPar', 6);
        setParam(gl, 'etaLampCool', 0);
        
        setParam(gl, 'heatCorrection', 1);
        
%        setParam(gl, 'heatCorrection', 1.5);
                
        %% try more efficient LEDs
%         setParam(gl, 'etaLampPar', 0.67);
    end
    
    setParam(gl, 'co2SpDay', 1000);
    
    
    % KWIN says 17.5 night, 18.5 day, the values here are used to get
    % approximately that value
    setParam(gl, 'tSpNight', 18.5); 
    setParam(gl, 'tSpDay', 19.5);
    setParam(gl, 'rhMax', 85);
    setParam(gl, 'hAir', 5);
    setParam(gl, 'hGh', 6.4);
    
    setParam(gl, 'lampsOffYear', 105);
    setParam(gl, 'lampsOffSun', 400);
    
    % big boiler
    setParam(gl, 'pBoil', 300*gl.p.aFlr.val);
    
    %% Double the maximal harvest rate
    addAux(gl, 'mcLeafHar', smoothHar(gl.x.cLeaf, gl.p.cLeafMax, 1e4, 10e4));
    
    % Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
    addAux(gl, 'mcFruitHar', smoothHar(gl.x.cFruit, gl.p.cFruitMax, 1e4, 10e4));
    
    
    %% Start with a mature crop
    if mature
        setVal(gl.x.cFruit, 2.8e5);
        setVal(gl.x.cLeaf, 0.9e5);
        setVal(gl.x.cStem, 2.5e5);
        setVal(gl.x.tCanSum, 3000);
    end
    
    %% Add blackout screen
    
    addState(gl, 'lampOffCount');
    addState(gl, 'runningTime');
    
%     addAux(gl, 'lampSwitchOff1', 1./(1+exp(-1e-2*(gl.x.lampOffCount-3600))));
%     
%     addAux(gl, 'lampSwitchOff', max(gl.a.lampSwitchOff1, 1-1./(1+exp(-1e-2*(gl.x.lampOffCount-500)))));
    

%     addAux(gl, 'lampSwitchOff1', gl.x.lampOffCount/100-35);
%     addAux(gl, 'lampSwitchOff', max(0,max(min(1,gl.x.lampOffCount/100-35),min(1, 2-gl.x.lampOffCount/100))));
    
%     addAux(gl, 'lampSwitchOff', gl.x.lampOffCount < 500 | gl.x.lampOffCount > 3600);
    
    setOde(gl, 'lampOffCount', ifElse(gl.u.lamp < 0.2, 1, -gl.x.lampOffCount-1));
    setVal(gl.x.lampOffCount, 1);
   
    setOde(gl, 'runningTime', '1');
    setVal(gl.x.runningTime, 0);

    % control for the lamps as if there was no screen [0/1]
    addAux(gl, 'lampOnNoScr', gl.d.iGlob < gl.p.lampsOffSun & ... % lamps are off if sun is bright
        gl.a.timeOfDay>gl.p.lampsOn & gl.a.timeOfDay<gl.p.lampsOff & ... % lamps are on between p.lampsOn to p.lampsOff
        (gl.d.dayRadSum < gl.p.lampRadSumLimit)); % the predicted daily radiation sum is less than the limit 
    
    
    % times when lamp should be on, taking into account restrictions
    addAux(gl, 'lampOn', (gl.x.runningTime>=3600).*(gl.a.lampOnNoScr.*(gl.d.isDaySmooth + ...
        (1-gl.d.isDaySmooth).* ... % lamp should be on
        (gl.x.tAir < gl.a.heatMax + gl.p.ventHeatPband).* ... % it's not too hot inside
        (gl.a.rhIn < gl.p.rhMax + gl.p.ventRhPband)))); % it's not too humid inside
    
     % times when lamp should be on, taking into account restrictions
%     addAux(gl, 'lampOn', (gl.x.runningTime>=3600).*(gl.a.lampOnNoScr.*(gl.d.isDaySmooth + ...
%         (1-gl.d.isDaySmooth).* ... % lamp should be on
%         (gl.x.tAir < gl.a.heatMax + 1).* ... % it's not too hot inside
%         (gl.a.rhIn < gl.p.rhMax + 2)))); % it's not too humid inside
    
    
    % Heating set point [°C]
    addAux(gl, 'heatSetPoint', gl.a.isDayInside*gl.p.tSpDay + (1-gl.a.isDayInside)*gl.p.tSpNight ...
        + gl.p.heatCorrection*gl.a.lampOnNoScr); % correction for LEDs when lamps are on
    % lamp correction ignores blackout screen issues to avoid circular
    % definitions
    
%     addAux(gl,'blScrTime', ifElse(gl.a.timeOfDay < gl.p.lampsOn+1, 0, ...
%         ifElse(gl.a.timeOfDay < gl.p.lampsOn+3, 1./(1+exp(-1*(gl.a.timeOfDay-0.5))), ...
%         ifElse(gl.a.timeOfDay < 12, 1, 0))));
%     
%     % control for the blackout screen as if there were no restrictions
%     addAux(gl, 'blScrNoLim', (gl.d.dayRadSum < gl.p.lampRadSumLimit).* ...  % the predicted daily radiation sum is less than the limit 
%         gl.a.blScrTime.*(1-gl.d.isDaySmooth));
%     
%     % this should be corrected, the restrictions on the lamp shouldn't
%     % matter during the day
%     addAux(gl, 'blScr', gl.a.blScrNoLim.* ... % screen should be closed
%         (gl.x.tAir < gl.a.heatMax + 1).* ... % it's not too hot inside
%         (gl.a.rhIn < gl.p.rhMax + 2)); % it's not too humid inside

    % Screen is closed at night when lamp is on
    addAux(gl, 'blScr', (1-gl.d.isDaySmooth).*gl.a.lampOn);

    
    gl.u.thScr = (1-gl.u.blScr).*min(gl.a.thScrCold, min(gl.a.thScrHeat, gl.a.thScrRh)); % Don't use thermal screen if blackout screen is on
    gl.u.thScr.val = 0;
    
    setDef(gl.u.blScr, gl.a.blScr.def);
    setVal(gl.u.blScr, 0);
    
    gl.e(1).condition = gl.x.lampOffCount;
    gl.e(1).direction = 1;
    gl.e(1).resetVars = [gl.x.lampOffCount gl.x.runningTime];
    gl.e(1).resetVals = [1 0];
    
    setParam(gl, 'kBlScr',5e-4);                % Blackout screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1}    
%     setParam(gl, 'kThScr',5e-4);                % Thermal screen flux coefficient 																m^{3} m^{-2} K^{-2/3} s^{-1}    5e-5 [1]
    
    
    %% Close blackout screen from sundown to sunup
%     gl.u.blScr = ifElse(gl.d.iGlob==0&gl.u.lamp>0,0.98,0);
    
    %% Increase outdoor temperature by 2°C
%     gl.d.tOut.val(:,2) = gl.d.tOut.val(:,2)+2;

    %% Increase RH set point by 10%
%     setParam(gl, 'rhMax', 95);

    %% Screens are only controlled by temperature
%     gl.u.thScr = min(gl.a.thScrCold, gl.a.thScrHeat);

    % Modify parameters based on function input
    % ParamName should be a vector of strings
    % paramVal should be a respective numeric vector
    if exist('paramNames', 'var') && ~isempty(paramNames)
        for k=1:length(paramNames)
            setParam(gl, paramNames(k), paramVals(k));
        end
    end
    
    %% Use transpiration from a given file
    if exist('transpFile', 'var') && ~isempty(transpFile)
        load(transpFile, 'mvCanAir');
        addInput(gl, 'mvCanAir', mvCanAir.val);
        setDef(gl.a.mvCanAir, 'd.mvCanAir');
    end
    
    %% Solve
    options = odeset('AbsTol', absTol, 'RelTol', relTol);
    solveFromFile(gl, 'ode15s', options);

    gl = changeRes(gl,300); % set resolution of trajectories at 5 minutes

    startTime = datestr(startTime);
    startTime = startTime(1:11);

    runTime = toc;
    fprintf('Elapsed time is %f seconds.\n', runTime);
    
    if saveFile
        save(['energyPlus_' fileLabel '_' location '_' simType '_' startTime '_' num2str(seasonLength) 'days.mat']);
    end
    
    disp(datetime('now'))
    
    beep
end

%% temp
function de = smoothHar(processVar, cutOff, smooth, maxRate)
% Define a smooth function for harvesting (leaves, fruit, etc)
% processVar - the DynamicElement to be controlled
% cutoff     - the value at which the processVar should be harvested
% smooth     - smoothing factor. The rate will go from 0 to max at
%              a range with approximately this width
% maxRate    - the maximum harvest rate

    de = maxRate./(1+exp(-(processVar-cutOff)*2*log(100)./smooth));

end