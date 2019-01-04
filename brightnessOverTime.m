classdef brightnessOverTime < handle
    
    properties (Access = public)
        hMain
        infoTxt
        loadTxt
        loadAxes
        
        openList
        subList
        
        dispFig
        
        dispFigTxt
        axes1
        chSlider
        frameSlider
        
        resize
        roiTool
        stiTool
        autoFluoDetector
        fp
        nf % notes figure
%         hgendatabase
        cell
        fileInfo
        openStates
        data
    end
    
    properties(Constant)
        
        mag =  [3.1 4.2 6.2 8.3 12.5 16.7 25 33.3 50 75 100,...
               150 200 300 400 600 800 1200 1600 2400 3200];
           
        screendims=get(0,'Screensize');
        
    end
    
    
        
   
    methods
        
        % Creat the main gui, including figure, infoTxt, menu, axes
        function obj = brightnessOverTime
            
            defaultsize=round(obj.screendims(3)/1366*9);
            os=computer;
            if defaultsize>9 && ~isempty(strfind(os,'PC'))
                defaultsize=9;
            end
            set(0,'defaultUicontrolFontSize',defaultsize);
%             cd('C:\Users\ZhouLab\Documents\MATLAB\brightnessOverTime');
            
            obj.hMain    =figure('Name','BrightnessOverTime',...
                'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Resize','off',...
                'Position',[(obj.screendims(3)-512)/2 obj.screendims(4)-82 512 25],...
                'CloseRequestFcn',@obj.mainCloseRequestFcn);
            
            obj.infoTxt  =uicontrol(obj.hMain,...
                'Style','text',...
                'BackgroundColor',get(obj.hMain,'Color'),...
                'Tag', 'infopanel',...
                'String', 'No Image Open!',...
                'HorizontalAlignment','left',...
                'Position',[8 5 350 15]);
            
            obj.loadTxt  =uicontrol(obj.hMain,...
                'Style','text',...
                'BackgroundColor',get(obj.hMain,'Color'),...
                'String', '',...
                'HorizontalAlignment','left',...
                'Position',[350 5 60 15]);
            
            obj.loadAxes =axes('Parent',obj.hMain,...
                'Units','pixels',...
                'Position',[410 5 100 15],...
                'Visible','off');
            
            obj.openList = createMenusAndToolbar(obj);
            
            obj.dispFig  = figure('Name','',...
                'MenuBar','none',...
                'ToolBar','none',...
                'NumberTitle','off',...
                'Resize','off',...
                'Tag','dispfig',...
                'Position',[(obj.screendims(3)-512)/2 obj.screendims(4)-652 512 512],...
                'Visible','off',...
                'CloseRequestFcn',@obj.closeSingleImage,...
                'WindowKeyPressFcn',@obj.zoomImage);    
           
            
            obj.axes1    = axes('Parent',obj.dispFig,...
                'Units','pixels',...
                'XColor',get(obj.dispFig,'Color'),...
                'YColor',get(obj.dispFig,'Color'),...
                'XTick',[],...
                'YTick',[],...
                'Position',[0 15 512 512]);                     
            
            obj.chSlider = uicontrol(obj.dispFig,...
                'Style','slider',...
                'BackgroundColor',get(obj.hMain,'Color'),...
                'Min', 1,'Max',2,...
                'SliderStep',[1 1],...
                'Value',1,...
                'Position',[0 0 512 15],...
                'TooltipString','channel',...
                'Interruptible','on',...
                'Callback',@obj.channelSelection);
            
             obj.frameSlider = uicontrol(obj.dispFig,...
                'Style','slider',...
                'BackgroundColor',get(obj.hMain,'Color'),...
                'Min', 1,'Max',2,...
                'SliderStep',[1 1],...
                'Value',1,...
                'Position',[0 0 512 15],...
                'Visible','off',...
                'TooltipString','frame',...
                'Interruptible','on');
%                 'Callback',@obj.frameSelection);
                hhSlider = handle (obj.frameSlider);
                hProp= findprop(hhSlider, 'Value');
                try
                hListener = addlistener (hhSlider, hProp, 'PostSet', @obj.frameSelection);% for matlab version 2014 or older
                catch
                 hListener = handle.listener (hhSlider, hProp, 'PostSet', @obj.frameSelection);% for matlab version before 2014
                end
                setappdata ( obj.frameSlider, 'sliderListener', hListener);
                
                % add a listener to dispFig Position
%                 addlistener(obj.dispFig, 'OuterPosition', 'PostSet', @obj.dispFigPositionChangeFcn);
                
                clear; 
                clc;
            
        end
        
        
        
        % -----------------------------------------------------------------
        function [openList] = createMenusAndToolbar (obj)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % File menu
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fileMenu = uimenu(obj.hMain,...
                'Label','File',...
                'Tag','file menu');
            
            % Open item
            uimenu(fileMenu,...
                'Label','Open',...
                'Accelerator','O',...
                'Separator','off',...
                'Callback',@obj.openFromFolder);
             % Open sample
            uimenu(fileMenu,...
                'Label','Open Sample',...
                'Separator','off',...
                'Callback',@obj.openSample);
            uimenu(fileMenu,...
                'Label','Open Batch',...
                'Separator','off',...
                'Callback',@obj.openBatchFromFolder);
            uimenu(fileMenu,...
                'Label','Open Cell',...
                'Separator','off',...
                'Callback',@obj.openCell);
%             openSampleMenu=uimenu(fileMenu,...
%                 'Label','Open Sample',...
%                 'Separator','off');
%             uimenu(openSampleMenu,...
%                 'Label','Tiff Stack',...
%                 'Separator','off',...
%                 'Callback',@obj.openSample); 
            openList = uimenu(fileMenu,...
                'Label','Open List',...
                'Tag','file list');
            importMenu=uimenu(fileMenu,...
                'Label','Import',...
                'Separator','off' );
            uimenu(importMenu,...
                'Label','Tiff Stack',...
                'Separator','off',...
                'Callback',@obj.importTiffStack);  
            % Close item
            uimenu(fileMenu,...
                'Label','Close',...
                'Separator','on',...
                'Callback',@obj.closeSingleImage);
            uimenu(fileMenu,...
                'Label','Close All',...
                'Separator','off',...
                'Callback',@obj.closeAllImage);
            % Save item
            uimenu(fileMenu,...
                'Label','Save Image',...
                'Separator','on',...
                'Callback',@obj.saveImage);
            uimenu(fileMenu,...
                'Label','Save As...',...
                'Separator','off',...
                'Callback',@obj.saveImageAs);
             uimenu(fileMenu,...
                'Label','Save Imagedata...',...
                'Separator','off',...
                'Callback',@obj.saveImagedata);
%             uimenu(fileMenu,...
%                 'Label','Save Stimulus...',...
%                 'Separator','off',...
%                 'Callback',@obj.saveStimulus);
            
            uimenu(fileMenu,...
                'Label','Export Stack',...
                'Separator','on',...
                'Callback',@obj.exportStack);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Image menu
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            imageMenu = uimenu(obj.hMain,...
                'Label','Image',...
                'Tag','image menu');
            uimenu(imageMenu,...
                'Label','Show Info',...
                'Accelerator','I',...
                'Separator','off',...
                'Callback',@obj.showImageInfo);
            %Stack
            stackMenu = uimenu(imageMenu,...
                'Label', 'Stack',...
                'Separator','on');
             uimenu(stackMenu,...
                'Label','Make Substack',...
                'Separator','off',...
                'Callback',@obj.makeSubstack);  
            %View
            viewMenu=uimenu(imageMenu,...
                'Label', 'View',...
                 'Separator','off');
           uimenu(viewMenu,...
                'Label','Original Stack',...
                'Separator','off',...
                'Callback',@obj.viewOriginalStack);  
            uimenu(viewMenu,...
                'Label','Average Frame',...
                'Separator','off',...
                'Callback',@obj.viewAverageFrame); 
            uimenu(viewMenu,...
                'Label','Open Image in New Window',...
                'Separator','off',...
                'Callback',@obj.openImageInNewWindow);
            
            % Adjust
            adjustMenu =uimenu(imageMenu,...
                'Label','Adjust',...
                'Separator','off');
            uimenu(adjustMenu,...
                'Label','Size...',...
                'Separator','off',...
                'Callback',@obj.adjustImageSize);
            uimenu(adjustMenu,...
                'Label','Contrast...',...
                'Separator','off',...
                'Callback',@obj.adjustImageContrast);
            % Color
            colorMenu =uimenu(imageMenu,...
                'Label','Color',...
                'Separator','off');
            uimenu(colorMenu,...
                'Label','Jet',...
                'Separator','off',...
                'Callback',@obj.colorSet);
            uimenu(colorMenu,...
                'Label','Green',...
                'Separator','off',...
                'Callback',@obj.colorSet);
            uimenu(colorMenu,...
                'Label','Red',...
                'Separator','off',...
                'Callback',@obj.colorSet);
            uimenu(colorMenu,...
                'Label','Blue',...
                'Separator','off',...
                'Callback',@obj.colorSet);
            uimenu(colorMenu,...
                'Label','Gray',...
                'Separator','off',...
                'Callback',@obj.colorSet);
            % Zoom
            zoomMenu =uimenu(imageMenu,...
                'Label','Zoom',...
                'Separator','off');
            uimenu(zoomMenu,...
                'Label','In [+]',...
                'Separator','off',...
                'Callback',@obj.zoomIn);
            uimenu(zoomMenu,...
                'Label','Out [-]',...
                'Separator','off',...
                'Callback',@obj.zoomOut);
            uimenu(zoomMenu,...
                'Label','Original Scale',...
                'Separator','off',...
                'Callback',@obj.zoomReset);
            % Pan
            uimenu(imageMenu,...
                'Label','Pan',...
                'Separator','on',...
                'Callback',@obj.panImage);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Tool menu
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            toolMenu =uimenu(obj.hMain,...
                'Label','Tool',...
                'Tag','tool menu');
            uimenu(toolMenu,...
                'Label','Template Matching',...
                'Callback',@obj.sliceAlignment);
            % roiToolBox
            uimenu(toolMenu,...
                'Label','roiToolBox',...
                'Callback',@obj.roiToolBox);
            uimenu(toolMenu,...
                'Label','stimulus',...
                'Callback',@obj.stimulus);
             uimenu(toolMenu,...
                'Label','Notes',...
                'Callback',@obj.addnote);
            uimenu(toolMenu,...
                'Label','Cell',...
                'Callback',@obj.generateCell);
            uimenu(toolMenu,...
                'Label','Wave_PIP2',...
                'Callback',@obj.wavePIP);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Analyze menu
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            analyzeMenu =uimenu(obj.hMain,...
                'Label','Analyze',...
                'Tag','analyze menu');
            % Measure
            uimenu(analyzeMenu,...
                'Label','Measure',...
                'Callback',@obj.openFluoProcessor);
            % Auto Fluorescence Detection
            uimenu(analyzeMenu,...
                'Label','Auto Fluorescence Detection',...
                'Callback',@obj.autoFluoChangeDetection);
            
            
        end
        
        % 
        function dispFigPositionChangeFcn (obj)
            % update position of ROI box if it is open
            if ~isempty(obj.roiTool)
                dispFigPos               = obj.dispFig.Position;
                obj.roiTool.fig.Position = [dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-250 160 250];
            end
            
            % update position of Measure box if it is open
            if ~isempty(obj.fp)
                roiFigPos                = obj.roiTool.fig.Position;
                obj.fp.fig.Position = [roiFigPos(1)+roiFigPos(3)+20 roiFigPos(2)+roiFigPos(4)-350 405 350];
            end
        end
        
        % Function to close main window 
        function mainCloseRequestFcn (obj,hObject,~)
            
            delete(obj.dispFig);
            
            % if roiToolBox is open, close it
            if ~isempty(obj.roiTool)
                delete(obj.roiTool.fig);
                obj.roiTool=[];
            end
            % if auto fluorescence detetor is open, close it
            if ~isempty(obj.autoFluoDetector)
                delete(obj.autoFluoDetector.fig);
                obj.autoFluoDetector=[];
            end
            
            % if auto fluorescence detetor is open, close it
            if ~isempty(obj.fp)
                delete(obj.fp.fig);
                obj.fp=[];
            end
            
%             if ~isempty(obj.stiTool)
%                 close(stimulus);
%                 obj.stiTool=[];
%             end

            % 
            if ~isempty(findobj('Name','Stimulus'))
                close('Stimulus');
            end
            
            %
%             if ~isempty (obj.cell)
%                 delete(obj.cell.h.fig)
%                 obj.cell = [];
%             end
%             
            % To add more
            delete(hObject);
        end
        
        % Function to close image window/single image 
        function closeSingleImage(obj,~,~)
            
            if ~isempty (obj.roiTool)&&~isempty(get(obj.roiTool.roiList,'String'))
                
%                 selection=questdlg('Save the ROIs?',...
%                     'ROI ToolBox',...
%                     'Yes','No','Yes');
%                 switch selection
%                     case'Yes'
%                         saveRoi(obj);
%                     case'No'
%                         
%                 end
                
                set(obj.roiTool.roiList,'String',[]);
                set(obj.roiTool.roiList,'Value',1);
            end
            
            if ~isempty (obj.stiTool)
                
                if ~isempty(findobj('Name','Stimulus'))
                    close('Stimulus');
                end
                obj.stiTool=[];
            end
            
            
            fileList=obj.fileInfo;
            if isempty(fileList)
                obj.data=[];
                set(obj.dispFig,'Visible','off');
                set(obj.infoTxt,'String','No Image Open!');
                return;
            end
            
            if isfield(fileList,'fullFileName') && ~isempty(fileList.fullFileName)
                fileN=length(fileList.fullFileName);
                if fileN==1
                    delete(obj.subList);
                    obj.subList=[];
                    fileList.fullFileName=[];
                    obj.data=[];
                    set(obj.dispFig,'Visible','off');
                    set(obj.infoTxt,'String','No Image Open!');
                else
                    deleteFileName=get(obj.dispFig,'name');
                    deleteFileName=deleteFileName(1:37); % when zoom in, dispFig name is different, e.g +(100%) 
                    for i=1:fileN
                        if strfind(fileList.fullFileName{i},deleteFileName)
                            delete(obj.subList(i));
                            obj.subList(i)=[];
                            fileList.fullFileName{i}=[];
                            fileList.fullFileName   = fileList.fullFileName(~cellfun(@isempty, fileList.fullFileName));
                            break;
                        end
                    end
                    
                    processImage(obj,fileList.fullFileName{1});
                    
                end
                obj.fileInfo=fileList;
            end
            
            
                      
        end
        
        % Function to close all images 
        function closeAllImage(obj,~,~)
            
             if ~isempty (obj.roiTool)&&~isempty(get(obj.roiTool.roiList,'String'))
                
