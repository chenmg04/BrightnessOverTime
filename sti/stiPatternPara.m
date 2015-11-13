function data=stiPatternPara(varargin)

if nargin==3
    data=varargin{1};
    num=varargin{2};
    pos =varargin{3};
elseif nargin==2
    data=varargin{1};
    num=varargin{2};
    pos =[0 200 0 250];
elseif nargin==0
    data=[];
    num=1;
    pos=[0 200 0 250];
end

% building gui
fig = figure('Name','Stimulus Pattern',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','none',...
    'Color','white',...
    'Units','pixels',...
    'Position',[pos(1)+532 pos(2) 240 pos(4)],...
    'Resize','off');
%                 'CloseRequestFcn',@obj.closePatternFig);

% creat pushtools
ht=uitoolbar(fig);
path=fileparts(which('addnotes'));

[X,map] = imread([path '\icons\file_open.gif']);
icon = ind2rgb(X,map);
uipushtool(ht,'CData',icon,'TooltipString','Open Notes','Separator','off','ClickedCallback',@importPattern);

[X,map] = imread([path '\icons\file_save.gif']);
icon = ind2rgb(X,map);
uipushtool(ht,'CData',icon,'TooltipString','Save Notes','Separator','off', 'ClickedCallback',@savePattern);

stiProperties  =uipanel('Title','',...
    'Parent', fig,...
    'FontSize',9,...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 40 220 200]);

tab = uitabpanel(...
    'Parent',stiProperties,...
    'TitleForegroundColor',[0 0 0],...
    'FrameBackgroundColor',[0.9412 0.9412 0.9412],...
    'TitleBackgroundColor',[0.8 0.8 0.8],...
    'PanelBackgroundColor',[1 1 1],...
    'TabPosition','lefttop',...
    'Position',[0,0,1,1],...
    'Margins',{[0,-1,1,0],'pixels'},...
    'PanelBorderType','line',...
    'Title',{'Parameters','Motion'});

stiList               =uicontrol('Style','listbox',...
    'Parent',stiProperties,...
    'Value',1,...
    'String',1:1:num,...
    'BackgroundColor','white',...
    'Position',[5 5 50 160],...
    'Callback',@selectStiList);

hpanel = getappdata(tab,'panels');

% panel 1, parameters
stiTypeTxt            =uicontrol('Style','text',...
    'String','Type:',...
    'BackgroundColor','white',...
    'Position',[110 130 30 20],...
    'Parent',hpanel(1));
stiTypeEdit           =uicontrol('Style','popupmenu',...
    'String','Select|Circle|Rectangle',...
    'BackgroundColor','white',...
    'Position',[145 134 60 20],...
    'Parent',hpanel(1),...
    'Callback',@stiType);
stiDurationTxt        =uicontrol('Style','text',...
    'String','Duration:',...
    'BackgroundColor','white',...
    'Position',[87 100 60 20],...
    'Parent',hpanel(1));
stiDurationEdit       =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 104 60 20],...
    'Parent',hpanel(1),...
    'Callback',@stiDuration);
stiRadiusTxt            =uicontrol('Style','text',...
    'String','Radius:',...
    'BackgroundColor','white',...
    'Position',[100 70 40 20],...
    'Visible', 'off',...
    'Parent',hpanel(1));
stiRadiusEdit           =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 74 60 20],...
    'Visible', 'off',...
    'Parent',hpanel(1),...
    'Callback',@stiRadius);
stiWidthTxt            =uicontrol('Style','text',...
    'String','Width:',...
    'BackgroundColor','white',...
    'Position',[107 70 30 20],...
    'Visible', 'off',...
    'Parent',hpanel(1));
stiWidthEdit           =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 74 60 20],...
    'Visible', 'off',...
    'Parent',hpanel(1),...
    'Callback',@stiWidth);
stiHeightTxt            =uicontrol('Style','text',...
    'String','Height:',...
    'BackgroundColor','white',...
    'Position',[102 40 40 20],...
    'Visible', 'off',...
    'Parent',hpanel(1));
stiHeightEdit           =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 44 60 20],...
    'Visible', 'off',...
    'Parent',hpanel(1),...
    'Callback',@stiHeight);

% panel 2, motion
movTypeTxt            =uicontrol('Style','text',...
    'String','Type:',...
    'BackgroundColor','white',...
    'Position',[110 130 30 20],...
    'Parent',hpanel(2));
movTypeEdit           =uicontrol('Style','popupmenu',...
    'String','None|Smooth',...
    'BackgroundColor','white',...
    'Position',[145 134 60 20],...
    'Parent',hpanel(2),...
    'Callback',@movType);
