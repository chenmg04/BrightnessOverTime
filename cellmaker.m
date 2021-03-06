classdef cellmaker < handle
    
    properties
        
        h
        fileinfo
        cellinfo
        savepath
        
    end
    
    methods
        
        function obj = cellmaker (varargin)
            
            obj.h.fig = figure('Name','Cell Info',...
                'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Resize','off',...
                'CloseRequestFcn',@obj.closeMainFcn);
            
            % set figure Position
            try
                dispfig=findobj('Tag','dispfig');
                obj.h.fig.Position = [dispfig.Position(1) dispfig.Position(2)-500 512 400];
            catch
                obj.h.fig.Position = [200 200 512 400];
            end
            
            % creat pushtools
            ht   = uitoolbar(obj.h.fig);
            path = fileparts(which('cellmaker'));
            
            [X,map] = imread([path '\icons\file_new.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','New','Separator','off','ClickedCallback',@obj.addFiles);
            
            % [X,map] = imread([path '\icons\file_open.gif']);
            % icon = ind2rgb(X,map);
            % uipushtool(ht,'CData',icon,'TooltipString','Open Notes','Separator','off','ClickedCallback',@importPattern);
            
            [X,map] = imread([path '\icons\file_save.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','Save Cell','Separator','off', 'ClickedCallback',@obj.saveCell);
            
            % [X,map] = imread([path '\icons\file_save_as.gif']);
            % icon = ind2rgb(X,map);
            % uipushtool(ht,'CData',icon,'TooltipString','Save Cell as','Separator','off','ClickedCallback',@saveCellAs);
            
            uicontrol(obj.h.fig,...
                'Style','text',...
                'BackgroundColor',get(obj.h.fig,'Color'),...
                'String', 'File List',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'Position',[8 370 80 20]);
            
            obj.h.fileList = uicontrol(obj.h.fig,...
                'Style','listbox',...
                'BackgroundColor','White',...
                'String', '',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'Position',[8 10 150 350],...
                'Callback',@obj.viewFileFromList);
            
            filePanel = uipanel('Title','',...
                'Parent', obj.h.fig,...
                'FontSize',9,...
                'BackgroundColor','white',...
                'Units','pixels',...
                'Position',[170 10 338 350]);
            fileTab = uitabpanel(...
                'Parent',filePanel,...
                'TitleForegroundColor',[0 0 0],...
                'FrameBackgroundColor',[0.9412 0.9412 0.9412],...
                'TitleBackgroundColor',[0.8 0.8 0.8],...
                'PanelBackgroundColor',[1 1 1],...
                'TabPosition','lefttop',...
                'Position',[0,0,1,1],...
                'Margins',{[0,-1,1,0],'pixels'},...
                'PanelBorderType','line',...
                'Title',{'Notes','Cell Summary'});
            
            hpanel = getappdata(fileTab,'panels');
            
            obj.h.filenotes = uicontrol('Style','text',...
                'BackgroundColor','White',...
                'String', '',...
                'FontSize',9,...
                'HorizontalAlignment','left',...
                'Position',[0 0 330 325],...
                'Parent',hpanel(1));
            
            obj.h.cellinfo = uicontrol('Style','edit',...
                'BackgroundColor','White',...
                'String', '',...
                'FontSize',9,...
                'Max', 10,...
                'HorizontalAlignment','left',...
                'Position',[5 5 330 315],...
                'Parent',hpanel(2));
            
            
            % initialization
            if nargin == 1 
                try
                    obj.fileinfo   = varargin{1}.fileinfo;
                    obj.cellinfo   = varargin{1}.cellinfo;
                    obj.savepath   = varargin{1}.savepath;
                    obj.h.cellinfo.String = obj.cellinfo;
                    if ~isempty(obj.savepath)
                        obj.h.fig.Name = ['Cell Info-' obj.savepath];
                    end
                        
                catch
                    obj.fileinfo.filedir = varargin{1};
                end
                loadInfo(obj);
            elseif nargin == 2
                obj.fileinfo.filedir = varargin{1};
                obj.savepath = varargin{2};
                obj.h.fig.Name = ['Cell Info-' obj.savepath];
                loadInfo(obj);
            else
                obj.fileinfo=[];
                obj.cellinfo=[];
            end
            
        end
        
        % add new files
        function addFiles (obj, ~, ~)
            
            selectFileNames = selectBatchFromFolder;
            obj.fileinfo.filedir = selectFileNames;
            loadInfo(obj);
            
        end
        
        function loadInfo (obj, ~, ~)
            
            fileN = length(obj.fileinfo.filedir);
            for i = 1:fileN
                fullfilename = obj.fileinfo.filedir{i};
                [~,filename]=fileparts(fullfilename);
                shortFilename=filename(end-17:end);
                
                listNames = obj.h.fileList.String;
                listNames = [listNames; shortFilename];
                obj.h.fileList.String = listNames;
                obj.h.fileList.Value  = i;
                
                % iminfo
                name_metadata=[fullfilename '\meta_' filename '.mat'];
                if exist(name_metadata, 'file')
                    imdata = load(name_metadata);
                    if isfield(imdata.metadata,'notes')
                        obj.fileinfo.notes{i} = imdata.metadata.notes;
                    else
                        obj.fileinfo.notes{i} = '';
                    end
                    obj.h.filenotes.String = obj.fileinfo.notes{i};
                end
            end
        end
        
        % view files from fileList
        function viewFileFromList(obj, ~, ~)
            
            fileIndex = obj.h.fileList.Value;
            obj.h.filenotes.String = obj.fileinfo.notes{fileIndex};
        end
        
        % save updates in the current cell
        function saveCell(obj, ~, ~)
            
            if strcmp('Cell Info', obj.h.fig.Name)
                saveCellAs(obj);
            else
                fullCellname  = obj.h.fig.Name (11:end);
                [~, cellname] = fileparts(fullCellname);
                cellinfoname  = [fullCellname '\info_' cellname '.mat'];
                
                obj.cellinfo  = obj.h.cellinfo.String;
                load(cellinfoname);
                data.cellinfo = obj.cellinfo;
                save(cellinfoname,'data');
            end
        end
        
        % save cell in a new directory
        function saveCellAs(obj, ~, ~)
            
            if isempty(obj.fileinfo.filedir)
                return;
            end
            
            [cellname, pathname] = uiputfile('*.*','Save Cell as');
            if isequal(cellname,0) || isequal(pathname,0)
                return;
            end
            
            fileN = length (obj.fileinfo.filedir);
            fullCellname=fullfile(pathname,cellname);
            for i=1:fileN
                cd(obj.fileinfo.filedir{i});
                [~,filename{i}]=fileparts(obj.fileinfo.filedir{i});
                newfullname{i} = fullfile(fullCellname, filename{i});
                mkdir(fullCellname, filename{i});
                copyfile('*.mat', newfullname{i});
            end
            obj.cellinfo            = obj.h.cellinfo.String;
            obj.savepath            = fullCellname;
            data.fileinfo.filenames = filename;
            data.fileinfo.notes     = obj.fileinfo.notes;
            data.cellinfo           = obj.cellinfo;
            save([fullCellname '\info_' cellname], 'data');
            obj.h.fig.Name = ['Cell Info-' fullCellname];
            
        end
        
        
        function closeMainFcn (obj, ~, ~)
            
            delete(obj.h.fig);
            obj.h =[];
        end
        
    end
    
    
end