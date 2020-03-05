function skyT = skyTempRdam(airTemp, time)
%SKYTEMPMRDAM Estimate the sky temperature based on air temperature and cloud cover in Rotterdam
% Usage:
% skyT = skyTempRdam(airTemp, time)
% Needs the file '\cloudCoverRotterdam2009-2012\cloudRotterdam2009_2012.mat'
% which contains hourly cloud cover data for Rotterdam in the years 2009-2012
%   inputs:
%       airTemp - air temperature [°C]
%       time - datenum (within the years 2009-2012)
%       airTemp and time must have the same dimensions
%   output:
%       skyTemp - estimated sky temperature [°C]

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    currentFile = mfilename('fullpath');
    currentFolder = fileparts(currentFile);
    
    path = [currentFolder '\cloudCoverRotterdam2009-2012\cloudRotterdam2009_2012.mat']; 
    

    load(path, 'cloudRotterdam2009_2012');
    clouds = interp1(cloudRotterdam2009_2012(:,1),cloudRotterdam2009_2012(:,2),time);
    skyT = skyTempMonteith(airTemp, clouds);
end