%                 selection=questdlg('Save the ROIs?',...
%                     'ROI ToolBox',...
%                     'Yes','No','Yes');
%                 switch selection
%                     case'Yes'
%                         saveRoi(obj);
%                     case'No'
%                         
%                 end
                
                set(obj.roiTool.roiList,'String',[]);
                set(obj.roiTool.roiList,'Value',1);
            end
            
            if ~isempty (obj.stiTool)
                
                if ~isempty(findobj('Name','Stimulus'))
                    close('Stimulus');
                end
                obj.stiTool=[];
            end
            
            fileList=obj.fileInfo;
            if isfield(fileList,'fullFileName') && ~isempty(fileList.fullFileName)
                delete(obj.subList);
                obj.subList=[];
                fileList.fullFileName=[];
                obj.data=[];
                set(obj.dispFig,'Visible','off');
                set(obj.infoTxt,'String','No Image Open!');
            end
            obj.fileInfo=fileList;
            
            % delete related cell info
            obj.cell = [];
        end
        
        % Function to save single image in the original folder 
        function saveImage(obj,~,~)
            
            imPosition=get(obj.dispFig,'Position');
            obj.data.metadata.previewSize(1)=imPosition(3);
            obj.data.metadata.previewSize(2)=imPosition(4);
            metadata=obj.data.metadata;
            save(obj.data.info.metamat.name,'metadata');
            set(obj.infoTxt,'String','Image Was Saved!');
        end
        
        % Function to save single image as different formats in selected
        % folder
        function saveImageAs(obj,~,~)
            
            defaultPath = 'C:\Users\Minggang\Google Drive\Projects\vGluT3\vglut3-GCaMP6\Paper';
            [filename, pathname] = uiputfile({'*.tif','Tiff(*.tif)';'*.jpg','Jpeg(*.jpg)';...
                                              '*.png','Png(*.png)';'*.gif','Gif(*.gif)';...
                                              '*.*','All Files(*.*)' },'Save as',defaultPath);
            if isequal(filename,0) || isequal(pathname,0)
                set(obj.infoTxt,'String','User pressed cancel!');
                return;
            end
            
            cd(pathname);
            image=getframe(obj.axes1);
            imwrite(image.cdata,filename);
            set(obj.infoTxt,'String',sprintf('Image saved to %s\n',fullfile(pathname, filename)));
        end
        
         function saveImagedata(obj,~,~)
             if ~exist(['raw_im_' obj.openStates.image.fileName '.mat'],'file')
                 movefile(['im_' obj.openStates.image.fileName '.mat'], ['raw_im_' obj.openStates.image.fileName '.mat']);
             end
             imagedata = obj.data.imagedata;
             if obj.data.metadata.iminfo.channel ==1
                obj.data.metadata.previewFrame =mean(imagedata(:,:,:),3);
            else
                obj.data.metadata.previewFrame{1}=mean(imagedata(:,:,1,:),4);
                obj.data.metadata.previewFrame{2}=mean(imagedata(:,:,2,:),4);
             end
            metadata=obj.data.metadata;
            save(obj.data.info.metamat.name,'metadata')
            
             save(obj.data.info.immat.name, 'imagedata');
             set(obj.infoTxt,'String','Imagedata Was Saved!');
         end
         % Function to save stimulus in the metadata
%         function saveStimulus(obj,~,~)
%             
%             if isempty(obj.stiTool) | isempty (obj.stiTool.patternInfo)
%                 return;
%             end
%             
%             obj.data.metadata.stiInfo.data=obj.stiTool.data;
%             obj.data.metadata.stiInfo.baselineLength=obj.stiTool.baselineLength;
%             obj.data.metadata.stiInfo.threshold=obj.stiTool.threshold;
%             obj.data.metadata.stiInfo.avenum=obj.stiTool.avenum;
%             obj.data.metadata.stiInfo.nSti=obj.stiTool.nSti;
%             obj.data.metadata.stiInfo.startFrameN=obj.stiTool.startFrameN;
%             obj.data.metadata.stiInfo.endFrameN=obj.stiTool.endFrameN;
%             obj.data.metadata.stiInfo.trailInfo=obj.stiTool.trailInfo;
%             obj.data.metadata.stiInfo.patternInfo=obj.stiTool.patternInfo;
%             metadata=obj.data.metadata;
%             save(obj.data.info.metamat.name,'metadata');
%             set(obj.infoTxt,'String','Stimulus Was Saved!');
%         end
        
        function exportStack (obj,~,~)
            
            [filename, pathname] = uiputfile({'*.tif','Tiff(*.tif)';...
                '*.*','All Files(*.*)' },'Export as');
            if isequal(filename,0) || isequal(pathname,0)
                set(obj.infoTxt,'string','User pressed cancel!');
                return;
            end
            
            cd(pathname);
            if ~obj.data.info.immat.loaded
                if exist(obj.data.info.immat.name,'file')
                    obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                    obj.data.info.immat.loaded=1;
                end
            end
%             fullfilename= fullfile(pathname,filename);
%             imgdata=squeeze(obj.data.imagedata(:,:,2,:));
         
            imgdata=obj.data.imagedata; imgdata(:,:,3,:)=0;
            option.color=true;
                        saveastiff(imgdata,filename,option);
                        option.color=false;
            % %             saveastiff(squeeze(obj. data.imagedata(:,:,2,:)),[obj.openStates.image.fileName '.tif']);
%             t = Tiff(filename,'w');
%             tagstruct.ImageLength = size(imgdata,1);
%             tagstruct.ImageWidth = size(imgdata,2);
%             tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
%             tagstruct.BitsPerSample = 64;
%             tagstruct.SamplesPerPixel = 1;
%             tagstruct.RowsPerStrip = 16;
%             tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
%             tagstruct.Software = 'MATLAB';
%             t.setTag(tagstruct);
%             t.write(imgdata);
%             t.close();
            set(obj.infoTxt,'String',sprintf('ImageStack exported to %s\n',pathname));
        end
        
        % Function to zoom image by pressing keys; uparrow, zoom in;
        % downarrow zoom out; leftarrow, back to original
        function zoomImage(obj,hObject,eventdata)
            % Callback to parse keypress event data to zoom image
%             axes(obj.axes1);
            if strcmp(eventdata.Key,'uparrow')
                zoomIn(obj,hObject, eventdata)
            elseif strcmp(eventdata.Key,'downarrow')
                zoomOut(obj,hObject, eventdata)
            elseif strcmp(eventdata.Key,'leftarrow')
                zoomReset(obj,hObject, eventdata)
            end
        end
        
        % Function to zoom in image 
        function zoomIn(obj,~, ~)
            
            % Determin whether there are image open
            if isempty(obj.openStates)
                return;
            end
            
            magN     = obj.openStates.image.magN;
            zoomFactor= obj.openStates.image.zoomFactor;
            
            if magN==length(obj.mag)
                return;
            end
            
            magN = magN+1;
            magFactor=obj.mag(magN);
            
            if isfield(obj.openStates.image,'curImageSize')
                imWidth=obj.openStates.image.curImageSize(1);
                imHeight=obj.openStates.image.curImageSize(2);
            elseif isfield(obj.data.metadata,'previewSize')
                imWidth =obj.data.metadata.previewSize(1);
                imHeight=obj.data.metadata.previewSize(2);
            else
                imWidth =obj.data.metadata.iminfo.pixelsPerLine;
                imHeight=obj.data.metadata.iminfo.linesPerFrame;
            end
            
            updateImWidth =imWidth*magFactor/100;
            updateImHeight=imHeight*magFactor/100;
            
            mainFigPos=get(obj.hMain,'Position');
            figPosition=get(obj.dispFig,'Position');            
            axesPosition=get(obj.axes1, 'Position');
            
            if zoomFactor || figPosition (3)>800 || figPosition (4)>800 || updateImWidth>800 || updateImHeight>800
                axes(obj.axes1);
                zoom(obj.mag(magN)/obj.mag(magN-1));
                zoomFactor=zoomFactor+1;                
            
            elseif updateImWidth < figPosition(3)
                set(obj.dispFig,'Position',[figPosition(1) mainFigPos(2)-60-updateImHeight figPosition(3) updateImHeight+figPosition(4)-axesPosition(4)]);
                set(obj.axes1,'Position',[(figPosition(3)-updateImWidth)/2  axesPosition(2) updateImWidth updateImHeight]);
                
            elseif updateImWidth >=figPosition(3)
                set(obj.dispFig,'Position',[figPosition(1) mainFigPos(2)-60-updateImHeight updateImWidth updateImHeight+figPosition(4)-axesPosition(4)]);
                set(obj.axes1,'Position',[0 axesPosition(2) updateImWidth updateImHeight]);
                if obj.openStates.image.viewMode==1
                    set(obj.chSlider,'Position',[0 0 updateImWidth 15]);
                else
                    set(obj.chSlider,'Position',[0 15 updateImWidth 15]);
                    set(obj.frameSlider,'Position',[0 0 updateImWidth 15]);
                end

            end
            
            figName=obj.openStates.image.fileName;
            if magN==11
                updateFigName=figName;
            else
                updateFigName=[figName,' ','(',num2str(magFactor),'%',')'];
            end
            set(obj.dispFig,'Name',updateFigName);
            
            obj.openStates.image.magN = magN;
            obj.openStates.image.zoomFactor =zoomFactor; 
            
            dispFigPos               = obj.dispFig.Position;
            % update position of ROI box if it is open
            if ~isempty(obj.roiTool) 
                obj.roiTool.fig.Position = [dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-250 160 250];
            end
            
            % update position of auto detection box if it is open
            if ~isempty(obj.autoFluoDetector)    
                obj.autoFluoDetector.fig.Position = [dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-400 160 110];
            end
                       
            % update position of Measure box if it is open
            if ~isempty(obj.fp)
                obj.fp.fig.Position = [dispFigPos(1)+dispFigPos(3)+200 dispFigPos(2)+dispFigPos(4)-350 405 350];
            end
            
        end
        
        % Function to zoom out image 
        function zoomOut(obj,~, ~)
            
            % Determin whether there are image open
            if isempty(obj.openStates)
                return;
            end
            
            magN     = obj.openStates.image.magN;
            zoomFactor= obj.openStates.image.zoomFactor;
            
            if magN==1
                return;
            end
            
            magN = magN-1;
            magFactor=obj.mag(magN);
            
            if isfield(obj.openStates.image,'curImageSize')
                imWidth=obj.openStates.image.curImageSize(1);
                imHeight=obj.openStates.image.curImageSize(2);
            elseif isfield(obj.data.metadata,'previewSize')
                imWidth =obj.data.metadata.previewSize(1);
                imHeight=obj.data.metadata.previewSize(2);
            else
                imWidth =obj.data.metadata.iminfo.pixelsPerLine;
                imHeight=obj.data.metadata.iminfo.linesPerFrame;
            end
            
            updateImWidth =imWidth*magFactor/100;
            updateImHeight=imHeight*magFactor/100;
            
            mainFigPos=get(obj.hMain,'Position');
            figPosition=get(obj.dispFig,'Position');
            axesPosition=get(obj.axes1, 'Position');
            
            if zoomFactor
                axes(obj.axes1);
                zoom(obj.mag(magN)/obj.mag(magN+1));
                zoomFactor=zoomFactor-1;
                
            elseif updateImWidth < 134
                set(obj.dispFig,'Position',[figPosition(1) mainFigPos(2)-60-updateImHeight 134 updateImHeight+figPosition(4)-axesPosition(4)]);
                set(obj.axes1,'Position',[(134-updateImWidth)/2 axesPosition(2) updateImWidth updateImHeight]);
                if obj.openStates.image.viewMode==1
                    set(obj.chSlider,'Position',[0 0 134 15]);
                else
                    set(obj.chSlider,'Position',[0 15 134 15]);
                    set(obj.frameSlider,'Position',[0 0 134 15]);
                 end
            elseif updateImWidth >=134
                set(obj.dispFig,'Position',[figPosition(1) mainFigPos(2)-60-updateImHeight updateImWidth updateImHeight+figPosition(4)-axesPosition(4)]);
                set(obj.axes1,'Position',[0 axesPosition(2) updateImWidth updateImHeight]);
                 if obj.openStates.image.viewMode==1
                    set(obj.chSlider,'Position',[0 0 updateImWidth 15]);
                else
                    set(obj.chSlider,'Position',[0 15 updateImWidth 15]);
                    set(obj.frameSlider,'Position',[0 0 updateImWidth 15]);
                 end
            end
            
            figName=obj.openStates.image.fileName;
            if magN==11
                updateFigName=figName;
            else
                updateFigName=[figName,' ','(',num2str(magFactor),'%',')'];
            end
            set(obj.dispFig,'Name',updateFigName);
            
            obj.openStates.image.magN = magN;
            obj.openStates.image.zoomFactor =zoomFactor; 
            
            dispFigPos               = obj.dispFig.Position;
            % update position of ROI box if it is open
            if ~isempty(obj.roiTool) 
                obj.roiTool.fig.Position = [dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-250 160 250];
            end
            
            % update position of auto detection box if it is open
            if ~isempty(obj.autoFluoDetector)    
                obj.autoFluoDetector.fig.Position = [dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-400 160 110];
            end
                       
            % update position of Measure box if it is open
            if ~isempty(obj.fp)
                obj.fp.fig.Position = [dispFigPos(1)+dispFigPos(3)+200 dispFigPos(2)+dispFigPos(4)-350 405 350];
            end
        end
        
        % Function to zoom reset image 
        function zoomReset(~,~, ~)
            
            
        end
        
        % Function to pan image %bugs exists, needs repair
        function panImage (obj, ~, ~)
            
            axes(obj.axes1);
            pan ON;
        end
        
        
        % Function to update image window 
        function  updateDispFig (obj)
            
            if isfield(obj.data.metadata,'previewSize')
                figWidth =obj.data.metadata.previewSize(1);
                figHeight=obj.data.metadata.previewSize(2);
            else
                figWidth =obj.data.metadata.iminfo.pixelsPerLine;
                figHeight=obj.data.metadata.iminfo.linesPerFrame;
            end
            
            % Update dispFig
            mainFigPos=get(obj.hMain,'Position');
            updateFigName=obj.openStates.image.fileName;
             set(obj.dispFig,'Name',updateFigName,'Visible','on');axis off;
            if figWidth >134 % figure width can not be smaller than 134
            set(obj.dispFig,'Position',[mainFigPos(1) mainFigPos(2)-60-figHeight figWidth figHeight+15]);
            else
                set(obj.dispFig,'Position',[mainFigPos(1) mainFigPos(2)-60-figHeight 134 figHeight+15]);
            end
            
            % Update Axes
            imPosition=get(obj.dispFig,'Position');
            if imPosition(3)>figWidth
                set(obj.axes1,'Position',[(imPosition(3)-figWidth)/2 15 figWidth figHeight]);drawnow;                
            else
                set(obj.axes1,'Position',[0 15 figWidth figHeight]);drawnow;
            end
            
            %Update chSlider
            axesPosition = get(obj.axes1, 'Position');
            if obj.data.metadata.iminfo.channel==1
%                 delete(obj.chSlider);
                set(obj.chSlider, 'Visible','off');
                set(obj.axes1,'Position',[axesPosition(1) axesPosition(2)-15 axesPosition(3) axesPosition(4)+15]);drawnow;   
                obj.data.fluoImageHandles=imagesc(obj.data.metadata.previewFrame, 'Parent',obj.axes1);axis off;drawnow;
                colorSelection('Green');
                obj.openStates.image.color='Green';
            else
                set(obj.chSlider, 'Visible','on');
                if imPosition(3)>figWidth
                    set(obj.chSlider,'Position',[0 0 imPosition(3) 15]);drawnow;
%                     set(obj.frameSlider,'Position',[0 0 imPosition(3) 15]);drawnow;
                else
                    set(obj.chSlider,'Position',[0 0 figWidth 15]);drawnow;
%                      set(obj.frameSlider,'Position',[0 0 figWidth 15]);drawnow;
                end
                set(obj.chSlider,'Value',2);
                obj.data.fluoImageHandles=imagesc(obj.data.metadata.previewFrame{2}, 'Parent',obj.axes1); axis off;drawnow;colorSelection('Green');
                obj.openStates.image.color{1}='Red';
                obj.openStates.image.color{2}='Green';
            end
            
            % Update frameSlider
%             frameNumber = obj.data.metadata.iminfo.framenumber;
%             set( obj. frameSlider, 'Max', frameNumber);
%             set (obj. frameSlider, 'SliderStep', [1/frameNumber 10/frameNumber]);
            
            
        end
        
        % Function to select different channels in GRB image
        function sliderSelection (obj,hObject,option) 
            
            if obj.data.metadata.iminfo.channel==2
            chSliderValue=get(obj.chSlider,'Value');
            end
            axes(obj.axes1);
%             cla ;
            
            magN     = obj.openStates.image.magN;
            zoomFactor= obj.openStates.image.zoomFactor; 
            
            hAxes1 = get(obj.axes1,'Children');
            delete (hAxes1(end));
            hAxes1(end)=[];
            nhAxes1=length(hAxes1);
            
            try
                frameSliderValue=round(get(obj.frameSlider,'Value'));
            catch
            end
            
            switch option
                case 1% for chSlider
                    if   obj.data.metadata.iminfo.channel==2
                        
                        if obj.openStates.image.viewMode==1 % view Average Frame
