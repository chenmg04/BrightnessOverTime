function [po,osi,mdl] = von_Mises_fit_os(d,y)
% [po,osi] = von_Mises_fit1(d,y) 
%
% Fit responses to bars at different orientations, to get the preferred
% orientation and calculate the orientation selective index
%
% INPUT
% d: adjusted degrees after tunning the responses (put the max response in 
%    middle for modeling, see align_os.m)
% y: responses
%
% OUTPUT
% po: preferred orientation (degrees)
% osi: orientation selective index
% mdl: fitted model

X = [-90,-60,-30,0,30,60] ;

% von Mises distribution, b(1)~kappa, b(2)~u
rmax = max(y);
myfun = @(b,x) rmax * exp(b(1) * cos((x-b(2)) / 180 * 3.14)) / exp(b(1));

% fit
beta0 = [1;0];
mdl = fitnlm(X,y,myfun,beta0);

% po 
po = mdl.Coefficients{'b2','Estimate'} + d(4);

% choose the nearest datapoint to this po as preferred, and its orthogonal 
% as null, to calculate osi as osi = (preferred - null) / (preferred +
% null); altanatively, osi can be calculated with predicted data
[~,ind] = min(abs(po-d));
if ind <=3
    osi = (y(ind) - y(ind+3)) / (y(ind) + y(ind+3));
else
    osi = (y(ind) - y(ind-3)) / (y(ind) + y(ind-3));
end

