classdef stim < handle

    
    properties
        h
        
        threshold      
        data % traces for stimulus
        trailInfo % trail info <startFrameN, endFrameN, stiAmp>
        patternInfo % pattern info 
        paraInfo % stimulus parameters
        
        lastSti
    end
    
    methods
        function obj = stim (varargin)
            
%             if nargin
%                 try
%                     obj.threshold=varargin{1}.threshold;
%                     obj.data=varargin{1}.data;
%                     obj.trailInfo=varargin{1}.trailInfo;
%                     obj.patternInfo=varargin{1}.patternInfo;
%                     obj.paraInfo=varargin{1}.paraInfo;
%                 catch
%                     obj.data=varargin{1};
%                 end
%                 
%             else
%                 obj.data=[];
%                 choice=questdlg('No Stimulus File Found! Would you like to import stimulus file?',...
%                     'Import Stimulus File',...
%                     'No', 'Yes', 'Yes');
%                 switch choice
%                     case 'Yes',
%                         openStimulus(obj);
%                     case 'No'
%                         return;
%                 end
%             end
            
            %--------------------------------------------------------------
            % Build GUI
            obj.h.fig = figure('Name','Stimulus',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Toolbar','figure',...
                'Color','white',...
                'Units','pixels',...
                'Position',[426 20 512 250],...
                'Resize','off',...
                'CloseRequestFcn',@obj.closeMainFig);  
            
             % File Menu
             fileMenu= uimenu(obj.h.fig,...
                'Label','File',...
                'Tag','file menu');
             uimenu(fileMenu,...
                'Label','Open...',...
                'Separator','off',...
                'Callback',@obj.openStimulus);
             uimenu(fileMenu,...
                'Label','Save',...
                'Separator','off',...
                'Callback',@obj.saveStimulus);
            % Detect Menu
            detectMenu = uimenu(obj.h.fig,...
                'Label','Detect',...
                'Tag','detect menu');
            uimenu(detectMenu,...
                'Label','Stimuli',...
                'Accelerator','S',...
                'Separator','off',...
                'Callback',@obj.detectStimulus);
           detectPatternMenu= uimenu(detectMenu,...
                'Label','Pattern',...
                'Separator','off');
             
           uimenu(detectPatternMenu,...
                'Label','Auto Detection',...
                'Separator','off',...
                'Callback',@obj.autoPatternDetection);
           uimenu(detectPatternMenu,...
                'Label','Manual Detection',...
                'Separator','off',...
                'Callback',@obj.manualPatternDetection);
            % Edit Menu
            editMenu= uimenu(obj.h.fig,...
                'Label','Edit',...
                'Tag','detect menu');
             uimenu(editMenu,...
                'Label','Insert Stimulus',...
                'Separator','off',...
                'Callback',@obj.insertStimulus);
            uimenu(editMenu,...
                'Label','Set Pattern',...
                'Accelerator','P',...
                'Separator','off',...
                'Callback',@obj.setPattern);
            % View Menu
            viewMenu = uimenu(obj.h.fig,...
                'Label','View',...
                'Tag','view menu');
            uimenu(viewMenu,...
                'Label','Raw Trace',...
                'Separator','off',...
                'Callback',@obj.showRawTrace);
            uimenu(viewMenu,...
                'Label','Fitted Trace',...
                'Separator','off',...
                'Callback',@obj.showFitTrace);
            uimenu(viewMenu,...
                'Label','Pattern Trace',...
                'Separator','off',...
                'Callback',@obj.showPatternTrace);
             uimenu(viewMenu,...
                'Label','Pattern Parameter',...
                'Separator','off',...
                'Callback',@obj.showPatternParameter);
            
            % delete uncessary Toolbar
            set(0,'Showhidden','on');
            ch = get(obj.h.fig,'children');
            chatags=get(ch,'Tag');
            ftb_ind=find(strcmp(chatags,'FigureToolBar'));
            UT = get(ch(ftb_ind),'children');
            delete(UT(1:8));
            delete(UT((end-4):end));                          
             
