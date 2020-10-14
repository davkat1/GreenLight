% EXAMPLECROPMODEL Example of running only the crop component of the GreenLight model 

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

time = 0:300:86400; % 1 day in 5 minute intervals
rad = [500*ones(144,1); zeros(145,1)];
temp = [22*ones(144,1); 18*ones(145,1)];
co2 = [1000*ones(144,1); 300*ones(145,1)];

gl = createCropModel([time' rad temp co2], 0);  

%% Solve
solveFromFile(gl, 'ode15s');

gl = changeRes(gl,300); % set resolution of trajectories at 5 minutes

%% Plot some outputs 
% see createCropModel for more options

dateFormat = 'HH:00'; 
% This format can be changed, see help file for MATLAB function datestr

subplot(2,3,1)
plot(gl.d.tCan)
ylabel('Canopy temperature (°C)')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(2,3,2)
plot(gl.d.co2InPpm)
ylabel('CO2 concentration (mg m^{-3})')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(2,3,3)
plot(gl.d.iGlob)
ylabel('Radiation (W m^{-2})')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(2,3,4)
plot(gl.a.mcAirCan)
hold on
plot(gl.a.mcAirBuf)
plot(gl.a.mcBufAir)
plot(gl.a.mcOrgAir)
ylabel('mg m^{-2} s^{-1}')
legend('Net assimilation (CO_2)', 'Net photosynthesis (gross photosynthesis minus photorespirattion, CH_2O)',...
'Growth respiration (CH_2O)','Maintenance respiration (CH_2O)')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(2,3,5)
plot(gl.x.cFruit)
hold on
plot(gl.x.cStem)
plot(gl.x.cLeaf)
plot(gl.x.cBuf)
ylabel('mg (CH_2O) m^{-2}')
yyaxis right
plot(gl.a.lai)
ylabel('m^2 m^{-2}')
legend('Fruit dry weight','Stem dry weight','Leaf dry weight','Buffer content','LAI')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);

subplot(2,3,6)
plot(gl.x.cFruit)
ylabel('mg (CH_2O) m^{-2}')
yyaxis right
plot(gl.a.mcFruitHar)
ylabel('mg (CH_2O) m^{-2} s^{-1}')
legend('Fruit dry weight','Fruit harvest')

numticks = get(gca,'XTick');
dateticks = datenum(datenum(gl.t.label)+numticks/86400);
datestrings = datestr(dateticks,dateFormat);
xticklabels(datestrings);