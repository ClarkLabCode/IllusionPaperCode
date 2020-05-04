function [droppedNaNTraces, epochsWithFewNans] = RemoveMovingEpochs(flyRespSnipMat, snipShift, params, dataRate)

if nargin==1
    snipShift = 1;
    epochDurations = repmat({'length(x)-snipShift'}, size(flyRespSnipMat));
else
    epochDurations = cellfun(@(dur) num2str(dur), num2cell(round([params.duration]'/60*dataRate)), 'Uni', 0);
    epochDurations = repmat(epochDurations, 1, size(flyRespSnipMat, 2));
    snipShift = abs(round(snipShift*dataRate/1000))+1;
end

% Get rid of epochs with too many NaNs
thresholdNaNs = 0.1;
epochsWithFewNans = cellfun(@(x, dur) sum(isnan(x(snipShift:snipShift+min([eval(dur), end-snipShift]), :)), 1)/size(x(snipShift:snipShift+min([eval(dur), end-snipShift])), 1)<thresholdNaNs, flyRespSnipMat, epochDurations, 'UniformOutput', false);
droppedNaNTraces = cellfun(@(fewNans, timeTraces)... we take in a logical for good epoch columns and the columns of time traces
    reshape(...
    timeTraces(...
    repmat(fewNans, [size(timeTraces,1), 1])... repeat the logical vector for the length of the columns
    ),... index the time traces so they only get the true columns (i.e. columns with < thresholdNaNs)
    [size(timeTraces, 1) sum(fewNans)]),... the answer is logically indexed so it comes out as a column vector; reshape it to the appropriate size
    epochsWithFewNans, flyRespSnipMat, 'UniformOutput', false);