%                             hAxes1(nhAxes1+1)=imagesc(obj.data.metadata.previewFrame{chSliderValue}, 'Parent',obj.axes1);axis off;drawnow;colorSelection(obj.openStates.image.color{chSliderValue});
                             hAxes1(nhAxes1+1) = imshow(obj.data.metadata.previewFrame{chSliderValue},[],'Parent',obj.axes1);
                             axes(obj.axes1);colorSelection(obj.openStates.image.color{chSliderValue});drawnow;axis off;drawnow;
                        else % view Original Stacks
                            hAxes1(nhAxes1+1)  = imagesc(obj.data.imagedata(:,:,chSliderValue, frameSliderValue));axis off;drawnow;
                             axes(obj.axes1);colorSelection(obj.openStates.image.color{chSliderValue});
                        end
                        set(obj.chSlider, 'Enable', 'off');
                        figure(obj.dispFig);
                        drawnow;
                        set(obj.chSlider, 'Enable', 'on');
                    else
                        hAxes1(nhAxes1+1)=imagesc(obj.data.metadata.previewFrame, 'Parent',obj.axes1);axis off;drawnow;
                         axes(obj.axes1);colorSelection(obj.openStates.image.color);
                    end
                    
                case  2 % for frameSlider
                    
                    set(obj.infoTxt,'String',frameSliderValue);
                    if ~obj.data.info.immat.loaded
                        if exist(obj.data.info.immat.name,'file')
                            obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                            obj.data.info.immat.loaded=1;
                        end
                    end
                    if obj.data.metadata.iminfo.channel==1
                         hAxes1(nhAxes1+1)=imagesc(obj.data.imagedata(:,:,1, frameSliderValue), 'Parent',obj.axes1);axis off;drawnow;
                          axes(obj.axes1);colorSelection(obj.openStates.image.color);
                    else
                        hAxes1(nhAxes1+1)=imagesc(obj.data.imagedata(:,:,chSliderValue, frameSliderValue), 'Parent',obj.axes1);axis off;drawnow;
                         axes(obj.axes1);colorSelection(obj.openStates.image.color{chSliderValue});
                    end
                        set(obj.frameSlider, 'Enable', 'off');
                        figure(obj.dispFig);
                        drawnow;
                        set(obj.frameSlider, 'Enable', 'on');
            end
            
            
            if ~isfield(obj.openStates,'roi')
                if zoomFactor
                    startZoomMagN=magN-zoomFactor;
                    zoom (obj.mag(magN)/obj.mag(startZoomMagN));
                end
            end
                
            curhAxes1=get(obj.axes1,'Children'); % some problem here 
            if hAxes1(end)~=curhAxes1(end)
                set(obj.axes1,'Children',hAxes1);
            end
%             % a but needs figure out
%             if nhAxes1==0
%                 if ~isfield(obj.openStates,'roi')
%                     if zoomFactor
%                         startZoomMagN=magN-zoomFactor;
%                         zoom (obj.mag(magN)/obj.mag(startZoomMagN));
%                     end
%                 end
%             else
%                 if zoomFactor
%                     startZoomMagN=magN-zoomFactor;
%                     zoom (obj.mag(magN)/obj.mag(startZoomMagN));
%                 end
%             end
            
            % force the slider to lose focus, so to use KeyPressFcn for zoomImage. This is very much a hack.
%             set(hObject, 'Enable', 'off');
%             figure(obj.dispFig);
%             drawnow;
%             set(hObject, 'Enable', 'on');

        end
        
         function channelSelection (obj,hObject,~) 
             
              option =1;
            sliderSelection (obj,hObject,option); 
         end
        
        function frameSelection(obj,hObject, ~)
            
            option =2;
            sliderSelection (obj,hObject,option); 
        end
        
        function importTiffStack (obj, ~, ~)
           % reading tiff 
            [filename,pathname] = uigetfile ('*.tif', 'Pick a .tif file');
            cd(pathname);
            fullfilename=fullfile(pathname,filename);
            processImage (obj, fullfilename);

            
%             infoImage = imfinfo(filename);
%             mImage =infoImage(1).Width;
%             nImage =infoImage(1). Height;
%             ch = infoImage(1).SamplesPerPixel;
%             frameNumber = length(infoImage);
%             imagedata=zeros (nImage, mImage, ch, frameNumber, 'uint16');
%             
%             t= Tiff (filename, 'r');
%             for i=1:frameNumber
%                 t.setDirectory(i);
%                 imagedata(:,:,:,i)=t.read();
%             end
%             t.close;
%             % set  obj data
%             obj.data =[];
%             % imagedata
%             if ch==1
%             obj.data.imagedata = imagedata;
%             iminfo.channel=1;
%             obj.data.metadata.previewFrame =mean(imagedata(:,:,:),3);
%             else
%             obj.data.imagedata = imagedata(:,:,1:2,:);  
%              iminfo.channel=2;
%              obj.data.metadata.previewFrame{1}=mean(imagedata(:,:,1,:),4);
%              obj.data.metadata.previewFrame{2}=mean(imagedata(:,:,2,:),4);
%             end
%             % metadata
%             obj.openStates.image.fileName=filename;
%             obj.data.info.immat.loaded =1;
%             iminfo.data= infoImage(1).FileModDate;
%             iminfo.framenumber=frameNumber;
%             iminfo.pixelsPerLine=mImage;
%             iminfo.linesPerFrame=nImage;
%            obj.data.metadata.iminfo=iminfo;
%                
%             set(obj.infoTxt,'String', 'Creating Image');           
%             
%             axes(obj.axes1);
%             cla reset;
%             updateDispFig(obj);
%             
%             obj.openStates.image.curImage=obj.data.metadata.previewFrame;
%             obj.openStates.image.curImagePath=pathname;
%             obj.openStates.image.magN=11;
%             obj.openStates.image.zoomFactor=0;
%             obj.openStates.image.viewMode=1;
%        
%             set(obj.infoTxt,'string', []);
            
        end
        
        % Function to open a file from folder
        function openFromFolder (obj,~,~)
            
            try
                curImagePath = obj.openStates.image.curImagePath;
            catch
                curImagePath =[];
            end
            
            if ~isempty(curImagePath)
                filedir=uigetdir(curImagePath);
            else
                try
                    filedir = uigetdir('E:\Jimmy''s Lab\projects\vglut3\vglut3-GCaMP3\raw');
                catch
                    filedir = uigetdir;
                end
            end
            
            if ~filedir
                set(obj.infoTxt,'String','No folder selected!');
                return;
%             elseif isempty(strfind(filedir,'BrightnessOverTime'))&& isempty(strfind(filedir,'ZSeries'))&& isempty(strfind(filedir,'TSeries'))
%                 set(obj.infoTxt,'String','Not Support!');
%                 return;
            end
            cd(filedir);
            obj.data=[];
            processImage(obj, filedir);
%             if ~go
%                 set(obj.infoTxt,'String','Error in the folder!')
%             end
            
        end
        
        % Function to open sample files (only 1 now)
        function openSample (obj, ~, ~)
            path=fileparts(which('brightnessOverTime'));
            filedir = [path '\samples\BrightnessOverTime-01222014-1409-2198'];
            cd(filedir);
            obj.data=[];
            processImage(obj, filedir);
        end
        % Function to open multiple files from folder
        function openBatchFromFolder (obj,~,~)
                                                   
           selectFileNames = selectBatchFromFolder (obj.hMain.Position);
           
           if ~isempty(selectFileNames)
               for i=1:length(selectFileNames)
                   processImage(obj,selectFileNames{i});
               end
           end
           
        end
        
        function openCell (obj,~,~)
            
            obj.cell = [];
            
            filedir=uigetdir;
            [~, cellname] = fileparts(filedir);
            cellinfoname  =[filedir '\info_' cellname '.mat'];
            if exist(cellinfoname,'file')
                cellinfo = load(cellinfoname);
                for i = 1: length(cellinfo.data.fileinfo.filenames)
                    fullfilename{i} = fullfile(filedir, cellinfo.data.fileinfo.filenames{i});
                    processImage(obj, fullfilename{i});
                end
                obj.cell = cellmaker(fullfilename,filedir); 
                obj.cell.cellinfo = cellinfo.data.cellinfo;
                obj.cell.h.cellinfo.String = obj.cell.cellinfo;
            end
         end
        
        % Function to open a file from the open list
        function openListFile (obj,~,~,filedir)
            
            % determine whether the image is opened currently
            if  isequal(obj.openStates.image.curImagePath,filedir)
                %if opened, determin whether the image is same as previewFrame
                if isequal(obj.openStates.image.curImage,obj.data.metadata.previewFrame)
                    return;
                else
                    axes(obj.axes1);
                    cla; updateDispFig(obj);
                    obj.openStates.image.curImage=metadata.previewFrame;
                    obj.openStates.image.curImagePath=filedir;
                    obj.openStates.image.magN=11;
                    obj.openStates.image.zoomFactor=0;
                end
            end
            
            cd(filedir);
            axes(obj.axes1);
            cla;
            processImage(obj,filedir);
            
        end
        
        
        % Function to process image information when openning files
        function  processImage (obj, filedir)
            
            obj.dispFig.UserData = filedir; % for later use, e.g., to save stimulus, notes, exact this path info. Previously used pwd, but there were errors. 
            
            [~, fileName] = fileparts(filedir);
            obj.openStates.image.fileName=fileName;
            set(obj.infoTxt,'String', sprintf('Opening %s\n',fileName));
            
            % generate open list
            fileList=obj.fileInfo;
                      
            if isfield(fileList,'fullFileName') && ~isempty(fileList.fullFileName)
                fileN=length(fileList.fullFileName);
                i=1;
                while i<=fileN
                    if ~strcmp(fileList.fullFileName{i},filedir)
                        i=i+1;
                    else
                        break;
                    end
                    
                    if i==fileN+1;
                        fileList.fullFileName{fileN+1}=filedir;
                        obj.subList(fileN+1)=uimenu(obj.openList,'label',filedir,'position',1,'Callback',{@obj.openListFile,filedir});
                    end
                end
                
            else
                fileList.fullFileName{1}=filedir;
                obj.subList(1)=uimenu(obj.openList,'label',filedir,'position',1,'Callback',{@obj.openListFile,filedir});
                
            end
            obj.fileInfo =  fileList;         
                        
            %load image
            
            axes(obj.axes1);
            cla reset;
            try
                delete(obj.openStates.roi.curRoih);
            catch
            end
            set(obj.dispFig,'visible','off');
%             setappdata(handles.axes1,'zoomFactor',0);
            

%             obj.data.info.immat.exist=0; obj.data.info.immat.loaded=0;
%             obj.data.info.metamat.exist=0; obj.data.info.metamat.loaded=0;
            
            obj.data.info.immat.name  =fullfile(filedir, sprintf('im_%s.mat',fileName)); obj.data.info.immat.loaded=0;
            obj.data.info.metamat.name=fullfile(filedir, sprintf('meta_%s.mat',fileName));
            obj.data.info.stimmat.name=fullfile(filedir, sprintf('stim_%s.mat',fileName));
            
%             go=0;
%             
%             if ~go
%                 
%                 imagedataUP=0;
                
                if  exist(obj.data.info.immat.name,'file') && exist (obj.data.info.metamat.name,'file')
                    
%                     obj.data.info.metamat.exist=1;
                    load(obj.data.info.metamat.name);
                    
                    if isfield(metadata.iminfo, 'frameNumber')
                        f=fieldnames(metadata.iminfo);
                        f{strmatch('frameNumber', f, 'exact')}='framenumber';
                        c=struct2cell(metadata.iminfo);
                        metadata.iminfo=cell2struct(c,f);
                    end
                    
%                     obj.data.info.metamat.loaded=1;
                    obj.data.metadata=metadata;
                                        
%                     if  isfield(metadata,'previewFrame')
                        
                        updateDispFig(obj);
%                         obj.data.fluoImageHandles=imagesc(metadata.previewFrame,'parent',obj.axes1);drawnow;
%                         axis off;
%                         colormap(jet);
                        obj.openStates.image.curImage=metadata.previewFrame;
                        obj.openStates.image.curImagePath=filedir;
                        obj.openStates.image.magN=11;
                        obj.openStates.image.zoomFactor=0;
                        obj.openStates.image.viewMode =1;
%                         imagedataUP=1;
%                     else
%                         try
%                             dy=metadata.imheader.acq.linesPerFrame;
%                             dx=metadata.imheader.acq.pixelsPerLine;
%                             obj.data.fluoImageHandles=imagesc(uint16(1000*rand(dy,dx)),'parent',obj.axes1);
%                         catch
%                             
%                         end
%                     end
                    obj.data.metadata=metadata;
                else
                   openImage(obj,filedir);
                end
                
%                 if imagedataUP %show ROI
                    
                    axes(obj.axes1);
                    hold on;
                    if isfield(obj.data.metadata,'ROIdata')  && ~isempty(obj.data.metadata.ROIdata)
                        nROIs  =length(obj.data.metadata.ROIdata);
                        t=zeros(nROIs);
                        for i=1:nROIs
                            lineh=plot(obj.data.metadata.ROIdata{i}.pos(:,1),obj.data.metadata.ROIdata{i}.pos(:,2),'white', 'LineWidth',2);
                            obj.data.metadata.ROIdata{i}.linehandles=lineh;
                            t(i)=text(obj.data.metadata.ROIdata{i}.cenX,obj.data.metadata.ROIdata{i}.cenY,sprintf('%d',i),'color','white','parent',obj.axes1);
                            obj.data.metadata.ROIdata{i}.thandles=t(i);
                            hold on;
                        end
                        obj.openStates.roi.curRoih=[];
                        obj.openStates.roi.curRoiN=1;
                        roiToolBox (obj);
                        set(obj.roiTool.roiList,'string',{1:1:nROIs}, 'userdata',{1:1:nROIs});
                        set(obj.roiTool.roiList,'Value',1);
                    else
                        if ~isempty(obj.roiTool)
                            set(obj.roiTool.roiList,'string',[]);
                            set(obj.roiTool.roiList,'value',1);
                        end
                    end
                    
                    % if the fluoProcessor is open, read parameters from
                    % metadata
                    if ~isempty(obj.fp)
                        if isfield(obj.data.metadata,'processPara')
                            obj.fp.bcftEdit.String             = obj.data.metadata.processPara.filter;
                            obj.fp.traceLengthEdit.String      = obj.data.metadata.processPara.traceLength;
                            obj.fp.yminEdit.String             = obj.data.metadata.processPara.ymin;
                            obj.fp.ymaxEdit.String             = obj.data.metadata.processPara.ymax;
                            
                            % read baseline parameters
                            baselineLength  = obj.data.metadata.processPara.baselineLength;
                            if ~isempty(baselineLength) && ~unique(isnan(baselineLength))
                                obj.fp.tivblRb.Value   = 1;
                                obj.fp.tvblEdit.String = baselineLength;
                            else
                                % previous version only has baselineLength
                                
                                fixedLength     = obj.data.metadata.processPara.fixedLength;
                                if ~isempty(fixedLength) && ~unique(isnan(fixedLength))
                                    obj.fp.fdRb.Value    = 1;
                                    obj.fp.fdEdit.String = fixedLength;
                                else
                                    fixedValue      = obj.data.metadata.processPara.fixedValue;
                                    obj.fp.fvRb.Value    = 1;
                                    obj.fp.fvEdit.String = fixedValue;
                                end
                            end
                            % read prestimulus length, earlier version doesn't have
                            % this parameter
                            try
                                obj.fp.preStmLengthEdit.String = obj.data.metadata.processPara.preStmLength;
                            catch
                            end
                        end
                        
                        try
                            nROI = length(obj.data.metadata.ROIdata);
                            obj.fp.srEdit.String = ['1:' num2str(nROI)];
                        catch
                        end
                    end
 
                if ~isempty (obj.stiTool) 
                    
%                     if ~isempty(obj.stiTool.hfig)
                    if ~isempty(findobj('Name', 'Stimulus'))
                        close('Stimulus');
                    end
                    obj.stiTool=[];
                end
                
                if  exist(obj.data.info.stimmat.name,'file') 
                    
                    load(obj.data.info.stimmat.name);
                    obj.stiTool=stidata;
                end
                
                if ~isempty(obj.nf) 
                    if ~isempty(obj.nf.h) % notes figure is open
                        try
                            obj.nf.notes = obj.data.metadata.notes;
                            obj.nf.h.editField.String = obj.nf.notes;
                        catch
%                             delete(obj.nf.h.fig);
%                             obj.nf =[];
                            obj.nf.notes = [];
                            obj.nf.h.editField.String = '';
                        end
                    else
                        obj.nf =[];
                    end
                end
