function threshold = movableHorizontalLine ( hFig, ax )

% Create the variable which is required to know if the line move is active or not.
mouseDown = false;
% Create the first value for the xlimMode (used in callbacks)
yLimMode = 'auto';
% set the mouse actions for the provided figure
hFig.WindowButtonMotionFcn = @MouseMove;
hFig.WindowButtonUpFcn     = @MouseUp;
% plot the vertical line
xlim = get ( ax, 'xlim' );
ylim = get ( ax, 'ylim' );
hLine = plot ( ax, xlim, [ylim(2)/2 ylim(2)/2],'r','ButtonDownFcn', @MouseDown );
cp =[];
% a function which is called whenever the mouse is moved
    function MouseMove (varargin)
        % only run this section if the user has clicked on the line
        if mouseDown
            % get the current point on the axes
            cp = get ( ax, 'CurrentPoint' );
            % update the ydata of the line handle.
            set ( hLine, 'YData', [cp(1,2) cp(1,2)] );
            
        end
    end
% callback from the user clicking on the line
    function MouseDown (varargin )
        % get the current xlimmode
        yLimMode = get ( ax, 'ylimMode' );
        % setting this makes the xlimits stay the same (comment out and test)
        set ( ax, 'ylimMode', 'manual' );
        % set the mouse down flag
        mouseDown = true;
        %
        h = findobj(ax, 'Type','text');
        if ~isempty(h)
            delete(h)
        end
    end
% on mouse up
    function MouseUp (varargin)
        % reset the xlim mode once the moving stops
        set ( ax, 'ylimMode', yLimMode );
        % reset the mouse down flag.
        mouseDown = false;
        if ~isempty(cp)
            text( ax, cp(1,1),cp(1,2), num2str(cp(1,2)),'Color','red');
        end
    end

waitfor(hFig);
if ~isempty(cp)
    threshold = cp(1,2);
end

end