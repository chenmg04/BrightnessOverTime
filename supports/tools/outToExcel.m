function V = outToExcel (out)

% single ROI or sum of all the ROIs
if length(out) == 1
    nsti = size(out.peakAveTrace,2);
    V(1:nsti,1:2) = out.peakAveTrace';
    V(1:nsti,3)   = out.asyInd';
end
end