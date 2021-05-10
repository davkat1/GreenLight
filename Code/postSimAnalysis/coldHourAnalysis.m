function [minTemp, coldHours] = coldHourAnalysis(gl)
%COLDHOURANALYSIS Return the lowest achieved indoor temperature (out of hourly averages) and number of cold hours in a GreenLight simulation.
% A cold hour is defined as an hour where the average indoor temperature was at
% least 1°C colder than the average setpoint for indoor temperature.
%
% Usage:
%   [minTemp, coldHours] = coldHourAnalysis(gl)
%
% Input:
%   gl -    a GreenLight model instance, after simulating and after ensuring
%           all time trajectories have regular time intervals (by using
%           chageRes)
% Outputs:
%   minTemp -   The minimum achieved indoor temperature
%   coldHours - The number of cold hours

% David Katzin, Wageningen University, April 2021
% david.katzin@wur.nl
% david.katzin1@gmail.com

    % Difference between achieved temperature and setpoint, such that an
    % hour is considered as cold (°C)
    coldHourDiff = 1;
    
    % Values for achieveid indoor temperature and temperature setpoint
    tAirVals = gl.x.tAir.val(:,2);
    setpointVals = gl.a.heatSetPoint.val(:,2);
    
    % frequency of time data, s
    timeFreq = gl.a.hBoilPipe.val(2,1) - gl.a.hBoilPipe.val(1,1); 
    
    % number of cells that represent an hour
    hourSize = floor(3600/timeFreq);

    % number of hours in dataset
    numHours = ceil(length(tAirVals)/hourSize);

    % average temperature each hour, °C
    hourlyAvgTemp = zeros(numHours,1);
    
    % average setpoint each hour, °C
    hourlyAvgSetpoint = zeros(numHours,1);
    
    for k=1:numHours
        hourlyAvgTemp(k) = mean(tAirVals( ((k-1)*hourSize+1):(k*hourSize) ));
        hourlyAvgSetpoint(k) = mean(setpointVals( ((k-1)*hourSize+1):(k*hourSize) ));
    end

    minTemp = min(hourlyAvgTemp); % lowest hourly average temperature
    coldHours = sum(hourlyAvgTemp < (hourlyAvgSetpoint-coldHourDiff)); % number of cold hours
end