%                 go=1;
%             end
        end
        
        % Function to open a new file
        function openImage(obj,filedir)           
             
            if isdir(filedir)
            [imagedata, metadata] = importPrairieTif(obj,filedir);
            else
                [imagedata, metadata] = openTiffStack(obj,filedir);
                [filepath, filename] = fileparts (filedir);
                obj.data.info.metamat.name=[filepath '\meta_' filename '.mat'];
                obj.data.info.immat.name=[filepath '\im_' filename '.mat'];
                obj.data.info.stimmat.name=[filepath '\stim_' filename '.mat'];
            end
            
            imsize=size(imagedata);
            if length(imsize)==5 % multiple sequences, Tseries
                [~, filename]=fileparts(filedir);
                imdata=imagedata;
                for i=1:imsize(5)
                    subfoldername=[filename '-sequence' num2str(i)];
                    mkdir(filedir,subfoldername);
                    
                    metadata.previewFrame{1}=mean(imdata(:,:,1,:,i),4);
                    metadata.previewFrame{2}=mean(imdata(:,:,2,:,i),4);
                    
                    obj.data.info.metamat.name=[fullfile(filedir,subfoldername) '\meta_' subfoldername '.mat'];
                    obj.data.info.immat.name=[fullfile(filedir,subfoldername) '\im_' subfoldername '.mat'];
                    
                    imagedata=squeeze(imdata(:,:,:,:,i));
                    
                    save(obj.data.info.metamat.name,'metadata');
                    set(obj.infoTxt,'string', 'Saving Imagedata');
                    drawnow;
                    save(obj.data.info.immat.name,'imagedata');
                end
                
            else
%                 try
                if metadata.iminfo.channel ==1
                    metadata.previewFrame =mean(imagedata(:,:,:),3);
                else
                    metadata.previewFrame{1}=mean(imagedata(:,:,1,:),4);
                    metadata.previewFrame{2}=mean(imagedata(:,:,2,:),4);
                end
%                 catch
%                     metadata.iminfo.channel =1;
%                     metadata.previewFrame =mean(imagedata(:,:,:),3);
%                 end
                %             metadata.stiInfo.sti(:,1)= 1:1:metadata.iminfo.framenumber;
                %             metadata.stiInfo.sti(:,2)= squeeze(mean((mean(imagedata(:,:,1,:),1)),2)); % average all pixel intensity in every frame in CH1 to show light stimulus
                
                save(obj.data.info.metamat.name,'metadata')
                set(obj.infoTxt,'string', 'Saving Imagedata');
                drawnow;
                save(obj.data.info.immat.name,'imagedata')
            end
%             obj.data.info.metamat.exist=1;
            obj.data.metadata=metadata;
            
            set(obj.infoTxt,'String', 'Creating Image');           
            
            axes(obj.axes1);
            cla reset;
            updateDispFig(obj);
%             obj.data.fluoImageHandles=imagesc(metadata.previewFrame,'parent',obj.axes1);
%             axis off;
%             cmap=zeros(64,3);cmap(:,2)=0:1/63:1;colormap(cmap);
            obj.openStates.image.curImage=metadata.previewFrame;
            obj.openStates.image.curImagePath=filedir;
            obj.openStates.image.magN=11;
            obj.openStates.image.zoomFactor=0;
            obj.openStates.image.viewMode=1;
            
%             set(obj.infoTxt,'string', 'Saving Imagedata');
%             drawnow;
%             save(obj.data.info.immat.name,'imagedata')
%             obj.data.info.immat.exist=1;
            obj.data.imagedata=imagedata;        
            set(obj.infoTxt,'string', []);
            
            
%             go=1;
        end
        
        %------------------------------------------------------------------
        % Function to open Prairie Tiffs, modified from import_PrairieTif.m
        % @GrassRoots Biotechnology 2011
        function [imagedata, metadata]=importPrairieTif(obj,img_full_path)
                                  
            DataType      ='uint16';         

            % If image folder or tif or XML files DNE, return empty
            if isempty(dir(img_full_path)) || numel(dir([img_full_path '/*.tif']))==0 ...
                    || numel(dir([img_full_path '/*.xml']))==0
                imagedata = []; return;
            end
            
            % Make path *nix compatible, extract name of image
