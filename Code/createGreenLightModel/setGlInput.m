function setGlInput(gl, weatherInput)
%SETGLINPUT Set inputs for a GreenLight model instance
%
% Function inputs:
% 	gl 					 A DynamicModel object representing the GreenLight model
%   weatherInput         A matrix with 8 columns, in the following format:
%       weatherInput(:,1)    timestamps of the input [s] in regular intervals
%       weatherInput(:,2)    radiation     [W m^{-2}]  outdoor global irradiation 
%       weatherInput(:,3)    temperature   [°C]        outdoor air temperature
%       weatherInput(:,4)    humidity      [kg m^{-3}] outdoor vapor concentration
%       weatherInput(:,5)    co2 [kg{CO2} m^{-3}{air}] outdoor CO2 concentration
%       weatherInput(:,6)    wind        [m s^{-1}] outdoor wind speed
%       weatherInput(:,7)    sky temperature [°C]
%       weatherInput(:,8)    Temperature of external soil layer [°C]
%       weatherInput(:,9)    daily radiation sum [MJ m^{-2} day^{-1}] (optional)
%
% The inputs are then converted and copied to the following fields:
%   d.iGlob                  radiation from the sun [W m^{-2}]
%   d.tOut                   Outdoor air temperature [°C]
%   d.vpOut                  Outdoor vapor pressure [Pa]
%   d.co2Out                 Outdoor CO2 concentration [mg m^{-3}]
%   d.wind                   Outdoor wind speed [m s^{-1}]
%   d.tSky                   Sky temperature [°C]
%   d.tSoOut                 Temperature of external soil layer [°C]
%   d.isDay                  Indicates if it's day [1] or night [0], with a transition in between 
%   d.dayRadSum              daily radiation sum [MJ m^{-2} day^{-1}]

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    if size(weatherInput, 2) == 8
        % add daily radiation sum
        weatherInput = [weatherInput (dayLightSum(...
            ... % convert seconds from start of sim to datenum
            datenum(gl.t.label)+weatherInput(:,1)/86400,...
            weatherInput(:,2)))'];
    end
        
    % Global radiation [W m^{-2}]
    d.iGlob = DynamicElement('d.iGlob');
    
    % Outdoor air temperature [°C]
    d.tOut = DynamicElement('d.tOut');
    
    % Outdoor vapor pressure [Pa]
    d.vpOut = DynamicElement('d.vpOut');
    
    % Outdoor co2 concentration [mg m^{-3}]
    d.co2Out = DynamicElement('d.co2Out');
    
    % Outdoor wind speed [m s^{-1}]
    d.wind = DynamicElement('d.wind');
    
    % Sky temperature [°C]
    d.tSky = DynamicElement('d.tSky');
    
    % Temperature of external soil layer [°C]
    d.tSoOut = DynamicElement('d.tSoOut');
    
    % Daily radiation sum from the sun [MJ m^{-2} day^{-1}]
    d.dayRadSum = DynamicElement('d.dayRadSum');

    
    time = weatherInput(:,1);
    d.iGlob.val = [time weatherInput(:,2)];
    d.tOut.val = [time weatherInput(:,3)];
    
    % convert vapor density to pressure
    d.vpOut.val = [time vaporDens2pres(weatherInput(:,3), weatherInput(:,4))]; 
    d.co2Out.val = [time weatherInput(:,5)*1e6]; % convert kg to mg
    d.wind.val = [time weatherInput(:,6)];
    d.tSky.val = [time weatherInput(:,7)];
    d.tSoOut.val = [time weatherInput(:,8)];
    d.dayRadSum.val = [time weatherInput(:,9)];
    
    d.isDay = DynamicElement('d.isDay'); % 1 during day, 0 during night
    
    isDay = 1*(weatherInput(:,2)>0); % 1 during day, 0 during night
    
    d.isDaySmooth = DynamicElement('d.isDaySmooth');
    isDaySmooth = isDay;
    
    % add a transition period to isDay
    % this is important for control purposes, and cannot be added as an
    % auxiliary state because we need to know in advance that night will
    % start soon (default 1 hour ahead) to start decresing isDay
    transSize = 12; % length of transition period between night and day
                    % should be even. Default is 12*5min = 1 hour
    trans = linspace(0,1,transSize);
    sunset = false; % indicates if we are during sunset
    for k=transSize:length(isDay)-transSize
        if isDay(k) == 0
            sunset = false;
        end
        if isDay(k)==0 && isDay(k+1)==1
            isDay(k-transSize/2:k+transSize/2-1)=trans;
        elseif isDay(k)==1 && isDay(k+1)==0 && ~sunset
            isDay(k-transSize/2:k+transSize/2-1)=1-trans;
            sunset = true;
        end
    end
    
    % add a transition period to isDaySmooth
    % this is important for control purposes, and cannot be added as an
    % auxiliary state because we need to know in advance that night will
    % start soon (default 1 hour ahead) to start decresing isDay
    
    trans = 1./(1+exp(-10*(trans-0.5)));
    sunset = false; % indicates if we are during sunset
    for k=transSize:length(isDaySmooth)-transSize
        if isDaySmooth(k) == 0
            sunset = false;
        end
        if isDaySmooth(k)==0 && isDaySmooth(k+1)==1
            isDaySmooth(k-transSize/2:k+transSize/2-1)=trans;
        elseif isDaySmooth(k)==1 && isDaySmooth(k+1)==0 && ~sunset
            isDaySmooth(k-transSize/2:k+transSize/2-1)=1-trans;
            sunset = true;
        end
    end
    
    d.isDay.val = [time isDay];
    d.isDaySmooth.val = [time isDaySmooth];
	
	gl.d = d;
end