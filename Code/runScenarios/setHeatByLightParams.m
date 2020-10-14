function setHeatByLightParams(gl, intensity)
%SETWORLDPARAMS Set parameters for running worldwide greenhouse
%   Detailed explanation goes here
    
    if ~exist('intensity', 'var')
        intensity = 66;
    end
    
    setParam(gl, 'co2SpDay', 1000);
    
    setParam(gl, 'lampsOn', 0);
    
    % KWIN says 17.5 night, 18.5 day, the values here are used to get
    % approximately that value
    setParam(gl, 'tSpNight', 18.5); 
    setParam(gl, 'tSpDay', 19.5);
    setParam(gl, 'rhMax', 87);
    setParam(gl, 'hAir', 6.5);
    setParam(gl, 'hGh', 8);
    
    setParam(gl, 'ventHeatPband', 4);
    setParam(gl, 'ventRhPband', 50); 
    
    setParam(gl, 'lampsOffYear', 105);
    setParam(gl, 'lampsOffSun', 600);
    setParam(gl, 'lampRadSumLimit', 14);
    
    % no boiler
    setParam(gl, 'pBoil', 0);
    
    % Varying lamp intensity
    setParam(gl, 'thetaLampMax', intensity);
    setParam(gl, 'capLamp', (intensity/66)*10);
    setParam(gl, 'cHecLampAir', (intensity/66)*2.3);

end

