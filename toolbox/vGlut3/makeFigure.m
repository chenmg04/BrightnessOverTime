function makeFigure (peakON, peakOFF)

figure;
m = length (peakON);
n = length (peakOFF);
for i = 1:m
    subplot(2,1,1),axis([0.5 6 0 300]);
    plot([1,2],peakON(i,1:2),'-ks','LineWidth',0.5);hold on;
    plot([3,4],peakON(i,3:4),'-ks','LineWidth',0.5);hold on;
end

for i = 1:n
     subplot(2,1,2),axis([0.5 6 0 300]);
     plot([1,2],peakOFF(i,1:2),'-ks','LineWidth',0.5);hold on;
     plot([3,4],peakOFF(i,3:4),'-ks','LineWidth',0.5);hold on;
end

ONAve = mean(peakON);OFFAve = mean(peakOFF);
ONerr = std(peakON)/sqrt(m);OFFerr  = std(peakOFF)/sqrt(n);

subplot(2,1,1),axis([0.5 6 0 300])
plot([1,2],ONAve(1:2),'-rs','LineWidth',2);h = errorbar([1,2],ONAve(1:2),ONerr(1:2),'r','LineWidth',2);
plot([3,4],ONAve(3:4),'-rs','LineWidth',2);errorbar([3,4],ONAve(3:4),ONerr(3:4),'r','LineWidth',2);

subplot(2,1,2),axis([0.5 6 0 300]);
plot([1,2],OFFAve(1:2),'-rs','LineWidth',2);errorbar([1,2],OFFAve(1:2),OFFerr(1:2),'r','LineWidth',2);
plot([3,4],OFFAve(3:4),'-rs','LineWidth',2);errorbar([3,4],OFFAve(3:4),OFFerr(3:4),'r','LineWidth',2);

end