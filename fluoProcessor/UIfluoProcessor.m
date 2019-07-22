
function f = UIfluoProcessor (varargin)

set(0, 'defaultUicontrolBackgroundColor','White');
f.fig      = figure   ('Name','Measure',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Resize','off',...
    'Color','white');

% Get reference figure position
if nargin
    refPos         = varargin{1};
    f.fig.Position = [refPos(1)+refPos(3)+20 refPos(2)+refPos(4)-650 205 650];
else
    f.fig.Position = [200 200 205 650];
end

% ROI panel
roiPanel = uipanel(f.fig,...
    'Title','Select ROI',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 560 190 80]);

bg1      = uibuttongroup(roiPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 40 190 30]);

f.crRb     = uicontrol(bg1,...
    'Style','radiobutton',...
    'String','CurROI',...
    'Position',[5 5 70 20],...
    'Callback',@curROI);
f.srRb     = uicontrol(bg1,...
    'Style','radiobutton',...
    'String','ChROIs',...
    'Position',[75 5 70 20],...
    'TooltipString','Choose ROI number, either single or multhiple. e.g., 85; 1:10; 1,3,5,7',...
    'Callback',@selectROI);
f.srEdit   = uicontrol(roiPanel,...
    'Style','Edit',...
    'String','2',...
    'BackgroundColor','white',...
    'Position',[140 45 40 16]);

%
bg2      = uibuttongroup(roiPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[70 0 190 45]);
f.irRb     = uicontrol(bg2,...
    'Style','radiobutton',...
    'Enable','off',...
    'String','Individual',...
    'Position',[5 25 80 20]);
f.arRb     = uicontrol(bg2,...
    'Style','radiobutton',...
    'String','Sum',...
    'Enable','off',...
    'Value',1,...
    'Position',[5 7 70 20],...
    'Callback',@showSumOfROIs);

% Filter panel
ftPanel  = uipanel(f.fig,...
    'Title','Filter Response',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 510 190 45]);
f.bcftRb   = uicontrol(ftPanel,...
    'Style','radiobutton',...
    'String','Boxcar : Window Size',...
    'Value',1,...
    'Position',[5 5 130 20]);
f.bcftEdit = uicontrol(ftPanel,...
    'Style','Edit',...
    'String','2',...
    'Position',[140 5 40 16]);

% Setting baseline panel
blPanel  = uipanel(f.fig,...
    'Title','Set Baseline',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 425 190 80]); 
bg3      = uibuttongroup(blPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 0 190 80],...
    'SelectionChangedFcn',@bselection);

f.tvblRb   = uicontrol(bg3,...
    'Style','radiobutton',...
    'String','Trace-variable',...
    'Value',1,...
    'Position',[5 45 170 20]);
f.tvblEdit = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[140 45 40 16]);
f.fdRb     = uicontrol(bg3,...
    'Style','radiobutton',...
    'String','Fixed Duration',...
    'Position',[5 25 100 20]);
f.fdEdit   = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[140 25 40 16]);
f.fvRb     = uicontrol(bg3,...
    'Style','radiobutton',...
    'String','Fixed Value',...
    'Position',[5 5 100 20]);
f.manSelectBlPb =uicontrol(blPanel,...
    'Style','pushbutton',...
    'String','Select',...
    'Position',[90 5 40 16]);
f.fvEdit   = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[140 5 40 16]);

% Trace Properties panel
tpPanel  = uipanel(f.fig,...
    'Title','Trace Properties',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 360 190 60]);
preStmLengthTxt     = uicontrol(tpPanel,...
    'Style','text',...
    'String','preStmLength:',...
    'Position',[0 20 85 20]);
f.preStmLengthEdit  = uicontrol(tpPanel,...
    'Style','Edit',...
    'String','1',...
    'Position',[100 24 60 16]);
traceLengthTxt      = uicontrol(tpPanel,...
    'Style','text',...
    'String','TraceLength:',...
    'Position',[0 0 85 20]);
f.traceLengthEdit   = uicontrol(tpPanel,...
    'Style','Edit',...
    'String','10',...
    'Position',[100 4 60 16]);

% Module panel
mdPanel  = uipanel(f.fig,...
    'Title','Module',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 310 190 45]);
f.dsRb     = uicontrol(mdPanel,...
    'Style','radiobutton',...
    'String','DS',...
    'Position',[5 5 80 20],...
    'Callback',@selectDsModule);
f.osRb     = uicontrol(mdPanel,...
    'Style','radiobutton',...
    'String','OS',...
    'Position',[65 5 80 20]);

% Display panel
dpPanel  = uipanel(f.fig,...
    'Title','Display Options',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 147 190 160] );

%Trail radio group
bg5      = uibuttongroup(dpPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 85 190 55]);
f.rtRb     = uicontrol(bg5,...
    'Style','radiobutton',...
    'String','Raw',...
    'Value',1,...
    'Position',[5 35 90 20]);
% f.rt1Rb    = uicontrol(bg5,...
%     'Style','radiobutton',...
%     'String','Raw(deltaF/F)',...
%     'Position',[5 10 120 20]);
f.tbtRb    = uicontrol(bg5,...
    'Style','radiobutton',...
    'String','Trail',...
    'Position',[65 35 90 20]);
