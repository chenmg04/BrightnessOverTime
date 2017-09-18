function ave = makeScatterPlot (celldata)

% h = figure;
ave = []; 
nLayers = length(celldata.asyInd);
for i = 1:nLayers
    scatter(celldata.asyInd{i}(:,1),celldata.asyInd{i}(:,2),200,'k');hold on;
    ave(i,1) = celldata.asyInd{i}(1,1); 
    ave(i,2) = mean(celldata.asyInd{i}(:,2));
    ave(i,3) = std(celldata.asyInd{i}(:,2));
end

scatter(ave(:,1),ave(:,2),200,'r','linewidth',1);hold on;
errorbar(ave(:,1),ave(:,2),ave(:,3),'-rx','linewidth',1);
end