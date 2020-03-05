function [weather, startTime] = loadSelYearHiRes(firstDay, seasonLength)
% LOADSELYEARHIRES Get weather data for a given season, based on reference year for Dutch greenhouses, WITH A MODIFICATION FOR MODERN CLIMATES
% The data is given in 5-minute intervals
%
% The reference year is based on:
% Breuer, J. J. G., and N. J. Van de Braak. "Reference year for Dutch greenhouses." In 
% International Symposium on Models for Plant Growth, Environmental Control and Farm 
% Management in Protected Cultivation 248, pp. 101-108. 1988.
%
% THE TEMPERATURES WERE INCREASED BY 1.5°C, IN ACCORDANCE WITH THE DIFFERENCE OF 
% THE AVERAGE TEMPERATURE IN THE REFERENCE YEAR, AND THE AVERAGE TEMPERATURE IN 2016
%
% Usage:
%   [weather, startTime] = loadSelYear(firstDay, length)
%
% Needs the file 'Code\inputs\Reference year SEL2000\seljaarhires.mat', 
% which containts a table in the following format: 
% Column                            Unit             More info
% 1 - time since beginning of year  [s]
% 2 - outdoor global radiation      [W m^{-2}]
% 3 - wind speed                    [m/s]
% 4 - air temperature               [°C]
% 5 - sky temperature               [°C]
% 6 - ?????
% 7 - CO2 concentration             [ppm]           assumed to be constant 320, not included in the original Breuer&Braak paper
% 8 - day number                    [day]
% 9 - relative humidity             [%]
%
% Inputs: 
%   firstDay       Where to start looking at the data 
%                       (days since start of the year, fractions accepted)
%   length         Length of the input in days (fractions accepted)
% Output:
%   weather         A 7 column matrix with the following columns:
%       weather(:,1)    timestamps of the input [s] in regular intervals of 300, starting with 0
%       weather(:,2)    radiation   [W m^{-2}]              outdoor global irradiation 
%       weather(:,3)    temperature [°C]                    outdoor air temperature
%       weather(:,4)    humidity    [kg m^{-3}]             outdoor vapor concentration
%       weather(:,5)    co2         [kg{CO2} m^{-3}{air}]   outdoor CO2 concentration
%       weather(:,6)    wind        [m s^{-1}]              outdoor wind speed
%       weather(:,7)    sky temp    [°C]
%   startTime       date and time of starting point (datetime)

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    SECONDS_IN_DAY = 24*60*60;
    CO2_PPM = 400; % assumed constant value of CO2 ppm
    
    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);
    
    path = [currentFolder '\Reference year SEL2000\seljaar.mat']; 
    
    %% load hi res seljaar
    load(path, 'seljaarhires');
    seljaar = seljaarhires;    
    
    %% Cut out the required season
    interval = seljaar(2,1)-seljaar(1,1); % assumes all data is equally spaced
    
    firstDay = mod(firstDay,365); % in case value is bigger than 365
    
    % use only needed dates
    startPoint = 1+round((firstDay-1)*SECONDS_IN_DAY/interval);
        % index in the time array where data should start reading
    endPoint = startPoint-1+round(seasonLength*SECONDS_IN_DAY/interval);
    
    % calculate date and time of first data point
    startTime = datetime(2000,1,1,0,0,0)+seljaar(startPoint,1)/SECONDS_IN_DAY;
        
    dataLength = length(seljaar(:,1));
    newYears = (endPoint-mod(endPoint,dataLength))/dataLength; 
        % number of times data crosses the new year
        
    if endPoint <= dataLength % required season passes over end of year
        season = seljaar(startPoint:endPoint,:); 
    else
        season = seljaar(startPoint:end,:);
        for n=1:newYears-1
            season = [season; seljaar];
        end
        endPoint = mod(endPoint,dataLength);
        season = [season; seljaar(1:endPoint,:)];
    end
    
    % Reformat data
    %% INCREASE TEMPERATURE BY 1.5°C, TO FIT BETTER WITH MODERN CLIMATE!!!
	
    % convert timestamp to seconds since start of season
    weather(:,1) = interval*(0:length(season(:,1))-1); % time
    weather(:,2) = season(:,2); % radiation
    weather(:,3) = season(:,4)+1.5; % air temperature % INCREASE OF TEMPERATURE BY 1.5
    weather(:,4) = rh2vaporDens(weather(:,3), season(:,9)); % humidity
    weather(:,5) = co2ppm2dens(weather(:,3),CO2_PPM); % co2 ppm
    weather(:,6) = season(:,3);
    weather(:,7) = season(:,5);
end