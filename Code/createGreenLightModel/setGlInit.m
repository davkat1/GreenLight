function setGlInit(gl, indoor)
%SETGLINIT Set the initial values for the GreenLight model.
%
% Typical usage:
%   setGlInit(gl, indoor)
% Inputs:
%   gl - a DynamicModel element, with its parameters already set by using
%       setGlParams(m)
%   indoor          (optional) A 3 column matrix with:
%       indoor(:,1)     timestamps of the input [s] in regular intervals of 300, starting with 0
%       indoor(:,2)     temperature       [°C]             indoor air temperature
%       indoor(:,3)     vapor pressure    [Pa]             indoor vapor concentration
%       indoor(:,4)     co2 concentration [mg m^{-3}]      indoor vapor concentration%
%

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

    x = gl.x;
    p = gl.p;
    d = gl.d;
    
    if exist('indoor','var') && ~isempty(indoor)
        % initial values are equal to indoor values
        x.tAir.val = indoor(1,2);
        x.vpAir.val = indoor(1,3);
        x.co2Air.val = indoor(1,4);
        
    else
        % Air and vapor pressure are assumed to start at the night setpoints
        x.tAir.val = p.tSpNight.val;
        x.vpAir.val = p.rhMax.val/100*satVp(x.tAir.val);

        % CO2 concentration is equal to outdoor CO2
        x.co2Air.val = d.co2Out.val(1,2);
    end
    
    % The top compartment is equal to the main compartment
    x.tTop.val = x.tAir.val;
    x.co2Top.val = x.co2Air.val;
    x.vpTop.val = x.vpAir.val;
    
    % Assumptions about other temperatures
    x.tCan.val = x.tAir.val+4;
    x.tCovIn.val = x.tAir.val;
    x.tThScr.val = x.tAir.val;
    x.tBlScr.val = x.tAir.val;
    x.tFlr.val = x.tAir.val;
    x.tPipe.val = x.tAir.val;
    x.tCovE.val = x.tAir.val;
    x.tSo1.val = x.tAir.val;
    x.tSo2.val = 1/4*(3*x.tAir.val+d.tSoOut.val(1,2));
    x.tSo3.val = 1/4*(2*x.tAir.val+2*d.tSoOut.val(1,2));
    x.tSo4.val = 1/4*(x.tAir.val+3*d.tSoOut.val(1,2));
    x.tSo5.val = d.tSoOut.val(1,2);
    x.tLamp.val = x.tAir.val;
    x.tIntLamp.val = x.tAir.val;
    x.tCan24.val = x.tCan.val;
    
    % the time variable is taken from m.t
    x.time.val = datenum(getDefStr(gl.t));
    
    if isfield(d, 'tPipe') && d.tPipe.val(1,2) > 0
        x.tPipe.val = d.tPipe.val(1,2);
    else
        x.tPipe.val = x.tAir.val;
    end
    
    if isfield(d, 'tGroPipe') && d.tGroPipe.val(1,2) > 0
        x.tGroPipe.val = d.tGroPipe.val(1,2);
    else
        x.tGroPipe.val = x.tAir.val;
    end
    
    %% crop model
    x.cBuf.val = 0;
    
    % start with 3.12 plants/m2, assume they are each 2 g = 6240 mg/m2.
    x.cLeaf.val = 0.7*6240;
    x.cStem.val = 0.25*6240;
    x.cFruit.val = 0.05*6240;
    
    x.tCanSum.val = 0;
    
    % Time - start with the datenum of when the simulation starts
    x.time.val = datenum(gl.t.label);
    
    %%    
	gl.x = x;
end

