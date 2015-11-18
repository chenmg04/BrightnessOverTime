classdef stimPara < handle
    
    properties    
        h
    end
    
    properties
        data
%         para
%         patternInfo
    end
    
    methods
        
        function obj = stimPara (data, num)
            
                      obj.data=data; % input data, data / patternInfo
           
            %--------------------------------------------------------------
            % build GUI
            stimFig=findobj('Name','Stimulus');
            mainFigPosition=get(stimFig,'Position');
            
            obj.h.fig = figure('Name','Stimulus Pattern',...
                'NumberTitle','off',...
                'MenuBar','none',...
                'Toolbar','none',...
                'Color','white',...
                'Units','pixels',...
                'Position',[mainFigPosition(1)+532 mainFigPosition(2) 240 mainFigPosition(4)],...
                'Resize','off',...
                'CloseRequestFcn',@obj.closePatternFig);
            
            ht=uitoolbar(obj.h.fig);
            
            path=fileparts(which('stim'));
            
            [X,map] = imread([path '\icons\file_open.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','Import Stimulus Pattern','Separator','off','ClickedCallback',@obj.importPattern);
            
            [X,map] = imread([path '\icons\file_save.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','Save Stimulus Pattern as','Separator','off','ClickedCallback',@obj.savePattern);                              
            
            stiProperties         =uipanel('Title','',...
                'Parent', obj.h.fig,...
                'FontSize',9,...
                'BackgroundColor','white',...
                'Units','pixels',...
                'Position',[10 40 220 200]);
            
            obj.h.tab = uitabpanel(...
                'Parent',stiProperties,...
                'TitleForegroundColor',[0 0 0],...
                'FrameBackgroundColor',[0.9412 0.9412 0.9412],...
                'TitleBackgroundColor',[0.8 0.8 0.8],... 
                'PanelBackgroundColor',[1 1 1],...
                'TabPosition','lefttop',...
                'Position',[0,0,1,1],...
                'Margins',{[0,-1,1,0],'pixels'},...
                'PanelBorderType','line',...
                'Title',{'Para','Motion','Position','Contrast'});
            
            obj.h.stiList               =uicontrol('Style','listbox',...
                'Parent',stiProperties,...
                'Value',1,...
                'String',1:1:num,...
                'BackgroundColor','white',...
                'Position',[5 5 50 160],...
                'Callback',@obj.selectStiList);
            
            hpanel = getappdata(obj.h.tab,'panels');
            
            % panel 1, parameters
            obj.h.stiTypeTxt            =uicontrol('Style','text',...
                'String','Type:',...
                'BackgroundColor','white',...
                'Position',[100 130 40 20],...
                'Parent',hpanel(1));
            obj.h.stiTypeEdit           =uicontrol('Style','popupmenu',...
                'String','Select|Circle|Rectangle',...
                'BackgroundColor','white',...
                'Position',[145 134 60 20],...
                'Parent',hpanel(1),...
                'Callback',@obj.stiType);
            obj.h.stiDurationTxt        =uicontrol('Style','text',...
                'String','Duration:',...
                'BackgroundColor','white',...
                'Position',[80 100 60 20],...
                'Parent',hpanel(1));
            obj.h.stiDurationEdit       =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 104 60 20],...
                'Parent',hpanel(1),...
                'Callback',@obj.stiDuration);
            obj.h.stiRadiusTxt            =uicontrol('Style','text',...
                'String','Radius:',...
                'BackgroundColor','white',...
                'Position',[90 70 50 20],...
                'Visible', 'off',...
                'Parent',hpanel(1));                                  
            obj.h.stiRadiusEdit           =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 74 60 20],...
                'Visible', 'off',...
                'Parent',hpanel(1),...
                'Callback',@obj.stiRadius);
            obj.h.stiWidthTxt            =uicontrol('Style','text',...
                'String','Width:',...
                'BackgroundColor','white',...
                'Position',[92 70 50 20],...
                'Visible', 'off',...
                'Parent',hpanel(1));                                  
            obj.h.stiWidthEdit           =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 74 60 20],...
                'Visible', 'off',...
                'Parent',hpanel(1),...
                'Callback',@obj.stiWidth);
            obj.h.stiHeightTxt            =uicontrol('Style','text',...
                'String','Height:',...
                'BackgroundColor','white',...
                'Position',[90 40 50 20],...
                'Visible', 'off',...
                'Parent',hpanel(1));                                  
            obj.h.stiHeightEdit           =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 44 60 20],...
                'Visible', 'off',...
                'Parent',hpanel(1),...
                'Callback',@obj.stiHeight);                        
            
            % panel 2, motion
            obj.h.movTypeTxt            =uicontrol('Style','text',...
                'String','Type:',...
                'BackgroundColor','white',...
                'Position',[100 130 40 20],...
                'Parent',hpanel(2));
            obj.h.movTypeEdit           =uicontrol('Style','popupmenu',...
                'String','None|Smooth',...
                'BackgroundColor','white',...
                'Position',[145 134 60 20],...
                'Parent',hpanel(2),...
                'Callback',@obj.movType);
             obj.h.movDirectionTxt    =uicontrol('Style','text',...
                'String','Move Direction:',...
                'BackgroundColor','white',...
                'Position',[55 70 90 20],...
                'Visible','off',...
                'Parent',hpanel(2));
            obj.h.movDirectionEdit   =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 74 60 20],...
                'Visible','off',...
                'Parent',hpanel(2),...
                'Callback',@obj.movDirection);
            obj.h.movSpeedTxt        =uicontrol('Style','text',...
                'String','Move Speed:',...
                'BackgroundColor','white',...
                'Position',[68 40 75 20],...
                'Visible','off',...
                'Parent',hpanel(2));
            obj.h.movSpeedEdit       =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 44 60 20],...
                'Visible','off',...
                'Parent',hpanel(2),...
                'Callback',@obj.movSpeed);
            
            % Panel 3, position
            obj.h.posXTxt        =uicontrol('Style','text',...
                'String','X:',...
                'BackgroundColor','white',...
                'Position',[87 100 60 20],...
                'Parent',hpanel(3));
            obj.h.posXEdit       =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 104 60 20],...
                'Parent',hpanel(3),...
                'Callback',@obj.posX);
            obj.h.posYTxt            =uicontrol('Style','text',...
                'String','Y:',...
                'BackgroundColor','white',...
                'Position',[100 70 40 20],...
                'Parent',hpanel(3));                                  
            obj.h.posYEdit           =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 74 60 20],...
                'Parent',hpanel(3),...
                'Callback',@obj.posY);
            
            % Panel 4, contrast
            obj.h.bckTxt        =uicontrol('Style','text',...
                'String','Background:',...
                'BackgroundColor','white',...
                'Position',[55 100 90 20],...
                'Parent',hpanel(4));
            obj.h.bckEdit       =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 104 60 20],...
                'Parent',hpanel(4),...
                'Callback',@obj.bckb);
            obj.h.objTxt            =uicontrol('Style','text',...
                'String','Object:',...
                'BackgroundColor','white',...
                'Position',[90 70 50 20],...
                'Parent',hpanel(4));                                  
            obj.h.objEdit           =uicontrol('Style','Edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[145 74 60 20],...
                'Parent',hpanel(4),...
                'Callback',@obj.objb);
            
            % Buttons
            obj.h.stiUpdate             =uicontrol('Style','pushbutton',...
                'String','OK',...
                'BackgroundColor','white',...
                'Position',[160 10 60 25],...
                'Parent',obj.h.fig,...
                'Callback',@obj.updateStiPattern);
            obj.h.stiReset              =uicontrol('Style','pushbutton',...
                'String','Reset',...
                'BackgroundColor','white',...
                'Position',[90 10 60 25],...
                'Parent',obj.h.fig,...
                'Callback',@obj.resetStiPattern);
            obj.h.setAll              =uicontrol('Style','pushbutton',...
                'String','Set All',...
                'BackgroundColor','white',...
                'Position',[20 10 60 25],...
                'Parent',obj.h.fig,...
                'Callback',@obj.setAll);
            
            % Initiation
            if ~isempty(obj.data)
