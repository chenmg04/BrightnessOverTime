function tso = createAndProcessTswlsObject (inten, stidata, ftnum, framePeriod, traceLength, preStmLength, baselineLength, fixedLength,fixedValue)

% create a tswls object with inten and stidata
tso   = tswls (inten, stidata);
% filter data
tso.bcfilt (ftnum);
% extract individual traces and average traces
tso.extTraces (framePeriod, traceLength, preStmLength,'average1',baselineLength,'average2',fixedLength,'fixedValue',fixedValue);

end