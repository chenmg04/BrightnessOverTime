classdef sti < handle
% A class to read stimulus data, detect stimulus onset/offset timing,
% define stimulus pattern etc., so that this stimulus could be used to 
% analyze stimulus-driven neuronal responses in electrophysiology or 
% imaging experiments.
    properties
        data % traces for stimulus
        threshold      
        trail % trail info <startFrameN, endFrameN>
        pattern % pattern info 
    end
    
    methods
        function obj = sti (varargin)  
            if nargin
                try
                    obj.threshold=varargin{1}.threshold;
                    obj.data=varargin{1}.data;
                    obj.trailInfo=varargin{1}.trailInfo;
                    obj.patternInfo=varargin{1}.patternInfo;
                    obj.paraInfo=varargin{1}.paraInfo;
                catch
                    obj.data=varargin{1};
                end
            else
                obj.data=[];
            end
            
             if size(obj.data,2)==1
                baseline=mean(obj.data(1:50,1)); 
                obj.data(:,2)=(obj.data(:,1)-baseline)/baseline;
            end
        end
        
        
        function load(obj,~,~)
            % function to load stimulus data
            
            [filename, pathname] = uigetfile('*.mat', 'Pick a file');
            if isequal(filename,0) || isequal(pathname,0)
                disp('User pressed cancel');
                return;
            end
            fullfilename=fullfile(pathname, filename);
            b=load(fullfilename);
            try
                obj.threshold=b.stidata.threshold;
                obj.data=b.stidata.data;
                obj.trailInfo=b.stidata.trailInfo;
                obj.patternInfo=b.stidata.patternInfo;
                obj.paraInfo=b.stidata.paraInfo;
            catch  
                try
                    obj.data=b.stidata;
                catch
                    obj.data=(b.data)'; % labchart files saved as .mat file
                end
            end
            
            if size(obj.data,2)==1
                baseline=mean(obj.data(1:50,1)); 
                obj.data(:,2)=(obj.data(:,1)-baseline)/baseline;
            end

        end
        
        
        function detect(obj, threshold)            
            % function to detect stimulus timing
            %
            % threshold: threshold to detect the stimulus timing
            % For example:
            % t = sti(data)
            % t.detect(1)
            
            if isempty(obj.data)
                return;
            end
            
            obj.threshold = threshold;
            
            % use function detectEvent to detect the onset and offset
            [~, startpoint, endpoint] = detectEvent(obj.stim.data(:,1), threshold, 'positive');
            obj.trail(:,1) = startpoint;
            obj.trail(:,2) = endpoint;
            
        end
                
        function obj = correct(obj,nsti,amplitude)
            % function to correct stimulus timing due to software problem
            %
            % nsti: sti # for correction, e.g., [3,4]
            % amplitude: sti amplitude for better visulization
             
            % define the right stimulus duration as the minimus duration
            % among those stimuli
            if ~isempty(nsti)
                duration = min(obj.trail(:,2)-obj.trail(:,1));
                % the software always have errors for the startpoints somehow
                for i = 1: length(nsti)
                    obj.obj.trail(nsti(i),1) = obj.obj.trail(nsti(i),2) - duration;
                end
            end
            
            % generate stimulus data with new amplitude
            obj.data(:,2) = 0;
            for n = 1: length(obj.trail)
                obj.data(obj.trail(n,1):obj.trail(n,1),2)   = amplitude;
            end 
            
            
        end

        function insert(obj, m)
            % function to insert stimulus, for example, some stimulus are
            % not detectable under imaging experiments, and for dual
            % patch-imaging experiments, we also need mannually insert
            % stimulus
            %
            % m, a matrix contains the onset and offset of
            % stimulus, m = [onset,offset]
            
            % insert new stimulus into the end
            nSti=size(obj.trail,1);
            for i=1:size(m,1)
                obj.trail(nSti+i,1)=m(i,1);
                obj.trail(nSti+i,2)=m(i,2);
                % set amplitude
                if size(obj.data,2) == 2
                    obj.data(m(i,1):m(i,1),2) = max(obj.data(:,2));
                end
                    
            end
            %sortrows
             obj.trail = sortrows(obj.trail);
            
        end
        
        function setPattern(obj, pat)
            % function to set pattern for stimulus. 
            %
            % for example, to test neurons' receptive field property,
            % concentric spots with 8 different diameters were given 
            % and repeat 3 times. we can define that there are 8 different
            % stimulus patterns, and then we can easy average the responses
            %
            % pat: either a single number or a cell.
            % for example, if pat = 8, it means there are 8 different
            % stimulus and they were given in sequences; if pat =
            % {[1,3,5];[2,4,6];[7,8]}, there are 3 different stimulus, 1st
            % contains 1,3,5 stimulus, 2nd contains 2,4,6 etc.
            
            if isempty(obj.trail)
                   sprintf('Please detect stimulus first!');
                return;
            end
            
            obj.pattern=[];
            if iscell(pat)
                obj.pattern = pat;
            else % single number
                nsti = 1: length(obj.trail);
                for i = 1:pat-1
                    obj.pattern{i} = nsti(find(mod(nsti,pat) == i));
                end
                 obj.pattern{pat} = nsti(find(mod(nsti,pat) == 0));
            end
            
        end
        
        % function to show stimulus trace, three options, raw, fit and pattern    
        function showTrace(obj,haxes,option)
            
            if haxes==0
                figure;
            else
                axes(haxes);
            end
            
            switch option
                case 'Raw'
                    plot(obj.data(:,2));
                    xlabel('Frame #'); ylabel('delta F/F');title('Raw');
                case 'Fit'
                    plot(obj.data(:,3),'Color','r');
                    xlabel('Frame #'); ylabel('delta F/F');title('Fitted');
                case 'Pattern'
                    if isempty(obj.patternInfo)
                        return;
                    else
%                         axes(obj.h.axes);cla;
                        patternTraceLength=obj.data(1,4);
                        plot(1:1:patternTraceLength,obj.data(2:patternTraceLength+1,4),'Color','g');
                        xlabel('Frame #'); ylabel('delta F/F');title('Pattern');
                    end
            end
        end
            
                   
           %function to set stimulus pattern parameters
            function setStiPatternPara (obj,~,~)
                
                if ~isempty(obj.patternInfo)
                    patN=length(obj.patternInfo);
                    if ~isempty(obj.paraInfo)
                        try % old version
                            for i=1:nPat
                                para(i)=obj.paraInfo(obj.patternInfo(i).trailN(1));
                            end
                        catch
                            para=obj.paraInfo;
                        end
                    else
                        para=[];
                    end
                    obj.paraInfo=stiPatternPara(para,patN);
                end
            end
            
       
    end
    
    
    
end
            