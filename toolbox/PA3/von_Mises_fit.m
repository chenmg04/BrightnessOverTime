function von_Mises_fit(d,y)

% orientations of stimulus

X = [-90,-60,-30,0,30,60] / 180 * pi;

% von Mises distribution, b(1)~kappa, b(2)~u
rmax = max(y);
myfun = @(b,x) rmax * exp(b(1) * cos(x-b(2))) / exp(b(1));

% fit
beta0 = [1;0];
mdl = fitnlm(X,y,myfun,beta0);

% po
po = mdl.Coefficients{'b2','Estimate'} / 3.14 * 180 + d(4);

% osi = (preferred - null) / (preferred + null)
[~,ind] = min(abs(po-d));
if ind <=3
    osi = (y(ind) - y(ind+3)) / (y(ind) + y(ind+3));
else
    osi = (y(ind) - y(ind-3)) / (y(ind) + y(ind-3));
end

% plot
figure;

% original datapoints
plot(d,y,'k*'); hold on;

xx = linspace(-1.57,1.57)';
% fitted line
% xx1= linspace(-90,90)';
% line(xx1,predict(mdl,xx),'linestyle','-','color','r')
% xlabel(d(2,:));
%
if d(1) == -90
    xx1= linspace(-90,90)';
    line(xx1,predict(mdl,xx),'linestyle','-','color','r')
    xticks(-90:30:90);
else
    xx1= linspace(0,180)';
    line(xx1,predict(mdl,xx),'linestyle','-','color','r')
    xticks(0:30:180);
end
% yticks(0:20:80);
xlabel('Degree of Orientation');
ylabel('Response Amplitude');
title(sprintf('Preferred Orientation is %.2f, OSI is %.2f',po,osi));