movDirectionTxt    =uicontrol('Style','text',...
    'String','Move Direction:',...
    'BackgroundColor','white',...
    'Position',[55 70 90 20],...
    'Visible','off',...
    'Parent',hpanel(2));
movDirectionEdit   =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 74 60 20],...
    'Visible','off',...
    'Parent',hpanel(2),...
    'Callback',@movDirection);
movSpeedTxt        =uicontrol('Style','text',...
    'String','Move Speed:',...
    'BackgroundColor','white',...
    'Position',[68 40 75 20],...
    'Visible','off',...
    'Parent',hpanel(2));
movSpeedEdit       =uicontrol('Style','Edit',...
    'String','0',...
    'BackgroundColor','white',...
    'Position',[145 44 60 20],...
    'Visible','off',...
    'Parent',hpanel(2),...
    'Callback',@movSpeed);

% Buttons
stiUpdateButton             =uicontrol('Style','pushbutton',...
    'String','OK',...
    'BackgroundColor','white',...
    'Position',[160 10 60 25],...
    'Parent',fig,...
    'Callback',@updateStiPattern);
stiResetButton               =uicontrol('Style','pushbutton',...
    'String','Reset',...
    'BackgroundColor','white',...
    'Position',[90 10 60 25],...
    'Parent',fig,...
    'Callback',@resetStiPattern);
setAllButton              =uicontrol('Style','pushbutton',...
    'String','Set All',...
    'BackgroundColor','white',...
    'Position',[20 10 60 25],...
    'Parent',fig,...
    'Callback',@setAll);
% Initiation
if ~isempty(data)
    %             if isfield (obj.data(1),'stiType')
    selectStiType=data(1).stiType;
    set(stiTypeEdit,'Value',selectStiType);setStiSizeCtrBoxes (selectStiType,1);
    selectMovType=data(1).movType;
    set(movTypeEdit,'Value',selectMovType);setMovCtrBoxes(selectMovType, 1);
    set(stiDurationEdit,'String',data(1).duration);
    
else
    for i=1:num
        data(i).stiType=1;
        data(i).movType=1;
        data(i).duration=0;
        data(i).size=[];
    end
end

% wait
waitfor(fig);

    function []=importPattern (varargin)
        
        defaultPathname=[path '\Stim Pattern Library'];
        [filename, pathname] = uigetfile('*.mat','Select file',defaultPathname);
        if isequal(filename,0) || isequal(pathname,0)
            return;
        end
        fullfilename=fullfile(pathname, filename);
        p=load(fullfilename);
        data=p.patterndata;
        selectStiType=data(1).stiType;
        set(stiTypeEdit,'Value',selectStiType);setStiSizeCtrBoxes (selectStiType,1);
        selectMovType=data(1).movType;
        set(movTypeEdit,'Value',selectMovType);setMovCtrBoxes(selectMovType, 1);
        set(stiDurationEdit,'String',data(1).duration);
    end

    function []=savePattern (varargin)
        defaultPathname=[path '\Stim Pattern Library'];
        [filename, pathname] = uiputfile('*.mat','Save as',defaultPathname);
        if isequal(filename,0) || isequal(pathname,0)
            return;
        end
        fullfilename=fullfile(pathname, filename);
        patterndata=data;
        save(fullfilename,'patterndata');
        
    end

    function []=stiType(varargin)
        
        selectType=get(stiTypeEdit,'Value');
        selectIndex=get(stiList,'Value');
        data(selectIndex).stiType=selectType;
        setStiSizeCtrBoxes (selectType, selectIndex);
    end

    function []=setStiSizeCtrBoxes(selectType, index)
        
        if selectType==2
            set(stiRadiusTxt,'Visible','on');
            set(stiRadiusEdit,'Visible','on');
            
            try
                set(stiRadiusEdit,'String',data(index).size(1));
            catch
                set(stiRadiusEdit,'String','0');
            end
            
            try
                data(index).size(2)=[];
            catch
            end
            
            set(stiWidthTxt,'Visible','off');
            set(stiWidthEdit,'Visible','off','String','0');
            set(stiHeightTxt,'Visible','off');
            set(stiHeightEdit,'Visible','off','String','0');
            
        elseif selectType==3
            set(stiWidthTxt,'Visible','on');
            set(stiWidthEdit,'Visible','on');
            set(stiHeightTxt,'Visible','on');
            set(stiHeightEdit,'Visible','on');
            
            try
                set(stiWidthEdit,'String',data(index).size(1));
            catch
                set(stiWidthEdit,'String','0');
            end
            
            try
                set(stiHeightEdit,'String',data(index).size(2));
            catch
                set(stiHeightEdit,'String','0');
            end
            
            set(stiRadiusTxt,'Visible','off');
            set(stiRadiusEdit,'Visible','off','String','0');
            
        else
            set(stiRadiusTxt,'Visible','off');
            set(stiRadiusEdit,'Visible','off','String','0');
            set(stiWidthTxt,'Visible','off');
            set(stiWidthEdit,'Visible','off','String','0');
            set(stiHeightTxt,'Visible','off');
            set(stiHeightEdit,'Visible','off','String','0');
        end
    end
