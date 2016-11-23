
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
    f.fig.Position = [refPos(1)+refPos(3)+20 refPos(2)+refPos(4)-350 405 350];
else
    f.fig.Position = [200 200 405 350];
end

% ROI panel
roiPanel = uipanel(f.fig,...
    'Title','Select ROI',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 260 190 80]);

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
    'Position',[5 25 70 20]);
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
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 210 190 45]);
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
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 105 190 100]); 
bg3      = uibuttongroup(blPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 0 190 80]);

f.tvblRb   = uicontrol(bg3,...
    'Style','radiobutton',...
    'String','Trace-variable',...
    'Value',1,...
    'Position',[5 65 170 20],...
    'Callback',@selectVariableBaseline);
f.tvblEdit = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Position',[140 65 40 16]);
f.tivblRb  = uicontrol(bg3,...
    'Style','radiobutton',...
    'String','Trace-invariable',...
    'Position',[5 45 170 20],...
    'Callback',@selectInVariableBaseline);
    
bg4      = uibuttongroup(blPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[20 0 190 45]);
f.fdRb     = uicontrol(bg4,...
    'Style','radiobutton',...
    'Enable','off',...
    'String','Fixed Duration',...
    'Position',[5 25 100 20]);
f.fdEdit   = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Enable','off',...
    'Position',[140 25 40 16]);
f.fvRb     = uicontrol(bg4,...
    'Style','radiobutton',...
    'String','Fixed Value',...
    'Enable','off',...
    'Position',[5 5 100 20]);
f.manSelectBlPb =uicontrol(blPanel,...
    'Style','pushbutton',...
    'String','Select',...
    'Position',[105 5 30 16]);
f.fvEdit   = uicontrol(blPanel,...
    'Style','Edit',...
    'String','',...
    'Enable','off',...
    'Position',[140 5 40 16]);

% Trace Properties panel
tpPanel  = uipanel(f.fig,...
    'Title','Trace Properties',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[10 40 190 60]);
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
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[210 295 190 45]);
f.dsRb     = uicontrol(mdPanel,...
    'Style','radiobutton',...
    'String','DS',...
    'Position',[5 5 80 20],...
    'Callback',@selectDsModule);

% Display panel
dpPanel  = uipanel(f.fig,...
    'Title','Display Options',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[210 132 190 160] );

%Trail radio group
bg5      = uibuttongroup(dpPanel,...
    'Units','pixels',...
    'BorderType','none',...
    'BackgroundColor','white',...
    'Position',[0 115 190 25]);
f.rtRb     = uicontrol(bg5,...
    'Style','radiobutton',...
    'String','Raw',...
    'Value',1,...
    'Position',[5 5 90 20]);
f.tbtRb    = uicontrol(bg5,...
    'Style','radiobutton',...
    'String','Trail',...
    'Position',[55 5 90 20]);
f.atRb     = uicontrol( bg5,...
    'Style','radiobutton',...
    'String','Ave',...
    'Position',[110 5 70 20]);
% Axis
f.axisRb   = uicontrol(dpPanel,...
    'Style','radiobutton',...
    'String','Axis',...
    'Value',1,...
    'Position',[4 95 80 20]);
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
    'Position',[5 3 45 20]);
f.redRb    = uicontrol(bg6,...
    'Style','radiobutton',...
    'String','Red',...
    'Position',[55 3 40 20]);
f.blueRb   = uicontrol(bg6,...
    'Style','radiobutton',...
    'String','Blue',...
    'Position',[110 3 40 20]);

% Output panel
opPanel  = uipanel(f.fig,...
    'Title','Output Options',...
    'BackgroundColor','white',...
    'Units','pixels',...
    'Position',[210 40 190 90]);
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
    'Position',[230 10 60 25]);
f.processROIPb            =uicontrol(f.fig,...
    'Style','pushbutton',...
    'String','Process',...
    'Position',[295 10 60 25]);

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

% When Trace-variable selected, Fixed Duration and Fixed Value are not allowed to choose
    function selectVariableBaseline (varargin)
        
        if strcmp(f.fdRb.Enable,'on')
            f.fdRb.Enable   = 'off';
            f.fvRb.Enable   = 'off';
            f.fdEdit.Enable = 'off';
            f.fdEdit.String = '';
            f.fvEdit.Enable = 'off';
            f.fvEdit.String = '';
        end
    end

% When Trace-inariable selected, Fixed Duration and Fixed Value are allowed to choose
    function selectInVariableBaseline (varargin)
        
        if strcmp(f.fdRb.Enable,'off')
            f.tvblEdit.String = '';
            f.fdRb.Enable     = 'on';
            f.fvRb.Enable     = 'on';
            f.fdEdit.Enable   = 'on';
            f.fvEdit.Enable   = 'on';
        end
    end

% When select DS module, select Average  
    function selectDsModule (varargin)
        
        if ~f.atRb.Value
            f.atRb.Value = 1;
        end     
    end

% When click selectPath button, choose a path and put the pathname into pathEdit
    function selectPath (varargin)
        
        [filename, pathname] = uiputfile('.xlsx');
        f.nameEdit.String    = filename;
        f.pathEdit.String    = pathname;
    end



end