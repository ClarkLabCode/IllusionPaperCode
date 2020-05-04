function analysis = BarPairRoiAnalysis(flyResp,epochs,params,dataRate,varargin)
% Call this with an empty roiSelectionFunction--all ROI selection will
% occur in here so we can compile all the ROIs together!

interleaveEpoch=13;
numIgnore = 0; % number of epochs to ignore
flyEyes = [];
epochsForSelectivity = {'' ''};
duration = 2000;
barToCenter = 2;
snipShift = -500;
% This is used to determine how to check for the optimal alignment to a
% single bar--the first column of the epochsForSelectivity is being checked
% against having this term somewhere as an indication that this ROI should
% respond more to a positive contrast bar.
polarityPosCheck = 'Light';
% Same as above, but this is check to see if it's progressive motion
% If true, every bar pair response from the response matrix proceeds to
% subtract the average of the interleave *that is in the matrix* (i.e. if
% you have 500ms of interleave you keep around, it averages the 500ms, if
% 1s, it averages the 1s, etc.
subInterleaveBarPair = false;
% This if the whole bar, half bar, and short bar lengths--0 value at index
% means that bar wasn't there, empty variable should default to {1, .5,
% .15}, as below (but check ComputeBarPairResponseMatrix)
singleBarLengthsSeconds = {1, .5, .15};

% Default this to false, as generally not stimulus/response alignment
% happens

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% Gotta unwrap these because of how they're put in here--sometimes two
% appear because of combined flies, but these two should be identical so we
% only choose the first
flyEyes = cellfun(@(x) x{1}, flyEyes, 'uni', 0);
% dataPathsOut = [dataPathsOut{:}];
%     params = cellfun(@(prm) prm{1}, params, 'UniformOutput', false);

