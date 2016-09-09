function notes = addnotes(varargin)


t ='';

% creat main figure
fig = figure('Name','Notes',...
    'MenuBar','none',...
    'ToolBar','none',...
    'NumberTitle','off',...
    'Resize','off',...
    'Position',[200 200 300 300],...
    'CloseRequestFcn',@closeMainFcn);

% creat pushtools
ht=uitoolbar(fig);
path=fileparts(which('addnotes'));

% [X,map] = imread([path '\icons\file_open.gif']);
% icon = ind2rgb(X,map);
% uipushtool(ht,'CData',icon,'TooltipString','Open Notes','Separator','off','ClickedCallback',@obj.importPattern);

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
        t=varargin{1}.notes; 
        set(notesEdit,'String', t);
    end
end

origTest = t;
waitfor(fig);
% waitfor(notesEdit,'String');
% notes=get(notesEdit,'String');
notes = t;
 %
    function []=saveNotes(varargin)
        
        [~, filename]=fileparts(pwd);
        metafilename=['meta_' filename '.mat'];
        if exist(metafilename,'file')
            load(metafilename);
            t = get(notesEdit,'String');
            metadata.notes = t;
            save(metafilename,'metadata'); 
        else
            saveNotesAs;
        end
        delete(fig);
    end

%
    function []=saveNotesAs(varargin)
        [filename, pathname] = uiputfile('*.txt', 'Save Notes As');
        if isequal(filename,0) || isequal(pathname,0)
            disp('User pressed cancel')
        else
            disp(['User selected ', fullfile(pathname, filename)])
        end
%         notesname=fullfile(pathname,filename);
        t   = get(notesEdit,'String');
        fid = fopen('MyFile.txt','w');
        fprintf(fid, t);
        fclose(fid);
%         save(notesname,'notes','-ascii');
        delete(fig);
    end

    function [] = closeMainFcn (varargin)
        curTest   = get(notesEdit,'String');
        if strcmp(origTest, curTest)
            delete(fig);
        else
            selection=questdlg('Notes were changed, do you want to save the changes?',...
                    'Notes',...
                    'Yes','No','Yes');
                switch selection
                    case'Yes'
                        saveNotes;    
                    case'No'
                        delete(fig);
                end
        end
    end
end