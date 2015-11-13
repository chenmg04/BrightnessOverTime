classdef ds < handle
    
    properties 
        data
        pd
        vpd
        htw
    end
    
    methods
        function obj=ds(dp)
            if length(dp)<4 || rem(length(dp),2)==1
                sprintf('Please use correct data');
                return;
            end
            obj.data(:,1)=0:1/length(dp)*2*pi:(length(dp)-1)/length(dp)*2*pi;
            obj.data(:,2)=dp';
            
            Vx=sum(obj.data(:,2).*cos(obj.data(:,1)));
            Vy=sum(obj.data(:,2).*sin(obj.data(:,1)));
            obj.vpd  =sqrt(Vx^2+Vy^2);
            if Vy>0
                obj.pd=acosd(Vx/obj.vpd);
            else
                obj.pd=360-acosd(Vx/obj.vpd);
            end
        end
    end
end