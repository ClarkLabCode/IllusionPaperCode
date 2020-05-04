function analysis = TimeTraces(flyResp,epochs,params,dataRate,varargin)

combOpp = 1; % logical for combining symmetic epochs such as left and right
numIgnore = 3; % number of epochs to ignore
figLeg = {};
ttDuration = [];
ttSnipShift = -500;
plotFigs = 0;
numFlies = [];
plotOnly='turning';

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

%% duration and snip shift should be entered in miliseconds

longestDuration = params{1}(2).duration*1000/60;
for pp = 2:length(params{1})
    thisDuration = params{1}(pp).duration*1000/60;
    if thisDuration>longestDuration
        longestDuration = thisDuration;
    end
end

snipShift = ttSnipShift;

if isempty(ttDuration)
    duration = longestDuration + 2500;
else
    duration = ttDuration;
end

if isempty(numFlies)
    numFlies = length(flyResp);
end
averagedRois = cell(1,numFlies);

%% get processed trials

for ff = 1:numFlies
    
    analysis.indFly{ff} = GetProcessedTrials(flyResp{ff},epochs{ff},params{1},dataRate,...
        'behavioralData',varargin{:},'duration',duration, ...
        'snipShift',snipShift);
    
    % Remove ignored epochs
    selectedEpochs = analysis.indFly{ff}{end}.snipMat(numIgnore+1:end,:);
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'selectedEpochs';
    analysis.indFly{ff}{end}.snipMat = selectedEpochs;
    
    %% average over trials
    averagedTrials = ReduceDimension(selectedEpochs,'trials');
    
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
    
    %% average over Rois
    averagedRois{ff} = ReduceDimension(combinedOpposites,'Rois');
    
    % write to output structure
    analysis.indFly{ff}{end+1}.name = 'averagedRois';
    analysis.indFly{ff}{end}.snipMat = averagedRois{ff};
    
    
    %% Change names of analysis structures
    analysis.indFly{ff} = MakeAnalysisReadable(analysis.indFly{ff});
end

%% convert from snipMat to matrix wtih averaged flies
averagedFlies = ReduceDimension(averagedRois,'flies',@nanmean);
averagedFliesSem = ReduceDimension(averagedRois,'flies',@NanSem);

respMat = SnipMatToMatrix(averagedFlies); % turn snipMat into a matrix
respMatPlot = permute(respMat,[1 3 6 7 2 4 5]);

respMatSem = SnipMatToMatrix(averagedFliesSem); % turn snipMat into a matrix
respMatSemPlot = permute(respMatSem,[1 3 6 7 2 4 5]);

analysis.respMatPlot = respMatPlot;
analysis.respMatSemPlot = respMatSemPlot;
analysis.plotFigs = plotFigs;

if isempty(figLeg) && isfield(params(1),'epochName')
    for ii = (1+numIgnore):length(params)
        if ischar(params(ii).epochName)
            figLeg{ii-numIgnore} = params(ii).epochName;
        else
            figLeg{ii-numIgnore} = '';
        end
    end
end

timeX = ((1:round(duration*dataRate/1000))'+round(snipShift*dataRate/1000))*1000/dataRate;
analysis.timeX = timeX;

%% plot
if plotFigs
    middleTime = linspace(0,longestDuration,5);
    timeStep = middleTime(2)-middleTime(1);
    earlyTime = fliplr(0:-timeStep:snipShift);
    endTime = longestDuration:timeStep:duration+snipShift;
    plotTime = round([earlyTime(1:end-1) middleTime endTime(2:end)]*10)/10;
    
    yAxis = {['turning response (' char(186) '/s)'],'walking response (fold change)'};
    
    finalTitle = fTitle;
    
    for pp = 1:size(respMatPlot,3)
        if strcmp(plotOnly,'walking') && pp == 1
            continue;
        end
        if strcmp(plotOnly,'turning') && pp == 2
            continue;
        end
        
        MakeFigure;
        PlotXvsY(timeX,respMatPlot(:,:,pp),'error',respMatSemPlot(:,:,pp),'color',color);
        hold on;
        PlotConstLine(0);
        PlotConstLine(0,2);
        PlotConstLine(longestDuration,2);
        
        if pp == 2
            PlotConstLine(1);
        end
        
        ConfAxis('tickX',plotTime,'tickLabelX',plotTime,'labelX','time (ms)','labelY',[yAxis{pp} ' - ' num2str(numFlies) '/' num2str(numTotalFlies) ' flies'],'fTitle',finalTitle,'figLeg',figLeg);
        hold off;
    end
end
