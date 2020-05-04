function analysis = NaturalImageRoiAnalysis(flyResp,epochs,params,dataRate,varargin)
% Call this with an empty roiSelectionFunction--all ROI selection will
% occur in here so we can compile all the ROIs together!

interleaveEpoch=13;
flyEyes = [];
duration = 2000;
barToCenter = 2;
plotFlyAverage = true;
snipShift = -500;
% This is used to determine how to check for the optimal alignment to a
% single bar--the first column of the epochsForSelectivity is being checked
% against having this term somewhere as an indication that this ROI should
% respond more to a positive contrast bar.
polarityPosCheck = 'Light';
% This if the whole bar, half bar, and short bar lengths--0 value at index
% means that bar wasn't there, empty variable should default to {1, .5,
% .15}, as below (but check ComputeBarPairResponseMatrix)
singleBarLengthsSeconds = {1, .5, .15};
numPhasesOverride=72;
allAxesHandles = [];
figureHandles = [];

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% Gotta unwrap these because of how they're put in here--sometimes two
% appear because of combined flies, but these two should be identical so we
% only choose the first
flyEyes = cellfun(@(x) x{1}, flyEyes, 'uni', 0);

if any(cellfun('isempty', flyResp))
    nonResponsiveFlies = cellfun('isempty', flyResp);
    fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
    flyResp(nonResponsiveFlies) = [];
    epochs(nonResponsiveFlies) = [];
    if ~isempty(flyEyes)
        flyEyes(nonResponsiveFlies)=[];
    end
    params(nonResponsiveFlies) = [];
    epochsForSelection(nonResponsiveFlies) = [];
end

numFlies = length(flyResp);
numROIs = zeros(1, numFlies);
roiResps = [];

