function analysis = TimeAveraged(flyResp,epochs,params,dataRate,varargin)

combOpp = 1; % logical for combining symmetic epochs such as left and right
numSep = 1; % number of different traces in the paramter file
epochsForSelection = cell(1);
epochsForSelection{1} = {'' ''};
sepType = 'interleaved';
plotOnly = 'turning';
numTotalFlies = 0;
plotFigs = 0;
errorFunction = @NanSem;
numFlies = [];
numIgnore = 3;

%% ignore flies that don't have any ROIs
if any(cellfun('isempty', flyResp))
    nonResponsiveFlies = cellfun('isempty', flyResp);
    fprintf('The following flies did not respond: %s\n', num2str(find(nonResponsiveFlies)));
    flyResp(nonResponsiveFlies) = [];
    epochs(nonResponsiveFlies) = [];
else
    nonResponsiveFlies = [];
end

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if ~iscell(epochsForSelection)
    epochsForSelection = num2cell(epochsForSelection);
end

for ss = 1:length(epochsForSelection)
    for dd = 1:length(epochsForSelection{ss})
        if ~ischar(epochsForSelection{ss}{dd})
            epochsForSelection{ss}{dd} = num2str(epochsForSelection{ss}{dd});
        end
    end
end

if isempty(numFlies)
    numFlies = length(flyResp);
end
averagedRois = cell(1,numFlies);

analysis.params = params;

% run the algorithm for each fly
for ff = 1:numFlies
    
    %% get processed trials
    analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{ff},dataRate,'behavioralData',varargin{:});
    analysis.numTotalFlies = numTotalFlies;
    
    %% remove epochs you dont want analyzed
    ignoreEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'ignoreEpochs';
    analysis.indFly{ff}{end}.snipMat = ignoreEpochs;
    
    %% average over trials
    averagedTrials = ReduceDimension(ignoreEpochs,'trials');
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedTrials';
    analysis.indFly{ff}{end}.snipMat = averagedTrials;
    
    %% combine left ward and rightward epochs
    if combOpp
        combinedOpposites = CombineOpposites(averagedTrials);
    else
        combinedOpposites = averagedTrials;
    end
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'combinedOpposites';
    analysis.indFly{ff}{end}.snipMat = combinedOpposites;
    
    %% average over time
    averagedTime = ReduceDimension(combinedOpposites, 'time');
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedTime';
    analysis.indFly{ff}{end}.snipMat = averagedTime;
    
    %% average over Rois
    averagedRois{ff} = ReduceDimension(averagedTime,'Rois',@nanmean);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedRois';
    analysis.indFly{ff}{end}.snipMat = averagedRois;
    
    %% make analysis readable
    analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
end

%% convert from snipMat to matrix wtih averaged flies
averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
averagedFliesSem = ReduceDimension(averagedRois,'flies',errorFunction);

respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
respMatSep = SeparateTraces(respMat,numSep,sepType); % separate every numSnips epochs into a new trace to plot
respMatPlot = permute(respMatSep,[3 7 6 1 2 4 5]);

respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
respMatSemSep = SeparateTraces(respMatSem,numSep,sepType); % separate every numSnips epochs into a new trace to plot
respMatSemPlot = permute(respMatSemSep,[3 7 6 1 2 4 5]);

analysis.respMatPlot = respMatPlot;
analysis.respMatSemPlot = respMatSemPlot;
analysis.plotFigs = plotFigs;

%% convert from snipMat to matrix with individual flies

respMatInd = SnipMatToMatrix(averagedRois); % turn snipMat into a matrix
respMatIndSep = SeparateTraces(respMatInd,numSep,sepType); % separate every numSnips epochs into a new trace to plot
respMatIndPlot = permute(respMatIndSep,[3 5 6 7 1 2 4]); % remove all nonsingleton dimensions

analysis.respMatIndPlot = respMatIndPlot;

%% plot
if plotFigs
    if isempty(dataX)
        dataX = (1:size(respMatPlot,1));
    end
    
    dataX = Columnize(dataX);
    yAxis = {['turning response (' char(186) '/s)'],'walking response (fold change)'};
    
    try
        finalTitle = fTitle;
    catch
        finalTitle = '';
    end
    
    for pp = 1:size(respMatPlot,3)
        if strcmp(plotOnly,'walking') && pp == 1
            continue;
        end
        if strcmp(plotOnly,'turning') && pp == 2
            continue;
        end
        
        MakeFigure;
        PlotXvsY(dataX,respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp),'graphType',graphType);
        
        hold on;
        PlotConstLine(0);
        
        if pp == 2
            PlotConstLine(1);
        end
        hold off;
        
        ConfAxis(varargin{:},'tickLabelX',tickLabelX,'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) '/' num2str(numTotalFlies) ' flies'],'fTitle',finalTitle);
        
        if plotInd
            for ss = 1:numSep
                MakeFigure;
                PlotXvsY(dataX,respMatIndPlot(:,:,pp,ss),'graphType',graphType);
                
                hold on;
                PlotConstLine(0);
                
                if pp == 2
                    PlotConstLine(1);
                end
                hold off;
                
                ConfAxis(varargin{:},'tickLabelX',tickLabelX,'labelX',labelX,'labelY',[yAxis{pp} ' - ' num2str(numFlies) '/' num2str(numTotalFlies) ' flies'],'fTitle',finalTitle);
            end
        end
    end
end
