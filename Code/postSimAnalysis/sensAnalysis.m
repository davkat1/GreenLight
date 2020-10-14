inSumHps = nan(fileNum, 3);
outSumHps = nan(fileNum, 6);

for n=1:5
    fileName = ['summerHps' num2str(n)];
    load(fileName);
    eval(['simResult = ' fileName ';']);
    for k = 1:length(simResult)
        [simIn, simOut] = energyAnalysis(simResult(k));
        inSumHps(100*(n-1)+k,:) = simIn;
        outSumHps(100*(n-1)+k,:) = simOut;
    end
end

inSumLed = nan(fileNum, 3);
outSumLed = nan(fileNum, 6);

for n=1:5
    fileName = ['summerLed' num2str(n)];
    load(fileName);
    eval(['simResult = ' fileName ';']);
    for k = 1:length(simResult)
        [simIn, simOut] = energyAnalysis(simResult(k));
        inSumLed(100*(n-1)+k,:) = simIn;
        outSumLed(100*(n-1)+k,:) = simOut;
    end
end


inWinHps = nan(fileNum, 3);
outWinHps = nan(fileNum, 6);

for n=1:5
    fileName = ['winterHps' num2str(n)];
    load(fileName);
    eval(['simResult = ' fileName ';']);
    for k = 1:length(simResult)
        [simIn, simOut] = energyAnalysis(simResult(k));
        inWinHps(100*(n-1)+k,:) = simIn;
        outWinHps(100*(n-1)+k,:) = simOut;
    end
end

inWinLed = nan(fileNum, 3);
outWinLed = nan(fileNum, 6);

for n=1:5
    fileName = ['winterLed' num2str(n)];
    load(fileName);
    eval(['simResult = ' fileName ';']);
    for k = 1:length(simResult)
        [simIn, simOut] = energyAnalysis(simResult(k));
        inWinLed(100*(n-1)+k,:) = simIn;
        outWinLed(100*(n-1)+k,:) = simOut;
    end
end

load('winterLed');
[simIn, simOut] = energyAnalysis(glDef);
inWinLed(end+1,:) = simIn;
outWinLed(end+1,:) = simOut;

load('summerLed');
[simIn, simOut] = energyAnalysis(glDef);
inSumLed(end+1,:) = simIn;
outSumLed(end+1,:) = simOut;

load('winterHps');
[simIn, simOut] = energyAnalysis(glDef);
inWinHps(end+1,:) = simIn;
outWinHps(end+1,:) = simOut;

load('summerHps');
[simIn, simOut] = energyAnalysis(glDef);
inSumHps(end+1,:) = simIn;
outSumHps(end+1,:) = simOut;

inSumHps(:,4) = inSumHps(:,2)+inSumHps(:,3);
inSumLed(:,4) = inSumLed(:,2)+inSumLed(:,3);
inWinHps(:,4) = inWinHps(:,2)+inWinHps(:,3);
inWinLed(:,4) = inWinLed(:,2)+inWinLed(:,3);

savingsWinter = 1-inWinLed(:,4)./inWinHps(:,4);
savingsSummer = 1-inSumLed(:,4)./inSumHps(:,4);

plot(savingsSummer,'o')
hold on
plot(savingsWinter,'o')