flyResponseMatrix = [];
paramsPlot = [];
for ff = 1:numFlies
    
    roiResponsesOut = flyResp{ff};
    epochsForRois = epochs{ff};
    
    if any(strfind(epochsForSelectivity{iteration, 1}, polarityPosCheck))
        optimalResponseFieldPerRoi = 'PlusSingle';
    else
        optimalResponseFieldPerRoi = 'MinusSingle';
    end
    
    epochNames = {params{ff}.epochName};
    
    %% Get epochs with before/after timing as well
    analysis.indFly{ff} = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,'imagingData',varargin{:},'snipShift', snipShift, 'duration', duration);
    roiBorderedTrials = analysis.indFly{ff}{end}.snipMat(1:end,:);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'roiBorderedTrials';
    analysis.indFly{ff}{end}.snipMat = roiBorderedTrials;
    
    %% Remove epochs with too many NaNs
    [droppedNaNTraces, ~] = RemoveMovingEpochs(roiBorderedTrials, snipShift, params{ff}, dataRate);
    analysis.indFly{ff}{end+1}.name = 'droppedNaNTraces';
    analysis.indFly{ff}{end}.snipMat = droppedNaNTraces;
    
    %% Separate out half the single bar responses for alignment purposes
    s = rng; % Store random number generator state
    rng(0); % Initialize it to the same thing every time
    stillSingleEpochs = ~cellfun('isempty', regexp(epochNames, 'S[+-] '));
    presForAlign = cellfun(@(pres) randperm(size(pres, 2), floor(size(pres, 2)/2)), droppedNaNTraces(stillSingleEpochs, 1), 'UniformOutput', false);
    presForAlign = repmat(presForAlign, 1, size(droppedNaNTraces, 2));
    presForAvg = cellfun(@(pres, presAlign) find(~ismember(1:size(pres,2), presAlign)), droppedNaNTraces(stillSingleEpochs, :), presForAlign, 'UniformOutput', false);
    presTraceForAlign = cellfun(@(pres, presAlign) pres(:, presAlign), droppedNaNTraces(stillSingleEpochs, :), presForAlign, 'UniformOutput', false);
    presTraceForAvg = cellfun(@(pres, presAvg) pres(:, presAvg), droppedNaNTraces(stillSingleEpochs, :), presForAvg, 'UniformOutput', false);
    
    rng(s); % Return random number generator to prior state
    
    alignSepTraces = droppedNaNTraces;
    alignSepTraces(stillSingleEpochs, :) = presTraceForAvg;
        
    alignSepTraces = [alignSepTraces; presTraceForAlign];
    
    analysis.indFly{ff}{end+1}.name = 'alignSepTraces';
    analysis.indFly{ff}{end}.snipMat = alignSepTraces;
    
    %% average over trials
    averagedTrials = ReduceDimension(droppedNaNTraces,'trials',@nanmean);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedTrials';
    analysis.indFly{ff}{end}.snipMat = averagedTrials;
    
    %% Optimally align ROIs before averaging across them
    % First we've gotta find which is the preferred direction for this
    % roi
    regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
    [barPairSortingStructure, ~, epochsOfInterestFirst] = SortBarPairBarLocations(params{ff}, interleaveEpoch+1);
    if numPhasesOverride
        numPhases = numPhasesOverride;
    end

    %% get processed trials for optimal ROI alignment
    roiAlignRespsStruct = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,'imagingData',varargin{:},'snipShift', 0, 'duration', []);
    
    %% remove epochs you dont want analyzed
    roiAlignResps = roiAlignRespsStruct{end}.snipMat(1:end,:);
    [~,numROIs(ff)] = size(roiAlignResps);
    
    %% Find optimal alignment between ROIs
  
    if iscell(flyEyes)
        if strcmp(flyEyes{ff}, 'left')
            mirrorCheck = true;
        else
            mirrorCheck = false;
        end
    else
        if strcmp(flyEyes, 'left')
            mirrorCheck = true;
        else
            mirrorCheck = false;
        end
    end
    
    imgNum = unique(barPairSortingStructure.imgNum(~isnan(barPairSortingStructure.imgNum)));
    
    for roiNum = numROIs(ff):-1:1
        optimalBar = optimalResponseFieldPerRoi;
        projectorFrameRate = 60;
        samplesBeforeEpochStart = round(-1*snipShift/1000*dataRate); % snipShift is a negative number (time back) so we have to multiply by negative one
        samplesToAvgBeforeEpochStart = samplesBeforeEpochStart;
        epochStartSample = samplesBeforeEpochStart+1;
        samplesAfterEpochEnd = round(duration/1000*dataRate) - params{ff}(end).duration*dataRate/projectorFrameRate - samplesBeforeEpochStart;
        samplesAroundEpoch = [epochStartSample samplesToAvgBeforeEpochStart samplesAfterEpochEnd];        
        
        roiPhaseShift = [];
        [roiTrialResponseMatrix, matDescription, ~] = ComputeBarPairResponseMatrix(averagedTrials(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, numPhases, samplesAroundEpoch, roiPhaseShift, singleBarLengthsSeconds);
        
        phaseShiftToCenter = barToCenter; %centerPhaseOrig - matOut(1, natImgPhasesStart + centerPhaseOrig); % centerPhaseOrig is 0-indexed, so you don't need to delete 1
        roiResps = cat(3, roiResps, roiTrialResponseMatrix);
        
        paramsPlot = params{ff}(epochsOfInterestFirst:end);
        paramsPlot(1).optimalBar = optimalBar;
        
        roiTrialResponseMatrixes(1:size(roiTrialResponseMatrix, 1), :, roiNum) = roiTrialResponseMatrix;
    end
    
    
    if isempty(flyResponseMatrix)
        flyResponseMatrix = zeros(size(roiTrialResponseMatrixes, 1), size(roiTrialResponseMatrixes, 2), numFlies);
    end
    
    flyResponseMatrix(:, :, ff) = nanmean(roiTrialResponseMatrixes, 3);
    flyResponseMatrixSem(:, :, ff) = NanSem(roiTrialResponseMatrixes, 3);
    
    analysis.indFly{ff}{end+1}.name = 'responseMatrix';
    analysis.indFly{ff}{end}.responseMatrix = flyResponseMatrix(:, :, ff);
    analysis.indFly{ff}{end}.paramsPlot = paramsPlot;
    analysis.indFly{ff}{end}.dataRate = dataRate;
    analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
end
flyResponseMatrix(:, :, all(all(flyResponseMatrix==0 | isnan(flyResponseMatrix)))) = [];

if plotFlyAverage
    [figureHandles{end+1}, allAxesHandles{end+1}] = PlotNaturalImageAnalysis(flyResponseMatrix, matDescription, phaseShiftToCenter, paramsPlot, dataRate, snipShift/1000, duration/1000, regCheck, numPhases, varargin{:}, 'PlotType', 'Real', 'imgNum', imgNum);
end
allAxesHandles = [allAxesHandles{:}];
allImgAxesHandles = allAxesHandles(arrayfun(@(ax) ~isempty(ax.findobj('Type', 'Image')), allAxesHandles));
minC = min([allImgAxesHandles.CLim]);
maxC = max([allImgAxesHandles.CLim]);
[allImgAxesHandles.CLim] = deal([minC maxC]);
analysis.allImgAx = allImgAxesHandles;

allNonImgAxesHandles = allAxesHandles(arrayfun(@(ax) isempty(ax.findobj('Type', 'Image')), allAxesHandles));
if ~isempty(allNonImgAxesHandles)
    allSpctmAvgAx = allNonImgAxesHandles(arrayfun(@(ax) ~isempty(ax.findobj('Type', 'Bar')), allNonImgAxesHandles));
    allNonSpctmAvgAx = allNonImgAxesHandles(arrayfun(@(ax) isempty(ax.findobj('Type', 'Bar')), allNonImgAxesHandles));
    allTmAvgAx = allNonSpctmAvgAx(arrayfun(@(ax) ~isempty(ax.findobj('Type', 'ErrorBar')), allNonSpctmAvgAx));
    allSpcAvgAx = allNonSpctmAvgAx(arrayfun(@(ax) isempty(ax.findobj('Type', 'ErrorBar')), allNonSpctmAvgAx));
    
    mnTAx = min([allTmAvgAx.YLim]);% = deal([-0.2 0.4]);
    mxTAx = max([allTmAvgAx.YLim]);
    
    mnSAx = min([allSpcAvgAx.YLim]);
    mxSAx = max([allSpcAvgAx.YLim]);
    
    mnSTAx = min([allSpctmAvgAx.YLim]);
    mxSTAx = max([allSpctmAvgAx.YLim]);
    
    [allTmAvgAx.YLim] = deal([mnTAx mxTAx]);
    [allSpcAvgAx.YLim] = deal([mnSAx mxSAx]);
    [allSpctmAvgAx.YLim] = deal([mnSTAx mxSTAx]);
    analysis.allTmAvgAx = allTmAvgAx;
    analysis.allSpcAvgAx = allSpcAvgAx;
    analysis.allSpctmAvgAx = allSpctmAvgAx;
end

if ~isempty(allImgAxesHandles)
    allAxesParents = unique([allImgAxesHandles.Parent]);
    [allAxesParents.Colormap] = deal(colormap(b2r(minC, maxC)));
end

allFigureHandles = [figureHandles{:}];
for figH = 1:length(allFigureHandles)
    allFigureHandles(figH).Name = [allFigureHandles(figH).Name figureName];
end

analysis.roiResps = roiResps;
analysis.realResps = flyResponseMatrix;
analysis.matDescription = matDescription;
analysis.params = params{1};
analysis.numPhases = numPhases;
analysis.numROIs = numROIs;
