function [fracLight, savings, in, out, labels, yield] = fracLightVsTotalSavings(path)
%fracLightVsTotalSavings Summary of this function goes here
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
        labels{k} = label(underScores(1)+1:underScores(4)-1);
        yield(k) = trapz(gl.a.mcFruitHar)*1e-6/0.06; % kg fw/m2
        
        if mod(k,2) == 0 % LEDs are assumed to be on the even positions
            fracLight(k/2) = 100*in(k-1,3)/(in(k-1,2)+in(k-1,3));
            savings(k/2) = 100*(1-(in(k,2)+in(k,3))/(in(k-1,2)+in(k-1,3)));
        end
    end
    fprintf('\n');
    
end

