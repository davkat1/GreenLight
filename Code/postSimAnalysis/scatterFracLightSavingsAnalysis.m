% SCATTERFRACLIGHTSAVINGSANALYSIS Create a scatter plot of the fraction to light vs energy savings 
% Creates a scatter plot analyzing energy saving by transition to LEDs, as
% a function of the fraction of energy going to light in the HPS
% greenhouse, including all scenarios simulated.
% Used to create Figure 7 in: 
%   Katzin, D., Marcelis, L. F. M., & van Mourik, S. (2021). 
%   Energy savings in greenhouses by transition from high-pressure sodium 
%   to LED lighting. Applied Energy, 281, 116019. 
%   https://doi.org/10.1016/j.apenergy.2020.116019

% David Katzin, Wageningen University
% david.katzin@wur.nl
% david.katzin1@gmail.com

% Set directories for loading data
currentFile = mfilename('fullpath');
currentFolder = fileparts(currentFile);
outputFolder = strrep(currentFolder, '\Code\postSimAnalysis', ...
    '\Output\');
    % The last line may need to be modified, depending where the model 
    % output is saved
    % The path should include subfolders with simulation results, 
    % the subfolder names should correspond to the names below.
    % Each folder should have the following format for the file names: 
    % <location>_<lampType>_<optionalMoreInfo>
    % Each location should have both HPS and LED lamp type
    
% Create figure
figure('InvertHardcopy','off','PaperUnits','points','Color',[1 1 1],...
    'OuterPosition',[864 219 735 812]);

% Create axes
axes1 = axes;
hold(axes1,'on');
cc=lines(100);

%% Plot all results in a scatter plots
% Reference settings
[fracLightRef, savingsRef] = scatterFracLightSavings([outputFolder 'referenceSetting'], cc(1,:),'filled','o');
grid
hold on

% Other settings
[fracLightHeatAdj, savingsHeatAdj] = scatterFracLightSavings([outputFolder 'heatAdjustment'], cc(2,:),'filled','v');
[fracLightMoreHours, savingsMoreHours] = scatterFracLightSavings([outputFolder 'moreLightHours'], cc(5,:),'filled','o');
[fracLightColder, savingsColder] = scatterFracLightSavings([outputFolder 'colder'], cc(4,:),'filled','>');
[fracLightWarmer, savingsWarmer] = scatterFracLightSavings([outputFolder 'warmer'], cc(5,:),'filled','<');
[fracLightLowIns, savingsLowIns] = scatterFracLightSavings([outputFolder 'lowInsulation'], cc(6,:),'filled','<');
[fracLightHiIns, savingsHiIns] = scatterFracLightSavings([outputFolder 'highInsulation'], cc(7,:),'filled','>');
[fracLightLoLight, savingsPpfdLoLight] = scatterFracLightSavings([outputFolder 'ppfd100'], [0.718 0.275 1],'filled','<');
[fracLightHiLight, savingsHiLight] = scatterFracLightSavings([outputFolder 'ppfd400'], cc(9,:),'filled','>');

%% Analyze the data

% linear model for all simulations
x = [fracLightRef; fracLightHeatAdj; fracLightMoreHours; fracLightColder; fracLightWarmer; ...
    fracLightLowIns; fracLightHiIns; fracLightLoLight; fracLightHiLight];
y = [savingsRef; savingsHeatAdj; savingsMoreHours; savingsColder; savingsWarmer; ...
    savingsLowIns; savingsHiIns; savingsPpfdLoLight; savingsHiLight];
linearModel = fitlm(x,y); 

plot(0:100,0.4*(0:100),'Color',cc(1,:)) % potential savings
text(13.82, 8.368,'y = 0.4x','Color',cc(1,:),'FontSize', 7);
% plot the fitted model
xMdl = linearModel.VariableInfo.Range{1};
a = linearModel.Coefficients.Estimate(1);
b = linearModel.Coefficients.Estimate(2);
plot(0:100,a+(0:100)*b,'--','Color',cc(2,:))
text(14.926, -0.806,['y = ' num2str(b,'%.2f') 'x - ' num2str(-a,'%.2f')],...
    'Color',cc(2,:),'FontSize', 7);
text(14.926, -1.657,['R^{2} = ' num2str(linearModel.Rsquared.Ordinary,'%.2f')],...
    'Color',cc(2,:),'FontSize', 7);
text(14.926, -2.535,['RMSE = ' num2str(linearModel.RMSE,'%.2f')],...
    'Color',cc(2,:),'FontSize', 7);

%% Add figure elements
ylabel('Energy saving (%)')
xlabel('Fraction of energy used for lighting in HPS greenhouse (%)')
legend('Reference setting','Temperature adjustment under LEDs', 'Extended lamp hours',...
    'Lower indoor temperature','Higher indoor temperature','Low insulation','High insulation',...
    'Low lamp intensity', 'High lamp intensity','Potential energy saving',...
    'Achieved energy saving (linear regression)','Location','nw','FontSize',7);
grid
xlim(axes1,[0 100]);
ylim(axes1,[-5 40]);
grid(axes1,'on');
set(axes1,'FontName','arial','FontSize',7);

function [fracLight, savings] = scatterFracLightSavings(path, color, varargin)
% Scatter the fraction to light and the energy savings of simulations in a
% given path. 
% The path should include simulation results, ordered alphabetically in
% such a way that each HPS simulation is followed by an LED simulation
% of the same greenhouse.

    [fracLight, savings, ~, ~, labels] = ...
        fracLightVsTotalSavings(path);

    for k=1:length(labels)
        name = labels{k};
        locations{k} = upper(name);
    end
    locations=locations(1:2:end);

    scatter(fracLight,savings,30,color,varargin{:});
    text(fracLight+0.6,savings-0.6,locations,'Color',color,'FontSize', 7);
end

function [fracLight, savings, in, out, labels, yield] = fracLightVsTotalSavings(path)
% Return the fraction to light and the total energy savings for simulations
% in a given path.
% The path should include simulation results, ordered alphabetically in
% such a way that each HPS simulation is followed by an LED simulation
% of the same greenhouse.

    files = dir(path);
    files = files(3:end);
    
    if path(end)~= '\'
        path = [path '\'];
    end
    
    fileNum = length(files);
    
    labels = cell(fileNum,1);
    in = nan(fileNum, 3);
    out = nan(fileNum, 6);
    fracLight = nan(floor(fileNum/2),1);
    savings = nan(floor(fileNum/2),1);
    yield = nan(fileNum,1);
    
    for k=1:fileNum
        fprintf('%d / %d... ',k,fileNum);
        load([path files(k).name], 'gl');
        [simIn, simOut] = energyAnalysis(gl);

        in(k,:) = simIn; % [sunIn heatIn lampIn]
        out(k,:) = simOut; % [transp soilOut ventOut convOut firOut lampCool]
        label = files(k).name;
        underScores = find(label == '_');
        labels{k} = label(1:underScores(1)-1);
        yield(k) = trapz(gl.a.mcFruitHar)*1e-6/0.06; % kg fw/m2
        
        if mod(k,2) == 0 % LEDs are assumed to be on the even positions
            fracLight(k/2) = 100*in(k-1,3)/(in(k-1,2)+in(k-1,3));
            savings(k/2) = 100*(1-(in(k,2)+in(k,3))/(in(k-1,2)+in(k-1,3)));
        end
    end
    fprintf('\n');
    
end