function lightSum = dayLightSum(time, rad)
%DAYLIGHTSUM Calculate the light sum from the sun [MJ m^{-2} day^{-1}] for each day
% These values will be constant for each day, and change at midnight
% Inputs:
%   time - timestamps of radiation data (datenum format).
%          These timestamps must be in regular intervals
%   rad  - corresponding radiation data (W m^{-2})
%
% Output:
%   lightSum - daily radiation sum, with the same timestamps of time (MJ m^{-2} day^{-1})

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    interval = (time(2)-time(1))*86400; % interval in time data, in seconds

    mnBefore = 1; % the midnight before the current point
    mnAfter = find(diff(floor(time))==1,1)+1; % the midnight after the current point
    
    for k=1:length(time)
        
        % sum from midnight before until midnight after (not including)
        lightSum(k) = sum(rad(mnBefore:mnAfter-1));
        
        if k == mnAfter-1 % reached new day
            mnBefore = mnAfter;
            mnAfter = find(diff(floor(time(mnBefore+2:end)))==1,1)+mnBefore+2;
            if isempty(mnAfter)
                mnAfter = length(time);
            end
        end 
    end
    
    % convert to MJ/m2/day
    lightSum = lightSum*interval*1e-6;
end