f.atRb     = uicontrol( bg5,...
    'Style','radiobutton',...
    'String','Ave',...
    'Position',[125 35 70 20]);
% Axis
f.axisRb   = uicontrol(dpPanel,...
    'Style','radiobutton',...
    'String','Axis',...
    'Value',1,...
    'Position',[125 95 80 20]);
xminTxt  = uicontrol(dpPanel,...
    'Style','text',...
    'String','Xmin:',...
    'Position',[15 70 40 20]);
f.xminEdit = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','-2',...
    'Position',[55 75 30 16]);
xmaxTxt  = uicontrol(dpPanel,...
    'Style','text',...
    'String','Xmax:',...
    'Position',[90 70 40 20]);
f.xmaxEdit = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','35',...
    'Position',[130 75 30 16]);
yminTxt  = uicontrol(dpPanel,...
    'Style','text',...
    'String','Ymin:',...
    'Position',[15 50 40 20]);
f.yminEdit = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','-50',...
    'Position',[55 55 30 16]);
ymaxTxt  = uicontrol(dpPanel,...
    'Style','text',...
    'String','Ymax:',...
    'Position',[90 50 40 20]);
f.ymaxEdit = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','100',...
    'Position',[130 55 30 16]);

% Subplot
rowTxt   = uicontrol(dpPanel,...
    'Style','text',...
    'String','Row:',...
    'Position',[15 30 40 20]);
f.rowEdit  = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','1',...
    'Position',[55 35 30 16]);
colTxt   = uicontrol(dpPanel,...
    'Style','text',...
    'String','Col:',...
    'Position',[90 30 40 20]);
f.colEdit  = uicontrol(dpPanel,...
    'Style','Edit',...
    'String','1',...
    'Position',[130 35 30 16]);

% Color
bg6      = uibuttongroup(dpPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 5 200 25]);
f.blackRb  = uicontrol(bg6,...
    'Style','radiobutton',...
    'String','Black',...
    'Position',[5 3 50 20]);
f.redRb    = uicontrol(bg6,...
    'Style','radiobutton',...
    'String','Red',...
    'Position',[65 3 50 20]);
f.blueRb   = uicontrol(bg6,...
    'Style','radiobutton',...
    'String','Blue',...
    'Value',1,...
    'Position',[125 3 50 20]);

% Output panel
opPanel  = uipanel(f.fig,...
    'Title','Output Options',...
    'ForegroundColor','b',...
    'FontWeight','bold',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 55 190 90]);
f.edRb     = uicontrol(opPanel,...
    'Style','radiobutton',...
    'String','Export Data',...
    'Position',[4 50 120 20]);
nameTxt  = uicontrol(opPanel,...
    'Style','text',...
    'String','Name:',...
    'Position',[17 25 40 20]);
f.nameEdit = uicontrol(opPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[60 30 70 16]);
pathTxt  = uicontrol(opPanel,...
    'Style','text',...
    'String','Path:',...
    'Position',[17 5 40 20]);
f.pathEdit = uicontrol(opPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[60 10 100 16],...
    'Parent',opPanel);
f.selectPathPb  =uicontrol(opPanel,...
    'Style','pushbutton',...
    'String','...',...
    'Position',[160 10 20 16],...
    'Callback',@selectPath);


% % Buttons

f.saveProcessParaPb       =uicontrol(f.fig,...
    'Style','pushbutton',...
    'String','Save',...
    'Position',[40 20 60 25]);
f.processROIPb            =uicontrol(f.fig,...
    'Style','pushbutton',...
    'String','Process',...
    'Position',[105 20 60 25]);

% Functions to control GUI componets, no data transfer

% When curROI selected, Individual and Sum are not allowed to choose
% And no subplot, 1 Row & 1 Col  
    function curROI (varargin)
        
        if strcmp(f.irRb.Enable,'on')
            f.irRb.Enable = 'off';
            f.arRb.Enable = 'off';
        end
        
        f.rowEdit.String = '1'; 
        f.colEdit.String = '1';
    end

% When ChROIs selected, Individual and Sum are allowed to choose
    function selectROI (varargin)
        
        if strcmp(f.irRb.Enable,'off')
            f.irRb.Enable = 'on';
            f.arRb.Enable = 'on';
        end
    end

% When Select sum after ChROIs chosen, no subplot, Row & Col = 1
        
        function showSumOfROIs (varargin)
            
            f.rowEdit.String = 1;
            f.colEdit.String = 1;
        end
    
 %  
    function bselection(varargin)
        
        f.tvblEdit.String = '';
        f.fdEdit.String = '';
        f.fvEdit.String = '';
        
    end

% When select DS module, select Average  
    function selectDsModule (varargin)
        
        if ~f.atRb.Value
            f.atRb.Value = 1;
        end     
    end

% When click selectPath button, choose a path and put the pathname into pathEdit
    function selectPath (varargin)
        
        [filename, pathname] = uiputfile('.mat');
        f.nameEdit.String    = filename;
        f.pathEdit.String    = pathname;
    end



end