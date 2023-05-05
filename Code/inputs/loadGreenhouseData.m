function [outdoor, indoor, controls, startTime, filtInd] = loadGreenhouseData(firstDay, seasonLength, type, filter)
% LOADGREENHOUSEDATA Get data from various greenhouse lighting experiments
% The following datasets are avilable:
%   hps - WUR Glas 2010 with HPS toplights 
%   led - WUR Glas 2010 with LED toplights 
%   hybrid - GreenQ 2012 with HPS toplights and LED interlights
% The data is given in 5-minute intervals.
%
% The dataset for hps and led is described in:
%   Dueck, T., Janse, J., Schapendonk, A.H.C.M., Kempkes, F., Eveleens, B., 
%       Scheffers, K., Pot, S., Trouwborst, G., Nederhoff, E., and Marcelis, L.F.M. (2010). 
%       Lichtbenuttig van tomaat onder LED en SON-T belichting (Wageningen).
% The dataset for hybris is described in: 
%   Dueck, T., De Gelder, A., Janse, J., Baar, P.H., Eveleens, B., and 
%       Grootscholten, M. (2013). Het Nieuwe Belichten bij tomaat met minder CO2.
%   Vervoort, A. (2019). Evaluation and extension of a greenhouse
%       temperature model. MSc thesis, Farm Technology Group, Wageningen University.
%
% Usage:
%   [outdoor, indoor, contorls, startTime] = loadGreenhouseData(firstDay, seasonLength, type)
%
% Needs the files '..\toplight2010\data608.mat',
% '..\toplight2010\data609.mat', '..\greenQ\greenQ_correctedLamps.mat
% which contain a table in the following format: 
% Column    Description                         Unit             
% 1 		Time 								datenum (days since 0/0/0000)
% 2 		Radiation 							W m^{-2}
% 3 		Temp out 							°C
% 4 		Relative humidity out 				%		
% 5 		Wind speed 							m s^{-1}
% 6 		Temp in 							°C
% 7 		VPD in 								g m^{-3}
% 8 		Energy screen closure 				0-100 (100 is fully closed)
% 9 		Black out screen closure			0-100 (100 is fully closed)
% 10 		Lee side ventilation aperture		0-100 (100 is fully open)
% 11 		Wind side ventilation aperture 		0-100 (100 is fully open)
% 12 		Pipe rail temperature 				°C
% 13 		Grow pipes temperature 				°C
% 14 		Toplight on/off                     0/1 (1 is on)
% 15        Interlight on/off                   0/1 (1 is on)
% 23        CO2 injection                       0/1 (1 is on)
% 24        CO2 in                              ppm
%
% Inputs: 
%   firstDay       Where to start looking at the data 
%                       (days since start of the season, fractions accepted)
%                       The start of the season is 19-Oct-2009 15:15:00
%   length         Length of the input in days (fractions accepted)
%                       The length of the entire dataset is 126 days
%   type          'hps' for the HPS dataset 
%                 'led' for the LED dataset
%                 'hybrid' for the hybrid dataset
% Output:
%   outdoor         A 6 column matrix with the following columns:
%       outdoor(:,1)    timestamps of the input [s] in regular intervals of 300, starting with 0
%       outdoor(:,2)    radiation   [W m^{-2}]              outdoor global irradiation 
%       outdoor(:,3)    temperature [°C]                    outdoor air temperature
%       outdoor(:,4)    humidity    [kg m^{-3}]             outdoor vapor concentration
%       outdoor(:,5)    co2         [kg{CO2} m^{-3}{air}]   outdoor CO2 concentration
%       outdoor(:,6)    wind        [m s^{-1}]              outdoor wind speed
%   indoor          A 4 column matrix with:
%       indoor(:,1)     timestamps of the input [s] in regular intervals of 300, starting with 0
%       indoor(:,2)     temperature [°C]                    indoor air temperature
%       indoor(:,3)     humidity    [kg m^{-3}]             indoor vapor concentration
%       indoor(:,4)     co2         [ppm]                   indoor co2 concentration
%   controls
%       controls(:,1)     timestamps of the input [s] in regular intervals of 300, starting with 0
%       controls(:,2)     Energy screen closure 			0-1 (1 is fully closed)
%       controls(:,3)     Black out screen closure			0-1 (1 is fully closed)
%       controls(:,4)     Average ventilation aperture		0-1 (1 is fully open)
%       controls(:,5)     Pipe rail temperature 			°C
%       controls(:,6)     Grow pipes temperature 			°C
%       controls(:,7)     Toplight on/off                   0/1 (1 is on)
%       controls(:,8)     Interlights on/off                0/1 (1 is on)
%       controls(:,9)     CO2 injection                     0/1 (1 is on)
%       controls(:,10) 		Lee side ventilation aperture		0-1 (1 is fully open)
%       controls(:,11) 		Wind side ventilation aperture 		0-1 (1 is fully open)

