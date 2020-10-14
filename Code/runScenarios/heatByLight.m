function gl = heatByLight(location, seasonLength, firstDay, intensity, fileLabel, mature, paramNames, paramVals, auxNames, auxDefs, transpFile)
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

    absTol = 1e-6; % default is 1e-6; 1e-5 and even 1e-4 seem to also be ok
    relTol = 1e-3; % default is 1e-3; 1e-2 seems also fine

    disp(datetime('now'))
    disp(['starting heatByLight_' fileLabel '_' location '_' num2str(seasonLength) '_' num2str(firstDay)]);
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
        intensity = 66;
    end
    
    [season, startTime] = loadEnergyPlusData(firstDay, seasonLength, location);

    gl = createGreenLightModel(season, startTime);
    
    % set lamp params
    setLedParams(gl);
    
    % set parameters for worldwide comparison
    setHeatByLightParams(gl, intensity);
    
    %% Double the maximal harvest rate
    addAux(gl, 'mcLeafHar', smoothHar(gl.x.cLeaf, gl.p.cLeafMax, 1e4, 10e4));
    
    % Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
    addAux(gl, 'mcFruitHar', smoothHar(gl.x.cFruit, gl.p.cFruitMax, 1e4, 10e4));
    
    %% thermal screen ignores humidity 
    gl.u.thScr = DynamicElement(gl.a.thScrCold);
    
    %% Start with a mature crop
    if mature
        setVal(gl.x.cFruit, 2.8e5);
        setVal(gl.x.cLeaf, 0.9e5);
        setVal(gl.x.cStem, 2.5e5);
        setVal(gl.x.tCanSum, 3000);
    end

    % Modify parameters based on function input
    % ParamName should be a vector of strings
    % paramVal should be a respective numeric vector
    if exist('paramNames', 'var') && ~isempty(paramNames)
        for k=1:length(paramNames)
            setParam(gl, paramNames(k), paramVals(k));
        end
    end
    
    % Modify auxiliary states based on function input
    % auxNames should be a vector of strings
    % auxDefs should be a vector of strings
    if exist('auxNames', 'var') && ~isempty(auxNames)
        for k=1:length(auxNames)
            eval(strcat("setDef(gl.a.", auxNames(k), ",'", auxDefs(k), "');"));
        end
    end
    
    
    setParam(gl, 'hElevation', getElevation(location));
    
    %% Other parameters that depend on previously defined parameters
	    
	% Density of the air [kg m^{-3}]
	% Equation 23 [1]
    addParam(gl, 'rhoAir', gl.p.rhoAir0*exp(gl.p.g*gl.p.mAir*gl.p.hElevation/(293.15*gl.p.R)));
    
	% Heat capacity of greenhouse objects [J K^{-1} m^{-2}]
	% Equation 22 [1]
    addParam(gl, 'capAir', gl.p.hAir*gl.p.rhoAir*gl.p.cPAir);             % air in main compartment
    addParam(gl, 'capTop', (gl.p.hGh-gl.p.hAir)*gl.p.rhoAir*gl.p.cPAir);  % air in top compartments
    
	% Capacity for CO2 [m]
	addParam(gl, 'capCo2Air', gl.p.hAir);
    addParam(gl, 'capCo2Top', gl.p.hGh-gl.p.hAir);
	
    % Absolute air pressure at given elevation [Pa]
	% See https://www.engineeringtoolbox.com/air-altitude-pressure-d_462.html
    addParam(gl, 'pressure', 101325*(1-2.5577e-5*gl.p.hElevation)^5.25588);
    
    %% Use transpiration from a given file
    if exist('transpFile', 'var') && ~isempty(transpFile)
        load(transpFile, 'mvCanAir');
        addInput(gl, 'mvCanAir', mvCanAir.val);
        setDef(gl.a.mvCanAir, 'd.mvCanAir');
    end
    
    %% Solve
    startTime = datestr(startTime);
    startTime = startTime(1:11);
    startTime(startTime=='-') = '_';
    
    saveAs = ['heatByLight_' fileLabel '_' location '_' startTime '_' num2str(seasonLength) 'days'];
    
    options = odeset('AbsTol', absTol, 'RelTol', relTol);
    solveFromFile(gl, 'ode15s', options, [], saveAs);

    gl = changeRes(gl,300); % set resolution of trajectories at 5 minutes

    runTime = toc;
    fprintf('Elapsed time is %f seconds.\n', runTime);
    
    if saveFile
        save([saveAs '.mat']);
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

function elevation = getElevation(location)
% get elevation (m above sea level) based on data in the csv file
% currently this has been typed here manually

    switch(location)
        case 'ams'
            elevation = -2;
        case 'anc'
            elevation = 42;
        case 'kir'
            elevation = 452;
        case 'sam'
            elevation = 44;
        case 'stp'
            elevation = 4;
        case 'mos'
            elevation = 156;
        case 'ark'
            elevation = 13;
        case 'tok'
            elevation = 35;
        case 'ven'
            elevation = 6;
        case 'uru'
            elevation = 935;
        case 'che'
            elevation = 506;
        case 'sha'
            elevation = 5;
        case 'bei'
            elevation = 31;
        case 'win'
            elevation = 190;
        case 'cal'
            elevation = 1084;
        otherwise
            elevation = 0;
    end
end