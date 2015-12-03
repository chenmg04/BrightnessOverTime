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
             
            %--------------------------------------------------------------
            % Build GUI
            obj.h.fig = figure('Name','Stimulus',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Toolbar','figure',...
                'Color','white',...
                'Units','pixels',...
                'Resize','off',...
                'CloseRequestFcn',@obj.closeMainFig);  
            
            %align stimulus gui with the main figure
            try
                dispfig=findobj('Tag','dispfig');
                set(obj.h.fig,'Position',[dispfig.Position(1) dispfig.Position(2)-350 512 250]);
            catch
                set(obj.h.fig,'Position', [300 40 512 250]);
            end
            
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
                'Label','Stimuli Onset',...
                'Accelerator','S',...
                'Separator','off',...
                'Callback',@obj.detectStimulus);
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
            delete(UT(1:6));delete(UT(8));
            delete(UT((end-4):end));                          
             
            % add icons
            path=fileparts(which('stim'));
            [X,map] = imread([path '\icons\last_used.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ch(ftb_ind),'CData',icon,'TooltipString','Use exact parameters from last opened stimulus','Separator','off','ClickedCallback',@obj.useLast);
            
            % 
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
            
            % plot stimulus
             obj.h.axes=axes(...
                'Parent',obj.h.fig,...
                'Position',[.12,.2,.83,.7]);
            
            try
                plot(obj.data(:,2),'Parent',obj.h.axes);xlim([0 length(obj.data(:,2))]);
            catch
                baseline=mean(obj.data(1:50,1)); 
                obj.data(:,2)=(obj.data(:,1)-baseline)/obj.data(1,1);
                plot(obj.data(:,2),'Parent',obj.h.axes);xlim([0 length(obj.data(:,2))]);
                xlabel('Frame #'); ylabel('delta F/F');title('Raw');
            end
             
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
            
            try
                hMain=findobj('Name','BrightnessOverTime');
                infoPanel=findobj(hMain, 'Tag','infopanel');
                set(infoPanel, 'String', 'Stimulus was saved!')
            catch
            end
                
            
        end
        
        %function to close main stimulus figure
        function closeMainFig(obj, hObject, ~)
            
            if ~isempty(findobj('Name','Stimulus Pattern'))
                close('Stimulus Pattern');
            end
            
            delete(hObject);
            obj.h.fig=[];
            obj.h.axes=[];
                
        end
        
      %% function to detect stimulus   
        function detectStimulus(obj, ~, ~)
            
            showRawTrace (obj);
            
%             prompt={'Enter Baseline Length','Enter N Folds of SD','Enter Threshold Value', 'Enter Filter n'};
            prompt={'Enter Data Range','Enter Threshold Value', 'Filter Data (Boxcar n)'};
            dlg_title='Threshold';
            num_lines=1;
            
            try
%                 def={num2str(obj.threshold(1)),num2str(obj.threshold(2)),num2str(obj.threshold(3)), num2str(obj.threshold(4))};
                def={obj.threshold{1},obj.threshold{2},obj.threshold{3}};
            catch
                def={['1:' num2str(length(obj.data))],'0.02','0'};
            end
            p=inputdlg(prompt,dlg_title,num_lines,def);
                        
            if isequal(obj.threshold,p)
                axes(obj.h.axes);
                hold on;
                plot(obj.data(:,3),'color','r');
                return;
            end
            
%             detectStiOnset(obj, p)
%         end
%        
%             function detectStiOnset(obj, p,~)
                
            obj.threshold=p;
            filtern=str2double(p{3});
            norSti=moving_average(obj.data(:,2),filtern);
            axes(obj.h.axes); cla; plot(norSti);   
%             baselineAve=mean(norSti(1:p(1)));
%             sd= std(norSti(1:p(1)));
           dataRange=str2num(p{1}); 
            nFrames=length(dataRange);
            s=zeros(); i=1;
%             if p(3)~=0
                for n=1:nFrames;
                    if abs(norSti(dataRange(n)))>str2double(p{2})
                        s(i)= n;
                        i=i+1;
                    end
                end
%             else
%                 for n=2:nFrames;
%                     if abs(norSti(n))>baselineAve+p(2)*sd
%                         s(i)= n;
%                         i=i+1;
%                     end
%                 end
%             end
            d=find(diff(s)~=1); 
            nSti=length(d)+1;
            
            startFrameN=[];
            endFrameN=[];
            startFrameN(1)=s(1)+filtern;
            startFrameN(2:nSti)=s(d+1)+filtern;          
            endFrameN(1:nSti-1)=s(d)-filtern;
            endFrameN(nSti)=s(end)-filtern;
            
            obj.trailInfo=[];  obj.data(:,3)=0;
            yLimits=get(obj.h.axes,'YLim');
             for i=1: nSti
                obj.trailInfo(i). startFrameN=startFrameN(i);
                obj.trailInfo(i). endFrameN=endFrameN(i);
                
                amplitude=mean(obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,2));
                if amplitude<0
                    obj.trailInfo(i). amplitude=yLimits(1)/2;
                else
                    obj.trailInfo(i). amplitude=yLimits(2)/2;
                end
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
            
            % insert new stimulus into the end
            nSti=length(obj.trailInfo);
            obj.trailInfo(nSti+1).startFrameN=insertFrameN(1);
            obj.trailInfo(nSti+1).endFrameN=insertFrameN(2);
            
            yLimits=get(obj.h.axes,'YLim');
            amplitude=mean(obj.data(obj.trailInfo(nSti+1). startFrameN:obj.trailInfo(nSti+1). endFrameN,2));
            if amplitude<0
                obj.trailInfo(nSti+1). amplitude=yLimits(1)/2;
            else
                obj.trailInfo(nSti+1). amplitude=yLimits(2)/2;
            end
            obj.data(insertFrameN(1):insertFrameN(2),3)=obj.trailInfo(nSti+1).amplitude;
            
            %sortrows
             mtrail=(squeeze(cell2mat(struct2cell(obj.trailInfo))))';
             if ~issorted(mtrail,'rows')
                 sortedmtrail=sortrows(mtrail);
                 for i=1:nSti+1
                     obj.trailInfo(i).startFrameN=sortedmtrail(i,1);
                     obj.trailInfo(i).endFrameN=sortedmtrail(i,2);
                     obj.trailInfo(i).amplitude=sortedmtrail(i,3);
                 end
             end
              axes(obj.h.axes);  cla;
              plot(obj.data(:,2)); hold on;    
              plot(obj.data(:,3),'color','r'); 

        end
       
        % function to set stimulus pattern
         function setPattern (obj,~, ~)
             
             prompt={'Enter:'};
             dlg_title='Set Stimulus Pattern';
             num_lines=1;
             def={'0'};
             p=inputdlg(prompt,dlg_title,num_lines,def);
             
             q=strsplit(p{1},';');
             % single scalar, e.g., 8, indicates 8 patterns, and the repeat
             % of patterns is 1-2-3-...1-2-3-...
             if length(q)==1
                 patN=str2double(p{1});
                 nSti=1:length(obj.trailInfo);
                 for i=1:patN-1
                     obj.patternInfo(i).trailN=nSti(find(mod(nSti, patN)==i));
                 end
                 obj.patternInfo(patN).trailN=nSti(find(mod(nSti, patN)==0));
             else
                 patN=length(q);
                 for i=1:patN
                 obj.patternInfo(i).trailN=str2num(q{i});
                 end
             end
             
              plotPatternTrace(obj);
              obj.paraInfo=[];
              showPatternParameter(obj);
             
         end    
        
         % function to show, edit stimulus pattern info
         function showPatternParameter(obj,~,~)
             
             hpara= findobj('Name','Stimulus Pattern');
            if ~isempty(hpara)
                close('Stimulus Pattern');
            end
             
             if ~isempty(obj.patternInfo)
                 nPat=length(obj.patternInfo);
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
                 hpara=stimPara(para, nPat);
                 waitfor(hpara.h.fig);
                 obj.paraInfo=hpara.data;
%                  for i=1:nPat
%                      nTrail=length(obj.patternInfo(i).trailN);
%                      for j=1:nTrail
%                          obj.paraInfo(obj.patternInfo(i).trailN(j))=hpara.data(i);
%                      end
%                  end
                 
             end
             
         end
         
        
                  
         %function to show raw trace
         function showRawTrace (obj, ~, ~)
             
            axes(obj.h.axes);cla;
            plot(obj.data(:,2));xlim([0 length(obj.data(:,2))]);
            xlabel('Frame #'); ylabel('delta F/F');title('Raw');
         end
         
         %function to show fit trace
         function showFitTrace (obj, ~, ~)
             
            axes(obj.h.axes);cla;
             plot(obj.data(:,2));xlim([0 length(obj.data(:,2))]);hold on;
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