% function to change stimulus duration
    function []=stiDuration (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).duration=get(stiDurationEdit,'String');
    end
% function to change stimulus radius
    function []=stiRadius (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).size=[];
        data(selectIndex).size=str2double(get(stiRadiusEdit,'String'));
    end
% function to change stimulus width
    function []=stiWidth (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).size(1)=str2double(get(stiWidthEdit,'String'));
    end
% function to change stimulus height
    function []=stiHeight (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).size(2)=str2double(get(stiHeightEdit,'String'));
    end
% function to change motion type
    function []=movType(varargin)
        
        selectType=get(movTypeEdit,'Value');
        selectIndex=get(stiList,'Value');
        data(selectIndex).movType=selectType;
        setMovCtrBoxes(selectType, selectIndex)
    end

    function []=setMovCtrBoxes (selectType, index)
        
        if selectType==1
            set(movDirectionTxt,'Visible','off');
            set(movDirectionEdit,'Visible','off','String','0');
            set(movSpeedTxt,'Visible','off');
            set(movSpeedEdit,'Visible','off','String','0');
        else
            set(movDirectionTxt,'Visible','on');
            set(movDirectionEdit,'Visible','on');
            set(movSpeedTxt,'Visible','on');
            set(movSpeedEdit,'Visible','on');
            
            if isfield(data(index),'mov')
                if isfield(data(index).mov,'direction')
                    set(movDirectionEdit,'String',data(index).mov.direction);
                else
                    set(movDirectionEdit,'String','0');
                end
                
                if isfield(data(index).mov,'speed')
                    set(movSpeedEdit,'String',data(index).mov.speed);
                else
                    set(movSpeedEdit,'String','0');
                end
            else
                set(movDirectionEdit,'String','0');
                set(movSpeedEdit,'String','0');
            end
        end
        
    end

% function to change motion direction
    function []=movDirection (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).mov.direction=get(movDirectionEdit,'String');
    end

% function to change motion speed
    function []=movSpeed (varargin)
        
        selectIndex=get(stiList,'Value');
        data(selectIndex).mov.speed=get(movSpeedEdit,'String');
    end

% function to select different sti
    function []=selectStiList (varargin)
        
        selectIndex=get(stiList,'Value');
        selectStiType=data(selectIndex).stiType;
        set(stiTypeEdit,'Value',selectStiType); setStiSizeCtrBoxes (selectStiType,selectIndex);
        
        selectMovType=data(selectIndex).movType;
        set(movTypeEdit,'Value',selectMovType); setMovCtrBoxes(selectMovType,selectIndex);
        
        set(stiDurationEdit,'String',data(selectIndex).duration);
    end

% function to set all stimulus the same
    function []=setAll(varargin)
        
        selectIndex=get(stiList,'Value');
        
        for j=1:length(data)
            if j~=selectIndex
                data(j).stiType=data(selectIndex).stiType;
                data(j).movType=data(selectIndex).movType;
                data(j).duration=data(selectIndex).duration;
                data(j).size=data(selectIndex).size;
                
                if isfield(data(selectIndex),'mov')
                    data(j).mov=data(selectIndex).mov;
                end
            end
        end
        
    end

% function to reset stimulus parameters
    function []=resetStiPattern (varargin)
        
        %              obj.data=[];
        for j=1:length(data)
            data(j).stiType=1;
            data(j).movType=1;
            data(j).duration=0;
            data(j).size=[];
        end
        
        set(stiTypeEdit,'Value',1);setStiSizeCtrBoxes (1,1);
        set(movTypeEdit,'Value',1);setMovCtrBoxes(1,1);
        set(stiDurationEdit,'String','0');
        
    end

% function to update and generate stimulus pattern
    function []=updateStiPattern (varargin)
        
        delete(fig);
    end
end