%   startTime       date and time of starting point (datetime)

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    SECONDS_IN_DAY = 24*60*60;
    CO2_PPM = 400; % assumed constant value of CO2 ppm
    
    
    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);
    
    %% load file
    switch type
        case 'hps'
            load([currentFolder '\toplight2010\data609.mat'], 'data609');
            inputData = data609;
            inputData(:,15) = zeros(size(inputData(:,1))); % no interlights
        case 'led'
            load([currentFolder '\toplight2010\data608.mat'], 'data608');
            inputData = data608;
            inputData(:,15) = zeros(size(inputData(:,1))); % no interlights
        case 'hybrid'
            load([currentFolder '\greenQ\greenQ_correctedLamps.mat'], 'greenQ_correctedLamps');
            inputData = greenQ_correctedLamps;
            
            % no CO2 injection data, just give zeros
            inputData(:,23) = zeros(size(inputData(:,1)));
            % assume that indoor CO2 is same as outdoor
            inputData(:,24) = CO2_PPM*ones(size(inputData(:,1)));
        otherwise
            error('Wrong dataset type. Enter ''hps'', ''led'', or ''hybrid''.');
    end
    
    %% Cut out the required season
    interval = (inputData(2,1)-inputData(1,1))*SECONDS_IN_DAY; % assumes all data is equally spaced
    
    % use only needed dates
    startPoint = 1+round((firstDay-1)*SECONDS_IN_DAY/interval);
        % index in the time array where data should start reading
    endPoint = startPoint-1+round(seasonLength*SECONDS_IN_DAY/interval);
        
    inputData = inputData(startPoint:endPoint,:);
    
    % filter out data based on filter input
    if ~exist('filter', 'var') || isempty(filter)
        filter = 'none';
    end
    
    switch filter
        case 'dark'
            filtInd = inputData(:,14) == 0 ... % toplight off
                & inputData(:,2) == 0 ;  % no sun
        case 'blScr'
            filtInd = inputData(:,9) >= 80; % blackout screen closed
        case 'darkNoScreens'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,14) == 0 ... % toplight off
                & inputData(:,2) == 0 ;  % no sun
        case 'noScreens'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80;        % blackout screen open
        case 'darkNoScreenNoWind'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,14) == 0 ... % toplight off
                & inputData(:,2) == 0 ...  % no sun
                & inputData(:,5) == 0;  % no wind     
        case 'noWindNoScreens'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,5) == 0;  % no wind   
        case 'noWindNoRoof'
            filtInd = inputData(:,10) == 0 ...
                & inputData(:,11) == 0 ... % windows closed
                & inputData(:,5) == 0;  % no wind   
        case 'blScrNoWind'
            filtInd = inputData(:,9)>=80 ... % blackout screen closed
                & inputData(:,5) == 0;  % no wind   
        case 'blScrNoWindNoRoof'
            filtInd = inputData(:,9)>=80 ... % blackout screen closed
                & inputData(:,5) == 0 ...  % no wind   
                & inputData(:,10) == 0 ...
                & inputData(:,11) == 0 ; % windows closed
        case 'noWind'
            filtInd = inputData(:,5) == 0;  % no wind     
        case 'darkNoScreensNoRoof'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,14) == 0 ... % toplight off
                & inputData(:,2) == 0 ...  % no sun
                & inputData(:,10) == 0 ...
                & inputData(:,11) == 0 ; % windows closed
        case 'lightNoScreensNoRoof'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & (inputData(:,14) > 0 ... % toplight on 
                | inputData(:,2) > 0) ...  % or sun is out
                & inputData(:,10) == 0 ...
                & inputData(:,11) == 0 ; % windows closed
        case 'noScreensNoRoof'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,10) == 0 ...
                & inputData(:,11) == 0 ; % windows closed
        case 'noLampsNoScreens'
            filtInd = inputData(:,8)<80 ... % energy screen open
                & inputData(:,9)<80 ... % blackout screen open
                & inputData(:,14) == 0; % toplight off
        case 'noLamps'
                filtInd = inputData(:,14) == 0; % toplight off
        case 'lamps'
                filtInd = inputData(:,14) > 0; % toplight on
        case 'noLampsNoBlackout' 
            filtInd = inputData(:,9)<80 ... % blackout screen open
                & inputData(:,14) == 0; % toplight off
        case 'none' % don't filter out anything
            filtInd = true(length(inputData(:,1)),1);
        otherwise
            error(['Data filter not recognized. Available filters:\n' ...
                'noLampsNoScreens''\n' ...
                'noLampsNoBlackout''\n' ...
                '''none''']);
    end
    
    inputData = inputData(filtInd,:);
    
    % calculate date and time of first data point
    startTime = datetime(inputData(1,1),'ConvertFrom','datenum');
    
    %% Reformat data

    % convert timestamp to seconds since start of season
    outdoor(:,1) = interval*(0:length(inputData(:,1))-1); % time
    
    outdoor(:,2) = inputData(:,2); % radiation
    outdoor(:,3) = inputData(:,3); % air temperature 
    outdoor(:,4) = rh2vaporDens(inputData(:,3), inputData(:,4)); % humidity
    outdoor(:,5) = co2ppm2dens(inputData(:,3),CO2_PPM); % co2 ppm
    outdoor(:,6) = inputData(:,5);
    
    indoor(:,1) = outdoor(:,1);
    indoor(:,2) = inputData(:,6); % air temperature
    indoor(:,3) = rh2vaporDens(inputData(:,6), 100)-1e-3*inputData(:,7); 
        % vapor concentration [kg m^{-3}]
    indoor(:,4) = inputData(:,24); % co2 in [ppm]
    
    controls(:,1) = outdoor(:,1);
    controls(:,2) = inputData(:,8)/100; % energy screen
    controls(:,3) = inputData(:,9)/100; % blackout screen
    controls(:,4) = 0.5*(inputData(:,10)+inputData(:,11))/100; % ventilation
    
    % pipes
    pr = inputData(:,12); % pipe rail temperature
%     pr(find(pr==0))=indoor(find(pr==0),2); 
        % when pr temperature is 0, set it as the air temperature
    controls(:,5) = pr; % pipe rail temperature with adjustment for air
    
    gp = inputData(:,13); % grow pipe temperature
%     gp(find(gp==0))=indoor(find(gp==0),2); 
        % when gp temperature is 0, set it as the air temperature
    controls(:,6) = gp; % grow pipes temperature with adjustment for air
    
    controls(:,7) = inputData(:,14); % toplights
    controls(:,8) = inputData(:,15); % interlights 
    
    controls(:,9) = inputData(:,23); % co2 injection
    
    controls(:,10) = inputData(:,10)/100; % lee side ventilation
    controls(:,11) = inputData(:,11)/100; % wind side ventilation

    
    % timeline of filtered data
    outdoor(:,7) = inputData(:,1);
end