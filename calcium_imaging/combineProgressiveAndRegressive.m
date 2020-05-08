function combineProgressiveAndRegressive(analyis,stimuli,general_parameters,repeatSection)

interleaveEpoch=13;
cellTypes = {'T4 combined', 'T5 combined'};
optimalBars = {'PlusSingle', 'MinusSingle'};
for cT = 1:length(cellTypes)
    progAnalyses = analyis.analysis{2*cT-1};
    regAnalyses = analyis.analysis{2*cT};
    
    matDesc = progAnalyses.matDescription;
    allParamsPlot = progAnalyses.params(interleaveEpoch+1);
    allParamsPlot.optimalBar = optimalBars{cT};
    phasesPerBar = allParamsPlot.barWd/allParamsPlot.phaseShift;
    
    progAnalyses=progAnalyses.realResps;
    regAnalyses=regAnalyses.realResps;
    
    progResp=[];
    regResp=[];
    switch stimuli{1}
        case {'+- Edge', '+0 Edge', '-0 Edge'}
            for stimType = 1:size(matDesc, 1)
                startRow = matDesc{stimType, 3};
                numPhases = matDesc{stimType, 2};
                
                switch matDesc{stimType, 1}
                    case {'+- Edge', '+0 Edge', '-0 Edge'}
                        regRespStim = regAnalyses(startRow:startRow+numPhases-1, :, :);
                        regRespStim = regRespStim(end:-1:1, :, :);
                        regRespStim = circshift(regRespStim, -phasesPerBar);
                        regAnalyses(startRow:startRow+numPhases-1, :, :) = regRespStim;
                end
            end
        case {'+ Still','- Still'}
            for s=1:length(stimuli)
                currStim=stimuli{s};
                stimType=find(contains(matDesc(:,1),currStim));
                startRow = matDesc{stimType, 3};
                numPhases = matDesc{stimType, 2};
                progResp=[progResp;progAnalyses(startRow:startRow+numPhases-1,:,:)];
                regResp=[regResp;regAnalyses(startRow:startRow+numPhases-1,:,:)];
            end
    end
    combinedResp = cat(3, progAnalyses, regAnalyses);
    
    timeShift = general_parameters.snipShift/1000;
    durationSec = general_parameters.duration/1000;
    regCheck = false;
    
    [figureHandles, ~] = PlotEdgesROISummary(combinedResp,allParamsPlot,...
        timeShift, durationSec, regCheck, numPhases,'repeatSection', repeatSection);
    figureHandles.Name = [figureHandles.Name cellTypes{cT}];
    
    [figureHandlesTmAvg, ~] = PlotEdgesTimeAverage(combinedResp,allParamsPlot,...
        timeShift, durationSec, regCheck, numPhases,...
        'repeatSection', repeatSection);
    figureHandlesTmAvg.Name = [figureHandlesTmAvg.Name cellTypes{cT}];
end

