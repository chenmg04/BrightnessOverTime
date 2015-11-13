function [labchartdata]=labchart2mat (fileName)

load (fileName);

chN=length(datastart);
t  =1/samplerate(1);

for i=1:chN
    labchartdata(:,i)=data(datastart(i):dataend(i));
end

labchartdata(:,chN+1)=(datastart(1):1:dataend(1))*t;




