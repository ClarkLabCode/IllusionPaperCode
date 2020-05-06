function BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColor, epochDuration, traceStart, detectorArray, numPhases, phaseShift)

    if nargin<5
        epochDuration = barsOff;
        traceStart = 0;
        detectorArray = false;
        numPhases = 8;
        phaseShift = 0;
    elseif nargin<6
        traceStart = 0;
        phaseShift = 0;
        detectorArray = false;
        numPhases = 8;
        phaseShift = 0;
    elseif nargin<7
        detectorArray = false;
        numPhases = 8;
        phaseShift = 0;
    elseif nargin<8
        numPhases = 8;
        phaseShift = 0;
    elseif nargin<9
        phaseShift = 0;
    end
    
    phaseWidth = 8/numPhases; % 8 comes from the fact that these are plotted from -3.5 to 4.5
    
    axis([traceStart epochDuration -3.5 4.5])
    if detectorArray
        patch([barDelay barDelay barsOff barsOff], [0.5 0.5+phaseWidth 0.5+phaseWidth 0.5]-phaseWidth-phaseShift*phaseWidth, barColor)
        hold on
        plot([0,0], [0.5 0.5+phaseWidth]-phaseWidth-phaseShift*phaseWidth, 'r', 'LineWidth', 5);
    else
        patch([barDelay barDelay barsOff barsOff], [0.5 0.5+phaseWidth 0.5+phaseWidth 0.5]+phaseShift*phaseWidth, barColor)
        hold on
        plot([0,0], [0.5 0.5+phaseWidth]+phaseShift*phaseWidth, 'r', 'LineWidth', 5);
    end
    

    
    barsPlot.Color = get(gcf,'color');
    barsPlot.YColor = get(gcf,'color');
    barsPlot.XTick = [0 barsOff];
    barsPlot.XTickLabel = [0 barsOff];
    barsPlot.FontSize = 6;
    xlabel('Time (s)');
