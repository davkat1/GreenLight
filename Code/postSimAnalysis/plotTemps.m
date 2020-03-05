function plotTemps(gl)
%PLOTTEMPS Plot the temperature states of the GreenLight Vanthoor model
% Creates one figure with all temperature states together

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com
    
    plot(gl.x.tCan); hold on;
    plot(gl.x.tAir);
    plot(gl.x.tThScr);
    plot(gl.x.tTop);
    plot(gl.x.tCovIn);
    plot(gl.x.tCovE);
    plot(gl.d.tOut);
    plot(gl.x.tPipe);
    plot(gl.x.tGroPipe);
    plot(gl.x.tIntLamp);
% 	yyaxis right
	plot(gl.x.tLamp);
    legend('tCan','tAir','tThScr','tTop','tCovIn','tCovE','tOut','tPipe',...
        'tGroPipe','tIntLamp','tLamp');
	yyaxis left;
    hold off;
end