%             ht=uitoolbar(fig);
            path=fileparts(which('stim'));

            [X,map] = imread([path '\icons\last_used.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ch(ftb_ind),'CData',icon,'TooltipString','Use exact parameters from last opened stimulus','Separator','off','ClickedCallback',@obj.useLast);
            
            obj.h.axes=axes(...
                'Parent',obj.h.fig,...
                'Position',[.1,.2,.8,.7]);
            
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
                
                if nargin==2
                   obj.lastSti=varargin{2};
                end
            else
                obj.data=[];
                choice=questdlg('No Stimulus File Found! Would you like to import stimulus file?',...
                    'Import Stimulus File',...
                    'No', 'Yes', 'Yes');
                switch choice
                    case 'Yes',
                        openStimulus(obj);
                    case 'No'
                        return;
                end
            end
            
            try
                plot(obj.data(:,2),'Parent',obj.h.axes);
            catch
                baseline=mean(obj.data(1:50,1)); 
                obj.data(:,2)=(obj.data(:,1)-baseline)/obj.data(1,1);
                plot(obj.data(:,2),'Parent',obj.h.axes);
            end
            xlabel('Frame #'); ylabel('delta F/F');title('Raw');
             
        end
        
        function useLast(obj,~,~)
            
            if ~isempty(obj.lastSti)
                obj.threshold=obj.lastSti.threshold;
                detectStiOnset(obj,obj.threshold);
                obj.patternInfo=obj.lastSti.patternInfo;
                obj.paraInfo=obj.lastSti.paraInfo;
                plotPatternTrace(obj);
            end
        end
        
        function openStimulus(obj,~,~)
            
            [filename, pathname] = uigetfile('*.mat', 'Pick a file');
            if isequal(filename,0) || isequal(pathname,0)
                disp('User pressed cancel');
                return;
            else
                disp(['User selected ', fullfile(pathname, filename)]);
            end
            fullfilename=fullfile(pathname, filename);
            load(fullfilename);
            try
                obj.threshold=stidata.threshold;
                obj.data=stidata.data;
                obj.trailInfo=stidata.trailInfo;
                obj.patternInfo=stidata.patternInfo;
                obj.paraInfo=stidata.paraInfo;
            catch  
            obj.data=stidata;
            end
            showPatternTrace (obj);
            hpara= findobj('Name','Stimulus Pattern');
            if ~isempty(hpara)
                close(hpara);
            end
            
%             clear all;
        end
        
        function saveStimulus(obj,~,~)
            
            stidata.threshold=obj.threshold;
            stidata.data=obj.data;
            stidata.trailInfo=obj.trailInfo;
            stidata.patternInfo=obj.patternInfo;
            stidata.paraInfo=obj.paraInfo;
            
%             [filename, pathname] = uiputfile('*.mat', 'Save as...');
%             if isequal(filename,0) || isequal(pathname,0)
%                 disp('User pressed cancel')
%             else
%                 disp(['User selected ', fullfile(pathname, filename)])
%             end
            pathname=cd;
            [~, filename]=fileparts(pathname);
            filename=['stim_' filename];
            filename=fullfile(pathname,filename);
            save(filename,'stidata');
            
            
        end
        
        %function to close main stimulus figure
        function closeMainFig(obj, hObject, ~)
            
%             if ~isempty(obj.hpattern)
%                 close('Stimulus Pattern');
%                 obj.h.pattern=[];
%             end
%             
            delete(hObject);
            obj.h.fig=[];
            obj.h.axes=[];
                
        end
        
      %% function to detect stimulus   
        function detectStimulus(obj, ~, ~)
            
            showRawTrace (obj);
            
            prompt={'Enter Baseline Length','Enter N Folds of SD','Enter Threshold Value', 'Enter Filter n'};
            dlg_title='Threshold';
            num_lines=1;
            
            try
                def={num2str(obj.threshold(1)),num2str(obj.threshold(2)),num2str(obj.threshold(3)), num2str(obj.threshold(4))};
            catch
                def={'100','3','0','0'};
            end
            p=str2double(inputdlg(prompt,dlg_title,num_lines,def));
                        
            if isequal(obj.threshold,p)
                axes(obj.h.axes);
                hold on;
                plot(obj.data(:,3),'color','r');
                return;
            end
            detectStiOnset(obj, p)
        end
       
            function detectStiOnset(obj, p,~)
                
            obj.threshold=p;
           % p(1) baseline length; p(2) threshold value; p(3) filter value
            norSti=moving_average(obj.data(:,2),p(4));
            baselineAve=mean(norSti(1:p(1)));
            sd= std(norSti(1:p(1)));
            
            nFrames=length(obj.data);
            s=zeros(); i=1;
            if p(3)~=0
                for n=2:nFrames;
                    if abs(norSti(n))>baselineAve+p(3)
                        s(i)= n;
                        i=i+1;
                    end
                end
            else
                for n=2:nFrames;
                    if abs(norSti(n))>baselineAve+p(2)*sd
                        s(i)= n;
                        i=i+1;
                    end
                end
            end
            d=find(diff(s)~=1); 
            nSti=length(d)+1;
            
            startFrameN=[];
            endFrameN=[];
            startFrameN(1)=s(1)+p(4);
            startFrameN(2:nSti)=s(d+1)+p(4);          
            endFrameN(1:nSti-1)=s(d)-p(4);
            endFrameN(nSti)=s(end)-p(4);
            
            obj.trailInfo=[];  obj.data(:,3)=0;
             for i=1: nSti
                obj.trailInfo(i). startFrameN=startFrameN(i);
                obj.trailInfo(i). endFrameN=endFrameN(i);
                obj.trailInfo(i). amplitude=max(obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,2));
                obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,3)=obj.trailInfo(i). amplitude;
             end
             
             chkerr=zeros(22,nSti);
             for i=1:nSti
                 chkerr (1:11,i)=obj.data(obj.trailInfo(i).startFrameN-5:obj.trailInfo(i).startFrameN+5,2);
                 chkerr (12:22,i)=obj.data(obj.trailInfo(i).endFrameN-5: obj.trailInfo(i).endFrameN+5,2);
             end
             disp(chkerr);
            disp(startFrameN);
            axes(obj.h.axes); hold on;    
            plot(obj.data(:,3),'color','r'); title('Fitted');
                    
        end
        
        
        %
        function insertStimulus (obj,~, ~)
            
            prompt={'Enter Start Frame #', 'Enter End Frame #'};
            dlg_title='Insert';
            num_lines=1;
            def={'0','0'};
            insertFrameN=str2double(inputdlg(prompt,dlg_title,num_lines,def));
           
            
            % update trailInfo
            nSti=length(obj.trailInfo);
            if nSti==1
                obj.trailInfo(2).startFrameN=insertFrameN(1);
                obj.trailInfo(2).endFrameN=insertFrameN(2);
                obj.trailInfo(2).amplitude=max(obj.data(insertFrameN(1):insertFrameN(2),2));
                if  obj.trailInfo(2).amplitude<0.01
                     obj.trailInfo(2).amplitude= obj.trailInfo(2).amplitude*100;
                end
                obj.data(insertFrameN(1):insertFrameN(2),3)=obj.trailInfo(2). amplitude;
                return;
            end
            
            if insertFrameN(1)<obj.trailInfo(1).startFrameN
                obj.trailInfo(2:end+1)=obj.trailInfo;
                obj.trailInfo(1).startFrameN=insertFrameN(1);
                obj.trailInfo(1).endFrameN=insertFrameN(2);
                obj.trailInfo(1).amplitude=max(obj.data(insertFrameN(1):insertFrameN(2),2));
                 if  obj.trailInfo(2).amplitude<0.01
                     obj.trailInfo(2).amplitude= obj.trailInfo(2).amplitude*100;
                end
                obj.data(insertFrameN(1):insertFrameN(2),3)=obj.trailInfo(1). amplitude;
            else
                for i=2:nSti
                    if  insertFrameN(1)<obj.trailInfo(i).startFrameN && insertFrameN(1)>obj.trailInfo(i-1).startFrameN
                        obj.trailInfo(i+1:end+1)=obj.trailInfo(i:end);
                        obj.trailInfo(i).startFrameN=insertFrameN(1);
                        obj.trailInfo(i).endFrameN=insertFrameN(2);
                        obj.trailInfo(i).amplitude=max(obj.data(insertFrameN(1):insertFrameN(2),2));
                        if  obj.trailInfo(2).amplitude<0.01
                            obj.trailInfo(2).amplitude= obj.trailInfo(2).amplitude*100;
                        end
                        obj.data(insertFrameN(1):insertFrameN(2),3)=obj.trailInfo(i). amplitude;
                        break;
                    end
                    
                    if i==nSti
                        obj.trailInfo(nSti+1).startFrameN=insertFrameN(1);
                        obj.trailInfo(nSti+1).endFrameN=insertFrameN(2);
                        obj.trailInfo(nSti+1).amplitude=max(obj.data(insertFrameN(1):insertFrameN(2),2));
                        obj.data(insertFrameN(1):insertFrameN(2),3)=obj.trailInfo(nSti+1). amplitude;
                    end
                end
            end
            
            
                     
            
        end
        %% function to detect stimulus pattern automatically 
        
         function detectPattern(obj,~, ~)
             
             nSti=length(obj.trailInfo); 
             
             stiLength=zeros(1,nSti);
             for i=1:nSti
                 stiLength(i)=obj.trailInfo(i). endFrameN-obj.trailInfo(i). startFrameN+1;
             end
             % due to the accuracy of stimulus detection, the length of each stimulus detected is not exact the same
             minLength=min(stiLength); 
            
             detectedStiData=zeros(minLength-1,nSti);
             for i=1:nSti
                 detectedStiData(1:minLength-1,i)=obj.data( obj.trailInfo(i). startFrameN+1: obj.trailInfo(i). startFrameN+minLength-1,2);
             end
             
             % To detect whether stimulus is the same  based on ANOVA
             [~,~,stats] = anova1(detectedStiData);
             differenceDetection=multcompare(stats);
             
             % Find stimulus id # which are not different statistically
             s=differenceDetection(find(differenceDetection(:,6)>0.05),1:2);
             p=size(s);
             
             curPat=1;
             obj.patternInfo=[];
             obj.patternInfo(1).trailN=s(1,:);
             
             if p(1)~=1
                 for i=2:length(s)
                     
                     patN=length(obj.patternInfo);
                     j=1;
                     while j<=patN
                         
                         if find(ismember(s(i,:),obj.patternInfo(j).trailN)==1)
                             obj.patternInfo(j).trailN=[obj.patternInfo(j).trailN,s(i,:)];
                             break;
                         end
                         j=j+1;
                         
                     end
                     
                     if j==patN+1
                         curPat=patN+1;
                         obj.patternInfo(curPat).trailN=s(i,:);
                     end
                     
                 end
             end
             
             for i=1:curPat
                 obj.patternInfo(i).trailN=unique(obj.patternInfo(i).trailN);
             end
             
             % make sure every stimulus is in a pattern
             for i=1:nSti
                 
                 patN=length(obj.patternInfo);
                 j=1;
                 while j<=patN
                     
                     if find(obj.patternInfo(j).trailN==i)
                         break;
                     end
                     j=j+1;
                     
                 end
                 
                 if j==patN+1
                     obj.patternInfo(patN+1).trailN=i;
                 end
                 
             end
                         
         end
         
         function showPatternParameter(obj,~,~)
             
             hpara= findobj('Name','Stimulus Pattern');
            if ~isempty(hpara)
                close('Stimulus Pattern');
            end
             
             if ~isempty(obj.patternInfo)
                 nPat=length(obj.patternInfo);
                 if ~isempty(obj.paraInfo)
                     for i=1:nPat
                         para(i)=obj.paraInfo(obj.patternInfo(i).trailN(1));
                     end
                 else
                     para=[];
                 end
                 hpara=stimPara(para, nPat);
                 waitfor(hpara.h.fig);
                 
                 obj.paraInfo=hpara.data;
                 for i=1:nPat
                     nTrail=length(obj.patternInfo(i).trailN);
                     for j=1:nTrail
                         obj.paraInfo(obj.patternInfo(i).trailN(j))=hpara.data(i);
                     end
                 end
                 
             end
             
         end
         
         function setPattern (obj,~, ~)
             
             prompt={'Enter Stimulus Pattern n'};
             dlg_title='Set Stimulus Pattern';
             num_lines=1;
             def={'0'};
             p=str2double(inputdlg(prompt,dlg_title,num_lines,def));
             
             nSti=1:length(obj.trailInfo); 
             for i=1:p-1                       
                 obj.patternInfo(i).trailN=nSti(find(mod(nSti, p)==i));
             end
             obj.patternInfo(p).trailN=nSti(find(mod(nSti, p)==0));
             
              plotPatternTrace(obj);
               showPatternParameter(obj);
             
             
         end 
         
          function autoPatternDetection(obj,~, ~)
              
               try
                  axes(obj.h.axes);cla;
                  plot(obj.data(:,2));hold on;
                  plot(obj.data(:,3),'Color','r');
              catch
                  detectStimulus(obj);
              end
              
              detectPattern(obj);
               plotPatternTrace(obj);
               showPatternParameter(obj);
              
          end
        
        %% function to detect stimulus pattern  manually 
        
          function manualPatternDetection (obj, ~, ~)
              
              try
                  axes(obj.h.axes);cla;
                  plot(obj.data(:,2));hold on;
                  plot(obj.data(:,3),'Color','r');
              catch
                  detectStimulus(obj);
              end
              
              nSti=length(obj.trailInfo);
              hpara=stimPara(obj.paraInfo, nSti);
              waitfor(hpara.h.fig);
              obj.paraInfo=hpara.data;
               updateStiPattern (obj);
               plotPatternTrace(obj);
          end
                  
         %function to show raw trace
         function showRawTrace (obj, ~, ~)
             
            axes(obj.h.axes);cla;
