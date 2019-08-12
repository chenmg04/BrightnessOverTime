classdef notewriter< handle
    
    properties
        
        h
        notes
    end
    
    methods
        
        function obj = notewriter (varargin)
            
            % creat main figure
            obj.h.fig = figure('Name','Notes',...
                'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Resize','off',...
                'CloseRequestFcn',@obj.closeMainFcn);                                                  
            
            try
                dispfig=findobj('Tag','dispfig');
                set(obj.h.fig,'Position',[dispfig.Position(1) dispfig.Position(2)-370 300 300]);
            catch
                set(obj.h.fig,'Position', [200 200 300 300]);
            end
            
            % creat pushtools
            ht=uitoolbar(obj.h.fig);
            path=fileparts(which('notewriter'));
            
            % [X,map] = imread([path '\icons\file_open.gif']);
            % icon = ind2rgb(X,map);
            % uipushtool(ht,'CData',icon,'TooltipString','Open Notes','Separator','off','ClickedCallback',@obj.importPattern);
            
            [X,map] = imread([path '\icons\file_save.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','Save Notes','Separator','off', 'ClickedCallback',@obj.saveNotes);
            
            [X,map] = imread([path '\icons\file_save_as.gif']);
            icon = ind2rgb(X,map);
            uipushtool(ht,'CData',icon,'TooltipString','Save Notes as','Separator','off','ClickedCallback',@obj.saveNotesAs);
            
            % create editbox for notes
            obj.h.editField =uicontrol(obj.h.fig,...
                'Style','edit',...
                'BackgroundColor','White',...
                'String', '',...
                'FontSize',9,...
                'Max', 10,...  % set as multiple line editor
                'HorizontalAlignment','left',...
                'Position',[0 0 300 300]);
            
            
            % initialize edit box value
            if nargin
                    obj.notes =  varargin{1};
                    obj.h.editField.String = obj.notes;
            end
        end
            
            % 
            function saveNotes(obj,~,~)
                
                imf = findobj('Tag', 'dispfig'); 
                if isempty(imf)
                    saveNotesAs(obj);
                    return;
                end
                
                filedir = imf.UserData;
                [~, filename]=fileparts(filedir);
                metafilename=['meta_' filename '.mat'];
                
                cd(filedir);
                if exist(metafilename,'file')
                    load(metafilename);
                    obj.notes = obj.h.editField.String;
                    metadata.notes = obj.notes;
                    save(metafilename,'metadata');
                    
                    try
                        hMain=findobj('Name','BrightnessOverTime');
                        infoPanel=findobj(hMain, 'Tag','infopanel');
                        set(infoPanel, 'String', 'Notes was saved!')
                    catch
                    end
                else
                    saveNotesAs(obj);
                end

            end
            
            %
            function saveNotesAs(obj,~,~)
                obj.notes = obj.h.editField.String;
                
                [filename, pathname] = uiputfile('*.txt', 'Save Notes As');
                if isequal(filename,0) || isequal(pathname,0)
                    disp('User pressed cancel')
                    return;
                else
                    disp(['User selected ', fullfile(pathname, filename)])
                end
                cd(pathname);
                fid = fopen(filename,'w');
                fprintf(fid, obj.notes);
                fclose(fid);
            end
            
            
            function closeMainFcn (obj,~,~)
                
                if isempty(obj.notes)
                    note = '';
                else
                    note = obj.notes;
                end
                       
                if strcmp(note, obj.h.editField.String)
                     delete(obj.h.fig);
                     obj.h = [];
                else
                    selection=questdlg('Notes were changed, do you want to save the changes?',...
                        'Notes',...
                        'Yes','No','Yes');
                    switch selection
                        case'Yes'
                            saveNotes(obj);
                        case'No'
                            delete(obj.h.fig);
                            obj.h =[];
                    end
                end
            end

    end
end