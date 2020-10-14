% analyze fraction of light vs energy savings

% what I consider now the standard situation
[fracLight, savings, in, out, labels] = ...
    fracLightVsTotalSavings('C:\PhD\GreenLight Output 20200427\20200420LoLight');

for k=1:length(labels)
    name = labels{k};
    locations{k} = upper(name(end-6:end-4));
end
locations=locations(1:2:end);

% more light hours
[fracLight2, savings2, in2, out2, labels2] = ...
    fracLightVsTotalSavings('C:\PhD\GreenLight Output 20200427\20200418HighLight');

% no heat correction
[fracLight3, savings3, in3, out3, labels3] = ...
    fracLightVsTotalSavings('C:\PhD\GreenLight Output 20200427\20200422LoLightLedHc0');

for k=1:length(labels3)
    name = labels3{k};
    locations3{k} = upper(name(end-6:end-4));
end
locations3=locations3(1:2:end);

%% plot all the results
cc=lines(100);
scatter(fracLight,savings,70,cc(1,:), 'filled','o');
text(fracLight+0.3,savings-0.3,locations,'Color',cc(1,:),'FontSize', 12);
hold on
scatter(fracLight2,savings2,70,cc(2,:), 'filled','>');
text(fracLight2+0.3,savings2-0.3,locations,'Color',cc(2,:),'FontSize', 12);
scatter(fracLight3,savings3,70,cc(3,:),'filled','^');
text(fracLight3+0.3,savings3-0.3,locations3,'Color',cc(3,:),'FontSize', 12);

grid

% other scenarios
[fracLight4, savings4] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\colder',cc(4,:),'filled','>');
[fracLight5, savings5] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\warmer',cc(5,:),'filled','>');
[fracLight6, savings6] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\lowInsulation',cc(6,:),'filled','o');
[fracLight7, savings7] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\highInsulation',cc(7,:),'filled','>');
[fracLight8, savings8] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\highLight',cc(8,:),'filled','>');
[fracLight9, savings9] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\lowLight',cc(9,:),'filled','o');
[fracLight10, savings10] = scatterFracLightSavings('C:\PhD\GreenLight Output 20200427\20200422edgeCases\rh92',cc(2,:),'filled','d');

legend('Reference setting','More light hours','No heat correction',...
    'Colder','Warmer','Low insulation','High insulation',...
    'High light','Low light')

%%
% linear models for each of the separate simulation sets
mdl1 = fitlm(fracLight, savings); 
mdl2 = fitlm(fracLight2, savings2); 
mdl3 = fitlm(fracLight3, savings3); 
mdl12 = fitlm([fracLight; fracLight2], [savings; savings2]); 

% linear models for all simulations
x = [fracLight; fracLight2; fracLight3; fracLight4; fracLight5; ...
    fracLight6; fracLight7; fracLight8; fracLight9; fracLight10];
y = [savings; savings2; savings3; savings4; savings5; ...
    savings6; savings7; savings8; savings9; savings10];

mdlInt = fitlm(x,y); % all simulations
mdlWith0 = fitlm([0; x],[0; y]); % add a point at (0,0)
mdlNoInt = fitlm(x,y,'Intercept',false); % force intercept=0;

plot(0:100,0.4*(0:100),'Color',cc(3,:)) % potential savings
text(50, 30,'y = 0.4x','Color',cc(3,:),'FontSize', 14);

% plot one of the other models
xMdl = mdlInt.VariableInfo.Range{1};
a = mdlInt.Coefficients.Estimate(1);
b = mdlInt.Coefficients.Estimate(2);
plot(0:100,a+(0:100)*b,'--','Color',cc(1,:))
text(mean(xMdl), a+mean(xMdl)*b,['y = ' num2str(b,'%.2f') 'x - ' num2str(-a,'%.2f')],'Color',cc(1,:),'FontSize', 14);
text(mean(xMdl), a+mean(xMdl)*b+5,['R^{2} = ' num2str(mdlInt.Rsquared.Ordinary,'%.2f')],'Color',cc(1,:),'FontSize', 14);
text(mean(xMdl), a+mean(xMdl)*b+5,['RMSE = ' num2str(mdlInt.RMSE,'%.2f')],'Color',cc(1,:),'FontSize', 14);


title('Simulated energy savings by transition to LED');
ylabel('Energy saving (%)')
xlabel('Fraction of energy used for lighting in HPS greenhouse (%)')

legend('Reference setting','More light hours','No heat correction',...
    'Colder','Warmer','Low insulation','High insulation',...
    'High light','Low light','High RH',...
    'Potential savings','Predicted savings','Location','nw')
