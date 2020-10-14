function [in, out, savings, labels, yield, par, co2mean, co2inj] = worldBar(path)
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
    savings = nan(floor(fileNum/2),1);
    yield = nan(fileNum, 1);
    par = nan(fileNum, 1);
    co2mean = nan(fileNum, 1);
    co2inj = nan(fileNum, 1);

    
    for k=1:fileNum
        fprintf('%d / %d... ',k,fileNum);
        load([path files(k).name], 'gl');
        [simIn, simOut] = energyAnalysis(gl);

        in(k,:) = simIn; % [sunIn heatIn lampIn]
        out(k,:) = simOut;
        label = files(k).name;
        underScores = find(label == '_');
        labels{k} = label(underScores(end-3)+1:underScores(end-1)-1);
        
        yield(k) = trapz(gl.a.mcFruitHar)*1e-6/0.06; % kg fw/m2
        par(k) = trapz(gl.a.parCan)*1e-6; % mol PAR/m2
        co2mean(k) = mean(gl.a.co2InPpm); % ppm 
        co2inj(k) = 1e-6*trapz(gl.a.mcExtAir); % kg/m2
        
        if mod(k,2) == 0
            savings(k/2) = 100*(1-(in(k,2)+in(k,3))/(in(k-1,2)+in(k-1,3)));
        end
    end
    fprintf('\n');
    
    % get list of locations
    for k=1:length(labels)
        name = labels{k};
        locations{k} = upper(name(1:3));
    end
    
    % space out inputs
    originalIn = in;
    for k=2:2:length(in)
        in = [in(1:k+(k/2)-1,:); zeros(1,3); in(k+(k/2):end,:)];
    end
    
    b = bar(in(:,[2 3]), 'stacked'); % heatIn lampIn
    xticks(1.5:3:44.5)
    xticklabels(locations(1:2:end))
    grid;
    legend('Heating','Lighting');
    yticks(0:250:3500);
    ylabel('Energy input (MJ m^{-2} year^{-1})');
    title('Energy inputs in HPS and LED greenhouses')
    
    precision = 0;
    numFormat = ['%.' num2str(precision) 'f'];
    yOffset = -100;
    xOffset = -0.05;
    for k=1:length(b(1).YData)
        if b(1).YData(k)>0
            ht=text(xOffset+b(1).XData(k),yOffset+b(1).YData(k)/2,num2str(b(1).YData(k),numFormat),'FontSize',18);
            set(ht,'Rotation',90)
            ht=text(xOffset+b(1).XData(k),yOffset+b(1).YData(k)+b(2).YData(k)/2,num2str(b(2).YData(k),numFormat),'FontSize',18);
            set(ht,'Rotation',90)
        end
    end
end

