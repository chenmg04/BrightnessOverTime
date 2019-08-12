classdef stim < handle
    
    
    properties
        h
        
        threshold
        data % traces for stimulus
        trailInfo % trail info <startFrameN, endFrameN, stiAmp>
        patternInfo % pattern info
        paraInfo % stimulus parameters
        
    end
    
    methods
        function obj = stim (varargin)
            
            %--------------------------------------------------------------
            % Build GUI
            obj.h.fig = figure('Name','Stimulus',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Toolbar','none',...
                'Color','white',...
                'Units','pixels',...
                'Resize','on',...
                'CloseRequestFcn',@obj.closeMainFig);
            
            %align stimulus gui with the main figure
            try
                dispfig=findobj('Tag','dispfig');
                set(obj.h.fig,'Position',[dispfig.Position(1) 40 512 250]);
            catch
                set(obj.h.fig,'Position', [300 40 512 250]);
            end
            
            % File Menu
            fileMenu= uimenu(obj.h.fig,...
                'Label','File');
            uimenu(fileMenu,...
                'Label','Open',...
                'Callback',@obj.openStimulus);
            uimenu(fileMenu,...
                'Label','Save',...
                'Callback',@obj.saveStimulus);
            
            % Edit Menu
            editMenu= uimenu(obj.h.fig,...
                'Label','Edit');
            uimenu(editMenu,...
                'Label','Detect',...
                'Callback',@obj.detectStimulus);
            uimenu(editMenu,...
                'Label','Delete',...
                'Callback',@obj.deleteStimulus);
            uimenu(editMenu,...
                'Label','Insert',...
                'Callback',@obj.insertStimulus);
            uimenu(editMenu,...
                'Label','Pattern',...
                'Callback',@obj.setPattern);
            % Tools Menu
            toolsMenu = uimenu(obj.h.fig,...
                'Label','Tools');
            uimenu(toolsMenu,...
                'Label','Zoom In',...
                'Callback',@(src,evt)zoom(obj.h.fig,'on'));
            uimenu(toolsMenu,...
                'Label','Data cursor',...
                'Callback',@(src,evt)datacursormode(obj.h.fig,'on'));
            % View Menu
            viewMenu = uimenu(obj.h.fig,...
                'Label','View');
            uimenu(viewMenu,...
                'Label','Raw Trace',....
                'Callback',@obj.showRawTrace);
            uimenu(viewMenu,...
                'Label','Fitted Trace',...
                'Callback',@obj.showFitTrace);
            uimenu(viewMenu,...
                'Label','Pattern Trace',...
                'Callback',@obj.labelPatternTrace);
            uimenu(viewMenu,...
                'Label','Pattern Parameters',...
                'Callback',@obj.showPatternParameter);
            uimenu(viewMenu,...
                'Label','Original Data',....
                'Callback',@obj.showOriginal);
            
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
                
            else
                obj.data=[];
                choice=questdlg('No Stimulus File Found! Would you like to import stimulus file?',...
                    'Import Stimulus File',...
                    'No', 'Yes', 'Yes');
                switch choice
                    case 'Yes'
                        openStimulus(obj);
                    case 'No'
                        return;
                end
            end
            
            % plot stimulus
            obj.h.axes=axes(...
                'Parent',obj.h.fig,...
                'Position',[.12,.2,.83,.7]);
            
            if ~isempty(obj.trailInfo)
                showRawTrace(obj);
                nsti = length(obj.trailInfo);
                if ~isempty(obj.patternInfo)
                    npat = length(obj.patternInfo);
                    title(sprintf('%d Stimulus and %d Patterns', nsti, npat));
                else
                    title(sprintf('%d Stimulus', nsti));
                end
            else
                % some files very short, due to errors
                try
                   baseline=mode(obj.data(1:50,1));
                catch
                    baseline = obj.data(1,1);
                end
                
                % some files baseline are 0 due to some errors
                if baseline == 0
                    obj.data(:,2) = obj.data(:,1);
                else
                    obj.data(:,2)=(obj.data(:,1)-baseline)/obj.data(1,1);
                end
                showRawTrace(obj);
            end
          
        end
        
        
        function openStimulus(obj,~,~)
            
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
                    obj.data=b.data; % labchart files saved as .mat file
                end
            end
            
            if size(obj.data,2)==1
                %                 baseline=mean(obj.data(1:50,1));
                obj.data(:,2)=obj.data(:,1);
            end
            plot(obj.data(:,2),'Parent',obj.h.axes);xlim([0 length(obj.data(:,2))]);
        end
        
        function saveStimulus(obj,~,~)
            
            stidata.threshold=obj.threshold;
            stidata.data=obj.data;
            stidata.trailInfo=obj.trailInfo;
            stidata.patternInfo=obj.patternInfo;
            stidata.paraInfo=obj.paraInfo;
            
            imf = findobj('Tag', 'dispfig');
            filedir = imf.UserData;
            [~, filename]=fileparts(filedir);
            filename=['stim_' filename];
            filename=fullfile(filedir,filename);
            save(filename,'stidata');
            
            try
                hMain=findobj('Name','BrightnessOverTime');
                infoPanel=findobj(hMain, 'Tag','infopanel');
                set(infoPanel, 'String', 'Stimulus was saved!')
            catch
            end
            
            
            closeMainFig(obj);
            
        end
        
        %function to close main stimulus figure
        function closeMainFig(obj, ~, ~)
            
            if ~isempty(findobj('Name','Stimulus Pattern'))
                close('Stimulus Pattern');
            end
            
            delete(obj.h.fig);
            obj.h.fig=[];
            obj.h.axes=[];
            
        end
        
        % function to detect stimulus
        function detectStimulus(obj, ~, ~)
            
