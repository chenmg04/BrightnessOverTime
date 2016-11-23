function filterdata = fil(rawdata)
y = rawdata;

Fs = 8;           

%% part 1 (a): high pass filter
[b1,a1] = butter(5,0.05/(Fs/2),'high');
yfilt1 = filtfilt(b1,a1,y);
% 
% figure;
% freqz(b1,a1);
%% part 1 (b): stop band filter
[b2,a2] = butter(5,0.5,'low');
filterdata = filtfilt(b2,a2,y);

end