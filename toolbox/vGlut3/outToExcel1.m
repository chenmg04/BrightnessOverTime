function V = outToExcel1 (out)

roiNo = length(out);
if roiNo == 1
   data{1} = out;
else
   data   = out;
end

stiNo = size(data{1}.peakAveTrace,2);
col   = stiNo * 3;
V     = zeros(roiNo, col); % every stimulus, there is ON, OFF & index
for i = 1:roiNo
    V(i,1:3:col) = data{i}.peakAveTrace(1,:);
    V(i,2:3:col) = data{i}.peakAveTrace(2,:);
    V(i,3:3:col) = data{i}.asyInd;
end
end