%             if isfield (obj.data(1),'stiType')
                    selectStiType=obj.data(1).stiType;
                    set(obj.h.stiTypeEdit,'Value',selectStiType);setStiSizeCtrBoxes (obj,selectStiType,1);
                    selectMovType=obj.data(1).movType;
                    set(obj.h.movTypeEdit,'Value',selectMovType);setMovCtrBoxes(obj, selectMovType, 1);
                    set(obj.h.stiDurationEdit,'String',obj.data(1).duration);  
                    if isfield(obj.data(1), 'position')
                        set(obj.h.posXEdit,'String',obj.data(1).position(1));
                        set(obj.h.posXEdit,'String',obj.data(1).position(2));
                    else
                        for i=1:num % position was added later;
                            obj.data(i).position(1)=0;
                            obj.data(i).position(2)=0;
                        end
                    end
                    
                    if isfield(obj.data(1), 'contrast')
                        set(obj.h.bckEdit,'String',obj.data(1).contrast(1));
                        set(obj.h.objEdit,'String',obj.data(1).contrast(2));
                    else
                        for i=1:num %contrast was added later;
                            obj.data(i).contrast(1)=0;
                            obj.data(i).contrast(2)=0;
                        end
                    end
            else
                for i=1:num
                    obj.data(i).stiType=1; 
                    obj.data(i).movType=1;
                    obj.data(i).duration=0;
                    obj.data(i).size=[];
                    obj.data(i).position(1)=0;
                    obj.data(i).position(2)=0;
                    obj.data(i).contrast(1)=0;
                    obj.data(i).contrast(2)=0;
                end
            end
        end
        
        %------------------------------------------------------------------
        %%function to close pattern figure
        function closePatternFig (obj, hObject, ~)
            
            obj.h=[];
            delete(hObject);
        end
        
        function importPattern (obj, ~, ~)
            
            defaultPathname='C:\Users\Minggang\Documents\MATLAB\Stim Pattern Library';
            [filename, pathname] = uigetfile('*.mat','Select file',defaultPathname);
            if isequal(filename,0) || isequal(pathname,0)
                return;
            end
            fullfilename=fullfile(pathname, filename);
            load(fullfilename);
            obj.data=patterndata;
            selectStiType=obj.data(1).stiType;
            set(obj.h.stiTypeEdit,'Value',selectStiType);setStiSizeCtrBoxes (obj,selectStiType,1);
            selectMovType=obj.data(1).movType;
            set(obj.h.movTypeEdit,'Value',selectMovType);setMovCtrBoxes(obj, selectMovType, 1);
            set(obj.h.stiDurationEdit,'String',obj.data(1).duration);
            if isfield(obj.data(1), 'position')
                set(obj.h.posXEdit,'String',obj.data(1).position(1));
                set(obj.h.posXEdit,'String',obj.data(1).position(2));
            end
            
            if isfield(obj.data(1), 'contrast')
                set(obj.h.bckEdit,'String',obj.data(selectIndex).contrast(1));
                set(obj.h.objEdit,'String',obj.data(selectIndex).contrast(2));
            end
        end
        
        function savePattern (obj, ~, ~)
            defaultPathname='C:\Users\Minggang\Documents\MATLAB\Stim Pattern Library';
            [filename, pathname] = uiputfile('*.mat','Save as',defaultPathname);
            if isequal(filename,0) || isequal(pathname,0)
                return;
            end
            fullfilename=fullfile(pathname, filename);
            patterndata=obj.data;
            save(fullfilename,'patterndata');
            
        end
        
        % function to change stimulus type
        function stiType (obj, hObject, ~)
            
            selectType=get(hObject,'Value');
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).stiType=selectType;
            setStiSizeCtrBoxes (obj, selectType, selectIndex)
        end
            
        function setStiSizeCtrBoxes (obj, selectType, index)
            
            if selectType==2
                set(obj.h.stiRadiusTxt,'Visible','on');
                set(obj.h.stiRadiusEdit,'Visible','on');
                
