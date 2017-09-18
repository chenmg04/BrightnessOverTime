function V = readOutPeak (out)

V =[]; 
for i = 1: size(out.peakAve,3)
    for j = 1: size(out.peakAve, 1)          
        for l =1: size(out.peakAve, 2)
            if j == 1
                m = l *2 -1;
            else
                m = l*2;
            end
            V(i,m) = out.peakAve(j, l, i);
        end
    end
end