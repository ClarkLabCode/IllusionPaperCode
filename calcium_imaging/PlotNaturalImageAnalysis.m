function [figureHandles, axesHandles] = PlotNaturalImageAnalysis(roiSummaryMatrix, matDescription, phaseToCenter, allParamsPlot, ~, timeShift, duration, regCheck, numPhases, varargin)


paramsPlot = allParamsPlot(1);

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

projSegment = natImageProjection';

traceColor = varargin([false strcmp(varargin(1:end-1), 'traceColor')]);
if isempty(traceColor)
    traceColor = [ 1 0 0 ];
else
    traceColor = traceColor{1};
end

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);

stillFigHandle = MakeFigure;
stillFigHandle.Name = 'Natural ';
set(stillFigHandle,'visible','off');

natStaticRow = find(contains(matDescription(:, 1), 'Natural'));

epochsBlockStart = matDescription{natStaticRow, 3};
epochsBlockLengths = matDescription{natStaticRow, 2};

blockTitles = matDescription(natStaticRow, 1);

barsOff = paramsPlot.duration/60;
stillHandles = subplot(1, 3, 2);
roiMatSection = roiSummaryMatrix(epochsBlockStart+epochsBlockLengths-1:-1:epochsBlockStart, :, :);
imagesc(tVals, (-numPhases/2:numPhases/2-1), nanmean(roiMatSection, 3));
imgAx = axis;
title(blockTitles);

tmHandles = subplot(1, 3, 3); % avg will be last in row

roiMatSection = roiSummaryMatrix(epochsBlockStart+numPhases-1:-1:epochsBlockStart, tVals>=0 & tVals<=barsOff, :);
% In case there are fewer single phases than natural image
% phases
meanTime = nanmean(roiMatSection, 2);
meanTimeFly=nanmean(meanTime, 3);
PlotXvsY(( -numPhases/2:numPhases/2-1)',meanTimeFly/max(meanTimeFly),...
    'error', NanSem(meanTime, 3)/max(meanTimeFly), 'color', traceColor);

currAx = axis;
axis([imgAx(3:4) currAx(3:4)]);
view(90, 90); 

natImgPlot = subplot(1, 3, 1);
imagesc([0 1],[-numPhases/2 numPhases/2-1],projSegment(end:-1:1));
ylabel('Phase');
colormap(natImgPlot, 'gray');


%% Prettify still axes
yLims = [];
cLims = [];
% Using an exist instead of presetting stillHandles to an empty vector
% because that latter one breaks the contents of the graphics object vector
% and instead makes it a vector of handles grrr
if exist('stillHandles', 'var') && ~isempty(stillHandles)
    for i = 1:length(stillHandles)
        yLims = [yLims get(stillHandles(i), 'YLim')'];
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    tmXLims = [tmHandles.XLim'];
    minTmX = min(tmXLims(1, :));
    maxTmX = max(tmXLims(2, :));
    
    [tmHandles.XLim] = deal([minTmX maxTmX]);
    
    secondBarDelay = paramsPlot.secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = paramsPlot(1).duration/60;
    for i = 1:length(stillHandles)
        set(stillHandles(i), 'YLim', [minY, maxY]);
        hold(stillHandles(i),'on')
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            minC = min(cLims(1, :));
            maxC = max(cLims(2, :));
            colormap(stillHandles(i),b2r(minC, maxC));
        end
        plot(stillHandles(i),[barsOff barsOff], [minY maxY], '--k');
        plot(stillHandles(i),[secondBarDelay secondBarDelay], [minY maxY], '--k');
        plot(stillHandles(i),[0 0], [minY maxY], '--k');
        hold(stillHandles(i), 'off')        
    end
else
    close(stillFigure)
end

axesHandles = [stillHandles tmHandles];
figureHandles = [stillFigHandle];