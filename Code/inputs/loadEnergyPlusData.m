function [season, startTime] = loadEnergyPlusData(firstDay, seasonLength, location)
% LOADENERGYPLUSDATA Load data from the EnergyPlus database
% The data is given in 5-minute intervals.
%
% Usage:
%   [weather, startTime] = loadEnergyPlusData(firstDay, seasonLength, location)
%
% Needs the files ???????????? --TO DO ---
% which contain datasets in the following format: 
% Column    Description                         Unit             
%   hiresWeather         A matrix with 8 columns, in the following format:
%       hiresWeather(:,1)    timestamps of the input [datenum]
%       hiresWeather(:,2)    radiation          [W m^{-2}]  outdoor global irradiation 
%       hiresWeather(:,3)    temperature        [°C]        outdoor air temperature
%       hiresWeather(:,4)    humidity           [kg m^{-3}] outdoor vapor density
%       hiresWeather(:,5)    co2                [kg{CO2} m^{-3}{air}] outdoor CO2 density
%       hiresWeather(:,6)    wind               [m s^{-1}] outdoor wind speed
%       hiresWeather(:,7)    sky temperature    [°C]
%       hiresWeather(:,8)    temperature of external soil layer [°C]
%       hiresWeather(:,9)    daily radiation sum [MJ m^{-2} day^{-1}]
%
% Inputs: 
%   firstDay       Where to start looking at the data 
%                       (days since start of the year)
%   seasonLength   Length of the input in days (fractions accepted)
%   location       --- TO DO
%
% Output:
%   weather         A matrix with the same format of hiresWeather above,
%                   but its first column (the timestamps) is in seconds
%                   since the beginning of the data, and cut so that it
%                   start and ends in the requested time
%   startTime       date and time of starting point (datetime)

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    SECONDS_IN_DAY = 24*60*60;
    
    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);
    
    path = [currentFolder '\Weather data energyPlus\' location 'EnergyPlus.mat']; 
    
    %% load hi res seljaar
    load(path, 'hiresWeather');
    input = hiresWeather;    
    
    %% Cut out the required season
    interval = (input(2,1)-input(1,1))*SECONDS_IN_DAY; % assumes all data is equally spaced
    
    yearShift = floor(firstDay/365); % if firstDay is biggern than 365
    firstDay = mod(firstDay,365); % in case value is bigger than 365
        
    % use only needed dates
    startPoint = 1+round((firstDay-1)*SECONDS_IN_DAY/interval);
        % index in the time array where data should start reading
    endPoint = startPoint-1+round(seasonLength*SECONDS_IN_DAY/interval);
        
    dataLength = length(input(:,1));
    newYears = (endPoint-mod(endPoint,dataLength))/dataLength; 
        % number of times data crosses the new year
        
    % calculate date and time of first data point
    startTime = datetime(input(startPoint,1) + 365*yearShift, 'ConvertFrom','datenum');        
        
    if endPoint <= dataLength 
        season = input(startPoint:endPoint,:); 
    else % required season passes over end of year
        season = input(startPoint:end,:);
        for n=1:newYears-1
            season = [season; input];
        end
        endPoint = mod(endPoint,dataLength);
        season = [season; input(1:endPoint,:)];
    end
    
    % convert timestamp to seconds since start of season
    season(:,1) = interval*(0:length(season(:,1))-1); % time
end