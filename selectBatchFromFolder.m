function selectFileNames=selectBatchFromFolder (varargin)
            
filedir=uigetdir;

if ~filedir
    %                 set(obj.infoTxt,'String','No folder selected!');
    return;
end

cd(filedir);
newFiles=dir(filedir);
% batchdir=filedir;

for i=1:length(newFiles)
    newFilesName{i}=newFiles(i).name;
end

% mainFigPos=get(obj.hMain,'Position');
selectFileFig   =figure ('Name','Multiple Select',...
                                  'NumberTitle','off',...
                                  'MenuBar','none',...
                                  'Resize','off','Color','white' );

if  nargin
    mainFigPos=varargin{1};
    set(selectFileFig, 'Position', [mainFigPos(1) mainFigPos(2)-45-500 270 500]);
else
    set(selectFileFig, 'Position', [300 100 270 500]);
end
    

selectFileList   =uicontrol('Style','listbox','Value',1,'BackgroundColor','white',...
    'Parent', selectFileFig,...
    'Min',1, 'Max', 10,...
    'Position',[2 50 266 450],...
    'HorizontalAlignment','left','FontSize',10);

uicontrol('Parent', selectFileFig,...
    'Style', 'pushbutton',...
    'String','Select',...
    'Position',[150 10 80 30],'FontSize',10,...
    'Callback',@selectFiles);

set(selectFileList,'String', newFilesName);

selectFileNames={};
waitfor(selectFileFig);
    function []=selectFiles(varargin)
        selectFileN=get(selectFileList,'Value');
        for j=1:length(selectFileN)
            selectFileNames{j}=fullfile(filedir,newFilesName{selectFileN(j)});
        end
        close(selectFileFig);
    end
end