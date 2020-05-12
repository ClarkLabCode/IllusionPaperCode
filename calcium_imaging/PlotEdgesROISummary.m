function [figureHandles, axesHandles] = PlotEdgesROISummary(roiSummaryMatrix,allParamsPlot, timeShift, duration, regCheck, numPhases, varargin)

detectorArray = 1;
paramsPlot = allParamsPlot(1);
repeatSection = 1;
barToCenter=2;

subRows = 4;
colsPerRow = 10;

phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;

for ii = 1:2:length(varargin)
    if strmatch(varargin{ii},'repeatSection')
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
end

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);

% For xtPlotNeeded, S is single, E is edges, D is double
stillFigHandle = MakeFigure;
set(stillFigHandle,'visible','off');
stillFigHandle.Name = 'Edges ';
stillEpochsBlockStart = 1:numPhases:size(roiSummaryMatrix, 1);
if length(stillEpochsBlockStart) == 2
    blockTitles = {'+ Still', '- Still'};
    subColsData = {3:4 7:8};
    subRows = 1;
    xtPlotsNeeded = 'S';
    subColsXt={1:2 5:6};
elseif length(stillEpochsBlockStart) == 4
    switch paramsPlot.optimalBar
        case 'PlusSingle'
            blockTitles = {'-+ Still', '+- Still', '+ Still', '- Still'};
            stillEpochsBlockStart(1:2) = stillEpochsBlockStart(2:-1:1);
        case 'MinusSingle'
            blockTitles = {'+- Still', '-+ Still', '+ Still', '- Still'};
    end
    subColsData = {2:9 11:14 17:20};
    subRows = 2;
    % We're naming ON for optimal-nonoptimal based on response expectation here...
    
    % We know the input roiSummaryMatrix is rotated so the two edges are
    % displaced--here we rotate on of them back for the average (we can do
    % a simple average because the flies see the same amount of each
    % stimulus)
    if regCheck
        edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
        edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNOResp = circshift(edgeNOResp, [-(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
        edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
    else
        edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
        edgeNOResp = circshift(edgeNOResp, [(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
        edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
    end
    
    roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :) = edgesResp;
    % We won't plot the other, unaveraged, edges
    stillEpochsBlockStart(1) = [];
    blockTitles(1) = [];
    xtPlotsNeeded = 'ES';
elseif length(stillEpochsBlockStart) == 5
    % aren't we glad that when we drop the Still +-, we add two more to
    % make the length 5?
    
    %     phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;
    
    switch paramsPlot.optimalBar
        case 'PlusSingle'
            blockTitles = {'+- Edge', '-0 Edge', '+0 Edge', '+ Still', '- Still'};
            stillEpochsBlockStart(2:3) = stillEpochsBlockStart(3:-1:2);
            if regCheck
                edgeFullResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
                edgeFullResp = circshift(edgeFullResp, [-(phasesPerBar-1) 0]);
            else
                edgeFullResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
            end
        case 'MinusSingle'
            blockTitles = {'-+ Edge', '+0 Edge', '-0 Edge', '+ Still', '- Still'};
            if regCheck
                edgeFullResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
            else
                edgeFullResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
                edgeFullResp = circshift(edgeFullResp, [(phasesPerBar-1) 0]);
            end
    end
    
    
    if regCheck
        edgeOZResp = roiSummaryMatrix(stillEpochsBlockStart(3):stillEpochsBlockStart(3)+numPhases-1, :, :);
        % the 'N' for nonoptimal refers to the contrast being flipped from the good single bar one
        edgeNZResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNZResp = circshift(edgeNZResp, [-phasesPerBar 0]);
    else
        edgeOZResp = roiSummaryMatrix(stillEpochsBlockStart(3):stillEpochsBlockStart(3)+numPhases-1, :, :);
        edgeOZResp = circshift(edgeOZResp, [phasesPerBar-1 0]);
        % the 'N' for nonoptimal refers to the contrast being flipped from the good single bar one
        edgeNZResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNZResp = circshift(edgeNZResp, [-1 0]);
    end
    
    roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :) = edgeFullResp;
    roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :) = edgeNZResp;edgeOZResp;
    roiSummaryMatrix(stillEpochsBlockStart(3):stillEpochsBlockStart(3)+numPhases-1, :, :) = edgeOZResp;edgeNZResp;
    
    %colsPerRow = 24;
    %subCols = {3:8 11:16 19:24 25:34 39:48};
    %stimXtCols = {1:2 9:10 17:18 35:36 37:38};
    subRows = 1;
    xtPlotsNeeded = 'EZS';
    subColsData = { 2  4  6  8  10};
    subColsXt = { 1 3 5 7 9 };
    
elseif length(stillEpochsBlockStart) == 6
    % gradients!
    switch paramsPlot.optimalBar
        case 'PlusSingle'
            blockTitles = {'+- Still', '-+ Still', 'Grad Up Prog', 'Grad Up Reg', '+ Still', '- Still'};
            stillEpochsBlockStart(1:2) = stillEpochsBlockStart(2:-1:1);
        case 'MinusSingle'
            blockTitles = {'+- Still', 'Still +-', 'Grad Up Prog', 'Grad Up Reg', '+ Still', '- Still'};
    end
    subColsData = { 2  4  6  8  10};
    subRows = 1;
    
    % We know the input roiSummaryMatrix is rotated so the two edges are
    % displaced--here we rotate on of them back for the average (we can do
    % a simple average because the flies see the same amount of each
    % stimulus)
    if regCheck
        edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
        edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNOResp = circshift(edgeNOResp, [-(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
        edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
    else
        edgeONResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNOResp = roiSummaryMatrix(stillEpochsBlockStart(1):stillEpochsBlockStart(1)+numPhases-1, :, :);
        edgeNOResp = circshift(edgeNOResp, [(phasesPerBar-1) 0]); % This three is because there were 4 phasesPerBar for the edge responses...
        edgesResp = mean(cat(4, edgeONResp, edgeNOResp), 4);
    end
    
    roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :) = edgesResp;
    % We won't plot the other, unaveraged, edges
    stillEpochsBlockStart(1) = [];
    blockTitles(1) = [];
    subColsXt = { 1 3 5 7 9 };
    xtPlotsNeeded = 'EGS';
elseif isempty(stillEpochsBlockStart)
    subRows = 0;
end

for i = 1:length(stillEpochsBlockStart)
    stillHandles(i) = subplot(subRows, colsPerRow, subColsData{i});
    % Note that we're inverting the matrix here! This makes it plot as
    % if we had an array of ommatidia, looking at a still stimulus, as
    % opposed to a center ommatidia looking at a stimulus moved to
    % various locations
    roiMatSection = roiSummaryMatrix(stillEpochsBlockStart(i)+numPhases-1:-1:stillEpochsBlockStart(i), :, :);
    % In order to have seamless period turnovers, we plot three
    % periods (and then in Illustrator they'll look good...
    %             roiMatSection = repmat(roiMatSection, 3, 1);
    if repeatSection
        % In order to have seamless period turnovers, we plot three
        % periods (and then in Illustrator they'll look good...
        roiMatSection = repmat(roiMatSection, 3, 1);
        imagesc(tVals, -numPhases:2*numPhases-1, nanmean(roiMatSection, 3));
    else
        imagesc(tVals, 0:numPhases-1, nanmean(roiMatSection, 3));
    end
    
    %imgAx = axis;
    title(blockTitles{i});
end

if subRows
    subColXtInd = 1;
    for i = 1:length(xtPlotsNeeded)
        switch xtPlotsNeeded(i)
            case 'S'
                %                 numPlots = 2;
                % One light bar, one dark bar
                barsOff = paramsPlot(1).duration/60;
                barColors = [1 1 1; 0 0 0];
                barColorOrderOne = [1 2];
                barDelay = 0;
                ind = 1;
                
                barsPlot = subplot(subRows, 10, subColsXt{subColXtInd});
                BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColors(barColorOrderOne(ind), :), barsOff, 0, detectorArray, numPhases)
                
                subColXtInd = subColXtInd+1;
                ind = ind + 1;
                
                barsPlot = subplot(subRows, 10, subColsXt{subColXtInd});
                BarPairPlotSingleBarsXT(barsPlot, barsOff, barDelay, barColors(barColorOrderOne(ind), :), barsOff, 0, detectorArray, numPhases)
                
                subColXtInd = subColXtInd+1;
            case 'E'
                numPlots = 2; % One +- edge, one -+ edge
                barsOff = paramsPlot.duration/60;
                barColors = [1 1 1; 0 0 0];
                switch paramsPlot.optimalBar
                    case 'PlusSingle'
                        barColorOrderOne = [2 2];
                        barColorOrderTwo = [1 1];
                    case 'MinusSingle'
                        barColorOrderOne = [1 1];
                        barColorOrderTwo = [2 2];
                end
                ind = 1;
                
                %NOTE: the combination of regCheck and progMot don't necessarily make much sense here--try to assume they're legacy
                if regCheck
                    barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                    progMot = true;
                    BarPairPlotEdgesXT(barsPlot, barsOff, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot, detectorArray, numPhases, repeatSection)
                else
                    barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                    progMot = false;
                    BarPairPlotEdgesXT(barsPlot, barsOff,  barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot, detectorArray, numPhases, repeatSection)
                end
                hold on
                % 8 down here has to do with the 8 axis
                % units the xt plots span
                %plot([0,0], [0.5 1]-8/numPhases, 'r', 'LineWidth', 5);
                subColXtInd = subColXtInd+1;
            case 'G'
                barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                gradOff = paramsPlot.duration/60; % Currently assuming gradients are presented for the same amount of time as edges
                switch paramsPlot.optimalBar
                    case 'PlusSingle'
                        extremaToCenter = 'peak';
                    case 'MinusSingle'
                        extremaToCenter = 'trough';
                end
                positiveColor = 1;
                negativeColor = -1;
                
                progMot = true;
                
                GradientPlotXT(barsPlot, gradOff, positiveColor, negativeColor, extremaToCenter, progMot, detectorArray, numPhases, repeatSection)
                
                subColXtInd = subColXtInd+1;
                
                barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                
                progMot = ~progMot;
                GradientPlotXT(barsPlot, gradOff, positiveColor, negativeColor, extremaToCenter, progMot, detectorArray, numPhases, repeatSection)
                subColXtInd = subColXtInd+1;
            case 'Z'
                numPlots = 2; % One +0 edge, one -0 edge (in some order)
                
                barsOff = paramsPlot.duration/60;
                barColors = [1 1 1; 0.5 0.5 0.5; 0 0 0];
                switch paramsPlot.optimalBar
                    case 'PlusSingle'
                        barColorOrderOne = [3 2];
                        barColorOrderTwo = [2 1];
                    case 'MinusSingle'
                        barColorOrderOne = [1 2];
                        barColorOrderTwo = [2 3];
                end
                for plt = 1:numPlots
                    p1 = subColsXt{subColXtInd};
                    subColXtInd = subColXtInd + 1;
                    %NOTE: the combination of regCheck and progMot don't necessarily make much sense here--try to assume they're legacy
                    if regCheck
                        barsPlot = subplot(subRows, colsPerRow, p1);
                        progMot = true;
                        BarPairPlotEdgesXT(barsPlot, barsOff, barColors(barColorOrderOne(plt), :), barColors(barColorOrderTwo(plt), :), barToCenter, progMot, detectorArray, numPhases, repeatSection)
                    else
                        barsPlot = subplot(subRows, colsPerRow, p1);
                        progMot = false;
                        BarPairPlotEdgesXT(barsPlot, barsOff,  barColors(barColorOrderOne(plt), :), barColors(barColorOrderTwo(plt), :), barToCenter, progMot, detectorArray, numPhases, repeatSection)
                        
                    end
                    hold on
                    % 8 down here has to do with the 8 axis
                    % units the xt plots span
                    %plot([0,0], [0 8/numPhases], 'r', 'LineWidth', 5);
                end
        end
    end
end



%% Prettify still axes
yLims = [];
cLims = [];
% Using an exist instead of presetting stillHandles to an empty vector
% because that latter one breaks the contents of the graphics object vector
% and instead makes it a vector of handles grrr
if exist('stillHandles', 'var') && ~isempty(stillHandles)
    for i = 1:length(stillHandles)
        stillHandles(i).YLabel.String = 'Phase';
        yLims = [yLims get(stillHandles(i), 'YLim')'];
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)% strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            cLims = [cLims [min(potentialImage.CData(:)) max(potentialImage.CData(:))]'];
        end
    end
    
    minY = min(yLims(1, :));
    maxY = max(yLims(2, :));
    
    secondBarDelay = paramsPlot.secondBarDelay;
    % Duration is in frames; gotta convert to seconds w/ 60 frames/s number
    barsOff = paramsPlot(1).duration/60;
    for i = 1:length(stillHandles)
        set(stillHandles(i), 'YLim', [minY, maxY]);
        hold on
        potentialImage = findobj(stillHandles(i), 'Type', 'Image');
        if ~isempty(potentialImage)%strcmp(class(potentialImage), 'matlab.graphics.primitive.Image')
            minC = min(cLims(1, :));
            maxC = max(cLims(2, :));
            colormap(stillHandles(i),b2r(minC, maxC));
        end
        hold(stillHandles(i),'on')
        plot(stillHandles(i),[barsOff barsOff], [minY maxY], '--k');
        plot(stillHandles(i),[secondBarDelay secondBarDelay], [minY maxY], '--k');
        plot(stillHandles(i),[0 0], [minY maxY], '--k');
        hold(stillHandles(i),'off')
    end
    axesHandles = [stillHandles];
    figureHandles = [stillFigHandle];
end