%             norSti=moving_average(obj.data(:,2),5);
%             plot(norSti);
            plot(obj.data(:,2));
            xlabel('Frame #'); ylabel('delta F/F');title('Raw');
         end
         
         %function to show fit trace
         function showFitTrace (obj, ~, ~)
             
            axes(obj.h.axes);cla;
            plot(obj.data(:,3),'Color','r');
            xlabel('Frame #'); ylabel('delta F/F');title('Fitted');
         end
         
         %function to show pattern trace
         function showPatternTrace (obj, ~, ~)
             
             if isempty(obj.patternInfo)
                 return;
             else
                 axes(obj.h.axes);cla;
                 patternTraceLength=obj.data(1,4);
                 plot(1:1:patternTraceLength,obj.data(2:patternTraceLength+1,4),'Color','g');
                 xlabel('Frame #'); ylabel('delta F/F');title('Pattern');
             end
         end
         
         % function to update and generate stimulus pattern
         function updateStiPattern (obj, ~, ~)
             
             
             nSti=length(obj.paraInfo);
             for n=1:nSti
                 if isempty(obj.patternInfo)
                     
                     % if no stimulus pattern existed, creat the first one
                     curPat=1;
%                      temp(1)=obj.data(n);
%                      obj.patternInfo=temp;
                     
