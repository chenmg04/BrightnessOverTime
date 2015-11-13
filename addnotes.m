function notes = addnotes(varargin)


% creat main figure
fig = figure('Name','Notes',...
    'MenuBar','none',...
    'ToolBar','none',...
    'NumberTitle','off',...
    'Resize','off',...
    'Position',[200 200 300 300]);

% creat pushtools
ht=uitoolbar(fig);
path=fileparts(which('addnotes'));

[X,map] = imread([path '\icons\file_open.gif']);
icon = ind2rgb(X,map);
uipushtool(ht,'CData',icon,'TooltipString','Open Notes','Separator','off','ClickedCallback',@obj.importPattern);

[X,map] = imread([path '\icons\file_save.gif']);
icon = ind2rgb(X,map);
uipushtool(ht,'CData',icon,'TooltipString','Save Notes','Separator','off', 'ClickedCallback',@saveNotes);

[X,map] = imread([path '\icons\file_save_as.gif']);
icon = ind2rgb(X,map);
uipushtool(ht,'CData',icon,'TooltipString','Save Notes as','Separator','off','ClickedCallback',@saveNotesAs);

% create editbox for notes
notesEdit =uicontrol(fig,...
    'Style','edit',...
    'BackgroundColor','White',...
    'String', '',...
    'FontSize',9,...
    'Max', 10,...  % set as multiple line editor
    'HorizontalAlignment','left',...
    'Position',[0 0 300 300]);

% initialize edit box value 
if nargin 
    if isfield(varargin{1},'notes')
        data=varargin{1}.notes;
        set(notesEdit,'String', data);
    end
end


waitfor(notesEdit,'String');
notes=get(notesEdit,'String');
 %
    function []=saveNotes(varargin)
        
        [~, filename]=fileparts(pwd);
        metafilename=['meta_' filename '.mat'];
        if exist(metafilename,'file')
            load(metafilename);
            notes=get(notesEdit,'String');
            metadata.notes=notes;
            save(metafilename,'metadata'); 
        else
            saveNotesAs;
        end
        
    end

%
    function []=saveNotesAs(varargin)
        [filename, pathname] = uiputfile('*.txt', 'Save Notes As');
        if isequal(filename,0) || isequal(pathname,0)
            disp('User pressed cancel')
        else
            disp(['User selected ', fullfile(pathname, filename)])
        end
        notesname=fullfile(pathname,filename);
        notes=get(notesEdit,'String');
        save(notesname,'notes','-ascii');
        
    end
end