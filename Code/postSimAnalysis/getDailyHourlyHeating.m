function [dayHeating, dayHeat18toMidnight, hourHeating, hourHeat18toMidnight] = getDailyHourlyHeating(gl)
%GETDAILYHOURLYHEATING Returns the daily and hourly heat demand throughout the whole day and between 18 and midnight
% Daily heat demand is given in MJ m^{-2} day^{-1} and hourly heating
% demand is given as the average instantenaous demand [W m^{-2}]
%
% Usage:
%   [dayHeating, dayHeat18toMidnight, hourHeating, hourHeat18toMidnight] = getDailyHourlyHeating(gl)
%
% Input:
%   gl -    a GreenLight model instance, after simulating and after ensuring
%           all time trajectories have regular time intervals (by using
%           chageRes)
% Outputs:
%   dayHeating -            Daily heat demand [MJ m^{-2} day^{-1}]
%   dayHeat18toMidnight -   Daily heat demand for the hours between 18 and midnight [MJ m^{-2} day^{-1}]
%   hourHeating -           Hourly average heat demand [W m^{-2}]
%   hourHeat18toMidnight -  Hourly average heat demand for the hours between 18 and midnight [W m^{-2}]

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

    lampsOn = 24; % time of day when lamps go on
    lampsOff = 18; % time of day when lamps go off
    
    % heating input, W/m2
    heatIn = gl.a.hBoilPipe.val(:,2)+gl.a.hBoilGroPipe.val(:,2); 
    lampIn = gl.a.qLampIn.val(:,2)+gl.a.qIntLampIn.val(:,2);
       
    % frequency of time data, s
    timeFreq = gl.a.hBoilPipe.val(2,1) - gl.a.hBoilPipe.val(1,1); 

    % number of cells in heatIn that represent an hour
    hourSize = floor(3600/timeFreq);

    % number of hours and days in dataset
    numHours = ceil(length(heatIn)/hourSize);
    numDays = ceil(numHours/24);

    % average heating input in each hour, W/m2
    hourHeating = zeros(numHours,1);
    hourHeat18toMidnight = zeros(numHours,1);
    k18toMidnight = 0;

    for k=1:numHours
        hourHeating(k) = mean(heatIn( ((k-1)*hourSize+1):(k*hourSize) ));
        if mod(k,24)>=lampsOff || mod(k,24) == 0
            k18toMidnight = k18toMidnight+1;
            hourHeat18toMidnight(k18toMidnight) = hourHeating(k);
        end
    end

    % heating input per day, MJ/day/m2
    dayHeat18toMidnight = zeros(numDays,1);
    dayHeating = zeros(numDays,1);
    for k=1:numDays
       dayHeating(k) = 1e-6*3600*sum(hourHeating( ...
            (max(1,24*(k-1))) : ...    % 24k is the hour from 0:00 to 1:00
            (min(numHours, 24*k-1)))); %24k-1 is 23:00 to 0:00
       
       dayHeat18toMidnight(k) = 1e-6*3600*sum(hourHeating( ...
           (24*(k-1)+lampsOff):(24*(k-1)+lampsOn-1))); % heating from 18 to midnight      
    end
end
