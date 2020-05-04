function [figureHandles, axesHandles] = PlotEdgesTimeAverage(roiSummaryMatrix,allParamsPlot,timeShift, duration, regCheck, numPhases, varargin)


detectorArray = true;
paramsPlot = allParamsPlot(1);
repeatSection = true;
barToCenter=2;

if any(strcmp(varargin, 'detectorArray'))
    detectorArray = varargin{[false strcmp(varargin, 'detectorArray')]};
end

subRows = 2;
colsPerRow = 10;

numTimePoints = size(roiSummaryMatrix, 2);
tVals = linspace(timeShift, timeShift+duration,numTimePoints);

% For xtPlotNeeded, S is single, E is edges, D is double
stillFigHandle = MakeFigure;
set(stillFigHandle,'visible','off');
stillFigHandle.Name = 'Edges time avg ';
stillEpochsBlockStart = 1:numPhases:size(roiSummaryMatrix, 1);
if length(stillEpochsBlockStart) == 2
    blockTitles = {'+ Still', '- Still'};
    subColsData = {3:4 7:8};
    subColsXt = {1:2 5:6};
    
    subRows = 1;
    xtPlotsNeeded = 'S';
elseif length(stillEpochsBlockStart) == 4
    switch paramsPlot.optimalBar
        case 'PlusSingle'
            blockTitles = {'Still -+', 'Still +-', '+ Still', '- Still'};
            stillEpochsBlockStart(1:2) = stillEpochsBlockStart(2:-1:1);
        case 'MinusSingle'
            blockTitles = {'Still +-', 'Still -+', '+ Still', '- Still'};
    end
    subColsData = {2:9 11:14 17:20};
    subRows = 2;
    % We're naming ON for optimal-nonoptimal based on response expectation here...
    phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;
    
    
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
    
    phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;
    
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
        %             edgeNZResp = circshift(edgeNZResp, [-(phasesPerBar-1) 0]);
        edgeNZResp = circshift(edgeNZResp, [-phasesPerBar 0]);
    else
        edgeOZResp = roiSummaryMatrix(stillEpochsBlockStart(3):stillEpochsBlockStart(3)+numPhases-1, :, :);
        edgeOZResp = circshift(edgeOZResp, [phasesPerBar-1 0]);
        % the 'N' for nonoptimal refers to the contrast being flipped from the good single bar one
        edgeNZResp = roiSummaryMatrix(stillEpochsBlockStart(2):stillEpochsBlockStart(2)+numPhases-1, :, :);
        edgeNZResp = circshift(edgeNZResp, [-1 0]);
        %             edgeNZResp = circshift(edgeNZResp, [phasesPerBar 0]);
        
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
    
    % We're naming ON for optimal-nonoptimal based on response expectation here...
    phasesPerBar = paramsPlot.barWd/paramsPlot.phaseShift;
    
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

presRate = 60; % Hz

stimOff = paramsPlot.duration/presRate;
pointsOfTimeForIntegration = tVals>0 & tVals<stimOff;

for i = 1:length(stillEpochsBlockStart)
    pointsOfSpaceOfInterest = stillEpochsBlockStart(i):stillEpochsBlockStart(i)+numPhases-1;
    
    respTimePerFlyAvg = nanmean(roiSummaryMatrix(pointsOfSpaceOfInterest, pointsOfTimeForIntegration, :), 2);
    respTimeOverallAvg(:, i) = nanmean(respTimePerFlyAvg, 3);
    respTimeOverallSem(:, i) = NanSem(respTimePerFlyAvg, 3);
    
    stillHandles(i) = subplot(1, colsPerRow, subColsData{i});
    if repeatSection
        x_lims=(0.5:length(respTimeOverallAvg(:, i))*3)';
        PlotXvsY(x_lims, repmat(respTimeOverallAvg(:, i),3,1), ...
            'error', repmat(respTimeOverallSem(:, i),3,1), 'graphType', 'line');
    else
        x_lims=(0.5:length(respTimeOverallAvg))';
        PlotXvsY(x_lims, respTimeOverallAvg(:, i), 'error',...
            respTimeOverallSem(:, i), 'graphType', 'line');
    end
    axis tight
    view(-90, 90)
    xlim([min(x_lims) max(x_lims)])
    stillHandles(i).YDir = 'reverse';
    title(blockTitles{i});
end



if subRows
    subColXtInd = 1;
    for i = 1:length(xtPlotsNeeded)
        
        switch xtPlotsNeeded(i)
            case 'S'
                numPlots = 2;
                % One light bar, one dark bar
                stimOff = paramsPlot(1).duration/60;
                barColors = [1 1 1; 0 0 0];
                barColorOrderOne = [1 2];
                barDelay = 0;
                ind = 1;
                
                barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                BarPairPlotSingleBarsXT(barsPlot, stimOff, barDelay, barColors(barColorOrderOne(ind), :), stimOff, 0, detectorArray, numPhases)
                
                subColXtInd = subColXtInd+1;
                ind = ind + 1;
                
                barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                BarPairPlotSingleBarsXT(barsPlot, stimOff, barDelay, barColors(barColorOrderOne(ind), :), stimOff, 0, detectorArray, numPhases)
                
                subColXtInd = subColXtInd+1;
            case 'E'
                numPlots = 2; % One +- edge, one -+ edge
                stimOff = paramsPlot.duration/60;
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
                    BarPairPlotEdgesXT(barsPlot, stimOff, barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot, detectorArray, numPhases,repeatSection)
                else
                    barsPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                    progMot = false;
                    BarPairPlotEdgesXT(barsPlot, stimOff,  barColors(barColorOrderOne(ind), :), barColors(barColorOrderTwo(ind), :), barToCenter, progMot, detectorArray, numPhases,repeatSection)
                end
                hold on
                if barToCenter == 2
                    if detectorArray
                        % 8 down here has to do with the 8 axis
                        % units the xt plots span
                        plot([0,0], [0.5 1]-8/numPhases, 'r', 'LineWidth', 5);
                    else
                        plot([0,0], [0.5 1], 'r', 'LineWidth', 5);
                    end
                elseif barToCenter == 1
                    plot([0,0], [1.5 2.5], 'r', 'LineWidth', 5);
                end
                subColXtInd = subColXtInd+1;
            case 'G'
                gradPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                gradOff = paramsPlot.duration/60; % Currently assuming gradients are presented for the same amount of time as edges
                switch paramsPlot.optimalBar
                    case 'PlusSingle'
                        extremaToCenter = 'peak';
                    case 'MinusSingle'
                        extremaToCenter = 'trough';
                end
                peakColor = 1;
                troughColor = -1;
                progMot = true;
                
                GradientPlotXT(gradPlot, gradOff, peakColor, troughColor, extremaToCenter, progMot, detectorArray, numPhases, repeatSection)
                
                subColXtInd = subColXtInd+1;
                
                gradPlot = subplot(subRows, colsPerRow, subColsXt{subColXtInd});
                
                progMot = ~progMot;
                GradientPlotXT(gradPlot, gradOff, peakColor, troughColor, extremaToCenter, progMot, detectorArray, numPhases, repeatSection)
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
                    plot([0,0], [0 8/numPhases], 'r', 'LineWidth', 5);
                end
        end
    end
end

if ~exist('gradCompHandle','var')
    axesHandles = stillHandles;
    figureHandles = stillFigHandle;
else
    axesHandles = [stillHandles gradCompHandle];
    figureHandles = [stillFigHandle gradCompFig];
end
