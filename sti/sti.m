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
            
             if size(obj.data,2)==1
                baseline=mean(obj.data(1:50,1)); 
                obj.data(:,2)=(obj.data(:,1)-baseline)/baseline;
            end
        end
        
        % function to load stimulus data
        function loadData(obj,~,~)
            
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
        
%         function autoDetStiOnset(obj,~,~)
%             
%             % use first 50 data point to get sd
%             % and use 3 times of sd as the threshold to detect stimulus
%             
%             stidata=obj.data(:,1);
%             sd= std(stidata(1:50));
%             p=10*sd;
%             detectStiOnset(obj,p,stidata);
%         end
%         
%         function manDetStiOnset(obj,p,~)
%             
%             % manually set a threshold p
%             % and use delta F/F data to detect stimulus
%             
%             stidata=obj.data(:,2);
%             detectStiOnset(obj,p,stidata);
%             
%         end
        
        % function to detect stimulus onset time
        function detectStiOnset(obj, p)            
            
            if isequal(obj.threshold, p)
                return;
            end
            obj.threshold=p;
            % check data range for detection
            if isempty(p{1})
                stidata=obj.data(:,2);
                rs=1;rn=length(stidata);
            else
                rs=p{1}(1);rn=p{1}(2);
                stidata=obj.data(rs:rn,2);
            end
            % filter, boxcar
            stidata=moving_average(stidata,p{3});
           
            % thresholding
            s=zeros(); i=1;
            for n=rs:rn
                if abs(stidata(n))>p{2}
                    s(i)= n;
                    i=i+1;
                end
            end
                
            d=find(diff(s)~=1); 
            nSti=length(d)+1;
            startFrameN=[];
            endFrameN=[];
            startFrameN(1)=s(1)+p{3};
            startFrameN(2:nSti)=s(d+1)+p{3};          
            endFrameN(1:nSti-1)=s(d)-p{3};
            endFrameN(nSti)=s(end)-p{3};
            
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
        
        % function to insert stimulus
        function insertStimulus(obj, s, n)
            % s, startFrameN; n, endFrameN. s, n must be in pairs
            
            % insert new stimulus into the end
            nSti=length(obj.trailInfo);
            for i=1:length(s)
                obj.trailInfo(nSti+i).startFrameN=s(i);
                obj.trailInfo(nSti+i).endFrameN =n(i);
                obj.trailInfo(nSti+i).amplitude     =mean(obj.data(obj.trailInfo(nSti+i). startFrameN:obj.trailInfo(nSti+i). endFrameN,2));
                obj.data(s(i):n(i),3)                     =obj.trailInfo(nSti+i).amplitude;
            end
            %sortrows
             mtrail=(squeeze(cell2mat(struct2cell(obj.trailInfo))))';
             if ~issorted(mtrail,'rows')
                 sortedmtrail=sortrows(mtrail);
                 for i=1:nSti+length(s)
                     obj.trailInfo(i).startFrameN=sortedmtrail(i,1);
                     obj.trailInfo(i).endFrameN =sortedmtrail(i,2);
                     obj.trailInfo(i).amplitude     =sortedmtrail(i,3);
                 end
             end
            
        end
        % function to set stimulus pattern
        function setStiPattern(obj, q)
            
            if isempty(obj.trailInfo)
                sprintf('Please detect stimulus first!');
                return;
            end
            
            obj.patternInfo=[];
            if length(q)==1
                 nSti=1:length(obj.trailInfo);
                 for i=1:q-1
                     obj.patternInfo(i).trailN=nSti(find(mod(nSti, q)==i));
                 end
                 obj.patternInfo(q).trailN=nSti(find(mod(nSti, q)==0));
             else
                 patN=length(q);
                 for i=1:patN
                 obj.patternInfo(i).trailN=q{i};
                 end
            end
            
            % generate pattern traces, for later plots
            patN=length(obj.patternInfo);
            patternTrace=[]; firstFrameN=zeros(patN); lastFrameN=zeros(patN);
            for i=1:patN
                
                firstTrailN=obj.patternInfo(i).trailN(1);
                firstFrameN(i)=obj.trailInfo( firstTrailN). startFrameN;
                lastFrameN(i) =obj.trailInfo( firstTrailN). endFrameN;
                
                % Manually defined length
                preStartFrame=20;
                
                curLength=length(patternTrace);
                s=curLength+1;
                e=s+lastFrameN(i)-firstFrameN(i)+2*preStartFrame;
                patternTrace(curLength+1:e)=obj.data(firstFrameN(i)-preStartFrame:lastFrameN(i)+preStartFrame,3);
            end
            patternTraceLength=length(patternTrace);
            obj.data(1,4)=patternTraceLength;
            obj.data(2:patternTraceLength+1,4)=patternTrace;
            
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
            