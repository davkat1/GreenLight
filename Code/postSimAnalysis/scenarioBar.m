function [in, out, labels, yield, par, co2mean, co2inj, costs, carbonFootprint] = scenarioBar(path, heatType)
%WORLDBAR Summary of this function goes here
%   Detailed explanation goes here

    files = dir(path);
    files = files(3:end);
    
    if path(end)~= '\'
        path = [path '\'];
    end
    
    fileNum = length(files);
    
    labels = cell(fileNum,1);
    in = nan(fileNum, 3);
    out = nan(fileNum, 6);
    yield = nan(fileNum, 1);
    par = nan(fileNum, 1);
    co2mean = nan(fileNum, 1);
    co2inj = nan(fileNum, 1);
    costs = nan(fileNum, 1);
    carbonFootprint = nan(fileNum, 1);
    
    for k=1:fileNum
        load([path files(k).name], 'gl');
        [simIn, simOut] = energyAnalysis(gl);

        in(k,:) = simIn;
        out(k,:) = simOut;
        label = files(k).name;
        underScores = find(label == '_');
        labels{k} = label( ...
            [underScores(end-4)+1:underScores(end-3)-1 ...
            underScores(end-2):underScores(end-1)-1]);
        
        yield(k) = trapz(gl.a.mcFruitHar)*1e-6/0.06; % kg fw/m2
        par(k) = trapz(gl.a.parCan)*1e-6; % mol PAR/m2
        co2mean(k) = mean(gl.a.co2InPpm); % ppm 
        co2inj(k) = 1e-6*trapz(gl.a.mcExtAir); % kg/m2
        
        if strcmp(heatType, 'chp')
            elecBought = simIn(3)/gl.p.thetaLampMax.val*(gl.p.thetaLampMax.val-50);
            elecGen = 0.4/0.5*simIn(2);
            elecSold = elecGen-simIn(3)+elecBought;
            costs(k) = 0.17/(31.65*0.5)*simIn(2)+0.057/3.6*elecBought-0.037/3.6*elecSold;
            carbonFootprint(k) = 2.218/(31.65*0.5)*simIn(2)+0.64/3.6*elecBought-0.57/3.6*elecSold;
        else
            costs(k) = 0.19/(31.65*0.875)*simIn(2)+0.057/3.6*simIn(3);
            carbonFootprint(k) = 1.87/(31.65*0.875)*simIn(2)+0.64/3.6*simIn(3);
        end
    end
    
    in = in(:,[2 3 1]);
    
    bar(in,'stacked')
    hold on
    bar(out,'stacked')
    legend('heating','lamp','sun','transpiration','soilOut','ventOut','convOut','firOut','lampCool')
    xticklabels(labels)
    
end

