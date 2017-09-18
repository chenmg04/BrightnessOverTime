function ave = makeScatterPlot1 (celldata)

% h = figure;
ave = []; 
nLayers = length(celldata.peakAve);
for i = 1:nLayers
    scatter(celldata.peakAve{i}(:,1),celldata.peakAve{i}(:,2),200,'k');hold on;
    scatter(celldata.peakAve{i}(:,1),celldata.peakAve{i}(:,3),200,'k');hold on;
    ave(i,1) = celldata.peakAve{i}(1,1); 
    ave(i,2) = mean(celldata.peakAve{i}(:,2));
    ave(i,3) = std(celldata.peakAve{i}(:,2));
    ave(i,4) = mean(celldata.peakAve{i}(:,3));
    ave(i,5) = std(celldata.peakAve{i}(:,3));
end

scatter(ave(:,1),ave(:,2),200,'r','linewidth',1);hold on;
errorbar(ave(:,1),ave(:,2),ave(:,3),'-rx','linewidth',1);
scatter(ave(:,1),ave(:,4),200,'b','linewidth',1);hold on;
errorbar(ave(:,1),ave(:,4),ave(:,5),'-bx','linewidth',1);
% legend('ON','OFF');
end