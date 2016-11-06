classdef roitool < handle
    
    properties
        UIHandles
    end
    
    properties
        RoiData
        RoiHandles
        OpenedRois
    end
    
    methods
        % Parse inputs, initiate UI for roitool
        function obj = roitool (varargin)
            obj.UIHandles = UIRoiTool;
        end
    end
end