% If figureName is a cell, we need to change it depending on the
% iteration (i.e. depending on the ROIs we've selected)

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

modelMatrixPerRoi = [];
flyResponseTraces = [];
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
    roiBorderedTrials = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
    
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
    averagedTrials = ReduceDimension(alignSepTraces,'trials',@nanmean);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedTrials';
    analysis.indFly{ff}{end}.snipMat = averagedTrials;
    
    %% Optimally align ROIs before averaging across them
    % First we've gotta find which is the preferred direction for this
    % roi
    if ~iscell(flyEyes)
        regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes));
    else
        regCheck = isempty(strfind(lower(epochsForSelection{ff}{1}), flyEyes{ff}));
    end
    %         regCheck = 'We don''t use this anymore...';
    [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params{ff}, interleaveEpoch+1);

    %% get processed trials for optimal ROI alignment
    roiAlignRespsStruct = GetProcessedTrials(roiResponsesOut,epochsForRois,params{ff},dataRate,'imagingData',varargin{:},'snipShift', 0, 'duration', []);
    
    %% remove epochs you dont want analyzed
    roiAlignResps = roiAlignRespsStruct{end}.snipMat(numIgnore+1:end,:);
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
    
    
    numSingleBarRows = sum(~cellfun('isempty', regexp(epochNames, 'S[+-] ')));
    roiTrialResponseMatrixes = zeros(size(barPairSortingStructure.matrix, 2) ,length(averagedTrials{1, 1}), numROIs(ff));
    tVals = linspace(snipShift, snipShift+duration-1000/dataRate,length(averagedTrials{1, 1}));
    
    barsDistMax = max(barPairSortingStructure.direction)+1; % 0 dist is single bar and goes to 1
    centFieldNumMax = 2; % + and - polarities
    barNumMax = 2; % two bars in stimulus, 1 is progressive side, 2 is regressive side
    sideBarContrastNumMax = 2; % + and - polarities
    responseTracesMat = nan(numROIs(ff), barsDistMax, centFieldNumMax, barNumMax, sideBarContrastNumMax, length(tVals));
    responseTraces = [];
    
    for roiNum = numROIs(ff):-1:1
        optimalBar = optimalResponseFieldPerRoi;
        projectorFrameRate = 60;
        samplesBeforeEpochStart = round(-1*snipShift/1000*dataRate); % snipShift is a negative number (time back) so we have to multiply by negative one
        samplesToAvgBeforeEpochStart = samplesBeforeEpochStart;
        epochStartSample = samplesBeforeEpochStart+1;
        samplesAfterEpochEnd = round(duration/1000*dataRate) - params{ff}(end).duration*dataRate/projectorFrameRate - samplesBeforeEpochStart;
        samplesAroundEpoch = [epochStartSample samplesToAvgBeforeEpochStart samplesAfterEpochEnd];
        
        roiPhaseShift = [];
        [roiTrialResponseMatrix, matDescription, matOut] = ComputeBarPairResponseMatrix(averagedTrials(interleaveEpoch+1:end, roiNum), barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, numPhases, samplesAroundEpoch, roiPhaseShift, singleBarLengthsSeconds);
        
        stillBarPairDescInds = find(contains(matDescription(:, 1), 'Still'));
        for stillBarStim = 1:length(stillBarPairDescInds)
            stillBarsStimCol = matDescription{stillBarPairDescInds(stillBarStim), 3};
            % in row 2 is the direction of bar displacement, which
            % also includes the distance, in row 4 is the contrast
            % of the second bar, which is 0 if it's only a single
            % bar
            % Add one because this will be an index later on
            barsDist = abs(matOut(2, stillBarsStimCol)*matOut(4, stillBarsStimCol))+1;
            
            % ComputeBarPairResponseMatrix outputs the bar
            % contrasts (in the name) in the progressive direction
            barCont(1) = matOut(3, stillBarsStimCol);
            barCont(2) = matOut(4, stillBarsStimCol);
            for barNum = 1:2 % two bar stimuli
                if barCont(barNum)>0
                    centField = 'PlusSingle';
                    centFieldNum = 1;
                elseif barCont(barNum)<0
                    centField = 'MinusSingle';
                    centFieldNum = 2;
                elseif barCont(barNum) == 0
                    % This is the single bar case
                    continue
                end
                
                sideBarInd = ~(barNum-1)+1; % trick makes a 2 a 1 and a 1 a 2
                if barCont(sideBarInd)>0
                    sideBarContrast = 'PlusSingle';
                    sideBarContrastNum = 1;
                elseif barCont(sideBarInd)<0
                    sideBarContrast = 'MinusSingle';
                    sideBarContrastNum = 2;
                elseif barCont(sideBarInd) == 0
                    sideBarContrast = 'Blank';
                    sideBarContrastNum = 1;
                end
                
                % Grab the appropriate time trace from
                % roiTrialResponseMatrix
                responseMatRow = stillBarsStimCol; % cols in the stim description are in rows here
                responseMatNumPhases = matDescription{stillBarPairDescInds(stillBarStim), 2};
                centPhase = responseMatRow + round(responseMatNumPhases/2) - 1; % it's halfway down from the top; numPhases should be even, buut...
                roiTimeTrace = nan(1, size(roiTrialResponseMatrix, 2)); % default
                               
                if barsDist == 1 % single bar
                    roiTimeTrace = roiTrialResponseMatrix(centPhase, :);
                elseif barsDist == 2 % adjacent bars
                    if prod(barCont)<0 % negative correlation
                        if (strcmp(centField, optimalBar) && barNum==2) || (~strcmp(centField, optimalBar) && barNum==1)
                            roiTimeTrace = roiTrialResponseMatrix(centPhase+(sideBarInd-1), :);
                        else
                            roiTimeTrace = roiTrialResponseMatrix(centPhase-(barNum-1), :);
                        end
                    elseif prod(barCont)>0 % positive correlation
                        if strcmp(centField, optimalBar)
                            roiTimeTrace = roiTrialResponseMatrix(centPhase+(sideBarInd-1), :);
                        else
                            roiTimeTrace = roiTrialResponseMatrix(centPhase-(barNum-1), :);
                        end
                    end
                elseif barsDist == 3 % next nearest neighbor bars
                    % barNum is either 1 or 2, barNum-1 is 0 or 1,
                    % 2* make is 0 or 2, -1 again makes it -1 or 1;
                    % we subtract this value because when it's -1
                    % it was originally 1, the first bar, and we
                    % actually want the row after the center phase;
                    % conversely when it's +1 it was originally 2
                    % and we actually want the row before the
                    % center phase
                    roiTimeTrace = roiTrialResponseMatrix(centPhase-(2*(barNum-1)-1), :);
                end
                
                % This structure will have array index=distance between
                % bars, fieldName=contrast of center, field index=side
                % on which adjacent bar appears (1 is regressive side,
                % 2 is progressive side), subfield=contrast of side bar
                responseTraces(roiNum, barsDist).(centField)(barNum).(sideBarContrast) = roiTimeTrace;
                responseTracesMat(roiNum, barsDist, centFieldNum, barNum, sideBarContrastNum, :) = roiTimeTrace;
            end
        end
        
        paramsPlot = params{ff}(epochsOfInterestFirst:end);
        paramsPlot(1).optimalBar = optimalBar;
        roiTrialResponseMatrixes(:, :, roiNum) = roiTrialResponseMatrix;
    end
    
    if isempty(flyResponseTraces)
        respTraceSize = size(responseTracesMat);
        flyResponseTraces = zeros([numFlies respTraceSize(2:end)]);
    end
    
    flyResponseTraces(ff, :, :, :, :, :) = nanmean(responseTracesMat, 1);
    
    analysis.indFly{ff}{end+1}.name = 'responseMatrix';
    analysis.indFly{ff}{end}.responseTraces = responseTraces;
    analysis.indFly{ff}{end}.paramsPlot = paramsPlot;
    analysis.indFly{ff}{end}.dataRate = dataRate;
    analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
end

flyResponseTraces(all(reshape(flyResponseTraces, numFlies, [])'==0 | isnan(reshape(flyResponseTraces, numFlies, [])')), :, :, :, :, :) = [];

analysis.roiResps = roiResps;
analysis.roiModelResps = modelMatrixPerRoi;
analysis.realResps = flyResponseTraces;
analysis.matDescription = matDescription;
analysis.params = params{1};
analysis.numPhases = numPhases;
analysis.numROIs = numROIs;

end
