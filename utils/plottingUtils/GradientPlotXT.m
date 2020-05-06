function GradientPlotXT(barsPlot, gradOff, positiveColor, negativeColor, extremaToCenter, progMot, detectorArray, numPhases, repeatSection)


% Assuming each phase is 5 degrees
phaseWidth = 8/numPhases; % 8 comes from the fact that these are plotted from -3.5 to 4.5

phaseWidthDeg = 5; % degrees
plotGradWidth = 8; % -3.5->4.5 covers 8 slots

if strcmp(extremaToCenter, 'peak')
    barShiftDeg = 0;
elseif strcmp(extremaToCenter, 'trough')
    barShiftDeg = phaseWidthDeg;
else
    barShiftDeg = -phaseWidthDeg;
end

if ~repeatSection
    lowerBound = -4 + phaseWidth;
    upperBound = 4 + phaseWidth;
    shifts = 0;
else
    lowerBound = -4 + phaseWidth - plotGradWidth;
    upperBound = 4 + phaseWidth + plotGradWidth;
    shifts = -1:1;
end

tStart = 0-.1*gradOff;
tStop = gradOff + .1*gradOff;
axLims = [tStart tStop lowerBound upperBound];
patch(axLims([1 1 2 2]), axLims([3 4 4 3]), [0.5 0.5 0.5], 'EdgeColor', 'none');

degPerGrad = phaseWidthDeg * numPhases;
gradient = repmat(linspace(negativeColor, positiveColor, degPerGrad), [20 1])'; % Resolution of one degree
gradient = circshift(gradient, [phaseWidthDeg*numPhases/2, 1]); % shift the edge to be at the middle

if progMot
    axis(axLims)
    gradient = gradient(end:-1:1, :);
    ax = gca;
    ax.YDir = 'normal'; hold on
    for sects = shifts
        if detectorArray
            imagesc([0 gradOff], sects*plotGradWidth + [-3.5 4.5], circshift(gradient, [-phaseWidthDeg+barShiftDeg, 1]));
        else
            % TODO Check
            imagesc([0 gradOff], sects*plotGradWidth + [-3.5 4.5], circshift(gradient, [phaseWidthDeg+barShiftDeg, 1]));
        end
    end
   
else
    axis(axLims)
    % TODO Something is funky with the below bars
    ax = gca;
    ax.YDir = 'normal'; hold on
    for sects = shifts
        if detectorArray
            imagesc([0 gradOff], sects*plotGradWidth + [-3.5 4.5], circshift(gradient, [-barShiftDeg, 1]));
        else
            % TODO Check
            imagesc([0 gradOff], sects*plotGradWidth + [-3.5 4.5], circshift(gradient, [-barShiftDeg, 1]));
        end
    end
end

colormap(barsPlot, 'gray');
barsPlot.Color = get(gcf,'color');
barsPlot.YColor = get(gcf,'color');

barsPlot.XTick = [0 gradOff];
barsPlot.XTickLabel = [0 gradOff];
xlabel('Time (s)');
