function BarPairPlotEdgesXT(barsPlot, bothBarsOff, barColorOne, barColorTwo, barToCenter, progMot, detectorArray, numPhases, repeatSection)


phaseWidth = 8/numPhases; % 8 comes from the fact that these are plotted from -3.5 to 4.5

plotBarWidth = 4; % -3.5->4.5 covers 8 slots, and each bar is half of that, 4 slots

if nargin<9
    repeatSection = false;
end

if barToCenter == 0
    barShift = 0;
elseif barToCenter == 1
    barShift = phaseWidth;
else
    barShift = -phaseWidth;
end

if ~repeatSection
    lowerBound = -4 + phaseWidth;
    upperBound = 4 + phaseWidth;
    shifts = 0;
else
    lowerBound = -4 + phaseWidth - plotBarWidth*2;
    upperBound = 4 + phaseWidth + plotBarWidth*2;
    shifts = -1:1;
end

axLims = [0-.1*bothBarsOff bothBarsOff+.1*bothBarsOff lowerBound upperBound];
patch(axLims([1 1 2 2]), axLims([3 4 4 3]), [0.5 0.5 0.5], 'EdgeColor', 'none');

if progMot
    axis(axLims)
    for sects = shifts
        if detectorArray
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + 2*phaseWidth + [0 4 4 0]-phaseWidth, barColorOne, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects +2*phaseWidth + [-4 0 0 -4]-phaseWidth, barColorTwo, 'EdgeColor', 'none')
            % Do the wraparound
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects +2*phaseWidth + [-8 -4 -4 -8]-phaseWidth, barColorOne, 'EdgeColor', 'none')
        else
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects +phaseWidth + [0 4 4 0]+phaseWidth, barColorOne, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects +phaseWidth + [-4 0 0 -4]+phaseWidth, barColorTwo, 'EdgeColor', 'none')
            % Do the wraparound
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects +phaseWidth + [-8 -4 -4 -8]+phaseWidth, barColorOne, 'EdgeColor', 'none')
        end
    end
   
else
    % TODO Something is funky with the below bars--some (-4->1) are 5 in
    % height and others (1->5) are 4 in height
    axis(axLims)
    for sects = shifts
        if detectorArray
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + 2*phaseWidth + [-4 0 0 -4]+barShift-phaseWidth, barColorOne, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + 2*phaseWidth + [0 4 4 0]+barShift-phaseWidth, barColorTwo, 'EdgeColor', 'none')
            % Do the wraparound
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + 2*phaseWidth + [-8 -4 -4 -8]+barShift-phaseWidth, barColorTwo, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + 2*phaseWidth + [4 8 8 4]+barShift-phaseWidth, barColorOne, 'EdgeColor', 'none')
        else
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + phaseWidth + [-4 0 0 -4]+barShift+phaseWidth, barColorOne, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + phaseWidth + [0 4 4 0]+barShift+phaseWidth, barColorTwo, 'EdgeColor', 'none')
            % Do the wraparound
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + phaseWidth + [-8 -4 -4 -8]+barShift+phaseWidth, barColorTwo, 'EdgeColor', 'none')
            patch([0 0 bothBarsOff bothBarsOff], plotBarWidth*2*sects + phaseWidth + [4 8 8 4]+barShift+phaseWidth, barColorOne, 'EdgeColor', 'none')
        end
    end
end


barsPlot.Color = [0.5 0.5 0.5];
barsPlot.YColor = get(gcf,'color');

barsPlot.XTick = [0 bothBarsOff];
barsPlot.XTickLabel = [0 bothBarsOff];
xlabel('Time (s)');
