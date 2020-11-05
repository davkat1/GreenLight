function season = cutEnergyPlusData(firstDay, seasonLength, path)
% CUTENERGYPLUSDATA Cut data from EnergyPlus to the required season segment 
%
% The EnergyPlus data is a full year (Jan 1 - Dec 31). This function cuts
% out a segment of the data according to the desired season. 
% Allows passing over the end of the year, e.g., a segment of November-March.
% Also allows a season of more than a year if needed (but the years will
% have identical weather).
%
% Usage:
%   season = loadEnergyPlusData(firstDay, seasonLength, path)
%
% Inputs: 
%   firstDay       Where to start looking at the data (days since start of 
%                  the year). Example: 1 (Jan 1)
%   seasonLength   Length of the input in days (fractions accepted). 
%                  Example: 1
%   path           Path of a MAT file in the energyPlus format, created using saveWeatherMat
%                  and has a variable named hiresWeather in the format as
%                  below. Example: 'beiCSWD.mat'
%
%       Column               Description                        Unit             
%       hiresWeather(:,1)    timestamps of the input            [datenum]
%       hiresWeather(:,2)    outdoor global irradiation         [W m^{-2}]   
%       hiresWeather(:,3)    outdoor air temperature            [°C]        
%       hiresWeather(:,4)    outdoor vapor density              [kg m^{-3}] 
%       hiresWeather(:,5)    outdoor CO2 density                [kg{CO2} m^{-3}{air}] 
%       hiresWeather(:,6)    outdoor wind speed                 [m s^{-1}] 
%       hiresWeather(:,7)    sky temperature                    [°C]
%       hiresWeather(:,8)    temperature of external soil layer [°C]
%       hiresWeather(:,9)    daily radiation sum                [MJ m^{-2} day^{-1}]
%       hiresWeather(:,10)   elevation                          [m]
%
%
% Output:
%   season          A matrix with the same format of hiresWeather above,
%                   cut so that it start and ends in the requested time
%
% Used to generate the data in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    SECONDS_IN_DAY = 24*60*60;
    
    %% load hi res seljaar
    load(path, 'hiresWeather');
    input = hiresWeather;    

    %% Cut out the required season
    interval = (input(2,1)-input(1,1))*SECONDS_IN_DAY; % assumes all data is equally spaced
    
    yearShift = floor(firstDay/365); % if firstDay is bigger than 365
    firstDay = mod(firstDay,365); % in case value is bigger than 365
        
    % use only needed dates
    startPoint = 1+round((firstDay-1)*SECONDS_IN_DAY/interval);
        % index in the time array where data should start reading
    endPoint = startPoint-1+round(seasonLength*SECONDS_IN_DAY/interval);
        
    dataLength = length(input(:,1));
    newYears = (endPoint-mod(endPoint,dataLength))/dataLength; 
        % number of times data crosses the new year
        
    if endPoint <= dataLength 
        season = input(startPoint:endPoint,:); 
    else % required season passes over end of year
        season = input(startPoint:end,:);
        resetDate = input(:,1)-input(1,1)+interval/SECONDS_IN_DAY; % dates from input but start at 0+interval
        for n=1:newYears-1
            dateShift = resetDate+season(end,1);
            inputDateShift = [dateShift input(:,2:end)];
            season = [season; inputDateShift];
        end
        endPoint = mod(endPoint,dataLength);
        dateShift = resetDate+season(end,1);
        inputDateShift = [dateShift input(:,2:end)];
        season = [season; inputDateShift(1:endPoint,:)];
    end
end