%             img_full_path = regexprep(img_full_path, '\', '/');
            [~, img_name] = fileparts(img_full_path);
                        
            % Read in metadata from xml file
            text = fileread([img_full_path '/' img_name '.xml']);
            
            date = regexp ( text, 'date="(.*?)"', 'tokens', 'once');
            
            % Check software version, added 1/18/2018
            ver  = regexp (text, 'PVScan.*?version="(.*?)"', 'tokens', 'once');
            % For latestest version, the xml file was changed
            if ver{1} == '5.4.64.100'
                
                % Find dimensions of 5D image
                
                % XY dimensions:
                xdim = str2double(regexp(text, ...
                    'PVStateValue key="pixelsPerLine" value="(\d*)"', 'tokens','once'));
                ydim = str2double(regexp(text, ...
                    'PVStateValue key="linesPerFrame" value="(\d*)"', 'tokens','once'));
                
                % Channel dimension
                ch_img_names_cell =  regexp(text, ...
                    'File channel="(\d*)".*?filename="(.*?)"', 'tokens');
                ch = cellfun(@(x) str2double(x{1}),ch_img_names_cell);
                img_names = cellfun(@(x) x{2},ch_img_names_cell, 'UniformOutput', 0);
                ch_n   = unique (ch);
                nCh    = numel(ch_n);
                
                % Z or framenumber for timeseries
                framenumber = length(ch)/nCh;
                zslice = 1: framenumber;
                
                % T dimension
                tpoints = 1;
                
                % Bit depth of img in filesystem
                tif_bit_depth = str2double(regexp(text, ...
                    'PVStateValue key="bitDepth" value="(\d*)"', 'tokens','once'));
                
                % Parse  metadata, HERE ONLY KEEP date, channel,
                % framenumber, frameperiod, pixelsPerLine, linesPerFrame
                set(obj.infoTxt,'string', 'Parsing Metadata');
                drawnow;
                
                framePeriod = str2double(regexp(text, ...
                    'PVStateValue key="framePeriod" value="(0.\d*)"', 'tokens','once'));
                parNames = [{'date'} {'channel'} {'framenumber'} {'framePeriod'} {'pixelsPerLine'} {'linesPerFrame'}];
                parValues  = [date {nCh} {framenumber} {framePeriod} {xdim} {ydim}];
                metadata.iminfo = cell2struct(parValues, parNames, 2);
                
            else
                % Find dimensions of 5D image %
                
                % XY dimensions: Entries assumed to be the same for pixel dimensions
                xdim = str2double(regexp(text, ...
                    'Key key="pixelsPerLine".*?value="(\d*)"', 'tokens','once'));
                ydim = str2double(regexp(text, ...
                    'Key key="linesPerFrame".*?value="(\d*)"', 'tokens','once'));
                
                % Z axis dimension
                z_cell =  regexp(text, 'Frame relative.*?index="(\d*)"', 'tokens');
                zslice = cellfun(@(x) str2double(x{1}),z_cell);
                
                
                % T axis dimension
                t_cell =  regexp(text, 'Sequence type=.*?cycle="(\d*)"', 'tokens');
                tpoints = cellfun(@(x) str2double(x{1}),t_cell);
                if tpoints == 0; tpoints=1; end
                framenumber =length (z_cell)/length(t_cell);
                
                % Channel dimension (img names found on same line, parsed also)
                ch_img_names_cell =  regexp(text, ...
                    'File channel="(\d*)".*?filename="(.*?)"', 'tokens');
                ch = cellfun(@(x) str2double(x{1}),ch_img_names_cell);
                img_names = cellfun(@(x) x{2},ch_img_names_cell, 'UniformOutput', 0);
                ch_n   = unique (ch);
                nCh    = numel(ch_n);
                
                % Bit depth of img in filesystem
                tif_bit_depth = str2double(regexp(text, ...
                    '<Key key="bitDepth".*?value="(\d*)"', 'tokens','once'));
                
                % Parse  metadata
                set(obj.infoTxt,'string', 'Parsing Metadata');
                drawnow;
                
                frameText  = regexp (text, '<Frame .*?</Frame>', 'match', 'once');
                parNames  = regexp ( frameText, '<Key key="(\w+)".*?', 'tokens');
                parValues  = regexp ( frameText, '<Key .*?value="(.*?)"', 'tokens');
                parValues  = [parValues{:}]; parValues = [num2cell(str2double(parValues(1:2))) parValues(3) num2cell(str2double(parValues(4:end)))];
                parNames = [{'date'} {'channel'} {'framenumber'} parNames{:}];
                parValues  = [date {nCh} {framenumber} parValues{:}];
                metadata.iminfo = cell2struct(parValues, parNames, 2);
                
            end
            
            % Channel index
            ch_ind = ch;
                 
            
            % Zslice and timpoint index need to be repeated to match img_names elements
            flat = @(x) x(:);
            z_ind = flat(repmat(zslice, [nCh 1]));
            t_ind = flat(repmat(tpoints, [numel(unique(z_ind))*nCh 1]));
                        
            % Clear xml text form memory, not needed for final img import
            clear text;
                        
            % Initialize image specified datatype
            imagedata = zeros(ydim, xdim, nCh, ...
                max(zslice), max(tpoints), DataType);
            
            % Initialize waitebar for loading img
            waitbar_init(obj.loadAxes);
            
            % Read individual tif files into 5D img
            for n = 1:numel(img_names)
                tic;
                waitbar_fill(obj.loadAxes,n/numel(img_names));
                set(obj.infoTxt,'string', sprintf('Reading Image %d # %d / %d',str2double(img_full_path(end-3:end)), n, numel(img_names)));
                imagedata(:,:,ch_ind(n),z_ind(n),t_ind(n)) = imread([img_full_path...
                    '/' img_names{n}]) * double(intmax(DataType)/2^tif_bit_depth); %read image as 16-bit tiff file!!important to understand bit depth, the way to code color
                dt=toc;
                set(obj.loadTxt,'string',sprintf('%.1f s remaining',dt*(numel(img_names)-n)));
            end
            set(obj.loadTxt,'string',[]);
            
            % make waitbar invible after loading 
            c = get(obj.loadAxes,'Children');
            delete (c);
            set(obj.loadAxes,'visible','off');
            drawnow;
            
            % Remove extra singleton dimensions
            imagedata = squeeze(imagedata);
            
        end
        
        function [imagedata, metadata] = openTiffStack (obj,filedir)
            
            infoImage = imfinfo(filedir);
            % now only supports tiffs written by ScanImage or ImageJ
            if isfield (infoImage(1), 'ImageDescription')
                if isempty (strfind(infoImage(1).ImageDescription, 'state.software.version=3.7'))
                    software ='ScanImage';
                elseif isempty (strfind(infoImage(1).ImageDescription, 'ImageJ'))
                    software  ='ImageJ';
                else
                    software ='Others';
                end
            end
            
            
            % metadata, only import several useful from image headers
           metadata.iminfo.date = infoImage(1).FileModDate;
           frameNumber= length(infoImage); metadata.iminfo.frameNumber=frameNumber;
           mImage=infoImage(1).Width;  metadata.iminfo.pixelsPerLine=mImage;
           nImage=infoImage(1).Height;  metadata.iminfo.linesPerFrame=nImage;
           metadata.iminfo.bitDepth=infoImage(1).BitDepth;
           switch software
               case 'ScanImage'
                   ch=str2double(regexp(infoImage(1).ImageDescription, 'state.acq.numberOfChannelsSave=(\d*)', 'tokens','once'));
                   frameRate=str2double(regexp(infoImage(1).ImageDescription, 'state.acq.frameRate=(\d*)', 'tokens','once'));
               case 'ImageJ'
                   
               case 'Others'
           end
           
        
            mImage =infoImage(1).Width;
            nImage =infoImage(1). Height;
            ch = infoImage(1).SamplesPerPixel;
            frameNumber = length(infoImage);
            imagedata=zeros (nImage, mImage, ch, frameNumber, 'uint16');
            
%             t= Tiff (filename, 'r');
 t= Tiff (filedir, 'r');
            for i=1:frameNumber
                t.setDirectory(i);
                imagedata(:,:,:,i)=t.read();
            end
            t.close;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Part 2. edit image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        % Function to show image info
        function showImageInfo (obj, ~, ~)
            
            if isfield(obj.data,'metadata')
                figName=obj.openStates.image.fileName;
                infoName=fieldnames(obj.data.metadata.iminfo);
                infoValue=struct2cell(obj.data.metadata.iminfo);
                infoLength=length(infoName);
                info=cell(infoLength,1);
                
                for i=1:infoLength
                    info{i}=sprintf('%s : %s',infoName{i},num2str(infoValue{i}));
                end
                
                dispFigPos            =get(obj.dispFig,'Position');
                
                figure   ('Name',figName(1,end-8:end),'NumberTitle','off','color','white',...
                                   'MenuBar','none','position',[dispFigPos(1)-240 100 220 780],'Resize','off');
                infoList=uicontrol('Style','listbox','Value',1,'BackgroundColor','white',...
                                   'Position',[1 1 219 780],'HorizontalAlignment','left','FontSize',10);
                set(infoList,'String',info);
                set(infoList,'Value',1);
            else
                NoImage;
                return;
            end
        end
        %
        function makeSubstack (obj, ~, ~)
            
            [filename, pathname] = uiputfile ('*.*','Save Substack as',obj.openStates.image.fileName);
            if isequal(filename,0) || isequal(pathname,0)
                return;
            end
            
            prompt   = {'Slices:'};
            dlg_title= 'Substack Maker';
            num_lines= 1;
            def      = {''};
            p        = inputdlg(prompt,dlg_title,num_lines,def); 
            slices   = str2num(p{1});
            
            if ~obj.data.info.immat.loaded
                if exist(obj.data.info.immat.name,'file')
                    obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                    obj.data.info.immat.loaded=1;
                end
            end
            
            imagedata                      = obj.data.imagedata(:,:,:,slices);
            metadata.iminfo             = obj.data.metadata.iminfo;
            metadata.iminfo.framenumber = length(slices);
            metadata.previewFrame{1}    = mean(imagedata(:,:,1,:),4);
            metadata.previewFrame{2}    = mean(imagedata(:,:,2,:),4);
            
            % generate folder for substack
            cd (pathname);
            mkdir(filename);
            fullfilename = fullfile(pathname,filename);
            cd(fullfilename);
            save(['meta_' filename '.mat'],'metadata');
            save(['im_' filename '.mat'],'imagedata');
            
            % generate preview
            obj.data=[];
            processImage(obj, fullfilename);
        end
        %
        function viewOriginalStack (obj,hObject, ~)
            
            if obj.openStates.image.viewMode==2
                return;
            end
            
            obj.openStates.image.viewMode=2;
            % update dispFig
            imPosition=get(obj.dispFig,'Position');
            set(obj.dispFig, 'Position', [imPosition(1) imPosition(2)-15 imPosition(3) imPosition(4)+15]);
            %update axes1
            axesPosition=get(obj.axes1, 'Position');
            set(obj.axes1, 'Position', [axesPosition(1) axesPosition(2)+15 axesPosition(3) axesPosition(4)]);
            %update sliders
            if  obj.data.metadata.iminfo.channel==2
            slider1Position=get(obj.chSlider, 'Position');
            set(obj.chSlider, 'Position', [ slider1Position(1) slider1Position(2)+15 slider1Position(3) slider1Position(4)]);
            set(obj.frameSlider, 'Position', [ slider1Position(1) 0 slider1Position(3) slider1Position(4)]);
            set(obj.frameSlider, 'Value', 1);
            else
                set(obj.frameSlider, 'Position', [ 0 0 axesPosition(3) 15]);
            end
            set(obj.frameSlider,'Visible', 'on');
            try
            frameNumber = obj.data.metadata.iminfo.framenumber;
            catch
                frameNumber = obj.data.metadata.iminfo.frameNumber;
            end
            set( obj. frameSlider, 'Max', frameNumber);
            set (obj. frameSlider, 'SliderStep', [1/frameNumber 10/frameNumber]);
            %update image
            sliderSelection (obj,hObject,2); 
        end
        
        %
        function viewAverageFrame (obj,hObject, ~)
            
             if obj.openStates.image.viewMode==1
                return;
             end
            
             obj.openStates.image.viewMode=1;
            % update dispFig
            imPosition=get(obj.dispFig,'Position');
            set(obj.dispFig, 'Position', [imPosition(1) imPosition(2)+15 imPosition(3) imPosition(4)-15]);
            %update axes1
            axesPostion=get(obj.axes1, 'Position');
            set(obj.axes1, 'Position', [axesPostion(1) axesPostion(2)-15 axesPostion(3) axesPostion(4)]);
            %update sliders
            if  obj.data.metadata.iminfo.channel==2
            slider1Position=get(obj.chSlider, 'Position');
            set(obj.chSlider, 'Position', [ slider1Position(1) slider1Position(2)-15 slider1Position(3) slider1Position(4)]);
            end
            set(obj.frameSlider,'Visible', 'off');
            %update image
            sliderSelection (obj,hObject,1); 
            
        end
        
        function openImageInNewWindow(obj,~, ~)
            
            c=getframe(obj.axes1);
            figure;
            imshow(c.cdata,[]);
        end
        
        % Function to ajust image size
        function adjustImageSize (obj, ~, ~)
            
            if strcmp(get(obj.dispFig,'Visible'),'off')
                NoImage;
                return;
            end
            
            if isfield(obj.openStates,'curImageSize')
                imWidth=obj.openStates.image.curImageSize(1);
                imHeight=obj.openStates.image.curImageSize(2);
            elseif isfield(obj.data.metadata,'previewSize')
                imWidth =obj.data.metadata.previewSize(1);
                imHeight=obj.data.metadata.previewSize(2);
            else
                imWidth =obj.data.metadata.iminfo.pixelsPerLine;
                imHeight=obj.data.metadata.iminfo.linesPerFrame;
            end
            
            obj.resize.fig         =figure   ('Name','Resize','NumberTitle','off',...
                                              'MenuBar','none','Position',[150 150 200 140],...
                                              'Resize','off','Color','white');
            obj.resize.fixedRatio  =uicontrol('Style','checkbox','String','Constrain aspect ratio',...
                                              'Value',1,'Position',[10 40 150 20],...
                                              'HorizontalAlignment','left','Backgroundcolor','white');
                                    uicontrol('Style','text','String','Width (pixels):',...
                                              'Position',[10 95 100 20],...
                                              'HorizontalAlignment','right','Backgroundcolor','white');
                                    uicontrol('Style','text','String','Height (pixels):',...
                                              'Position',[10 70 100 20],...
                                              'HorizontalAlignment','right','Backgroundcolor','white');
            obj.resize.imWidthEdit =uicontrol('Style','edit','String',imWidth,...
                                              'Position',[120 95 50 20],...
                                              'HorizontalAlignment','left','Backgroundcolor','white');
            obj.resize.imHeightEdit=uicontrol('Style','edit','string',imHeight,...
                                              'Position',[120 70 50 20],...
                                              'HorizontalAlignment','left','backgroundcolor','white');
            set(obj.resize.imWidthEdit,'Callback',@obj.changeImWidth);
            set(obj.resize.imHeightEdit,'Callback',@obj.changeImHeight);
            obj.resize.processResize=uicontrol('Style','pushbutton','String','OK',...
                                               'Position',[120 10 50 20],...
                                               'HorizontalAlignment','center','Backgroundcolor','white',...
                                               'Callback',@obj.processResize);
        end
        
        % Function to change image width
        function changeImWidth (obj, ~, ~)
            
            if get(obj.resize.fixedRatio,'Value')
                originalImWidth =obj.data.metadata.iminfo.pixelsPerLine;
                originalImHeight=obj.data.metadata.iminfo.linesPerFrame;
                imWidth    =str2double(get(obj.resize.imWidthEdit,'String'));
                imHeight   =round(imWidth/originalImWidth*originalImHeight);
                set(obj.resize.imHeightEdit,'String',imHeight);drawnow;
            end
        end
        
        % Function to change image height
        function changeImHeight (obj, ~, ~)
            
            if get(obj.resize.fixedRatio,'Value')
                originalImWidth =obj.data.metadata.iminfo.pixelsPerLine;
                originalImHeight=obj.data.metadata.iminfo.linesPerFrame;
                imHeight    =str2double(get(obj.resize.imHeightEdit,'String'));
                imWidth     =round(imHeight/originalImHeight*originalImWidth);
                set(obj.resize.imWidthEdit,'String',imWidth);drawnow;
            end
        end
        
        % Function to process resize
        function processResize (obj, ~, ~)
            
            imWidth =str2double(get(obj.resize.imWidthEdit,'String'));
            imHeight=str2double(get(obj.resize.imHeightEdit,'String'));
            obj.openStates.image.curImageSize(1)=imWidth;
            obj.openStates.image.curImageSize(2)=imHeight;
            
            figPosition=get(obj.dispFig,'Position');
            figName=obj.openStates.image.fileName;
            
            if imWidth >600 || imHeight >600
                
                imFactor  =round(600/max(imWidth,imHeight)*100);
                diff(1:10)=obj.mag(1:10)-imFactor;
                absDiff   =abs(diff);
                minDiff   =min(absDiff);
                magN      =find(absDiff==minDiff);
                magFactor =obj.mag(magN);
                
                obj.openStates.image.magN = magN;
                obj.openStates.image.zoomFactor =0; 
                
                updatedImWidth=round(imWidth*magFactor/100);
                updatedImHeight=round(imHeight*magFactor/100);
                updateFigName=[figName,' ','(',num2str(magFactor),'%',')'];
                
                set(obj.dispFig,'Name',updateFigName,'Position',[figPosition(1) obj.screendims(4)-140-updatedImHeight updatedImWidth updatedImHeight+15]);
                set(obj.axes1,'Position',[0 15 updatedImWidth updatedImHeight]);
                set(obj.chSlider,'Position',[0 0 updatedImWidth 15]);
                
            elseif imWidth < 134
                
                obj.openStates.image.magN = 11;
                obj.openStates.image.zoomFactor =0;
                
                set(obj.dispFig,'Name',figName,'Position',[figPosition(1) obj.screendims(4)-140-imHeight 134 imHeight+15]);
                set(obj.axes1,'Position',[(134-imWidth)/2 15 imWidth imHeight]);
                set(obj.chSlider,'Position',[0 0 134 15]);
            else    
                
                obj.openStates.image.magN = 11;
                obj.openStates.image.zoomFactor =0;
                
                set(obj.dispFig,'Position',[figPosition(1) obj.screendims(4)-140-imHeight imWidth imHeight]);
                set(obj.axes1,'Position',[0 15 imWidth imHeight]);
                set(obj.chSlider,'Position',[0 0 imWidth 15]);
                
            end
            figure(obj.dispFig);
            close('Resize');
        end
        
        function adjustImageContrast(obj,~,~)
            
            axes(obj.axes1);
            imcontrast;
        end
        
        % Function to set colors 
        function colorSet (obj, hObject, ~)
            
            label = get( hObject, 'Label' );
            axes(obj.axes1);
            colorSelection(label);
            
            chSliderValue=get(obj.chSlider,'Value');
            obj.openStates.image.color{chSliderValue}=label;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Part 3. Tools
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        % slice Alignment
        function sliceAlignment (obj, ~, ~)
        
            set(obj.infoTxt,'String','Please select a rectangle region!');
            axes(obj.axes1);
            selectedRegion = imrect;
            selectedRegionPosition = round(selectedRegion.getPosition);
            
            chSliderValue=get(obj.chSlider,'Value');
            frameSliderValue=round(get(obj.frameSlider,'Value'));
            
            % load imagedata
            if ~obj.data.info.immat.loaded
                if exist(obj.data.info.immat.name,'file')
                    obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                    obj.data.info.immat.loaded=1;
                end
            end
            
            template = obj.data.imagedata( selectedRegionPosition(2)+1:selectedRegionPosition(2)+selectedRegionPosition(4),...
                                                            selectedRegionPosition(1)+1:selectedRegionPosition(1)+selectedRegionPosition(3),...
                                                            chSliderValue, frameSliderValue);
             imsize = size(obj.data.imagedata);
             corImagedata= zeros( imsize(1), imsize(2),imsize(3),imsize(4), 'uint16');
             waitbar_init(obj.loadAxes);
             
             for i=1:imsize(4)
                 waitbar_fill(obj.loadAxes,i/imsize(4));
                 set(obj.infoTxt,'String', sprintf('Correcting Image # %d / %d',i, imsize(4)));
                 c=normxcorr2( template,obj.data.imagedata(:,:,chSliderValue, i));
                 [ypeak, xpeak] = find (c==max(c(:)));
                 yoffSet = ypeak-size (template, 1);
                 xoffSet = xpeak-size (template, 2);
                 ycor = selectedRegionPosition(2)-yoffSet;
                 xcor = selectedRegionPosition(1)-xoffSet;
                 set(obj.loadTxt,'String',sprintf('X: %d, Y: %d',xcor, ycor));
                 if ycor>0 && xcor>0
                 corImagedata(ycor+1: imsize(1), xcor+1:imsize(2), chSliderValue, i)=obj.data.imagedata(1: imsize(1)-ycor, 1:imsize(2)-xcor, chSliderValue, i);
                 elseif ycor<=0 &&xcor<=0
                 corImagedata(1: imsize(1)-abs(ycor), 1:imsize(2)-abs(xcor), chSliderValue, i)=obj.data.imagedata(abs(ycor)+1: imsize(1), abs(xcor)+1:imsize(2), chSliderValue, i);
                 elseif ycor>0 && xcor<=0
                  corImagedata(ycor+1: imsize(1), 1:imsize(2)-abs(xcor), chSliderValue, i)=obj.data.imagedata(1: imsize(1)-ycor, abs(xcor)+1:imsize(2), chSliderValue, i);
                 else
                  corImagedata(1: imsize(1)-abs(ycor), xcor+1:imsize(2), chSliderValue, i)=obj.data.imagedata(abs(ycor)+1: imsize(1), 1:imsize(2)-xcor, chSliderValue, i);  
                 end
                 
             end         
            
            set(obj.loadTxt,'string',[]);
            
            % make waitbar invible after loading 
            c = get(obj.loadAxes,'Children');
            delete (c);
            set(obj.loadAxes,'visible','off');
            drawnow;
            
             selectedRegion.delete;
             obj.data.imagedata=corImagedata;
             set(obj.infoTxt,'String','Correction was done!');
             
        end
        
        % roiToolBox
        function roiToolBox (obj, ~, ~)
            
            if isempty(obj.roiTool)
                initRoiToolBox (obj)
            end
        end
        
        % initialize gui for roiToolBox
        function initRoiToolBox (obj)
            
            dispFigPos            =get(obj.dispFig,'Position');
            
            obj.roiTool.fig       =figure   ('Name','ROI ToolBox','NumberTitle','off',...
                                             'MenuBar','none','Position',[dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-250 160 250],...
                                             'Resize','off','Color','white',... 
                                             'CloseRequestFcn',@obj.roiToolBoxClose);
                                         
%             setappdata(obj.roiToolBox,'handles',obj.roiToolBoxh);
            obj.roiTool.roiList   =uicontrol('Style','listbox','Value',1,'BackgroundColor','white',...
                                             'Position',[1 1 80 249],...
                                             'HorizontalAlignment','left',...
                                             'Callback',@obj.roiList);
            obj.roiTool.addRoi    =uicontrol('Style','pushbutton','String','Add',...
                                             'Position',[81 220 79 30],...
                                             'Callback',@obj.addRoi);
            obj.roiTool.updateRoi =uicontrol('Style','pushbutton','String','Update',...
                                             'Position',[81 190 79 30],...
                                             'Callback',@obj.updateRoi);
            obj.roiTool.deletRoi  =uicontrol('Style','pushbutton','String','Delete',...
                                             'Position',[81 160 79 30],...
                                             'Callback',@obj.deleteRoi);
            obj.roiTool.importRoi =uicontrol('Style','pushbutton','String','Import',...
                                             'Position',[81 130 79 30],...
                                             'Callback',@obj.importRoi);
            obj.roiTool.saveRoi   =uicontrol('Style','pushbutton','String','Save',...
                                             'Position',[81 100 79 30],...
                                             'Callback',@obj.saveRoi);
            obj.roiTool.measureRoi=uicontrol('Style','pushbutton','String','Measure',...
                                             'Position',[81 70 79 30],...
                                             'Callback',@obj.measureRoi);
            obj.roiTool.showAllRoi=uicontrol('Style','checkbox','String','ShowAll',...
                                             'Position',[81 35 77 25],'Backgroundcolor','white');
            obj.roiTool.labelRoi  =uicontrol('Style','checkbox','String','Labels',...
                                             'Position',[81 10 77 25],'Backgroundcolor','white',...
                                             'Callback',@obj.labelRoi );
        end
        
        % Functio to select in roiList
        function roiList (obj, hObject, ~)
            
           
            % handles.roiList=getappdata(handles.roiToolBox,'handles');
%             obj.roiList=guidata(obj.axes1);
            if ~isfield(obj.data,'metadata') || ~isfield(obj.data.metadata,'ROIdata')  || isempty(obj.data.metadata.ROIdata)
                NoROI;
                return;
            end
            
            axes(obj.axes1);
            hold on;
            nROIs  =length(obj.data.metadata.ROIdata);
            preSelectROI  =obj.openStates.roi.curRoih;
            preSelectIndex=obj.openStates.roi.curRoiN;
            
            if preSelectIndex ~=0
                if nROIs==1 %only one ROI
%                   return;
                else
                    if ~isempty(preSelectROI)
                    delete(preSelectROI);
                    lineh=plot(obj.data.metadata.ROIdata{preSelectIndex}.pos(:,1),obj.data.metadata.ROIdata{preSelectIndex}.pos(:,2),'white', 'LineWidth',2);
                    obj.data.metadata.ROIdata{preSelectIndex}.linehandles=lineh;
                    end
                end
            end
            
            index=get(hObject,'Value');
            delete(obj.data.metadata.ROIdata{index}.linehandles);
            selectROI=impoly(obj.axes1,obj.data.metadata.ROIdata{index}.pos);
            obj.openStates.roi.curRoih=selectROI;
            obj.openStates.roi.curRoiN=index;
        end
        
        % Function to add new roi
        function addRoi (obj,~,~)
            
            if isempty(obj.openStates)
                
                choice=questdlg('There are no images open! Would you like to open now?',...
                    'No Image',...
                    'No', 'Yes','Yes');
                switch choice
                    case 'No'
                        return;
                    case 'Yes'
                        openFromFolder (obj);
                end
                return;
            end
            
            axes(obj.axes1);
            if isfield (obj.openStates,'roi')
                preSelectROI  =obj.openStates.roi.curRoih;
                preSelectIndex=obj.openStates.roi.curRoiN;
            else
                preSelectROI=[];
                preSelectIndex=[];
            end
            hold on;
            
            % check whether there are ROIs already, and show these ROIs
            if isfield(obj.data.metadata,'ROIdata') &&~isempty(obj.data.metadata.ROIdata)
                nROIs  =length(obj.data.metadata.ROIdata);
                curROIn=nROIs+1;
                
                if ~isempty(preSelectIndex)
                    delete(preSelectROI);
                    lineh=plot(obj.data.metadata.ROIdata{preSelectIndex}.pos(:,1),obj.data.metadata.ROIdata{preSelectIndex}.pos(:,2),'white', 'LineWidth',2);
                    obj.data.metadata.ROIdata{preSelectIndex}.linehandles=lineh;
%                     setappdata(handles.roiList,'handles',[]);
%                     setappdata(handles.roiList,'index',[]);
                end
                
            else
                curROIn=1;
            end
            
            % draw new ROI
            
            newROIPolyh=impoly;
            newROIdata=getPosition(newROIPolyh);
            % ROI just added was selected by defaut! This is different than selection from ROIList
            obj.openStates.roi.curRoih=newROIPolyh;
            obj.openStates.roi.curRoiN=curROIn;
            
            % Determine the center of the polygon and label ROI
            x=(min(newROIdata(:,1))+max(newROIdata(:,1)))/2;
            y=(min(newROIdata(:,2))+max(newROIdata(:,2)))/2;
            t(curROIn)=text(x,y,sprintf('%d',curROIn),'color','white','Parent',obj.axes1);
            set(obj.roiTool.roiList,'String',{1:1:curROIn}, 'Userdata',{1:1:curROIn});
            set(obj.roiTool.roiList,'Value', curROIn);           
            
            newROIdata=[newROIdata;newROIdata(1,:)];
            obj.data.metadata.ROIdata{curROIn}.pos=newROIdata;
            obj.data.metadata.ROIdata{curROIn}.cenX=x;
            obj.data.metadata.ROIdata{curROIn}.cenY=y;
            obj.data.metadata.ROIdata{curROIn}.ROIhandles=newROIPolyh;
            obj.data.metadata.ROIdata{curROIn}.thandles=t(curROIn);
            
            % Add defaut value to Total ROI number in Measure panel if it
            % is open
            if ~isempty(obj.fp)
                obj.fp.srEdit.String = ['1:' num2str(curROIn)];
            end
                
        end
        
        % Function to update roi
        function updateRoi (obj, ~, ~)
            
            selectIndex=obj.openStates.roi.curRoiN;
            
            if ~isfield(obj.data,'metadata')
                NoImage;
                return;
            elseif ~isfield(obj.data.metadata,'ROIdata') || isempty(obj.data.metadata.ROIdata)
                NoROI;
                return;
            elseif isempty(selectIndex)
                NoROI_Selected
                return;
            end
            axes(obj.axes1);
            hold on;
            
            selectROI=obj.openStates.roi.curRoih;
            updatePos=getPosition(selectROI);
            updateROI=selectROI;
            
            x=(min(updatePos(:,1))+max(updatePos(:,1)))/2;
            y=(min(updatePos(:,2))+max(updatePos(:,2)))/2;
            delete(obj.data.metadata.ROIdata{selectIndex}.thandles);
            t(selectIndex)=text(x,y,sprintf('%d',selectIndex),'color','white','Parent',obj.axes1);
            
            updatePos=[updatePos;updatePos(1,:)];
            obj.data.metadata.ROIdata{selectIndex}.pos=updatePos;
            obj.data.metadata.ROIdata{selectIndex}.cenX=x;
            obj.data.metadata.ROIdata{selectIndex}.cenY=y;
            obj.data.metadata.ROIdata{selectIndex}.ROIhandles=updateROI;
            obj.data.metadata.ROIdata{selectIndex}.thandles=t(selectIndex);
            
            if isfield(obj.data.metadata.ROIdata{selectIndex},'linehandles')
                obj.data.metadata.ROIdata{selectIndex}=rmfield(obj.data.metadata.ROIdata{selectIndex},'linehandles');
            end
            
            if isfield(obj.data.metadata.ROIdata{selectIndex},'intensity')
                obj.data.metadata.ROIdata{selectIndex}=rmfield(obj.data.metadata.ROIdata{selectIndex},'intensity');
            end

            obj.openStates.roi.curRoiN=selectIndex;
            obj.openStates.roi.curRoih=updateROI;
        end
        
        % Function to delete roi
        function deleteRoi (obj, ~, ~)
            
            selectIndex=obj.openStates.roi.curRoiN;
            
            if ~isfield(obj.data,'metadata')
                NoImage;
                return;
            elseif ~isfield(obj.data.metadata,'ROIdata') || isempty(obj.data.metadata.ROIdata)
                NoROI;
                return;
            elseif isempty(selectIndex)
                if strcmp(DeleteAll,'No')
                    return;
                else
                    axes(obj.axes1);
                    cla;
                    chSliderValue=get(obj.chSlider,'Value');
                    
                    hAxes1 = get(obj.axes1,'Children');
                    nhAxes1=length(hAxes1);            
                    
                    if isequal(obj.openStates.image.curImage,obj.data.metadata.previewFrame)
                        hAxes1(nhAxes1+1)=imagesc(obj.openStates.image.curImage{chSliderValue},'Parent',obj.axes1);colorSelection(obj.openStates.image.color{chSliderValue});
                    else
                        hAxes1(nhAxes1+1)=imagesc(obj.data.curImage,'Parent',obj.axes1);colormap(gray);
                    end
                    set(obj.axes1,'Children',hAxes1);
                    
                    obj.data.metadata=rmfield(obj.data.metadata,'ROIdata');
                    set(obj.roiTool.roiList,'String',[]);
                    set(obj.roiTool.roiList,'Value',1);
                    return;
                end
            end
            
%             hold on;
            nROIs  =length(obj.data.metadata.ROIdata);
            
            % delete selected ROI
            selectROI=obj.openStates.roi.curRoih;
            delete(selectROI);
            
            % delete text for selected ROI
            delete(obj.data.metadata.ROIdata{selectIndex}.thandles);
            obj.data.metadata.ROIdata{selectIndex}=[];
            obj.data.metadata.ROIdata = obj.data.metadata.ROIdata(~cellfun(@isempty, obj.data.metadata.ROIdata));
            
            leftnROIs=nROIs-1;
            if leftnROIs==0
                set(obj.roiTool.roiList,'String',[]);
            else  
                t=zeros(leftnROIs);
                for i=1:leftnROIs
                    delete(obj.data.metadata.ROIdata{i}.thandles)
                    t(i)=text(obj.data.metadata.ROIdata{i}.cenX,obj.data.metadata.ROIdata{i}.cenY,sprintf('%d',i),'Color','white','Parent',obj.axes1);
                    obj.data.metadata.ROIdata{i}.thandles=t(i);
                end
                set(obj.roiTool.roiList,'String',{1:1:leftnROIs}, 'Userdata',{1:1:leftnROIs});
            end
            set(obj.roiTool.roiList,'Value',1); 
            obj.openStates.roi.curRoiN=[];
            obj.openStates.roi.curRoih=[];
            
            % Add defaut value to Total ROI number in Measure panel if it
            % is open
            if ~isempty(obj.fp)
                if leftnROIs == 0
                    obj.fp.srEdit.String = '';
                else
                    obj.fp.srEdit.String = ['1:' num2str(leftnROIs)];
                end
            end

        end
        
        % Function to import roi
        function importRoi (obj, ~, ~ )
                        
            if isfield(obj.data,'metadata')
                
                filedir=uigetdir;
                if ~filedir
                    return;
                end
                cd(filedir);
                [~, filename] = fileparts(filedir);
                metafilename=fullfile(filedir, ['meta_' filename '.mat']);
                load(metafilename);
                
                axes(obj.axes1);
                hold on;
                if isfield(metadata,'ROIdata') && ~isempty(metadata.ROIdata)
                    obj.data.metadata.ROIdata=metadata.ROIdata;
                    nROIs  =length(obj.data.metadata.ROIdata); 
                    t=zeros(nROIs);
                    for i=1:nROIs
                        lineh=plot(obj.data.metadata.ROIdata{i}.pos(:,1),obj.data.metadata.ROIdata{i}.pos(:,2),'white', 'LineWidth',2);
                        obj.data.metadata.ROIdata{i}.linehandles=lineh;
                        t(i)=text(obj.data.metadata.ROIdata{i}.cenX,obj.data.metadata.ROIdata{i}.cenY,sprintf('%d',i),'color','white','parent',obj.axes1);
                        obj.data.metadata.ROIdata{i}.thandles=t(i);
                        hold on;
                    end
                    obj.openStates.roi.curRoih=[];
                    obj.openStates.roi.curRoiN=1;
                    %                         roiToolBox (obj);
                    set(obj.roiTool.roiList,'string',{1:1:nROIs}, 'userdata',{1:1:nROIs});
                    set(obj.roiTool.roiList,'Value',1);
                    
                else
                    NoROI;
                    return;
                end
                
            else
                NoImage;
                return;
            end
        end
        
        % Function to save roi
        function saveRoi (obj, ~, ~)
            
            try 
                d = obj.data.metadata.ROIdata;
            catch
                obj.infoTxt.String = 'Error! No Image or No ROI data!';
                return;
            end
            
            nROIs  =length(d); %only save ROI info, no fluo intensity.
            for i=1:nROIs
                if isfield(d{i},'intensity')
                    d{i}=rmfield(d{i},'intensity');                   
                end
                
                if isfield(d{i},'linehandles')
                    d{i}=rmfield(d{i},'linehandles');                   
                end
                
                if isfield(d{i},'ROIhandles')
                    d{i}=rmfield(d{i},'ROIhandles');
                end
                
                 if isfield(d{i},'thandles')
                     d{i}=rmfield(d{i},'thandles');
                end
            end
            
            load(obj.data.info.metamat.name); 
            metadata.ROIdata = d;
            save(obj.data.info.metamat.name, 'metadata');
            set(obj.infoTxt,'string','ROIs Saved!');
        end
        
        % Function to measure the intensity of roi
        function measureRoi (obj, ~, ~)
            
        
            nFrames  =obj.data.metadata.iminfo.framenumber;
           
            frameRate=obj.data.metadata.iminfo.framePeriod;
            fluoTime =frameRate*(1:1:nFrames);
            
            selectIndex=obj.openStates.roi.curRoiN;
            if isempty(selectIndex)
                NoROI_Selected;
                return;
            end
            if obj.data.metadata.iminfo.channel==1
                chN=1;
            else
                chN=get(obj.chSlider,'Value');
            end
            [intensityAve]=getintensity(obj,selectIndex,chN);
            
            figure(200);
            if chN==1
                plot(fluoTime,intensityAve,'Color','b');
            else
                plot(fluoTime,intensityAve,'Color','k');
            end
            hold on;
        end
        
        % Function to calculate the intensity
        function [intensityAve]=getintensity(obj,ROIn,chN)
            
            if isfield(obj.data.metadata.ROIdata{ROIn},'intensity')&&...
                    length(obj.data.metadata.ROIdata{ROIn}.intensity)>=chN &&...
                    ~isempty (obj.data.metadata.ROIdata{ROIn}.intensity {chN})
                intensityAve=obj.data.metadata.ROIdata{ROIn}.intensity{chN};
            else
                try
                nFrames  =obj.data.metadata.iminfo.framenumber;
                catch
                    nFrames  =obj.data.metadata.iminfo.frameNumber;
                end
                if ~obj.data.info.immat.loaded
                    if exist(obj.data.info.immat.name,'file')
                        obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                        obj.data.info.immat.loaded=1;
                    end
                end
                
                selectROI=obj.openStates.roi.curRoih;% problem here
                if ~isempty(selectROI)
                    curROI=selectROI;
                    mask=createMask(curROI);
                else
                    curROI=impoly(obj.axes1,obj.data.metadata.ROIdata{ROIn}.pos);
                    mask=createMask(curROI);
                    delete(curROI);
                end
                pmask=find(mask);
                npmask=max(size(pmask));
                intensityAve=zeros(nFrames,1);
                
                for i=1:nFrames
                    a=squeeze(obj.data.imagedata(:,:,chN,i));
                    intensityAve(i)=sum(a(pmask))/npmask;
                end
                obj.data.metadata.ROIdata{ROIn}.intensity{chN}=intensityAve;
            end
        end
        
        
        function labelRoi(obj,hObject,~)
            
             if isempty(obj.openStates) % no image open 
                return;
            end
            
            axes(obj.axes1);
            if isfield (obj.openStates,'roi')
                try
                    ROIdata=obj.data.metadata.ROIdata;
                    nROIs  =length(ROIdata);
                catch
                end
   
            end
           
            if get(hObject, 'Value')
                
                for i=1:nROIs
                    obj.data.metadata.ROIdata{i}.thandles=text(obj.data.metadata.ROIdata{i}.cenX,obj.data.metadata.ROIdata{i}.cenY,sprintf('%d',i),'color','white','Parent',obj.axes1);
                end
            else
                for i=1:nROIs
                    delete( obj.data.metadata.ROIdata{i}.thandles);
                    obj.data.metadata.ROIdata{i}=rmfield(obj.data.metadata.ROIdata{i},'thandles');
                end
            end
                
            
            
        end
        % Function to close roiToolBox window
        function roiToolBoxClose (obj, ~, ~)
            
%             handles.roiList=guidata(handles.axes1);
            
            if ~isempty(get(obj.roiTool.roiList,'String'))
                
%                 load(obj.data.info.metamat.name); 
%                 if ~isequal(metadata.ROIdata, obj.data.metadata.ROIdata)
%                     
%                     selection=questdlg('ROIs were changed. Save the changes?',...
%                         'ROI ToolBox',...
%                         'Yes','No','Yes');
%                     switch selection
%                         case'Yes'
%                             saveRoi(obj);
%                             
%                         case'No'
%                             
%                     end
%                 end
                
                axes(obj.axes1);
                 hAxes1 = get(obj.axes1,'Children');
                  nhAxes1=length(hAxes1);
                  delete(hAxes1(1:nhAxes1-1));
                 updateHAxes1=hAxes1(end);
                 set(obj.axes1,'Children',updateHAxes1);
                 
%                 cla;
%                 if isequal(obj.openStates.image.curImage,obj.data.metadata.previewFrame)
%                     imagesc(obj.openStates.image.curImage{2},'Parent',obj.axes1);colormap(jet);
%                 else
%                     imagesc(obj.openStates.image.curImage{2},'Parent',obj.axes1);colormap(gray);
%                 end
                obj.data.metadata=rmfield(obj.data.metadata,'ROIdata');
                
            end
            
            delete(obj.roiTool.fig);
            obj.roiTool=[];
        
        end
        
        % stimulus
        function stimulus (obj, ~, ~)
            
            % No image open
            if isempty(obj.data)
                set(obj.infoTxt,'String','Please Open An Image First!');
                return;
            end
            
            % two versions, compare date first
            y=str2double(regexp(obj.data.metadata.iminfo.date,'.*/.*/(\d*)','tokens','once'));
            m=str2double(regexp(obj.data.metadata.iminfo.date,'(\d)*/.*','tokens','once'));
            d=str2double(regexp(obj.data.metadata.iminfo.date,'.*/(\d)*/.*','tokens','once'));
            a=datecmp(y,m,d,2019,12,31);
            
            if a>=0 % version before 12/31/2016
            %Image open, did not open stiTool for this image
            if isempty (obj.stiTool)
                % Stimulus already processed, and saved in the metadata
                if isfield(obj.data.metadata,'stiInfo')
%                     obj.stiTool=stimulus(obj.data.metadata.stiInfo);
                    obj.stiTool=stim(obj.data.metadata.stiInfo);
                % First time to process the stimulus related to the image
                else
                    lastSti=[];
                    if isfield(obj.openStates,'sti')
                        lastSti=obj.openStates.sti;
                    end
                    
                    if obj.data.metadata.iminfo.channel==2
%                     choice=questdlg('Would you like to open stimulus from the red channel?',...
%                         'Open Stimulus',...
%                         'Yes','No','Yes');
%                     switch choice
%                         case 'Yes' % Chose stimulus from the red channel
                            if ~obj.data.info.immat.loaded
                                if exist(obj.data.info.immat.name,'file')
                                    obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                                    obj.data.info.immat.loaded=1;
                                end
                            end
                            stidata=squeeze(mean((mean(obj.data.imagedata(:,:,1,:),1)),2));
%                            obj.stiTool=stimulus(stidata);
                            obj.stiTool=stim(stidata,lastSti);
%                         case 'No'  % Import stimulus from other files
%                             obj.stiTool=stimulius();
                    else
                            obj.stiTool=stim();
                    end
                end
            else
                %Image open, opened stiTool for this image
                if ~isfield(obj.stiTool, 'h') || isempty(obj.stiTool.h.fig)
                    
%                     obj.stiTool=stimulus(obj.stiTool);
                      obj.stiTool=stim(obj.stiTool);
                else
                    return;
                end
            end
          
            waitfor(obj.stiTool.h.fig);
            try
                obj.openStates.sti.threshold=obj.stiTool.threshold;
                obj.openStates.sti.patternInfo=obj.stiTool.patternInfo;
                obj.openStates.sti.paraInfo =obj.stiTool.paraInfo;
            catch
            end
            else
                
            end
            
            
           
%             if ~isempty(obj.stiTool)
%                 return;
%             end
%             
%             if isempty (obj.openStates)
%                 set(obj.infoTxt,'String','No Image Open!')
%                 return;    
%             end
%             
%             if ~isfield (obj.data.metadata,'stidata')
%                 
%                 choice=questdlg('Where would you like to open stimulus from?',...
%                     'Open Stimulus',...
%                     'File','Red Channel','Red Channel');
%                 switch choice
%                     case 'File',
%                         [filename, pathname] = uigetfile('*.m', 'Pick a file');
%                         if isequal(filename,0) || isequal(pathname,0)
%                             set(obj.infoTxt,'String','User pressed cancel');
%                             return;
%                         else
%                             set(obj.infoTxt,'String',printf('User selected %s', fullfile(pathname, filename)));
%                         end
%                         
%                         stiRaw=fullfile(pathname, filename);
%                         load(stiRaw); obj.data.metadata.stidata.stiRaw=stiRaw;
%                     case 'Red Channel'
%                         obj.data.metadata.stidata.stiRaw=squeeze(mean((mean(obj.data.imagedata(:,:,1,:),1)),2));
%                         
%                 end
%             end
        end
        
        function addnote(obj, ~,~)
            
            if isempty(obj.nf)
                if isfield(obj.data,'metadata')
                    try
                        obj.nf = notewriter(obj.data.metadata.notes);
                    catch
                        obj.nf = notewriter;
                    end
                else
                    return;
                end
            else
                if isempty(obj.nf.h)
                    obj.nf = notewriter(obj.nf.notes);
                else
                    return;
                end
            end
        end
        
        function generateCell(obj, ~,~)
            
            if isempty(obj.cell)
                selection=questdlg('Select from Open List ?',...
                    '',...
                    'Yes','No','Yes');
                switch selection
                    case'Yes'
                        selectFilenames = selectBatchFromFolder (obj.fileInfo.fullFileName);
                        obj.cell        = cellmaker(selectFilenames);
                    case'No'
                        obj.cell = cellmaker;
                end
            else
                if isempty(obj.cell.h)
                    obj.cell = cellmaker(obj.cell);
                else
                    return;
                end
            end
            
        end
        
        % An add-in function to analyze wave-PIP2 corrlation
        function wavePIP(obj, ~,~)
            
            frameNumber = obj.data.metadata.iminfo.framenumber;
            selectIndex = obj.openStates.roi.curRoiN;
            % get raw intensity for current ROI
            inten = getintensity (obj, selectIndex, 2);
            % filter data
            inten          = moving_average(inten,4);
            % create a dialog
            hFig = dialog ( 'windowstyle', 'normal','Resize','on');
            % create an axes
            ax = axes ( 'parent', hFig, 'position', [0.1 0.2 0.8 0.7], 'nextplot', 'add' );
            plot(ax, 1:frameNumber,inten,'k','LineWidth',1);
            % create the draggable horizontal line
            threshold = movableHorizontalLine( hFig, ax);
            
            % detect the waves based on the threshold
            s=zeros(); i=1;
            for n=1:frameNumber;
                if inten(n) >= threshold
                    s(i)= n;
                    i=i+1;
                end
            end
            imdata = obj.data.imagedata;
%             ss = setdiff(1:frameNumber, s);
            ss = 1:1000;
            red.control = mean(imdata(:,:,1,ss),4);
            red.wave    = mean(imdata(:,:,1,s),4);
            green.control = mean(imdata(:,:,2,ss),4);
            green.wave    = mean(imdata(:,:,2,s),4);
            
            figure(100);
            subplot(1,2,1);
            imshow(red.control,[350 450]);axis off;drawnow;colorSelection('Red');     
            subplot(1,2,2);
            imshow(red.wave,[350 450]);axis off;drawnow;colorSelection('Red');
            figure(200);
            subplot(1,2,1);
            imshow(green.control,[300 1500]);axis off;drawnow;colorSelection('Green');
            subplot(1,2,2);
            imshow(green.wave,[300 1500]);axis off;drawnow;colorSelection('Green');
            
            figure(300);
            baseline = mean(inten(ss));
            deltaF   = (inten - baseline) / baseline *100;
            plot(1:frameNumber,deltaF,'k','LineWidth',1);
           
%             d=find(diff(s)~=1);
%             nSti=length(d)+1;
%             
%             startFrameN=[];
%             endFrameN=[];
%             startFrameN(1)=s(1)+filtern;
%             startFrameN(2:nSti)=s(d+1)+filtern;
%             endFrameN(1:nSti-1)=s(d)-filtern;
%             endFrameN(nSti)=s(end)-filtern;
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Part 4. Analyze
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        % Auto Fluorescence Detection figure
        function autoFluoChangeDetection (obj, ~, ~)
            
            if isempty(obj.autoFluoDetector)
                initAutoFluoDetector (obj)
            end
        end
        
        function initAutoFluoDetector (obj)
                  
            
            obj.autoFluoDetector.fig  =figure   ('Name','Auto Fluorescence Detector','NumberTitle','off',...
                'MenuBar','none',...
                'Resize','off','Color','white',...
                'CloseRequestFcn',@obj.autoFluoDetectionClose);
            try 
                roiFigPos=get(obj.roiTool.fig,'Position');
                set(obj.autoFluoDetector.fig,'Position',[roiFigPos(1) roiFigPos(2)-150 160 110]);
            catch
                dispFigPos            =get(obj.dispFig,'Position');
                set(obj.autoFluoDetector.fig,'Position',[dispFigPos(1)+dispFigPos(3)+20 dispFigPos(2)+dispFigPos(4)-400 160 110]);
            end
            
            %Creat uicontrol
            obj.autoFluoDetector.para               =uipanel('Title','',...
               'FontSize',9,...
               'BackgroundColor','white',...
               'Units','pixels',...
               'Position',[2 40 158 60],...
               'Parent',  obj.autoFluoDetector.fig);
            %Sti radio group
            obj.autoFluoDetector.sti                     =uibuttongroup('Units','pixels',...
               'BorderType','none',...
               'BackgroundColor','white',...
               'Position',[0 35 190 25],...
               'Parent',obj.autoFluoDetector.para);
            obj.autoFluoDetector.allSti            =uicontrol('Style','radiobutton',...
                'String','All Sti',...
                'BackgroundColor','white',...
                'Position',[1 0 70 20],...
                'Value',1,...
                'Parent',  obj.autoFluoDetector.sti);
            obj.autoFluoDetector.individualPattern         =uicontrol('Style','radiobutton',...
                'String','Pattern',...
                'BackgroundColor','white',...
                'Position',[50 0 90 20],...
                'Parent',  obj.autoFluoDetector.sti);
            obj.autoFluoDetector.patternEdit         =uicontrol('Style','edit',...
                'String','0',...
                'BackgroundColor','white',...
                'Position',[110 3 40 15],...
                'Parent',  obj.autoFluoDetector.sti);
             %onoff radio group
            obj.autoFluoDetector.resp                    =uibuttongroup('Units','pixels',...
               'BorderType','none',...
               'BackgroundColor','white',...
               'Position',[0 5 190 25],...
               'Parent',obj.autoFluoDetector.para);
            obj.autoFluoDetector.onResp            =uicontrol('Style','radiobutton',...
                'String','ON',...
                'BackgroundColor','white',...
                'Position',[1 0 60 20],...
                'Value',1,...
                'Parent', obj.autoFluoDetector.resp);
            obj.autoFluoDetector.offResp         =uicontrol('Style','radiobutton',...
                'String','OFF',...
                'BackgroundColor','white',...
                'Position',[41 0 55 20],...
                'Parent', obj.autoFluoDetector.resp);
            obj.autoFluoDetector.onoffResp         =uicontrol('Style','radiobutton',...
                'String','ONOFF',...
                'BackgroundColor','white',...
                'Position',[87 0 60 20],...
                'Parent',  obj.autoFluoDetector.resp);
            % Buttons
           
           obj.autoFluoDetector.processAutoDetection  =uicontrol('Style','pushbutton',...
               'String','Detect',...
               'BackgroundColor','white',...
               'Position',[90 10 60 25],...
               'Parent',obj.autoFluoDetector.fig,...
               'Callback',@obj.processAutoDetection);
           try
                stiInfo=obj.stiTool;
            catch
                stiInfo=obj.data.metadata.stiInfo;
           end
            
           try
               set(obj.autoFluoDetector.patternEdit,'String',['1:' num2str(length(stiInfo.patternInfo))]);
           catch
           end
        end
        
        function autoFluoDetectionClose (obj,hObject, ~)
            
            delete(hObject);
            obj.autoFluoDetector=[];
        end

        % function to detect fluorescence change automatically
        function processAutoDetection (obj,hObject, ~)
            
            if get (obj.autoFluoDetector.onResp,'Value')
                option=1;
            elseif get (obj.autoFluoDetector.offResp,'Value')
                option=2;
            else
                option=3;
            end
            
            %Stimulus information
            try
                stiInfo=obj.stiTool;
            catch
                stiInfo=obj.data.metadata.stiInfo;
            end
            
            if get(obj.autoFluoDetector.allSti,'Value')
                trailN=1:1:length(stiInfo.trailInfo);
            
            
            [fluoChangeData]=caculateFluoChange(obj,option,trailN);
%             filteredFluoChangeData=moving_average(fluoChangeData,1);
% kernel = [-1 -1 -1;-1 900 -1;-1 -1 -1];
% filteredFluoChangeData=imfilter(fluoChangeData,kernel,'same');
             filteredFluoChangeData=wiener2(fluoChangeData,[3 3]);
%             filteredFluoChangeData=100*fluoChangeData;
            showFluoChange(obj,hObject,filteredFluoChangeData);
               
            end
            
            if get(obj.autoFluoDetector.individualPattern,'Value')
                pat=str2num(get(obj.autoFluoDetector.patternEdit,'String'));
                patN=length(pat);
                if patN==1
                    trailN=stiInfo.patternInfo(pat).trailN;
                    [fluoChangeData]=caculateFluoChange(obj,option,trailN);
                    filteredFluoChangeData=wiener2(fluoChangeData,[3 3]);
                    showFluoChange(obj,hObject,filteredFluoChangeData);
                else
                    figure(666);
                    col=ceil(sqrt(patN));
                    row=ceil(patN/col);
                    for i=1:patN
                        trailN=stiInfo.patternInfo(pat(i)).trailN;
                        [fluoChangeData]=caculateFluoChange(obj,option,trailN);
                        filteredFluoChangeData=wiener2(fluoChangeData,[3 3]);
                        subplot(row,col,i),imagesc(filteredFluoChangeData,[-3000 3000]);title(num2str(pat(i)));axis off;drawnow;colormap(jet);drawnow;
                        
                        %                   imagesc(filteredFluoChangeData)
                    end
                end
                
            end
            
            
        end
        
        function [fluoChangeData]=caculateFluoChange(obj,option,trailN)
            
            % channel info
            if obj.data.metadata.iminfo.channel==1
                chN=1;
            else
                chN=get(obj.chSlider,'Value');
            end
            % detect whether fluoChangeData already exits
%             switch option
%                 case 0
%                     try fluoChangeData=obj.data.metadata.hotSpotFrame.on{chN};return;
%                     catch    
%                     end
%                 case 1
%                     try fluoChangeData=obj.data.metadata.hotSpotFrame.off{chN};return;
%                     catch    
%                     end
%                 case 2
%                     try fluoChangeData=obj.data.metadata.hotSpotFrame.off{chN};return;
%                     catch    
%                     end
%             end

            % image info
            frameRate=obj.data.metadata.iminfo.framePeriod;        
%             % test whether there is stimulus infomation 
%             try
%                  stiInfo=obj.stiTool;
%             catch
%                 try
%                     stiInfo=obj.data.metadata.stiInfo;
%                 catch
%                 stimulus(obj);
%                 waitfor(obj.stiTool.h.fig);
%                 stiInfo=obj.stiTool;
%                 end
%                 
%             end

            % load imagedata
            if ~obj.data.info.immat.loaded
                if exist(obj.data.info.immat.name,'file')
                    obj.data.imagedata=getfield(load(obj.data.info.immat.name),'imagedata');
                    obj.data.info.immat.loaded=1;
                end
            end
            
             try
                stiInfo=obj.stiTool;
            catch
                stiInfo=obj.data.metadata.stiInfo;
             end
            
            nSti=length(trailN);  
            sum1=0;sum2=0;sum3=0;
            for i=1:nSti
            onStart  =stiInfo.trailInfo(trailN(i)).startFrameN;
            onEnd   =stiInfo.trailInfo(trailN(i)).endFrameN;
            offStart =stiInfo.trailInfo(trailN(i)).endFrameN+1;
            offEnd  =stiInfo.trailInfo(trailN(i)).endFrameN+round(10/frameRate);
            BL       =mean(obj.data.imagedata(:,:,chN,onStart-round(1/frameRate):onStart),4);
            sum1   =sum1+squeeze(mean(obj.data.imagedata(:,:,chN,onStart:onEnd),4))-BL;
             sum2  =sum2+squeeze(mean(obj.data.imagedata(:,:,chN,offStart:offEnd),4))-BL;
            end
%             sum1=sum1/nSti; sum2=sum2/nSti;
            sum3=sum1+sum2;
            fluoCh={sum1 sum2 sum3};
            fluoChangeData=fluoCh{option};
%             fluoChangeData=fluoCh{2}-fluoCh{1};
            
            
            
%             sum1     =0;
%             sum2     =0;
%             switch option
%                 case 0
%                     for i=1:nSti
%                         sum1=sum1+squeeze(mean(obj.data.imagedata(:,:,chN,onStart(i):onEnd(i)),4));
%                         sum2=sum2+squeeze(mean(obj.data.imagedata(:,:,chN,onStart(i)-round(1/frameRate):onStart(i)),4));
%                     end
%                     fluoChangeData=sum1/nSti;
%                     baselineData=sum2/nSti;
%                     fluoChangeData=(fluoChangeData-baselineData)./baselineData;
%                     obj.data.metadata.hotSpotFrame.on{chN}=fluoChangeData;
%                 case 1
%                     for i=1:nSti
%                         sum1=sum1+squeeze(mean(obj.data.imagedata(:,:,chN,offStart(i):offEnd(i)),4));
%                     end
%                     fluoChangeData=sum1/nSti;
%                     fluoChangeData=fluoChangeData-obj.data.metadata.previewFrame{chN};
%                     obj.data.metadata.hotSpotFrame.off{chN}=fluoChangeData;
%                 case 2
%                     for i=1:nSti
%                         sum1=sum1+squeeze(mean(obj.data.imagedata(:,:,chN,onStart(i):onEnd(i)),4))+squeeze(mean(obj.data.imagedata(:,:,chN,offStart(i):offEnd(i)),4));
%                     end
%                     fluoChangeData=sum1/nSti;
%                     fluoChangeData=fluoChangeData-2*obj.data.metadata.previewFrame{chN};
%                     obj.data.metadata.hotSpotFrame.all{chN}=fluoChangeData;
%                     
%             end
        end
        
        function showFluoChange(obj,hObject,fluoChangeData)
            
            axes(obj.axes1);
%             cla ;
            
            magN     = obj.openStates.image.magN;
            zoomFactor= obj.openStates.image.zoomFactor; 
            
            hAxes1 = get(obj.axes1,'Children');
            delete (hAxes1(end));
            hAxes1(end)=[];
            nhAxes1=length(hAxes1);
            
%             hAxes1(nhAxes1+1) = imshow(fluoChangeData,[-3000 3000]);axis off;drawnow;colormap(jet);drawnow;
            hAxes1(nhAxes1+1) = imagesc(fluoChangeData,[-3000 3000]);colormap(gca,jet);drawnow;axis off;drawnow;
            obj.openStates.curImage=fluoChangeData;
            
            if ~isfield(obj.openStates,'roi')
                if zoomFactor
                    startZoomMagN=magN-zoomFactor;
                    zoom (obj.mag(magN)/obj.mag(startZoomMagN));
                end
            end
                
            curhAxes1=get(obj.axes1,'Children');
            if hAxes1(end)~=curhAxes1(end)
                set(obj.axes1,'Children',hAxes1);
            end
            % force the slider to lose focus, so to use KeyPressFcn for zoomImage. This is very much a hack.
            set(hObject, 'Enable', 'off');
            figure(obj.dispFig);
            drawnow;
            set(hObject, 'Enable', 'on');
           
        end
        
       %% Tool- Measure 
        function openFluoProcessor (obj, ~, ~)
            
            if isempty(obj.fp)
                initFluoProcessor (obj)
            end
        end
        
        % Load GUI for Measure and initiation
        function initFluoProcessor (obj)
            
            % Build GUI
            refPos = obj.roiTool.fig.Position;
            obj.fp = UIfluoProcessor(refPos);
            
            % Build Callback functions
            obj.fp.fig.CloseRequestFcn        = @obj.closeFluoProcessor;
            obj.fp.irRb.Callback              = @obj.showIndividualROI;
            obj.fp.osRb.Callback              = @obj.analyzeOS;
            obj.fp.rtRb.Callback              = @obj.showRaw;
            obj.fp.rtRb1.Callback             = @obj.showRaw;
            obj.fp.tbtRb.Callback             = @obj.showTraceByTrace;
            obj.fp.atRb.Callback              = @obj.showAverageTrace;
            obj.fp.manSelectBlPb.Callback     = @obj.manuallySelectBaselineValue;
            obj.fp.saveProcessParaPb.Callback = @obj.saveProcessPara;
            obj.fp.processROIPb.Callback      = @obj.processROI;
            
            
            % Initiazing
            if isfield(obj.data.metadata,'processPara')
                obj.fp.bcftEdit.String             = obj.data.metadata.processPara.filter;
                obj.fp.traceLengthEdit.String      = obj.data.metadata.processPara.traceLength;
                obj.fp.yminEdit.String             = obj.data.metadata.processPara.ymin;
                obj.fp.ymaxEdit.String             = obj.data.metadata.processPara.ymax;
                
                % read baseline parameters
                baselineLength  = obj.data.metadata.processPara.baselineLength; 
                if ~isempty(baselineLength) && ~unique(isnan(baselineLength))
                    obj.fp.tivblRb.Value   = 1;
                    obj.fp.tvblEdit.String = baselineLength;
                else
                    % previous version only has baselineLength
                    
                    fixedLength     = obj.data.metadata.processPara.fixedLength;
                    if ~isempty(fixedLength) && ~unique(isnan(fixedLength))
                        obj.fp.fdRb.Value    = 1;
                        obj.fp.fdEdit.String = fixedLength;
                    else
                        fixedValue      = obj.data.metadata.processPara.fixedValue;
                        obj.fp.fvRb.Value    = 1;
                        obj.fp.fvEdit.String = fixedValue;
                    end
                end
                % read prestimulus length, earlier version doesn't have
                % this parameter
                try
                    obj.fp.preStmLengthEdit.String = obj.data.metadata.processPara.preStmLength;
                catch
                end
            end
            
            % ROI number
            try
                nROI = length(obj.data.metadata.ROIdata);
                obj.fp.srEdit.String = ['1:' num2str(nROI)];
            catch
            end

            
        end
        
        % Function to close fluoProcessor
        function closeFluoProcessor (obj,hObject, ~)
            
            delete(hObject);
            obj.fp=[];
        end
        
        % When Select Individual after ChROIs chosen, Set subplot Row & Col
        % based on ROI number
        
        function showIndividualROI (obj, ~, ~)
            
            nROI = length (str2num(obj.fp.srEdit.String));
            obj.fp.rowEdit.String = ceil(sqrt(nROI));
            obj.fp.colEdit.String = ceil(nROI/(ceil(sqrt(nROI))));
        end
        
        function analyzeOS (obj, ~, ~)
            
            obj.fp.pathEdit.String ='F:\current projects\th2-GCaMP6s\analysis\os\';
            obj.fp.nameEdit.String ='OSPA.mat';
        end
        % Automatically update xmax value When Select Row 
        function showRaw (obj, ~, ~)
            
            frameNumber = obj.data.metadata.iminfo.framenumber;
            framePeriod = obj.data.metadata.iminfo.framePeriod;
            obj.fp.xmaxEdit.String = frameNumber * framePeriod + 2;
            
            % Baseline not regarding the stimulus, set fixed value as the
            % defaut method of setting baseline
            obj.fp.fvRb.Value = 1;
            
            % Empty other methods
            obj.fp.tvblEdit.String = '';
            obj.fp.fdEdit.String   = '';
            
            
        end
        
        % Automatically update xmax value When Select Trace
        function showTraceByTrace (obj, ~, ~)
            
            try
                nSti = length(obj.stiTool.trailInfo);
            catch
                obj.infoTxt.String = 'No stimulus data available!';
                return;
            end
              
            traceLength = str2double(obj.fp.traceLengthEdit.String);
            obj.fp.xmaxEdit.String = (traceLength + 1) * nSti + 1;
        end
        
        % Automatically update xmax value When Select Average
        function showAverageTrace (obj, ~, ~)
            
            try
                nPat = length(obj.stiTool.patternInfo);
            catch
                obj.infoTxt.String = 'No stimulus data available!';
                return;
            end
            
            traceLength    = str2double(obj.fp.traceLengthEdit.String);
            obj.fp.xmaxEdit.String = (traceLength + 1) * nPat + 1;
        end
        
        % Function to select fixed baseline value manually
        function manuallySelectBaselineValue (obj, ~, ~)
            
            frameNumber = obj.data.metadata.iminfo.framenumber;
            selectIndex = obj.openStates.roi.curRoiN;
            
            %channel info
            if obj.data.metadata.iminfo.channel == 1
                chN = 1;
            else
                chN = obj.chSlider.Value;
            end
            inten = getintensity (obj, selectIndex, chN);
            % boxcar filter window width
            ftnum          =str2double(obj.fp.bcftEdit.String); 
            % filter data
            inten          = moving_average(inten,ftnum);
            % create a dialog
            hFig = dialog ( 'windowstyle', 'normal','Resize','on');
            % create an axes
            ax = axes ( 'parent', hFig, 'position', [0.1 0.2 0.8 0.7], 'nextplot', 'add' );
            plot(ax, 1:frameNumber,inten,'k','LineWidth',1);
            % create the draggable horizontal line
            movableHorizontalLine( hFig, ax);
        end

        % Function to save process parameters
        function saveProcessPara (obj, ~, ~)
            
            load(obj.data.info.metamat.name); 
            metadata.processPara = obj.data.metadata.processPara;
            save(obj.data.info.metamat.name, 'metadata');
            obj.infoTxt.String = 'Processing Parameters Saved!';
        end
        
        % Function to process ROI
        function processROI (obj, ~, ~)
            
            obj.infoTxt.String = 'Processing...';
            
            % Reading image, roi, stimulus info
            
            % image info
            framePeriod = obj.data.metadata.iminfo.framePeriod;
            
            %channel info
            if obj.data.metadata.iminfo.channel==1
                chN = 1;
            else
                chN = obj.chSlider.Value;
            end
            
            % roi info
            try
                nROIs = length(obj.data.metadata.ROIdata);
            catch
                obj.infoTxt.String = 'Error! No ROIs!';
                return;
            end
            selectIndex = obj.openStates.roi.curRoiN;
            curROI      = obj.openStates.roi.curRoih;

            % reading from the panel
            
            % boxcar filter window width
            ftnum          =str2double(obj.fp.bcftEdit.String); 
            
            % baseline values
            baselineLength = str2double(obj.fp.tvblEdit.String); 
            fixedLength    = str2num(obj.fp.fdEdit.String); 
%             fixedLength    = str2double(obj.fp.fdEdit.String);
            fixedValue     = str2double(obj.fp.fvEdit.String); 
            
            % trace properties
            preStmLength   = str2double(obj.fp.preStmLengthEdit.String);  
            traceLength    = str2double(obj.fp.traceLengthEdit.String); 
            
            % display modes
            dm            = {'Raw','TrailByTrail','Average'};
            selectedValue = [1,2,3,] * [obj.fp.rtRb.Value;obj.fp.tbtRb.Value;obj.fp.atRb.Value]; 
            selectedDm    = char(dm(selectedValue));
            
            % axis
            xmin = str2double(obj.fp.xminEdit.String); 
            xmax = str2double(obj.fp.xmaxEdit.String);
            ymin = str2double(obj.fp.yminEdit.String); 
            ymax = str2double(obj.fp.ymaxEdit.String); 
            row  = str2double(obj.fp.rowEdit.String);
            col  = str2double(obj.fp.colEdit.String);
             
            % color 
            c    = [obj.fp.redRb.Value 0 obj.fp.blueRb.Value];
            
            % stimulus
            try
                stidata = obj.stiTool;
            catch
                obj.infoTxt.String = 'No stimulus data available!';
                return;
            end
            stidata.data(:,3) = abs(stidata.data(:,3)) * (0.15 * ymax) / max(abs(stidata.data(:,3)));
            
            % write parameters to obj.metadata
            obj.data.metadata.processPara.filter         = ftnum;
            obj.data.metadata.processPara.baselineLength = obj.fp.tvblEdit.String;
            obj.data.metadata.processPara.fixedLength    = obj.fp.fdEdit.String; % use string
            obj.data.metadata.processPara.fixedValue     = obj.fp.fvEdit.String;
            obj.data.metadata.processPara.preStmLength   = preStmLength;
            obj.data.metadata.processPara.traceLength    = traceLength;
            obj.data.metadata.processPara.ymin           = ymin;
            obj.data.metadata.processPara.ymax           = ymax;
            
            % Analyze using tswls class ( new updated) % Current ROI
            if obj.fp.crRb.Value
                
                inten = getintensity (obj, selectIndex, chN);
                % create a tswls object, filter, and extract traces
                tso = createAndProcessTswlsObject (inten, stidata, ftnum, framePeriod, traceLength,...
                                                   preStmLength,baselineLength,fixedLength,fixedValue);
                
                % display in differnt modes with color option
                h = figure ('Name',[obj.openStates.image.fileName(end-3:end) '-' num2str(selectIndex) '-' selectedDm],'NumberTitle','off');
                tso.showTraces(selectedDm,h,c);
 
            else % Multiple ROIs
                
                if ~isempty(curROI)
                    delete(curROI);
                    lineh = plot(obj.data.metadata.ROIdata{selectIndex}.pos(:,1),obj.data.metadata.ROIdata{selectIndex}.pos(:,2),'white', 'LineWidth',2,'Parent', obj.axes1);
                    obj.data.metadata.ROIdata{selectIndex}.linehandles = lineh;
                    obj.openStates.roi.curRoiN=1;
                    obj.openStates.roi.curRoih=[];
                end
                
                ROIs = str2num(obj.fp.srEdit.String);
                nROI = length (ROIs);
                
                for i = 1:nROI
                    inten(:,i) = getintensity (obj, ROIs(i), chN);
                end
                
                if obj.fp.irRb.Value
                    figure ('Name',[obj.openStates.image.fileName(end-3:end) '-' selectedDm],'NumberTitle','off');
                    for i = 1:nROI
                        tso{i} = createAndProcessTswlsObject (inten(:,i), stidata, ftnum, framePeriod, traceLength,...
                            preStmLength, baselineLength, fixedLength,fixedValue);
                        
                        % display in differnt modes with color option
                        h = subplot(row,col,i);
                        tso{i}.showTraces(selectedDm,h,c);
                        
                        % axis
                        axis([xmin xmax ymin ymax]);
                        if ~obj.fp.axisRb.Value
                            axis off;
                        end
                    end
                else
                    h = figure ('Name',[obj.openStates.image.fileName(end-3:end) '-Sum-' selectedDm],'NumberTitle','off');
                    tso = createAndProcessTswlsObject (mean(inten,2), stidata, ftnum, framePeriod, traceLength,...
                        preStmLength, baselineLength, fixedLength,fixedValue);
                    
                    % display in differnt modes with color option
                    tso.showTraces(selectedDm,h,c);
                end
                
            end
            
            axis([xmin xmax ymin ymax]);
            if ~obj.fp.axisRb.Value
                axis off;
            end
            
            
            % OS module
            if obj.fp.osRb.Value
                onLength = 2;
                offLength= 2;
                stLength = 8;
                
                nROI = length(tso);
                if nROI == 1
                    if isempty(tso.stadata)
                        tso.getStatistics (preStmLength,stLength,framePeriod,onLength,offLength);
                    end
                    
                    % put all measure data by peak or area together for ON,OFF and ON+OFF
                    d(1:2,:) = tso.stadata.peakAveTrace;
                    d(3,:)   = sum(tso.stadata.peakAveTrace);
                    d(4:5,:) = tso.stadata.area;
                    d(6,:)   = sum(tso.stadata.area);
                    
                    % display all original and fitted
                    figure;
                    for i = 1:6
                        resp = d(i,:);
                    
                    % tune the responses and fit with von mises model
                    [X,y] = align_os(resp);
                    [po,osi,mdl] = von_Mises_fit_os(X,y);                   
                    
                    % distinguish peak vs area
                    f = ceil(i/3); ff = i - 3 * (f-1);
                    l = {'Peak','Area'};
                    c = [1 0 0; 0 0 1; 0 0 0];
                    
                    % plot original data points
                    subplot(2,4,4*(f-1)+1),plot([-90,-60,-30,0,30,60,90],resp,'-','Color',c(ff,:));
                    hold on;
                    xticks(-90:30:90);
                    xlabel('Bar angle');
                    ylabel(l(f));
                    title('original');
                    
                    % plot predicted line
                    X1 = linspace(X(1),X(end)+30)';
                    y1 = predict(mdl,linspace(-90,90)');
                    subplot(2,4,i+f),plot(X,y,'*k');hold on;
                    line(X1,y1,'linestyle','-','Color',c(ff,:));
                    xticks(X(1):30:X(end)+30);
                    xlabel('Bar angle');
                    title(sprintf('OSD: %d, OSI: %.2f',round(po),osi));
                    
                    end
                end
            end
                
            % Export data
            if obj.fp.edRb.Value
                
                if isempty(tso.stadata)
                    return;
                end
                
                fullfilename = fullfile(obj.fp.pathEdit.String,obj.fp.nameEdit.String);
                
                %
                if exist(fullfilename,'file')
                    temp = load(fullfilename);
                    ncell= length(temp.db);
                    for i = 1:ncell
                        if strcmp(temp.db{i}.name,obj.openStates.image.fileName)
                            ButtonName = questdlg('Found the same file name, your choice for the data ?', ...
                                '', 'Discard', 'Replace', 'Append', 'Discard');                               
                            switch ButtonName
                                case 'Discard'
                                    return;
                                case 'Replace'
                                    temp.db{i}.peak = tso.stadata.peakAveTrace;
                                    temp.db{i}.area = tso.stadata.area;
                                case 'Append'
                                    continue;
                            end 
                        end
                    end
                    temp.db{ncell+1}.name = obj.openStates.image.fileName;
                    temp.db{ncell+1}.peak = tso.stadata.peakAveTrace;
                    temp.db{ncell+1}.area = tso.stadata.area;
                    db = temp.db;
                    save(fullfilename,'db');
                else
                    db{1}.name = obj.openStates.image.fileName;
                    db{1}.peak = tso.stadata.peakAveTrace;
                    db{1}.area = tso.stadata.area;
                    save(fullfilename,'db');
                end
                
                %                 v            = outToExcel(out);
                %                 xlswrite(fullfilename,v);
                %                 winopen(fullfilename);
                % %                 save (fullfilename,'v','-ascii', '-tabs' );
            end
            %
            obj.infoTxt.String = 'Process done!';
            
        end
           

    end
end


function waitbar_init(h_axes)

%h_axes is an axes handle
delete(get(h_axes,'Children'));
axis(h_axes,[0 1 0 1]);
axis(h_axes,'off');
rectangle('Position',[0 0 1 1],'Parent',h_axes,'FaceColor','w','EdgeColor',[0.94 0.94 0.94]);

end

function waitbar_fill(h_axes,fill)

c = get(h_axes,'Children');
if length(c) == 2
    if fill > 0
        set(c(1),'Position',[0 0 fill 1]);
        drawnow;
    elseif fill == 0
        delete(c(1));
    end
elseif fill > 0
    rectangle('Position',[0 0 fill 1],'Parent',h_axes,'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.94 0.94 0.94]);
    %         drawnow;
end

end

function colorSelection(selected_color)

switch selected_color
    case 'Green'
        cmap=zeros(256,3);cmap(:,2)=0:1/255:1;colormap(gca,cmap);
    case 'Red'
        cmap=zeros(256,3);cmap(:,1)=0:1/255:1;colormap(gca,cmap);
    case 'Blue'
        cmap=zeros(256,3);cmap(:,3)=0:1/255:1;colormap(gca,cmap);
    case 'Gray'
        colormap(gca,gray);
    case 'Jet'
        colormap(gca,jet);
end
        

end

