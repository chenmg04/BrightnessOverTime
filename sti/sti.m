classdef sti < handle

    
    properties
        data % traces for stimulus
        threshold      
        trailInfo % trail info <startFrameN, endFrameN, stiAmp>
        patternInfo % pattern info 
        paraInfo % stimulus parameters
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
            
        end
        % function to load stimulus data
        function loadData(obj,~,~)
            
            [filename, pathname] = uigetfile('*.mat', 'Pick a file');
            if isequal(filename,0) || isequal(pathname,0)
                disp('User pressed cancel');
                return;
            else
                disp(['User selected ', fullfile(pathname, filename)]);
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
        
        function autoDetStiOnset(obj,~,~)
            
            % use first 50 data point to get sd
            % and use 3 times of sd as the threshold to detect stimulus
            
            stidata=obj.data(:,1);
            sd= std(stidata(1:50));
            p=10*sd;
            detectStiOnset(obj,p,stidata);
        end
        
        function manDetStiOnset(obj,p,~)
            
            % manually set a threshold p
            % and use delta F/F data to detect stimulus
            
            stidata=obj.data(:,2);
            detectStiOnset(obj,p,stidata);
            
        end
        
        % function to detect stimulus onset time
        function detectStiOnset(obj,p,stidata)            
            
            if isequal(obj.threshold,p)
                return;
            end  
            obj.threshold=p;   
            
            nFrames=length(stidata);
            s=zeros(); i=1;
            for n=2:nFrames;
                if abs(stidata(n))>p
                    s(i)= n;
                    i=i+1;
                end
            end
                
            d=find(diff(s)~=1); 
            nSti=length(d)+1;
            
            startFrameN=[];
            endFrameN=[];
            startFrameN(1)=s(1);
            startFrameN(2:nSti)=s(d+1);          
            endFrameN(1:nSti-1)=s(d);
            endFrameN(nSti)=s(end);
            
            obj.trailInfo=[];  obj.data(:,3)=0;
             for i=1: nSti
                obj.trailInfo(i). startFrameN=startFrameN(i);
                obj.trailInfo(i). endFrameN=endFrameN(i);
                obj.trailInfo(i). amplitude=max(obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,2));
                obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,3)=obj.trailInfo(i). amplitude;
             end
             
             chkerr=zeros(22,nSti);
             for i=1:nSti
                 chkerr (1:11,i)  =obj.data(obj.trailInfo(i).startFrameN-5:obj.trailInfo(i).startFrameN+5,2);
                 chkerr (12:22,i)=obj.data(obj.trailInfo(i).endFrameN-5: obj.trailInfo(i).endFrameN+5,2);
             end
             disp(startFrameN);
             disp(chkerr);
            
        end
        
        % function to set stimulus pattern
        function setStiPattern(obj, patN)
            
            if isempty(obj.trailInfo)
                sprintf('Please detect stimulus first!');
                return;
            end
            
            nSti=1:length(obj.trailInfo);
            obj.patternInfo=[];
            if isscalar(patN)
                for i=1:patN-1
                    obj.patternInfo(i).trailN=nSti(find(mod(nSti,patN)==i));
                end
                obj.patternInfo(patN).trailN=nSti(find(mod(nSti, patN)==0));
            elseif iscell(patN)
                for i=1:length(patN)
                    j=patN{i};
                    obj.patternInfo(i).trailN=j;
                end
            elseif ismatrix(patN)
                for i=1:size(patN,1)
                    obj.patternInfo(i).trailN=patN(i,:);
                end
                
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
                        for i=1:patN
                            para(i)=obj.paraInfo(obj.patternInfo(i).trailN(1));
                        end
                    else
                        para=[];
                    end
                    obj.paraInfo=stiPatternPara(para,patN);
                end
            end
            
       
    end
    
    
    
end
            