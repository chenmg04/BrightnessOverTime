function data = roiToolBox(varargin)

%READING ARGUMENTS
if nargin==0
    haxes=gca;
    data=[];
elseif nargin==1
    haxes=varargin{1};
    data=[];
else
    haxes=varargin{1};
    data=varargin{2};
end
%CREATE GUI
fig = figure('Name', 'ROI ToolBox',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Position', [200 200 160 250],...
    'Color','white',...
    'Resize','off');

%BUTTONS
roiList   =uicontrol('Style','listbox',...
    'Value',1,...
    'Position',[1 1 80 249],...
    'HorizontalAlignment','left',...
    'Callback',@selectroi);
addbutton    =uicontrol('Style','pushbutton',...
    'String','Add',...
    'Position',[81 220 79 30],...
    'Callback',@addroi);
updatebutton =uicontrol('Style','pushbutton',...
    'String','Update',...
    'Position',[81 190 79 30],...
    'Callback',@updateroi);
deletbutton  =uicontrol('Style','pushbutton',...
    'String','Delete',...
    'Position',[81 160 79 30],...
    'Callback',@deleteroi);
importbutton =uicontrol('Style','pushbutton',...
    'String','Import',...
    'Position',[81 130 79 30],...
    'Callback',@importroi);
savebutton   =uicontrol('Style','pushbutton',...
    'String','Save',...
    'Position',[81 100 79 30],...
    'Callback',@saveroi);
measurebutton=uicontrol('Style','pushbutton',...
    'String','Measure',...
    'Position',[81 70 79 30],...
    'Callback',@measureroi);
showallbox=uicontrol('Style','checkbox',...
    'String','ShowAll',...
    'Position',[81 35 77 25]);
labelbox  =uicontrol('Style','checkbox',...
    'String','Labels',...
    'Position',[81 10 77 25],...
    'Callback',@labelroi );

%INITIATION

%
state=[];
nROIs=length(data);
if nROIs~=0
    axes(haxes);
    for i=1:nROIs
        data{i}.lineh=plot(data{i}.pos(:,1),data{i}.pos(:,2),'Color','white','LineWidth',2);
        data{i}.th    =text(data{i}.cenX, data{i}.cenY, num2str(i),'Color','white');
        hold on;
    end
    state.curROIh=[];
    state.curROIn=1;
    set(roiList, 'String',{1:1:nROIs});
    set(roiList, 'Value', 1);
end
%
if isempty(state)
    state.curROIh=[];
    state.curROIn=[];
end

%FUNCTION TO SELECT ROI
    function []=selectroi(varargin)
        if ~isempty(data)
            axes(haxes);
            hold on;
            nR=length(data);
            if state.curROIn~=0
                if nR==1
                else
                    if ~isempty(state.curROIh)
                        state.curROIh.delete;
                        data{state.curROIn}.lineh=plot(data{state.curROIn}.pos(:,1),data{state.curROIn}.pos(:,2),'Color','white','LineWidth',2);
                    end
                end
            end
            index=get(roiList,'Value');
            delete(data{index}.lineh);
            selectROIh=impoly(haxes,data{index}.pos);
            state.curROIh=selectROIh;
            state.curROIn=index;
        end
    end
%FUNCTION TO ADD ROI
    function []=addroi(varargin)
        % Check whether there are ROIs already
        axes(haxes);
        nR=length(data);
        if nR~=0
            curROIn=nR+1;
            if ~isempty(state.curROIh)
               delete(state.curROIh);
               data{state.curROIn}.lineh=plot(data{state.curROIn}.pos(:,1),data{state.curROIn}.pos(:,2),'Color','white','LineWidth',2);
            end
        else
            curROIn=1;
        end
        
        % Draw new ROI
        newROIh=impoly;
        newROIpos=newROIh.getPosition;
        state.curROIh=newROIh;
        state.curROIn=curROIn;
        %
        x=(min(newROIpos(:,1))+max(newROIpos(:,1)))/2;
        y=(min(newROIpos(:,2))+max(newROIpos(:,2)))/2;
        data{curROIn}.th    =text(x, y, num2str(curROIn),'Color','white');
        set(roiList,'String',{1:1:curROIn});
        set(roiList,'Value',curROIn);
        %
        newROIpos=[newROIpos;newROIpos(1,:)];
        data{curROIn}.pos=newROIpos;
        data{curROIn}.cenX=x;
        data{curROIn}.cenY=y;
        data{curROIn}.ROIh=newROIh;
    end
%FUNCTION TO UPDATE
    function []=updateroi(varargin)
        selectIndex=state.curROIn;
        axes(haxes);
        
        updateROIh     =state.curROIh;
        updateROIpos =updateROIh.getPosition;
        x=(min(updateROIpos(:,1))+max(updateROIpos(:,1)))/2;
        y=(min(updateROIpos(:,2))+max(updateROIpos(:,2)))/2;
        delete(data{selectIndex}.th);
        data{selectIndex}.th    =text(x, y, num2str(selectIndex),'Color','white');
        
        updateROIpos=[updateROIpos;updateROIpos(1,:)];
        data{selectIndex}.pos=updateROIpos;
        data{selectIndex}.cenX=x;
        data{selectIndex}.cenY=y;
        data{selectIndex}.ROIh=updateROIh;
    end
%FUNCTION TO DELETE
    function []=deleteroi(varargin)
        selectIndex=state.curROIn;
        selectROIh=state.curROIh;
        % delete roi 
        selectROIh.delete;
        % delete roi data
        delete(data{selectIndex}.th);
        data{selectIndex}=[];
        data=data(~cellfun(@isempty,data));
        %
        axes(haxes);
        nR=length(data);
        if nR==0
            set(roiList,'String',[]);
        else
            for j=1:nR
                delete(data{j}.th);
                data{j}.th=text(data{j}.cenX, data{j}.cenY, num2str(j),'Color', 'white');
            end
            set(roiList,'String',{1:1:nR});
        end
        set(roiList,'Value',1);
        state.curROIn=[];
        state.curROIh=[];
    end
%FUNCTION TO IMPORT
    function []=importroi(varargin)
        filedir=uigetdir;
        [~,filename]=fileparts(filedir);
        r=load(fullfile(filedir,sprintf('meta_%s.mat',filename)));  
        axes(haxes);
        if isfield(r.metadata,'ROIdata')&&~isempty(r.metadata.ROIdata)
            data=r.metadata.ROIdata;
            nR=length(data);
            for j=1:nR
                data{j}.lineh=plot(data{j}.pos(:,1),data{j}.pos(:,2),'Color','white','LineWidth',2);
                data{j}.th    =text(data{j}.cenX, data{j}.cenY, num2str(j),'Color','white');
                hold on;
            end
            state.curROIh=[];
            state.curROIn=1;
            set(roiList,'String',{1:1:nR});
            set(roiList,'Value',1);
        end
    end
%FUNCTION TO SAVE
    function []=saveroi(varargin)
    end

end