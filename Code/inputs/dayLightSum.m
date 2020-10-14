function lightSum = dayLightSum(weather)
%DAYLIGHTSUM Summary of this function goes here
%   Detailed explanation goes here

    mnBefore = 1; % the midnight before the current point
    mnAfter = find(diff(floor(weather(:,1)))==1,1)+1; % the midnight after the current point
    
    for k=1:size(weather,1)
        
        % sum from midnight before until midnight after (not including)
        lightSum(k) = sum(weather(mnBefore:mnAfter-1,2));
        
        if k == mnAfter-1 % reached new day
            mnBefore = mnAfter;
            mnAfter = find(diff(floor(weather(mnBefore+2:end,1)))==1,1)+mnBefore+2;
            if isempty(mnAfter)
                mnAfter = size(weather,1);
            end
        end 
    end
    
    % convert to MJ/m2/day
    lightSum = lightSum*300*1e-6;
end