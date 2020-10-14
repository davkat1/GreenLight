%% Winter
a=smooth(hpsWin.a.hBoilPipe,12);
y1=a.val(:,2);
x1=1:289;
a=smooth(ledWin.a.hBoilPipe,12);
y2=a.val(:,2);

a=smooth(hpsWin.a.qLampIn,12);
y5=a.val(:,2);
a=smooth(ledWin.a.qLampIn,12);
y6=a.val(:,2);

a=smooth(hpsWin.a.lCanAir,12);
y7=a.val(:,2);
a=smooth(ledWin.a.lCanAir,12);
y8=a.val(:,2);


x2=hpsWin.d.iGlob.val(:,1);
y3=hpsWin.d.iGlob.val(:,2);
y4=hpsWin.d.tOut.val(:,2);
ylabels{1} = 'Energy input (W m^{-2})';
ylabels{2} = 'Solar radiation (W m^{-2})';
ylabels{3} = 'Outdoor temperature (°C)';
ylabels{4} = 'Time (h)';
x1 = x1*24/x1(end);
x1 = x1(2:end-1);
y1 = y1(2:end-1);
y2 = y2(2:end-1);
y3 = y3(2:end-1);
y4 = y4(2:end-1);
y5 = y5(2:end-1);
y6 = y6(2:end-1);

[axWin,hlines]=multiplotyyy({x1 [y1,y2,y5,y6]},{x1,y3},{x1,y4},ylabels);
legend(cat(1,hlines{:}),'HPS heating','LED heating','HPS lighting','LED lighting','Solar radiation','Outdoor temperature','location','ne')
title('Winter');

axWin(3).YLim = [2 20];
axWin(2).YLim = [0 600]; 
axWin(1).XLim = [0 24];
axWin(1).XTick = [0 6 12 18 24];


%% Summer
a=smooth(hpsSum.a.hBoilPipe,12);
y1=a.val(:,2);
x1=1:289;
a=smooth(ledSum.a.hBoilPipe,12);
y2=a.val(:,2);
a=smooth(hpsSum.a.qLampIn,12);
y5=a.val(:,2);
a=smooth(ledSum.a.qLampIn,12);
y6=a.val(:,2);
x2=hpsSum.d.iGlob.val(:,1);
y3=hpsSum.d.iGlob.val(:,2);
y4=hpsSum.d.tOut.val(:,2);
ylabels{1} = 'Energy input (W m^{-2})';
ylabels{2} = 'Solar radiation (W m^{-2})';
ylabels{3} = 'Outdoor temperature (°C)';
ylabels{4} = 'Time (h)';
x1 = x1*24/x1(end);
x1 = x1(2:end-1);
y1 = y1(2:end-1);
y2 = y2(2:end-1);
y3 = y3(2:end-1);
y4 = y4(2:end-1);
y5 = y5(2:end-1);
y6 = y6(2:end-1);

[axSum,hlines]=multiplotyyy({x1 [y1,y2,y5,y6]},{x1,y3},{x1,y4},ylabels);
legend(cat(1,hlines{:}),'HPS heating','LED heating','HPS lighting','LED lighting','Solar radiation','Outdoor temperature','location','ne')
title('Summer');
axSum(1).YLim = [0 150];
axSum(3).YLim = [2 20];

axSum(1).XLim = [0 24];
axSum(1).XTick = [0 6 12 18 24];
