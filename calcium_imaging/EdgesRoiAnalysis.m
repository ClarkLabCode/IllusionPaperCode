function analysis = EdgesRoiAnalysis(flyResp,epochs,params,dataRate,varargin)

interleaveEpoch=13;
flyEyes = [];
epochsForSelectivity = {'' ''};
duration = 2000;
barToCenter = 2;
plotFlyAverage = 1;
snipShift = -500;
% This is used to determine how to check for the optimal alignment to a
% single bar--the first column of the epochsForSelectivity is being checked
% against having this term somewhere as an indication that this ROI should
% respond more to a positive contrast bar.
polarityPosCheck = 'Light';
% If true, we take half the single bar responses and use those to align the
% center of the RF--otherwise, we use them all
crossValidateCentRF = 1;
% This if the whole bar, half bar, and short bar lengths--0 value at index
% means that bar wasn't there, empty variable should default to {1, .5,
% .15}, as below (but check ComputeBarPairResponseMatrix)
singleBarLengthsSeconds = {1, .5, .15};

figureHandles = [];
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

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
paramsPlot = []; % For if we find no ROIs...
for ff = 1:numFlies
    
    roiResponsesOut = flyResp{ff};
    epochsForRois = epochs{ff};
    epochsForSelectionForFly = epochsForSelectivity;
    if any(strfind(epochsForSelectionForFly{iteration, 1}, polarityPosCheck))
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
    
    presForAlign = cellfun(@(pres) randperm(size(pres, 2), floor(size(pres, 2)/2)), droppedNaNTraces(stillSingleEpochs, :), 'UniformOutput', false);
    
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
    if crossValidateCentRF
        averagedTrials = ReduceDimension(alignSepTraces,'trials',@nanmean);
    else
        averagedTrials = ReduceDimension(droppedNaNTraces,'trials',@nanmean);
    end
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedTrials';
    analysis.indFly{ff}{end}.snipMat = averagedTrials;
    
    %% Optimally align ROIs before averaging across them
    regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
    if any(contains(epochNames, 'S+'))
        locStill = find(contains(epochNames, 'S+'), 1, 'first');
        if locStill < interleaveEpoch
            startEpoch = locStill-1; % start at the interleave before the first bar
        else
            startEpoch = interleaveEpoch;
        end
    else
        startEpoch = interleaveEpoch;
    end
    [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params{ff}, startEpoch+1);
    
    %% get processed trials for optimal ROI alignment
    roiAlignRespsStruct = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,'imagingData',varargin{:},'snipShift', 0, 'duration', []);
    
    %% remove epochs you dont want analyzed
    roiAlignResps = roiAlignRespsStruct{end}.snipMat(1:end,:);
    [~,numROIs(ff)] = size(roiAlignResps);
    
    %% Find optimal alignment between ROIs
    if strcmp(flyEyes{ff}, 'left')
        mirrorCheck = true;
    else
        mirrorCheck = false;
    end
    
    roiTrialResponseMatrixes = zeros(size(barPairSortingStructure.matrix, 2) ,length(averagedTrials{1, 1}), numROIs(ff));
    for roiNum = numROIs(ff):-1:1
        optimalBar = optimalResponseFieldPerRoi;
        projectorFrameRate = 60;
        samplesBeforeEpochStart = round(-1*snipShift/1000*dataRate); % snipShift is a negative number (time back) so we have to multiply by negative one
        samplesToAvgBeforeEpochStart = samplesBeforeEpochStart;
        epochStartSample = samplesBeforeEpochStart+1;
        samplesAfterEpochEnd = round(duration/1000*dataRate) - params{ff}(end).duration*dataRate/projectorFrameRate - samplesBeforeEpochStart;
        samplesAroundEpoch = [epochStartSample samplesToAvgBeforeEpochStart samplesAfterEpochEnd];
                
        roiPhaseShift = [];
        [roiTrialResponseMatrix, matDescription, ~] = ComputeBarPairResponseMatrix(averagedTrials(startEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, numPhases, samplesAroundEpoch, roiPhaseShift, singleBarLengthsSeconds);
        roiResps = cat(3, roiResps, roiTrialResponseMatrix);
        
        paramsPlot = params{ff}(epochsOfInterestFirst:end);
        paramsPlot(1).optimalBar = optimalBar;
        
        if ~isequal(size(roiTrialResponseMatrixes(:, :, 1)), roiTrialResponseMatrix)
            roiTrialResponseMatrixes(size(roiTrialResponseMatrix, 1)+1:end, :, :) = [];
        end
        roiTrialResponseMatrixes(:, :, roiNum) = roiTrialResponseMatrix;
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
    [figureHandles{end+1}, ~] = PlotEdgesROISummary(flyResponseMatrix,...
        paramsPlot, snipShift/1000,duration/1000, regCheck, numPhases, varargin{:});
    
    [figureHandles{end+1}, ~] = PlotEdgesTimeAverage(flyResponseMatrix,...
        paramsPlot, snipShift/1000,duration/1000, regCheck, numPhases, varargin{:});
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