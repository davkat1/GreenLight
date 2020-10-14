location = 'ams';
simType = 'led';
firstDay = 32;
seasonLength = 5;
mature = true;

paramRange = 1:241;

absTol = 1e-6; % default is 1e-6; 1e-5 and even 1e-4 seem to also be ok
relTol = 1e-3; % default is 1e-3; 1e-2 seems also fine

%% Create general gl object
[season, startTime] = loadEnergyPlusData(firstDay, seasonLength, location);

glDef = createGreenLightModel(season, startTime); % default greenLight model
feval(['set' upper(simType(1)) simType(2:end) 'Params'], glDef); % set lamp params


if strcmp(simType, 'led')
    intensity = 66;
    setParam(glDef, 'thetaLampMax', intensity);
    setParam(glDef, 'capLamp', 10*1.8/3*intensity/66);
    setParam(glDef, 'cHecLampAir', 2.3*1.8/3*intensity/66);
    setParam(glDef, 'etaLampPar', 0.5);
    setParam(glDef, 'zetaLampPar', 6);
    setParam(glDef, 'etaLampCool', 0);

    setParam(glDef, 'heatCorrection', 1);
end

setParam(glDef, 'co2SpDay', 1000);


% KWIN says 17.5 night, 18.5 day, the values here are used to get
% approximately that value
setParam(glDef, 'tSpNight', 18.5); 
setParam(glDef, 'tSpDay', 19.5);
setParam(glDef, 'rhMax', 85);
setParam(glDef, 'hAir', 5);
setParam(glDef, 'hGh', 6.4);

setParam(glDef, 'lampsOffYear', 105);
setParam(glDef, 'lampsOffSun', 400);

% big boiler
setParam(glDef, 'pBoil', 300*glDef.p.aFlr.val);

%% Double the maximal harvest rate
addAux(glDef, 'mcLeafHar', smoothHar(glDef.x.cLeaf, glDef.p.cLeafMax, 1e4, 10e4));

% Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
addAux(glDef, 'mcFruitHar', smoothHar(glDef.x.cFruit, glDef.p.cFruitMax, 1e4, 10e4));


% Start with a mature crop
if mature
    setVal(glDef.x.cFruit, 2.8e5);
    setVal(glDef.x.cLeaf, 0.9e5);
    setVal(glDef.x.cStem, 2.5e5);
    setVal(glDef.x.tCanSum, 3000);
end

%% Create various objects with different param values
paramNames = fieldnames(glDef.p);
gl(1,length(paramRange)*2) = DynamicModel();

for k=1:length(gl)
    gl(k) = DynamicModel(glDef);
    paramName = paramNames{ceil(k/2)};
    paramVal = glDef.p.(paramName).val;
    if mod(k,2) == 0
        paramVal = paramVal*1.1;
        relChange = '+10%';
    else
        paramVal = paramVal*0.9;
        relChange = '-10%';
    end
    setParam(gl(k), paramName, paramVal);

    tic;
    fprintf('%d of %d, %s at %s\n', k, length(gl), paramName, relChange);
    %% Solve
    options = odeset('AbsTol', absTol, 'RelTol', relTol);
    solveFromFile(gl(k), 'ode15s', options);

    gl(k) = changeRes(gl(k),300); % set resolution of trajectories at 5 minutes

    startTime = datestr(startTime);
    startTime = startTime(1:11);

    runTime = toc;
    fprintf('Elapsed time is %f seconds.\n', runTime);

    disp(datetime('now'))
end

beep


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