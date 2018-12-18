function [X,y] = align_os(Y)
% function to align the orientation selective response (Max in middle)
% for von Mises fit
%
% INPUT:
% Y: responses to stimulus at the corresping degrees, default
% [-90,-60,-30,0,30,60,90];
% OUTPUT:
% X,y: aligned orientation degrees and responses

% Retinas were aligned, preferred orientations are close to either 0 or 9

y90_max = max(Y(1),Y(7));
y90_min = min(Y(1),Y(7));

% % If preferred orientation is 0, resp at 0 should be larger than that at 90
if Y(4) > y90_max
    % keep the smaller response at 90 degree
    X = [-90,-60,-30,0,30,60];
    y = [y90_min Y(2:6)];
else
    % put 90 in the middle, keep the bigger response at 90 degree
    X = [0,30,60,90,120,150];
    y = [Y(4:6) y90_max Y(2:3)];
end

end