%             showRawTrace (obj);
            %
            prompt={'Enter Data Range','Enter Threshold Value', 'Filter Data (Boxcar n)'};
            dlg_title='Threshold';
            num_lines=1;
            %
            try
                def={obj.threshold{1},obj.threshold{2},obj.threshold{3}};
            catch
                def={['1:' num2str(length(obj.data))],'0.02','0'};
            end
            p=inputdlg(prompt,dlg_title,num_lines,def);
            %
            if isequal(obj.threshold,p)
                axes(obj.h.axes);
                hold on;
                plot(obj.data(:,3),'color','r');
                return;
            else
                obj.threshold = p;
            end
            
            % filter data and plot
            filtern=str2double(p{3});
            norSti=moving_average(obj.data(:,2),filtern);
            axes(obj.h.axes); cla; plot(norSti);
            
            % selected data range
            dataRange=str2num(p{1});
%             [nsti, startFrameN, endFrameN] = detectEvent(obj.data(dataRange,2), str2double(p{2}), 'positive');
            [nsti, startFrameN, endFrameN] = detectEvent(norSti(dataRange), str2double(p{2}), 'positive');
            %
            startFrameN=startFrameN+filtern+dataRange(1)-1;
            endFrameN=endFrameN-filtern+dataRange(1)-1;
            
            % plot detected
            obj.trailInfo=[];  obj.data(:,3)=0;
            yLimits=get(obj.h.axes,'YLim');
            for i=1: nsti
                obj.trailInfo(i). startFrameN=startFrameN(i);
                obj.trailInfo(i). endFrameN=endFrameN(i);
                
                amplitude=mean(obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,2));
                obj.trailInfo(i). amplitude=yLimits(2)/2;
                obj.data(obj.trailInfo(i). startFrameN:obj.trailInfo(i). endFrameN,3)=obj.trailInfo(i). amplitude;
                text(startFrameN(i),amplitude,sprintf('%d',i));
            end
            axes(obj.h.axes); hold on;
            plot(obj.data(:,3),'color','r'); title(sprintf('%d Stimulus Detected', nsti));
            
        end
        
        %
        function deleteStimulus (obj,~, ~)
            
            prompt = {'Enter Stimulus #, e.g., 8 or 8, 9'};
            dlg_title = 'Delete';
            num_lines = 1;
            def = {''};
            d = inputdlg(prompt,dlg_title,num_lines,def);
            n = str2num(d{1});
            
            m = 0; % none deleted initially
            for i = 1: length(n)
                ind = n(i) - m;
                obj.data(obj.trailInfo(ind).startFrameN:obj.trailInfo(ind).endFrameN,3)=0;
                obj.trailInfo(ind)=[];
                m = m + 1;
            end
            showFitTrace(obj);
        end
        
        %
        function insertStimulus (obj,~, ~)
            
            prompt={'Enter Start Frame #', 'Enter End Frame #'};
            dlg_title='Insert';
            num_lines=1;
            def={'0','0'};
            insertFrameN=inputdlg(prompt,dlg_title,num_lines,def);
            
            s=str2num(insertFrameN{1});
            n=str2num(insertFrameN{2});
            
            % insert new stimulus into the end
            nSti=length(obj.trailInfo);
            yLimits=get(obj.h.axes,'YLim');
            for i=1:length(s)
                obj.trailInfo(nSti+i).startFrameN=s(i);
                obj.trailInfo(nSti+i).endFrameN=n(i);

                % Make all amplitude as positive, and half of the
                % yLimit(1/25/2018)
                obj.trailInfo(nSti+i). amplitude=yLimits(2)/2;
                obj.data(s(i):n(i),3)=obj.trailInfo(nSti+i).amplitude;
            end
            %sortrows
            mtrail=(squeeze(cell2mat(struct2cell(obj.trailInfo))))';
            if ~issorted(mtrail,'rows')
                sortedmtrail=sortrows(mtrail);
                for i=1:nSti+length(s)
                    obj.trailInfo(i).startFrameN=sortedmtrail(i,1);
                    obj.trailInfo(i).endFrameN=sortedmtrail(i,2);
                    obj.trailInfo(i).amplitude=sortedmtrail(i,3);
                end
            end
           
            showFitTrace(obj);
        end
        
        
        
        % function to set stimulus pattern
        function setPattern (obj,~, ~)
            
            prompt={'Pattern:', 'Drug'};
            dlg_title='Set Stimulus Pattern';
            num_lines=1;
            
            m ='';
            if isempty(obj.patternInfo)
                def={'', ''};
            else
                m = num2str(obj.patternInfo(1).trailN);
                for i = 2:length(obj.patternInfo)
                    m = strcat(m, ';', num2str(obj.patternInfo(i).trailN));
                end
                def={m, ''};
            end
            p=inputdlg(prompt,dlg_title,num_lines,def);
            
            % 
            if isequal(m,p{1})
                return;
            end
            
            q=strsplit(p{1},';');
            % single scalar, e.g., 8, indicates 8 patterns, and the repeat
            % of patterns is 1-2-3-...1-2-3-...
            dc = str2double(p{2});
            obj.patternInfo=[];
            
            
            if length(q)==1
                patN=str2double(p{1});
                if isnan(dc) % no drugs performed
                    nSti=1:length(obj.trailInfo);
                    for i=1:patN-1
                        obj.patternInfo(i).trailN=nSti(find(mod(nSti, patN)==i));
                    end
                    obj.patternInfo(patN).trailN=nSti(find(mod(nSti, patN)==0));
                else
                    nStic = 1: dc -1; % with drugs, control
                    nStid = dc: length(obj.trailInfo); % drug
                    for i=1:patN-1
                        obj.patternInfo(i).trailN(1,:)=nStic(find(mod(nStic, patN)==i));
                        obj.patternInfo(i).trailN(2,:)=nStid(find(mod(nStid, patN)==i));
                    end
                    obj.patternInfo(patN).trailN(1,:)=nStic(find(mod(nStic, patN)==0));
                    obj.patternInfo(patN).trailN(2,:)=nStid(find(mod(nStid, patN)==0));
                end
            else
                patN=length(q);
                for i=1:patN
                    obj.patternInfo(i).trailN=str2num(q{i});
                end
            end
            
            labelPatternTrace(obj);
            
            % update auto fluorescence detector
            try
                hMain=findobj('Name','Auto Fluorescence Detector');
                patternbox=findobj(hMain, 'Tag','patternedit');
                set(patternbox, 'String', ['1:' num2str(length(obj.patternInfo))])
            catch
            end
            obj.paraInfo=[];
            
        end
        
        % function to show, edit stimulus pattern info
        function showPatternParameter(obj,~,~)
            
            hpara= findobj('Name','Stimulus Pattern');
            if ~isempty(hpara)
                %                 close('Stimulus Pattern');
                return;
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
            
            end
            
        end
        
        
        
        %function to show raw trace
        function showRawTrace (obj, ~, ~)
            
            axes(obj.h.axes);cla;
            plot(obj.data(:,2));axis auto; xlim([0 length(obj.data(:,2))]);
            xlabel('Frame #'); title('Raw');
        end
        
        % function to show fit trace
        function showFitTrace (obj, ~, ~)
            
            try
                axes(obj.h.axes);cla;
                plot(obj.data(:,2));xlim([0 length(obj.data(:,2))]);hold on;
                plot(obj.data(:,3),'Color','r');
                xlabel('Frame #');
            catch
            end
            
            nsti = length(obj.trailInfo);
            title(sprintf('%d Stimulus', nsti));
            for i = 1:nsti
                
                amplitude=mean(obj.data(obj.trailInfo(i).startFrameN:obj.trailInfo(i).endFrameN,2));
                text(obj.trailInfo(i).startFrameN,amplitude,sprintf('%d',i));
                
            end
        end
        
        % function to label traces as different patterns
        function labelPatternTrace(obj, ~, ~)
            showRawTrace(obj);
            
            patN = length(obj.patternInfo);
            title(sprintf('%d Stimulus Patterns', patN));
            for i = 1:patN
                ntrail = length(obj.patternInfo(i).trailN);
                for j = 1:ntrail
                    trail = obj.patternInfo(i).trailN(j);
                    amplitude=mean(obj.data(obj.trailInfo(trail). startFrameN:obj.trailInfo(trail). endFrameN,2));
                    text(obj.trailInfo(trail). startFrameN,amplitude,sprintf('%d',i));
                end
            end
            
        end
        
        
        % function to show original data for some inspection
        function showOriginal(obj,~,~)
            
            if ~isempty(obj.trailInfo)
                disp(' #   start  end  duration'); 
                for i = 1:length(obj.trailInfo)
                    duration = obj.trailInfo(i).endFrameN - obj.trailInfo(i).startFrameN +1;
                    fprintf('%2d % 6d,% 6d, %6d\n',i,obj.trailInfo(i).startFrameN,obj.trailInfo(i).endFrameN,duration);
                end
            end
%             obj.patternInfo;
        end
        
    end
    
end