%                      obj.patternInfo(curPat)=obj.data(n);
                     obj.patternInfo(curPat).trailN(1)=1;
                     m(1)=n;
                 else
                     patN=length(obj.patternInfo); % number of existing patterns
                     i=1;
                     while i<=patN
                         
                         info=obj.paraInfo(obj.patternInfo(i).trailN(1));
                         if isequal(info,obj.paraInfo(n)) % trail n is belong to pattern i
                             m(n)=i;
                             if find(obj.patternInfo(i).trailN==n)                % trail n is alreay in pattern i
                                 break;
                             end
                             patTrailN=length(obj.patternInfo(i).trailN);         % trail n is not in pattern i yet, add n
                             obj.patternInfo(i).trailN(patTrailN+1)=n;
                             break;
                         else
                             if find(obj.patternInfo(i).trailN==n)                % trail n is not in pattern i, but n in it, delete the number
                                 en=find(obj.patternInfo(i).trailN==n);
                                 obj.patternInfo(i).trailN(en)=[];
                             end
                             i=i+1;
                         end
                         
                         % trail n is not belong to any in the existing patterns, so
                         % creat a new pattern
                         if i==patN+1
                             curPat=patN+1;
                             m(n)=patN+1;
%                              obj.patternInfo(curPat)=obj.data(n);
                             obj.patternInfo(curPat).trailN(1)=n;
                         end
                     end
                 end
             end
             
             % if there is wrong n in some pattern, which is not belong to beyond the trailN (e.g, 20 stimulus total, but have # 21, 22 appears in some pattern, probably due to some update issue for threshold reset)
             trailArray=1:1:nSti;
             patN=length(obj.patternInfo);
             for i=1:patN
                 if find(ismember(obj.patternInfo(i).trailN,trailArray)==0)
                     delTrailN=find(ismember(obj.patternInfo(i).trailN,trailArray)==0);
                     obj.patternInfo(i).trailN(delTrailN)=[];
                 end
             end
             
             % if there is one in the existed pattern does not match any stimulus info (e.g, out of updated), delete this one
             if exist('m','var')
                 m(find(m==0))=[];
                 um=unique(m);
                 patarray=1:1:patN;
                 if find(ismember(patarray,um)==0)
                     delPatN=find(ismember(patarray,um)==0);
                     for j=1:length(delPatN)
                         obj.patternInfo(delPatN(j))=[];
                     end
                     obj.patternInfo = obj.patternInfo(~cellfun(@isempty, obj.patternInfo));
                 end
             end
             
        end
         
          function plotPatternTrace (obj, ~,~)
                 
             
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
             
             axes(obj.h.axes);cla;
             plot(1:1:patternTraceLength,patternTrace,'Color','g','LineWidth',2); title('Pattern'); axis auto;
         
          end
    end
    
end

