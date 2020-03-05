function soilT = soilTempNl(time)
%SOILTEMPNL An estimate of the soil temperature in the Netherlands in a given time of year
% Based on Figure 3 in 
%   Jacobs, A. F. G., Heusinkveld, B. G. & Holtslag, A. A. M. 
%   Long-term record and analysis of soil temperatures and soil heat fluxes in 
%   a grassland area, The Netherlands. Agric. For. Meteorol. 151, 774–780 (2011).
%
% Input:
%   time - seconds since beginning of the year [s]
% Output:
%   soilT - soil temperature at 1 meter depth at given time [°C]
%
% Calculated based on a sin function approximating the figure in the reference

% David Katzin, Wageningen University
% david.katzin@wur.nl

    SECS_IN_YEAR = 3600*24*365;
    soilT = 10+5*sin((2*pi*(time+0.625*SECS_IN_YEAR)/SECS_IN_YEAR));

end