%                 if isfield(obj.data(index).size,'radius')
%                     set(obj.h.stiRadiusEdit,'String',obj.data(index).size.radius);
%                 else
%                     set(obj.h.stiRadiusEdit,'String','0')
%                 end    
                 try
                     set(obj.h.stiRadiusEdit,'String',obj.data(index).size(1));
                 catch
                     set(obj.h.stiRadiusEdit,'String','0');
                 end
                 
                 try
                     obj.data(index).size(2)=[];
                 catch
                 end
                
                set(obj.h.stiWidthTxt,'Visible','off');
                set(obj.h.stiWidthEdit,'Visible','off','String','0');
                set(obj.h.stiHeightTxt,'Visible','off');
                set(obj.h.stiHeightEdit,'Visible','off','String','0');
                
            elseif selectType==3
                set(obj.h.stiWidthTxt,'Visible','on');
                set(obj.h.stiWidthEdit,'Visible','on');
                set(obj.h.stiHeightTxt,'Visible','on');
                set(obj.h.stiHeightEdit,'Visible','on');
                
%                 if isfield(obj.data(index).size,'width')
%                     set(obj.h.stiWidthEdit,'String',obj.data(index).size.width);
%                 else
%                     set(obj.h.stiWidthEdit,'String','0');
%                 end    
%                 
%                 if isfield(obj.data(index).size,'height')
%                     set(obj.h.stiHeightEdit,'String',obj.data(index).size.height);
%                 else
%                     set(obj.h.stiHeightEdit,'String','0');
%                 end  
                
                try
                    set(obj.h.stiWidthEdit,'String',obj.data(index).size(1));
                catch
                     set(obj.h.stiWidthEdit,'String','0');
                end
                
                try
                    set(obj.h.stiHeightEdit,'String',obj.data(index).size(2));
                catch
                     set(obj.h.stiHeightEdit,'String','0');
                end
                
                set(obj.h.stiRadiusTxt,'Visible','off');
                set(obj.h.stiRadiusEdit,'Visible','off','String','0');
            else
                set(obj.h.stiRadiusTxt,'Visible','off');
                set(obj.h.stiRadiusEdit,'Visible','off','String','0');
                 set(obj.h.stiWidthTxt,'Visible','off');
                set(obj.h.stiWidthEdit,'Visible','off','String','0');
                set(obj.h.stiHeightTxt,'Visible','off');
                set(obj.h.stiHeightEdit,'Visible','off','String','0');
            end
        end
        
         % function to change stimulus duration
        function stiDuration (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).duration=get(hObject,'string');
        end
        
        % function to change stimulus radius
        function stiRadius (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).size=[];
