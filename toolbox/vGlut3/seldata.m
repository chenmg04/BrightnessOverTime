function [peak,indx] = seldata (out,rois,nSti,layerIndex)

% from outdata select peakAve, asyInde for indicated rois and stimulus
nROIs = length(rois);
peak(1:nROIs,1) = layerIndex;
peak(1:nROIs,2) = out.peakAve(1,nSti,rois);
peak(1:nROIs,3) = out.peakAve(2,nSti,rois);

indx(1:nROIs,1) = layerIndex;
indx(1:nROIs,2) = out.asyInd(nSti,rois);
end