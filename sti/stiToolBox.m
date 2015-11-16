function stiobj=stiToolBox(varargin)



% Build GUI
fig = figure('Name','Stimulus',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','figure',...
    'Color','white',...
    'Units','pixels',...
    'Position',[426 20 512 250],...
    'Resize','off');
%                 'CloseRequestFcn',@closeMainFig);

% File Menu
fileMenu= uimenu(fig,...
    'Label','File',...
    'Tag','file menu');
uimenu(fileMenu,...
    'Label','Open...',...
    'Separator','off',...
    'Callback',@openStimulus);
uimenu(fileMenu,...
    'Label','Save',...
    'Separator','off',...
    'Callback',@saveStimulus);
% Detect Menu
detectMenu = uimenu(fig,...
    'Label','Detect',...
    'Tag','detect menu');
uimenu(detectMenu,...
    'Label','Stimuli Onset',...
    'Separator','off',...
    'Callback',@detectStimulus);

% Edit Menu
editMenu= uimenu(fig,...
    'Label','Edit',...
    'Tag','detect menu');
uimenu(editMenu,...
    'Label','Set Pattern',...
    'Separator','off',...
    'Callback',@setPattern);
uimenu(editMenu,...
    'Label','Insert Stimulus',...
    'Separator','off',...
    'Callback',@insertStimuli);

% View Menu
viewMenu = uimenu(fig,...
    'Label','View',...
    'Tag','view menu');
uimenu(viewMenu,...
    'Label','Raw Trace',...
    'Separator','off',...
    'Callback',@showRawTrace);
uimenu(viewMenu,...
    'Label','Fitted Trace',...
    'Separator','off',...
    'Callback',@showFitTrace);
uimenu(viewMenu,...
    'Label','Pattern Trace',...
    'Separator','off',...
    'Callback',@showPatternTrace);
uimenu(viewMenu,...
    'Label','Pattern Parameter',...
    'Separator','off',...
    'Callback',@showPatternParameter);

% delete uncessary Toolbar
set(0,'Showhidden','on');
ch = get(fig,'children');
chatags=get(ch,'Tag');
ftb_ind=find(strcmp(chatags,'FigureToolBar'));
UT = get(ch(ftb_ind),'children');
delete(UT(1:8));
delete(UT((end-4):end));

haxes=axes(...
    'Parent',fig,...
    'Position',[.15,.2,.8,.7]);

if nargin
    stiobj=varargin{1};
else
    stiobj=sti;
end

if ~isempty(stiobj.data)
    try
        stiobj.showTrace(haxes,'Raw');
    catch
        baseline=mean(stiobj.data(1:50,1));
        stiobj.data(:,2)=(stiobj.data(:,1)-baseline)/stiobj.data(1,1);
        stiobj.showTrace(haxes,'Raw');
    end
end
%
    function []=openStimulus(varargin)
        
        stiobj.loadData;
        stiobj.showTrace(haxes,'Raw');
    end

    function []=saveStimulus(varargin)
        
        % add into sti class methods (to do)
        stidata.threshold=stiobj.threshold;
        stidata.data=stiobj.data;
        stidata.trailInfo=stiobj.trailInfo;
        stidata.patternInfo=stiobj.patternInfo;
        stidata.paraInfo=stiobj.paraInfo;
        
        pathname=cd;
        [~, filename]=fileparts(pathname);
        filename=['stim_' filename];
        filename=fullfile(pathname,filename);
        save(filename,'stidata');
    end

% function to detect stimulus
    function []=detectStimulus(varargin)
        
        stiobj.showTrace(haxes,'Raw');
        
        prompt='Enter Threshold Value';
        dlg_title='Threshold';
        num_lines=1;
        
        try
            def={num2str(stiobj.threshold)};
        catch
            def={'0'};
        end
        p=str2double(inputdlg(prompt,dlg_title,num_lines,def));
        
        if isequal(stiobj.threshold,p)
            return;
        end
        
        stiobj.manDetStiOnset(p);
        stiobj.showTrace(haxes,'Fit');
    end

    % function to set stimulus pattern
    function []=setPattern(varargin)
        
        prompt={'Enter Stimulus Pattern n'};
        dlg_title='Set Stimulus Pattern';
        num_lines=1;
        if ~isempty(stiobj.patternInfo)
            def={num2str(length(stiobj.patternInfo))};
        else
            def={'0'};
        end
        I=inputdlg(prompt,dlg_title,num_lines,def);
        p=str2num(I{1});
        stiobj.setStiPattern(p);
        showPatternParameter();
%         patN=length(stiobj.patternInfo);
%         pos=get(fig,'Position');
%         stiobj.paraInfo=stiPatternPara(stiobj.paraInfo,patN,pos);
    end

%function to show raw trace
    function []=showRawTrace(varargin)
        
        stiobj.showTrace(haxes,'Raw');
    end

%function to show fit trace
    function []=showFitTrace (varargin)
        
        stiobj.showTrace(haxes,'Fit');
    end

%function to show pattern trace
    function showPatternTrace (varargin)
          
        if isempty(stiobj.patternInfo)
            return;
        else
            stiobj.showTrace(haxes,'Pattern');
        end
    end
%function to show pattern parameter
    function showPatternParameter(varargin)
        if ~isempty(stiobj.patternInfo)
            patN=length(stiobj.patternInfo);
            pos=get(fig,'Position');
            stiobj.paraInfo=stiPatternPara(stiobj.paraInfo,patN,pos);
        end
    end


end