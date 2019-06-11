function stiobj=stiToolBox(varargin)



% Build GUI
fig = figure('Name','Stimulus',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','none',...
    'Color','white',...
    'Units','pixels',...
    'Resize','on');
%     'CloseRequestFcn',@closeMainFig);

% Align stimulus gui with the main figure
try
    dispfig=findobj('Tag','dispfig');
    set(fig,'Position',[dispfig.Position(1) dispfig.Position(2)-350 512 250]);
catch
    set(fig,'Position', [300 40 512 250]);
end

% File Menu
fileMenu= uimenu(fig,...
    'Label','File');
uimenu(fileMenu,...
    'Label','Open',...
    'Callback',@openStimulus);
uimenu(fileMenu,...
    'Label','Save',...
    'Callback',@saveStimulus);

% Edit Menu
editMenu= uimenu(fig,...
    'Label','Edit');
uimenu(editMenu,...
    'Label','Detect',...
    'Callback',@detectStimulus);
uimenu(editMenu,...
    'Label','Insert',...
    'Callback',@insertStimulus);
uimenu(editMenu,...
    'Label','Pattern',...
    'Callback',@setPattern);

% Tools Menu
toolsMenu = uimenu(fig,...
    'Label','Tools');
uimenu(toolsMenu,...
    'Label','Zoom In',...
    'Callback',@(src,evt)zoom(fig,'on'));
uimenu(toolsMenu,...
    'Label','Data cursor',...
    'Callback',@(src,evt)datacursormode(fig,'on'));

% View Menu
viewMenu = uimenu(fig,...
    'Label','View');
uimenu(viewMenu,...
    'Label','Raw Trace',....
    'Callback',@showRawTrace);
uimenu(viewMenu,...
    'Label','Fitted Trace',...
    'Callback',@showFitTrace);
% uimenu(viewMenu,...
%     'Label','Pattern Trace',...
%     'Callback',@showPatternTrace);
% uimenu(viewMenu,...
%     'Label','Pattern Parameters',...
%     'Callback',@showPatternParameter);



% Initialization
if nargin
    stiobj=varargin{1};
else
    stiobj=sti;
end

haxes=axes(...
    'Parent',fig,...
    'Position',[.15,.2,.8,.7]);

if ~isempty(stiobj.data)
    try
        stiobj.showTrace(haxes,'Raw');
    catch
        baseline=mean(stiobj.data(1:50,1));
        stiobj.data(:,2)=(stiobj.data(:,1)-baseline)/stiobj.data(1,1);
        stiobj.showTrace(haxes,'Raw');
    end
end


%% Callback functions
    function openStimulus(varargin)
        
        stiobj.load;
        stiobj.showTrace(haxes,'Raw');
    end

    function saveStimulus(varargin)
        
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
    function detectStimulus(varargin)
        
        stiobj.showTrace(haxes,'Raw');
        
        prompt={'Enter Data Range','Enter Threshold Value', 'Filter Data (Boxcar n)'};
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
    function setPattern(varargin)
        
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
%     function showPatternTrace (varargin)
%         
%         if isempty(stiobj.patternInfo)
%             return;
%         else
%             stiobj.showTrace(haxes,'Pattern');
%         end
%     end

%function to show pattern parameter
%     function showPatternParameter(varargin)
%         if ~isempty(stiobj.patternInfo)
%             patN=length(stiobj.patternInfo);
%             pos=get(fig,'Position');
%             stiobj.paraInfo=stiPatternPara(stiobj.paraInfo,patN,pos);
%         end
%     end


end