%             obj.data(selectIndex).size.radius=get(hObject,'string');
            obj.data(selectIndex).size=str2double(get(hObject,'string'));
        end
        
        % function to change stimulus width
        function stiWidth (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
%             if isfield (obj.data(selectIndex).size,'radius')
%                 obj.data(selectIndex).size=rmfield(obj.data(selectIndex).size,'radius');
%             end
%             obj.data(selectIndex).size.width=get(hObject,'string');
              obj.data(selectIndex).size(1)=str2double(get(hObject,'string'));
        end
        
        % function to change stimulus height
        function stiHeight (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
%             if isfield (obj.data(selectIndex).size,'radius')
%                 obj.data(selectIndex).size=rmfield(obj.data(selectIndex).size,'radius');
%             end
%             obj.data(selectIndex).size.height=get(hObject,'string');
             obj.data(selectIndex).size(2)=str2double(get(hObject,'string'));
        end
        
        % function to change motion type
        function movType (obj, hObject, ~)
            
            selectType=get(hObject,'Value');
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).movType=selectType;
            setMovCtrBoxes (obj, selectType, selectIndex)
        end
            
        function setMovCtrBoxes (obj, selectType, index)
            
            if selectType==1
                set(obj.h.movDirectionTxt,'Visible','off');
                set(obj.h.movDirectionEdit,'Visible','off','String','0');
                set(obj.h.movSpeedTxt,'Visible','off');
                set(obj.h.movSpeedEdit,'Visible','off','String','0');
            else
                set(obj.h.movDirectionTxt,'Visible','on');
                set(obj.h.movDirectionEdit,'Visible','on');
                set(obj.h.movSpeedTxt,'Visible','on');
                set(obj.h.movSpeedEdit,'Visible','on');
                
                if isfield(obj.data(index),'mov')
                    if isfield(obj.data(index).mov,'direction')
                        set(obj.h.movDirectionEdit,'String',obj.data(index).mov.direction);
                    else
                        set(obj.h.movDirectionEdit,'String','0');
                    end
                    
                    if isfield(obj.data(index).mov,'speed')
                        set(obj.h.movSpeedEdit,'String',obj.data(index).mov.speed);
                    else
                        set(obj.h.movSpeedEdit,'String','0');
                    end
                else
                    set(obj.h.movDirectionEdit,'String','0');
                    set(obj.h.movSpeedEdit,'String','0');
                end
            end
                
        end
       
        % function to change motion direction
        function movDirection (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).mov.direction=get(hObject,'string');
        end
        
        % function to change motion speed
        function movSpeed (obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).mov.speed=get(hObject,'string');
        end
        
        % function to change position X
        function posX(obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).position(1)=get(hObject,'String');
        end
        
        % function to change position Y
        function posY(obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).position(2)=get(hObject,'String');
        end
        
         % function to change background brightness
        function bckb(obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).contrast(1)=str2double(get(hObject,'String'));
        end
        
        % function to change object brightness
        function objb(obj, hObject, ~)
            
            selectIndex=get(obj.h.stiList,'Value');
            obj.data(selectIndex).contrast(2)=str2double(get(hObject,'String'));
        end
        
         % function to select different sti
         function selectStiList (obj, hObject, ~)
             
             selectIndex=get(hObject,'Value');
             selectStiType=obj.data(selectIndex).stiType;
             set(obj.h.stiTypeEdit,'Value',selectStiType); setStiSizeCtrBoxes (obj,selectStiType,selectIndex);
             
             selectMovType=obj.data(selectIndex).movType;
             set(obj.h.movTypeEdit,'Value',selectMovType); setMovCtrBoxes(obj, selectMovType,selectIndex);
             
             set(obj.h.stiDurationEdit,'String',obj.data(selectIndex).duration);
              if isfield(obj.data(selectIndex), 'position')
                        set(obj.h.posXEdit,'String',obj.data(selectIndex).position(1));
                        set(obj.h.posXEdit,'String',obj.data(selectIndex).position(2));
              end
             
              if isfield(obj.data(selectIndex), 'contrast')
                        set(obj.h.bckEdit,'String',obj.data(selectIndex).contrast(1));
                        set(obj.h.objEdit,'String',obj.data(selectIndex).contrast(2));
              end
         end
         
         % function to set all stimulus the same
         function setAll(obj, ~, ~)
             
            selectIndex=get(obj.h.stiList,'Value'); 
             
             for i=1:length(obj.data)
                 if i~=selectIndex
                     obj.data(i).stiType=obj.data(selectIndex).stiType;
                     obj.data(i).movType=obj.data(selectIndex).movType;
                     obj.data(i).duration=obj.data(selectIndex).duration;
                     obj.data(i).size=obj.data(selectIndex).size;
                     obj.data(i).position(1)=obj.data(selectIndex).position(1);
                     obj.data(i).position(2)=obj.data(selectIndex).position(2);
                     obj.data(i).contrast(1)=obj.data(selectIndex).contrast(1);
                     obj.data(i).contrast(2)=obj.data(selectIndex).contrast(2);
                     
                     if isfield(obj.data(selectIndex),'mov')
                         obj.data(i).mov=obj.data(selectIndex).mov;
                     end
                 end
             end

         end
         
         % function to reset stimulus parameters
         function resetStiPattern (obj, ~, ~)
             
%              obj.data=[];
             for i=1:length(obj.data)
                 obj.data(i).stiType=1;
                 obj.data(i).movType=1;
                 obj.data(i).duration=0;
                 obj.data(i).size=[];
                 obj.data(i).position(1)=0;
                 obj.data(i).position(2)=0;
                 obj.data(i).contrast(1)=0;
                 obj.data(i).contrast(2)=0;
             end
             
             set(obj.h.stiTypeEdit,'Value',1);setStiSizeCtrBoxes (obj,1,1);
             set(obj.h.movTypeEdit,'Value',1);setMovCtrBoxes(obj, 1, 1);
             set(obj.h.stiDurationEdit,'String','0');
             
         end
         
         % function to update and generate stimulus pattern
         function updateStiPattern (obj,~, ~)
             
          
            delete(obj.h.fig);
            obj.h=[];
         end
         
    end
end