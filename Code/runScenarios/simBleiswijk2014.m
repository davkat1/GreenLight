function gl = simBleiswijk2014()
% simEnergyPlus  --TO DO: DESCRIPTION--
% Runs the model with parameter values representing an HPS compartment in
% Bleiswijk, The Netherlands in 2010. Data is loaded from this trial and
% compared to the simulated data
% transpFile is a string of a mat file containing a variable called mvCanAir

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    absTol = 1e-6; % default is 1e-6; 1e-5 and even 1e-4 seem to also be ok
    relTol = 1e-3; % default is 1e-3; 1e-2 seems also fine

    disp(datetime('now'))
    tic;
    load('M:\PhD\Models\Datasets\WurGlas 2011-2014\Data\indoorClimateWurGlas2014.mat')

    rad = indoorClimateWurGlas2014{:,2};
    temp = indoorClimateWurGlas2014{:,3};
    co2 = indoorClimateWurGlas2014{:,6};
    time = ((1:length(rad))-1)*300;
    
    load('M:\PhD\Models\Datasets\WurGlas 2011-2014\Data\outdoorWeatherWurGlas2014.mat')
    rad = outdoorWeatherWurGlas2014{:,2};
    
    rad = rad*80/60;
%     load('tCan.mat');
%     temp = tCan;
%     
%     load('co2Air.mat');
%     co2 = co2Air;
%     
%     load('iGlob.mat');
%     rad = iGlob;
    
    gl = createCropModel([time' rad temp co2], 0);

%     load('rParhGhSun.mat');
%     
%     addInput(gl, 'rParGhSun',rParGhSun);
%     setDef(gl.a.rParGhSun, 'd.rParGhSun');
    
    
    %% Double the maximal harvest rate
    addAux(gl, 'mcLeafHar', smoothHar(gl.x.cLeaf, gl.p.cLeafMax, 1e4, 10e4));
    
    % Fruit harvest [mg{CH2O} m^{-2} s^{-1}]
    addAux(gl, 'mcFruitHar', smoothHar(gl.x.cFruit, gl.p.cFruitMax, 1e4, 10e4));

    %% Solve
%     options = odeset('AbsTol', absTol, 'RelTol', relTol);
    solveFromFile(gl, 'ode15s');%, options);

    gl = changeRes(gl,300); % set resolution of trajectories at 5 minutes

    runTime = toc;
    fprintf('Elapsed time is %f seconds.\n', runTime);
    
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