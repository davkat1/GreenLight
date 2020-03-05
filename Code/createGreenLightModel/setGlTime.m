function setGlTime(gl, startTime)
%SETBVTIME Set timephase for a GreenLight greenhouse model
% Should be used after the inputs for gl have been defined
% Inputs:
%   gl    - a DynamicModel object to be used as a GreenLight model.
%   startTime - time when simulation starts (datenum, days since 0/0/0000)

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

	tStart = gl.d.iGlob.val(1,1);
	tEnd = gl.d.iGlob.val(end,1);
	
    setTime(gl, datestr(startTime), [tStart tEnd]);	
end