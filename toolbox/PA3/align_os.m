function [X,y] = align_os(R)
% function to align the orientation selective response (Max in middle)
% for von Mises fit
%
% INPUT:
% R: responses to stimulus at the corresping degrees, default
% [-90,-60,-30,0,30,60,90];
% OUTPUT:
% X,y: aligned orientation degrees and responses

% Retinas were aligned, preferred orientations are close to either 0 or 90
if length(R) == 7 %[-90,-60,-30,0,30,60,90]
    y90_max = max(R(1),R(7));
    y90_min = min(R(1),R(7));
    
    % % If preferred orientation is 0, resp at 0 should be larger than that at 90
    if R(4) > y90_max
        % keep the smaller response at 90 degree
        X = [-90,-60,-30,0,30,60];
        y = [y90_min R(2:6)];
    else
        % put 90 in the middle, keep the bigger response at 90 degree
        X = [0,30,60,90,120,150];
        y = [R(4:6) y90_max R(2:3)];
    end
else %[-90,-60,-30,0,30,60]
    if R(4)<R(1)
        X = [0,30,60,90,120,150];
        y = [R(4:6) R(1:3)];
    else
        X = [-90,-60,-30,0,30,60];
        y = R;
    end
end

end
