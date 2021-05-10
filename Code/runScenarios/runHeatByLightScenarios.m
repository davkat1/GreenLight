function gl = runHeatByLightScenarios(varargin)
%RUNHEATBYLIGHTSCENARIOS Function used to generate simulations in Chapter 5 of:
%   [1] Katzin, D. (2021). Energy saving by LED lighting in greenhouses: 
%       a process-based modelling approach (PhD thesis, Wageningen University).
%       https://doi.org/10.18174/544434

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % set optional arguments or default values
    parser = inputParser;
    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    validScalarNonNeg = @(x) isnumeric(x) && isscalar(x) && (x >= 0);
    validLampType = @(x) any(validatestring(x,{'hps','led','none'}));
    addParameter(parser, 'firstDay', 270, validScalarPosNum);
    addParameter(parser, 'seasonLength', 350, validScalarPosNum);
    addParameter(parser, 'saveFile', true, @(x) ischar(x) || islogical(x));
    addParameter(parser, 'lampType', 'hps', validLampType);
    addParameter(parser, 'blackoutScreen', false, @islogical);
    addParameter(parser, 'heatHarvest', false, @islogical);
    addParameter(parser, 'boiler', true, @islogical);
    addParameter(parser, 'ppfd', 200, validScalarPosNum);
    addParameter(parser, 'intPpfd', 0, validScalarNonNeg);
    addParameter(parser, 'twentyHours', false, @islogical);
    addParameter(parser, 'gradLamp', false, @islogical);
    addParameter(parser, 'paramNames', []);
    addParameter(parser, 'paramVals', []);

    parse(parser,varargin{:})
    args = parser.Results;
    
    % Set directories for loading data and saving output
    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);
    dataFolder = strrep(currentFolder, '\Code\runScenarios', ...
        '\Code\inputs\energyPlus\data\');
    outputFolder = strrep(currentFolder, '\Code\runScenarios', ...
        '\Output\');

    absTol = 1e-6; % default is 1e-6
    relTol = 1e-3; % default is 1e-3

    %% Simulation settings
    location = 'ams'; 

    paramNames = args.paramNames;
    paramVals = args.paramVals;
    
    %% Create file name
    if ischar(args.saveFile)
        label = [args.saveFile '_'];
        args.saveFile = true;
    else
        label = '';
    end
    if args.saveFile % save simulation
        filename = [outputFolder label location '_' args.lampType '_'];
        if strcmp(args.lampType,'none')
            filename = [outputFolder label location '_' 'noLamp' '_'];
        end
        if args.blackoutScreen
            filename = [filename 'blScr_'];
        end
        if args.heatHarvest
            filename = [filename 'hHarvest_'];
        end
        if ~args.boiler
            filename = [filename 'noBoil_'];
        end
        if args.ppfd ~= 200
            filename = [filename 'ppfd' num2str(args.ppfd) '_'];
        end
        if args.intPpfd > 0
            filename = [filename 'intLamp' num2str(args.intPpfd) '_'];
        end
        if args.twentyHours
            filename = [filename 'twentyHours_'];
        end
        if args.gradLamp
            filename = [filename 'gradLamp_'];
        end

        filename = [filename 'day' num2str(args.firstDay) '_length' num2str(args.seasonLength)];
    else % don't save simulation
        filename = '';
    end

    %% Load default values and prepare simulation
    % load climate data and cut it to requested season size
    weather = cutEnergyPlusData(args.firstDay, args.seasonLength, ...
        [dataFolder location 'EnergyPlus.mat']);

    if size(weather,2) < 10
        elevation = 0;
    else
        elevation = weather(1,10);
    end

    disp(datetime('now'))
    disp(['starting runGreenLight. Lamp type: ' args.lampType '. Filename: ' filename '.']);
    tic;

    lastwarn('', ''); % reset "last warning"

    % convert weather timestamps from datenum to seconds since beginning of data
    startTime = datetime(weather(1,1),'ConvertFrom','datenum');
    weather(:,1) = (weather(:,1)-weather(1,1))*86400;

    gl = createGreenLightModel(args.lampType, weather, startTime);
    setParams4haWorldComparison(gl); % set parameters according to a modern greenhouse
    setParam(gl, 'hElevation', elevation); % set elevation
    
    %% Thermal screen depends on global radiation:
    % The setpoint for screen closure is 
    % 5°C when iGlob < 50 W m^{-2}
    % 18°C when iGlob > 50 W m^{-2}
    % (With smoothing in between)
    gl.a.thScrSp = proportionalControl(gl.d.iGlob, 50, 10, 18, 5);
    
    %% Lamp cool down
    % Prevent lamp from switching on if it was turned off recently
    % for HPS, off time is one hour, for LED no lamp off time
    if strcmp(args.lampType, 'hps')
        addLampOffTime(gl, 3600);
    elseif strcmp(args.lampType, 'led')
        addLampOffTime(gl, 0);
    end
    
    %% Add heat harvesting 
    if args.heatHarvest 
        addHeatHarvesting(gl);
    end
    
    %% Set lamp control to twenty hours per day: from 22:00 to 18:00
    if args.twentyHours
        setParam(gl, 'lampsOn', 22);
    end
    
    %% Gradual control of the lamps:
    % Full intensity    if gl.d.iGlob < gl.p.lampsOffSun/2 (200 by default)
    % Half intensity    if 200 <= gl.d.iGlob <= gl.p.lampsOffSun (400 by default)
    % Lamps off         if gl.d.iGlob > gl.p.lampRad
    if args.gradLamp
        addAux(gl, 'lampNoCons', (1-0.5*(gl.d.iGlob>(gl.p.lampsOffSun/2))).*... % 0.5 if iGlob>lampsOffSun/2, 1 otherwise
            (gl.d.iGlob < gl.p.lampsOffSun).* ... % 1 if iGlob < lampsOffSun
            gl.a.lampTimeOfDay.* ... % lamps should be on this time of day
            (gl.d.dayRadSum < gl.p.lampRadSumLimit).* ... % the predicted daily radiation sum is less than the limit 
            gl.a.lampDayOfYear); % lamps should be on this day of year
    end

    %% Blackout screen
    if args.blackoutScreen
        % Control for blackout screen due to humidity - screens open if relative humidity exceeds rhMax+blScrExtraRh [%]                        
        setParam(gl, 'blScrExtraRh', 3); % Blackout screen open at 90% relative humidity - 3% more than the setpoint of 87%
        addParam(gl, 'useBlScr', 1);     % Use blackout screen 
    end
    
    %% Switch off boiler
    if ~args.boiler 
        setDef(gl.u.boil, '0');
    end
    
    %% Set defulat parameters for heating by light scenarios
    setHeatByLightParams(gl, args.lampType, args.ppfd, args.intPpfd) 
    
    %% Modify additional parameters based on function input
    % ParamName should be a vector of strings
    % paramVal should be a respective numeric vector
    if exist('paramNames', 'var') && ~isempty(paramNames)
        for k=1:length(paramNames)
            setParam(gl, paramNames(k), paramVals(k));
        end
    end

    %% Run simulation 
    % check if need to save file
    if strcmp(filename,'')
        args.saveFile = false;
    else
        args.saveFile = true;
    end

    % Reset other parameters that depend on previously defined parameters
    setDepParams(gl);
    
    % Run simulation 
    options = odeset('AbsTol', absTol, 'RelTol', relTol);
    solveFromFile(gl, 'ode15s', options);
    gl = changeRes(gl, 300);

    [~, warnId] = lastwarn(); % check if warning occured
    if(~isempty(warnId))
        filename = [filename '_warning'];
    end

    if args.saveFile
        save(filename);
    end

    toc;
    beep;
end