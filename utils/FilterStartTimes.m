function filtered = FilterStartTimes(epochStartTimes,maxRange,durations,runLength)

    [numEpochs,numFlies] = size(epochStartTimes);
    
    filtered = cell(numEpochs,numFlies);
    for epoch = 1:numEpochs
        for fly = 1:numFlies
            startTimes = epochStartTimes{epoch,fly};
            adjustedStartTimes = startTimes + maxRange(1);
            adjustedEndTimes = adjustedStartTimes + durations(epoch) + maxRange(2)-1; % duration of x is start+x-1
            filtered{epoch,fly} = startTimes(adjustedStartTimes > 0 ...
                                                       & ...
                                                       adjustedEndTimes <= runLength);
        end
    end
end