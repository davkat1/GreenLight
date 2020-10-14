function saveWeatherMat(csvFile, matFile)
% Load weather from a csv file generated from energy plus and convert into
% a MATLAB file in the following format:
%   weather         A matrix with 8 columns, in the following format:
%       weather(:,1)    timestamps of the input [datenum]
%       weather(:,2)    radiation     [W m^{-2}]  outdoor global irradiation 
%       weather(:,3)    temperature   [°C]        outdoor air temperature
%       weather(:,4)    humidity      [kg m^{-3}] outdoor vapor concentration
%       weather(:,5)    co2 [kg{CO2} m^{-3}{air}] outdoor CO2 concentration
%       weather(:,6)    wind        [m s^{-1}] outdoor wind speed
%       weather(:,7)    sky temperature [°C]
%       weather(:,8)    temperature of external soil layer [°C]
%
% Another column of data was added:
%       weather(:,9)    radiation sum coming from that sun during this day,
%       i.e., from the previous midnight to the next midnight [MJ m^{-2} day^{-1}]


    SIGMA = 5.6697e-8; % Stefan-Boltzmann constant, W m^{-2} K^{-4}
    KELVIN = 273.15; % 0°C in K, K
    CO2_PPM = 410; % CO2 concentration, ppm

    [num,txt] = xlsread(csvFile);

    rad = num(19:end,11); % Global radiation, W m^{-2}
    temp = num(19:end,4); % outdoor temperature, °C
    rh = num(19:end,6); % relative humidity, %
    radSky = num(19:end,10); % radiation from the sky, W m^{-2}
    wind = num(19:end,19); % wind speed, m s^{-1}

    time = datenum(txt{20,1})+(1:length(rad))'/24; % sample timepoints (datenum)
    startTime = datetime(time(1,1),'ConvertFrom','datenum'); % beginning of data (datetime)
    secsInYear = seconds(startTime-datetime(year(startTime),1,1,0,0,0)); 
        % seconds since beginning of year to beginning of data (seconds)

    vaporDens = rh2vaporDens(temp, rh); % vapor density, kg m^{-3}
    skyT = (radSky./SIGMA).^0.25 - KELVIN;
    co2 = co2ppm2dens(temp, CO2_PPM);

     %% fit soil to sin curve, based on 
     % https://nl.mathworks.com/matlabcentral/answers/121579-curve-fitting-to-a-sinusoidal-function

    y = num(8,22:33); % soil temperature at 2m depth
    x = 0.5:1:11.5; % months since beginning of year


    yu = max(y);
    yl = min(y);
    yr = (yu-yl);                               % Range of ‘y’
    yz = y-yu+(yr/2);
    zx = x(yz .* circshift(yz,[0 1]) <= 0);     % Find zero-crossings
    per = 2*mean(diff(zx));                     % Estimate period
    ym = mean(y);                               % Estimate offset
    fit = @(b,x)  b(1).*(sin(2*pi*x./per + 2*pi/b(3))) + b(4);    % Function to fit
    fcn = @(b) sum((fit(b,x) - y).^2);                              % Least-Squares cost function
    s = fminsearch(fcn, [yr;  per;  -1;  ym]);                       % Minimise Least-Squares
    s(2) = per;
    xp = linspace(min(x),max(x));
    % figure(1)
    % plot(x,y,'b',  xp,fit(s,xp), 'r')
    % grid

    SECS_IN_MONTH = 86400*365/12; % avg number of seconds in month
    soilTsec = @(sec)  s(1).*(sin(2*pi*sec./SECS_IN_MONTH./per + 2*pi/s(3))) + s(4);  
    % soil temperature at timepoint sec where sec is seconds since beginning of
    % year

    soilT = soilTsec(secsInYear+(time-time(1))*86400);

    weather = [time rad temp vaporDens co2 wind skyT soilT];
    % weather data in one-hour intervals
    
    weather = [weather dayLightSum(weather)'];
    % add daily light sum integral

    %% Extrapolate to 5 minute interval
    hiresTime = time(1):300/86400:time(end);

    hiresWeather = nan(length(hiresTime), size(weather,2)-1);

    hiresWeather(:,1) = hiresTime;
    for k=2:size(weather,2)-1
        hiresWeather(:,k) = pchip(time, weather(:,k), hiresTime);
    end
    
    hiresWeather = [hiresWeather dayLightSum(hiresWeather)'];

    save(matFile, 'weather', 'hiresWeather')
end