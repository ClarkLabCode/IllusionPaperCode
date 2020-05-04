function [out, outDesc, outSortMat, sortIndexes] = ComputeBarPairResponseMatrix(roiAveragedResponses, barPairSortingStructure, barToCenter, mirrorCheck, optimalBar, numPhases, samplesAroundEpoch, roiPhaseShift, singleLengthsSeconds)
% We take in a mirrorCheck because everything gets mirrored for the left
% eye--we could foresee things getting mirrored for the regressive layer of
% the right eye as well, hence it's called 'mirror check'
if nargin<6
    samplesAroundEpoch = [0 0 0];
    numPhases = 8;
    roiPhaseShift = [];
    singleLengthsSeconds = {1, .5, .15}; % lengths of normal, half, and short single
elseif nargin<7
    samplesAroundEpoch = [0 0 0];
    roiPhaseShift = [];
    singleLengthsSeconds = {1, .5, .15}; % lengths of normal, half, and short single
elseif nargin<8
    roiPhaseShift = [];
    singleLengthsSeconds = {1, .5, .15}; % lengths of normal, half, and short single
elseif nargin<9
    singleLengthsSeconds = {1, .5, .15}; % lengths of normal, half, and short single
end

if isempty(singleLengthsSeconds)
    singleLengthsSeconds = {1, .5, .15}; % lengths of normal, half, and short single
end

if length(samplesAroundEpoch) == 2
    samplesAroundEpoch = [samplesAroundEpoch(1)+1 samplesAroundEpoch(1) samplesAroundEpoch(2)];
end

numBootstraps = size(roiAveragedResponses{1, 1}, 2)-1;

sortingMatrix = barPairSortingStructure.matrix;
prefDir = 1;
nullDir = -1;
nextNearestDir = 2;
neighDir = 1;
% ['The columns of the matrix are sequential epochs from interleave.\n'...
%                         'The rows of the matrix are as follows:\n'...
%                         'bar phase\n'...
%                         'direction of motion\n'...
%                         'bar 1 contrast\n'...
%                         'bar 2 contrast\n'...
%                         'bar 2 delay\n'...
%                         'bar 1 location\n'...
%                         'bar 2 location\n'...
%                         'bar width\n'...
%                         'space width\n'...
%                         'phase width\n'...
%                         'bar 1 delay\n'...
%                         'bar 1 off\n'...
%                         'bar 2 off']);


if mirrorCheck 
    % This line serves to mirror the phases--when going to the left is
    % important, phases going to the right of 0,1,2,3 should become
    % phases 0,3,2,1
    sortingMatrix(1, :) = abs(mod(sortingMatrix(1, :), -numPhases));
    sortingMatrix(17, :) = abs(mod(sortingMatrix(17, :), -numPhases));
    % This line serves to correctly define the phases for bars one
    % apart for the left-going epochs. Initially these bars were
    % defined so that the phase of their leftmost bar matched the phase
    % of the first bar appearing in a directional pairing. The same is
    % done here, but now their right most bar matches (because we've
    % mirrored) 
    sortingMatrix(1, sortingMatrix(2, :)==nextNearestDir) = mod(sortingMatrix(1, sortingMatrix(2, :)==nextNearestDir)-1, numPhases);
    % This line serves to correctly define the phases for the single bar,
    % since it has to be aligned to the first bar but is aligned to the
    % second in leftward terms. Importantly, if the neighboring bars are
    % wider than the single bar, this shifts the single bar phase to be at
    % the leading side of the boundary between the neighboring bars,
    % instead of being at the beginning of one of them. Ignoring NaNs
    % serves to ignore the effects of gradient stimuli.
    phasesPerBar = sortingMatrix(8, sortingMatrix(2, :)==neighDir & sortingMatrix(4, :) ~= 0 & ~isnan(sortingMatrix(4, :)) & sortingMatrix(5, :) == 0)./sortingMatrix(10, sortingMatrix(2, :)==neighDir & sortingMatrix(4, :) ~= 0 & ~isnan(sortingMatrix(4, :)) & sortingMatrix(5, :) == 0);
    phasesPerBar = unique(phasesPerBar);
    if length(phasesPerBar)>1
        error('You seem to have neighboring bars in this stimulus of multiple widths. I don''t know which one to use as the important width.')
    elseif isempty(phasesPerBar)
        phasesPerBar = 1; % Making the assumption here that if there are no neighboring bars, than all the bars are the same width
    end
    % It turns out that gradient stimuli are aligned as with the single
    % bars, so their phases must be moved the same as well
    % Check: (second bar is 0 contrast AND bar width is one phase width
    % [i.e. not an edge-to-gray]) OR the second bar is not set (i.e. it's a
    % gradient)
    sortingMatrix(1, (sortingMatrix(4, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :)) | isnan(sortingMatrix(4, :))) = mod(sortingMatrix(1, (sortingMatrix(4, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :)) | isnan(sortingMatrix(4, :)))+phasesPerBar, numPhases);
    % These lines shift the bar locations to their correct location based
    % on leftwards movement (exactly what happened for the overall phases
    % in the first line, except you subtract one because the phases are
    % initially aligned to the first bar of the rightwards motion--so you
    % subtract one to align them to the first bar of the leftwards motion)
    sortingMatrix(6, :) = abs(mod(sortingMatrix(6, :)-1, -numPhases));
    sortingMatrix(7, :) = abs(mod(sortingMatrix(7, :)-1, -numPhases));
    % These lines switch the location of bar 1 & bar 2 for next-nearest
    % neighbor bars and nearest neighbor bars because when we're going
    % leftwards the first bar switches (same reason we had to change the
    % phase of these, and the same reason we'll be switching up the
    % contrast order below
    % Checks: direction is next nearest neighbor OR direction is nearest
    % neighbor AND no delay between bars AND (correlation is zero OR first
    % bar is wider than the phase width [accounts for edge-to-gray
    % stimuli]) AND first phase isn't flickering
    tempBar1Location = sortingMatrix(6, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1));
    tempBar2Location = sortingMatrix(7, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1));
    sortingMatrix(6, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1)) = tempBar2Location;
    sortingMatrix(7, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1)) = tempBar1Location;
    % These lines switch the contrast of bar 1 & bar 2 for next-nearest
    % neighbor bars because when we're going leftwards the first bar
    % switches (same reason we had to change the phase of these)
    % Checks (as above): direction is next nearest neighbor OR direction is
    % nearest neighbor AND no delay between bars AND (correlation is zero
    % OR first bar is wider than the phase width [accounts for edge-to-gray
    % stimuli]) AND first phase isn't flickering
    tempBar1Contrast = sortingMatrix(3, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1));
    tempBar2Contrast = sortingMatrix(4, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1));
    sortingMatrix(3, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1)) = tempBar2Contrast;
    sortingMatrix(4, sortingMatrix(2, :)==nextNearestDir | sortingMatrix(2, :)==neighDir & sortingMatrix(5, :) == 0 & (sortingMatrix(3, :).*sortingMatrix(4, :)~=0 | sortingMatrix(8, :) > sortingMatrix(10, :)) & sortingMatrix(4, :) ~= pi & sortingMatrix(4, :) ~= exp(1)) = tempBar1Contrast;

    % Here we deal with gradient stimuli
    % For the positive and negative location, all we have to do is shift the
    % phase of the positive or negative part as was done for the normal
    % phases
    sortingMatrix(14, :) =  abs(mod(sortingMatrix(14, :), -numPhases));
    sortingMatrix(15, :) =  abs(mod(sortingMatrix(15, :), -numPhases));
    
    
    prefDir = -1;
    nullDir = 1;
    roiPhaseShift = numPhases - roiPhaseShift;
else
    % If the neighboring bars are wider than the single bar, this shifts
    % the single bar phase to be at the leading side of the boundary
    % between the neighboring bars, instead of being at the beginning of
    % one of them. Ignoring NaNs serves to ignore the effects of gradient
    % stimuli.
    phasesPerBar = sortingMatrix(8, sortingMatrix(2, :)==neighDir & sortingMatrix(4, :) ~= 0 & ~isnan(sortingMatrix(4, :)) & sortingMatrix(5, :) == 0)./sortingMatrix(10, sortingMatrix(2, :)==neighDir & sortingMatrix(4, :) ~= 0 & ~isnan(sortingMatrix(4, :)) & sortingMatrix(5, :) == 0);
    phasesPerBar = unique(phasesPerBar);
    if length(phasesPerBar)>1
        error('You seem to have neighboring bars in this stimulus of multiple widths. I don''t know which one to use as the important width.')
    elseif isempty(phasesPerBar)
        phasesPerBar = 1; % Making the assumption here that if there are no neighboring bars, than all the bars are the same width
    end
    % It turns out that gradient stimuli are aligned as with the single
    % bars, so their phases must be moved the same as well
    % Check: (second bar is 0 contrast AND bar width is one phase width
    % [i.e. not an edge-to-gray]) OR the second bar is not set (i.e. it's a
    % gradient)
    sortingMatrix(1, (sortingMatrix(4, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :)) | isnan(sortingMatrix(4, :))) = mod(sortingMatrix(1, sortingMatrix(4, :)==0 | isnan(sortingMatrix(4, :)))-phasesPerBar+1, numPhases);
end

% Apparent motion bar checks:
% correct direction AND correct first bar polarity AND correct correlation
% AND delayed second bar onset
PPlusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)~=0);
PPlusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
PMinusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)~=0);
PMinusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
NPlusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)~=0);
NPlusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);
NMinusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)~=0);
NMinusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);

% Single bar checks: 
% correct first bar polarity AND second bar polarity is 0 AND first bar is
% presented the correct amount of time AND width is the correct phase width
PlusSingle = find(sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{1} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The normal plus single is the first index
MinusSingle = find(sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{1} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The normal plus single is the first index

% Single half-length bar checks: 
% correct first bar polarity AND second bar polarity is 0 AND first bar is
% presented the correct amount of time AND width is the correct phase width
PlusHalfSingle = find(sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{2} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The half plus single is the second index
MinusHalfSingle = find(sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{2} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The half minus single is the second index

% Single short-length bar checks: 
% correct first bar polarity AND second bar polarity is 0 AND first bar is
% presented the correct amount of time AND width is the correct phase width
PlusShortSingle = find(sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{3} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The short plus single is the third index
MinusShortSingle = find(sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(12, :) == singleLengthsSeconds{3} & sortingMatrix(8, :) == sortingMatrix(10, :)); % The short minus single is the third index

% Single flickering bar checks:
% flickering first bar (denoted by 'polarity' value being constant pi) AND
% second bar polarity is 0
FlickSingle = find(sortingMatrix(3, :) == pi & sortingMatrix(3, :).*sortingMatrix(4, :) == 0);

% Flickering bar checks:
% correct direction from adjacent to flicker AND flickering second bar
% (denoted by 'polarity' value being constant pi) AND no delay
FlickPlusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==pi & sortingMatrix(5, :)==0);
FlickMinusPref = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==pi & sortingMatrix(5, :)==0);
FlickPlusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==pi & sortingMatrix(5, :)==0);
FlickMinusNull = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==pi & sortingMatrix(5, :)==0);

% Single flickering bar bootstrap checks: 
% flickering first bar (denoted by 'polarity' value being constant e) AND
% second bar polarity is 0
FlickSingleBs = find(sortingMatrix(3, :) == exp(1) & sortingMatrix(3, :).*sortingMatrix(4, :) == 0);

% Flickering bar bootstrap checks:
% correct direction from adjacent to flicker AND flickering second bar
% (denoted by 'polarity' value being constant e) AND no delay
FlickPlusPrefBs = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==exp(1) & sortingMatrix(5, :)==0);
FlickMinusPrefBs = find(sortingMatrix(2, :) == prefDir & sortingMatrix(3, :)==-1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==exp(1) & sortingMatrix(5, :)==0);
FlickPlusNullBs = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==exp(1) & sortingMatrix(5, :)==0);
FlickMinusNullBs = find(sortingMatrix(2, :) == nullDir & sortingMatrix(3, :)==-1 & abs(sortingMatrix(3, :).*sortingMatrix(4, :))==exp(1) & sortingMatrix(5, :)==0);

% Next-nearest neighbor bar checks:
% correct next-nearest neighbor distance AND correct first bar polarity AND
% correct correlation
PPlusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
PMinusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1);
NPlusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);
NMinusDouble = find(sortingMatrix(2, :) == nextNearestDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1);

% Neighboring bar checks:
% correct neighboring distance AND correct first bar polarity AND correct
% correlation AND no delay between bar onsets AND width is the correct
% phase width
PPlusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :));
PMinusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :));
NPlusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :));
NMinusNeigh = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) == sortingMatrix(10, :));

% Edges checks:
% correct neighboring distance AND correct first bar polarity AND correct
% correlation AND no delay between bar onsets AND width is different from
% phase width
PPlusEdge = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));
PMinusEdge = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));
NPlusEdge = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));
NMinusEdge = find(sortingMatrix(2, :) == neighDir & sortingMatrix(3, :)==-1 & sortingMatrix(3, :).*sortingMatrix(4, :)==-1 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));

% Edges with gray checks:
% correct neighboring distance AND correct first bar polarity AND correct
% zero correlation AND no delay between bar onsets AND width is different
% from phase width
ZPlusEdge = find(sortingMatrix(2, :) == neighDir & (sortingMatrix(3, :)==1 | sortingMatrix(4, :) == 1) & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));
ZMinusEdge = find(sortingMatrix(2, :) == neighDir & (sortingMatrix(3, :)==-1 | sortingMatrix(4, :) == -1) & sortingMatrix(3, :).*sortingMatrix(4, :)==0 & sortingMatrix(5, :)==0 & sortingMatrix(8, :) ~= sortingMatrix(10, :));

% Gradient checks:
% existence of gradient location AND correct direction of gradient
GPrefIncreasing = find(~isnan(sortingMatrix(14, :)) & sortingMatrix(2, :) == prefDir);
GNullIncreasing = find(~isnan(sortingMatrix(14, :)) & sortingMatrix(2, :) == nullDir);

% Natural image checks:
% existence of image number
NatImg = find(~isnan(sortingMatrix(16, :)));

% Nonpresented natural image checks:
% column with all NaN columns
NatImgBlank = find(all(isnan(sortingMatrix))); % This is for the epochs not presented of the natural image

% Moving square waves ending at a specific phase
vels = unique(sortingMatrix(18, :));
vels = vels(~isnan(vels));
MovingSquareWaves = cell(size(vels));
for velNum = 1:length(vels)
    MovingSquareWaves{velNum} = find(sortingMatrix(18, :) == vels(velNum));
end

% Here we ensure that the epochs are in phase order, since there may have
% been some moved around
% Use the PPlusPref phases to reorder things in increasing order--gonna
% be annoying cuz you have to do this for each one...
[~, sortIndDir] = sort(sortingMatrix(1, PPlusPref));
PPlusPref = PPlusPref(sortIndDir);
PPlusNull = PPlusNull(sortIndDir);
PMinusPref = PMinusPref(sortIndDir);
PMinusNull = PMinusNull(sortIndDir);
NPlusPref = NPlusPref(sortIndDir);
NPlusNull = NPlusNull(sortIndDir);
NMinusPref = NMinusPref(sortIndDir);
NMinusNull = NMinusNull(sortIndDir);

if length(FlickPlusPref) == length(PlusSingle)
    [~, sortIndFlick] = sort(sortingMatrix(1, FlickPlusPref));
    FlickPlusPref = FlickPlusPref(sortIndFlick);
    FlickPlusNull = FlickPlusNull(sortIndFlick);
    FlickMinusPref = FlickMinusPref(sortIndFlick);
    FlickMinusNull = FlickMinusNull(sortIndFlick);
    
    if ~isempty(FlickPlusPrefBs)
        FlickPlusPrefBs = FlickPlusPrefBs(sortIndFlick);
        FlickPlusNullBs = FlickPlusNullBs(sortIndFlick);
        FlickMinusPrefBs = FlickMinusPrefBs(sortIndFlick);
        FlickMinusNullBs = FlickMinusNullBs(sortIndFlick);
    end
elseif ~isempty(FlickPlusPref)
    % Note that we have to do length+1 here because we only pad the
    % roiAveragedResponses *after* we've used the prior (current?)
    % length for aligning bar phases to the center
    FlickPlusPrefTemp = FlickPlusPref;
    FlickPlusNullTemp = FlickPlusNull;
    FlickMinusPrefTemp = FlickMinusPref;
    FlickMinusNullTemp = FlickMinusNull;
    
    FlickTemplate = (length(roiAveragedResponses)+1)*ones(size(PlusSingle));
    FlickPlusPref = FlickTemplate;
    FlickPlusNull = FlickTemplate;
    FlickMinusPref = FlickTemplate;
    FlickMinusNull = FlickTemplate;
    FlickPlusPref(sortingMatrix(1, FlickPlusPrefTemp)+1) = FlickPlusPrefTemp;
    FlickPlusNull(sortingMatrix(1, FlickPlusNullTemp)+1) = FlickPlusNullTemp;
    FlickMinusPref(sortingMatrix(1, FlickMinusPrefTemp)+1) = FlickMinusPrefTemp;
    FlickMinusNull(sortingMatrix(1, FlickMinusNullTemp)+1) = FlickMinusNullTemp;
    
    if ~isempty(FlickPlusPrefBs)
        FlickPlusPrefBsTemp = FlickPlusPrefBs;
        FlickPlusNullBsTemp = FlickPlusNullBs;
        FlickMinusPrefBsTemp = FlickMinusPrefBs;
        FlickMinusNullBsTemp = FlickMinusNullBs;
        
        FlickTemplate = (length(roiAveragedResponses)+1)*ones(size(PlusSingle));
        FlickPlusPrefBs = FlickTemplate;
        FlickPlusNullBs = FlickTemplate;
        FlickMinusPrefBs = FlickTemplate;
        FlickMinusNullBs = FlickTemplate;
        FlickPlusPrefBs(sortingMatrix(1, FlickPlusPrefBsTemp)+1) = FlickPlusPrefBsTemp;
        FlickPlusNullBs(sortingMatrix(1, FlickPlusNullBsTemp)+1) = FlickPlusNullBsTemp;
        FlickMinusPrefBs(sortingMatrix(1, FlickMinusPrefBsTemp)+1) = FlickMinusPrefBsTemp;
        FlickMinusNullBs(sortingMatrix(1, FlickMinusNullBsTemp)+1) = FlickMinusNullBsTemp;
    end
end

% Do the same for the singles--except use the PlusSingle
[~, sortIndSing] = sort(sortingMatrix(1, PlusSingle));
PlusSingle = PlusSingle(sortIndSing);
MinusSingle = MinusSingle(sortIndSing);
if ~isempty(PlusHalfSingle)
    PlusHalfSingle = PlusHalfSingle(sortIndSing);
    MinusHalfSingle = MinusHalfSingle(sortIndSing);
end
if ~isempty(PlusShortSingle)
    PlusShortSingle = PlusShortSingle(sortIndSing);
    MinusShortSingle = MinusShortSingle(sortIndSing);
end
if ~isempty(FlickSingle)
    if ~isempty(PlusSingle)
        if length(FlickSingle) == length(PlusSingle)
            FlickSingle = FlickSingle(sortIndSing);
        else
            % Note that we have to do length+1 here because we only pad the
            % roiAveragedResponses *after* we've used the prior (current?)
            % length for aligning bar phases to the center
            FlickSingleTemp = (length(roiAveragedResponses)+1)*ones(size(PlusSingle));
            for ep = 1:length(FlickSingle)
                phs = sortingMatrix(1, FlickSingle(ep));
                srtInd = sortingMatrix(1, PlusSingle)==phs;
                FlickSingleTemp(srtInd) = FlickSingle(ep);
            end
            FlickSingle = FlickSingleTemp;
        end
    else % happened when behavior was done, as single bars were not presented
        [~, sortIndSing] = sort(sortingMatrix(1, FlickSingle));
        FlickSingle = FlickSingle(sortIndSing);
    end
    
    % For bootstraps
    if ~isempty(FlickSingleBs)
        if length(FlickSingleBs) == length(PlusSingle)
            FlickSingleBs = FlickSingleBs(sortIndSing);
        else
            % Note that we have to do length+1 here because we only pad the
            % roiAveragedResponses *after* we've used the prior (current?)
            % length for aligning bar phases to the center
            FlickSingleBsTemp = (length(roiAveragedResponses)+1)*ones(size(PlusSingle));
            for ep = 1:length(FlickSingleBs)
                phs = sortingMatrix(1, FlickSingleBs(ep));
                srtInd = sortingMatrix(1, PlusSingle) == phs;
                FlickSingleBsTemp(srtInd) = FlickSingleBs(ep);
            end
            FlickSingleBs = FlickSingleBsTemp;
        end
    end
end

% We sort the moving square waves using the single sort
[~, sortIndMovSqWaves] = cellfun(@(velMovSqWv) sort(sortingMatrix(17, velMovSqWv)), MovingSquareWaves, 'uni', 0);
MovingSquareWaves = cellfun(@(velMovSqWv, sortIndMovSqWv) velMovSqWv(sortIndSing), MovingSquareWaves, sortIndMovSqWaves, 'uni', 0);

% We're sorting the natural image phases using their phases--this is
% because they may have more phases than the single phases; at the same
% time, this will let them fololow the mapping of the single phases
if ~isempty(NatImg) && ~isnan(sortingMatrix(1, NatImg(1))) % this last check is to distinguish static natural images at a phase from moving natural images
    [~, sortIndNat] = sort(sortingMatrix(1, NatImg));
    NatImg = NatImg(sortIndNat);
    sortedNatPhases = sortingMatrix(1, NatImg);
    NatImgPhasesFull = nan(1, numPhases);
    spaceBetNatPhases = diff(sortedNatPhases);
    sortedPhaseLoc = sortedNatPhases(1) + [0 cumsum(spaceBetNatPhases)];
    sortedPhaseLoc = sortedPhaseLoc + 1; % add 1 because phases are 0-indexed
    NatImgPhasesFull(sortedPhaseLoc) = NatImg;
    NatImg = NatImgPhasesFull;
end


% Do the same for the doubles--again, use PPlusDouble this time
[~, sortIndDoub] = sort(sortingMatrix(1, PPlusDouble));
PPlusDouble = PPlusDouble(sortIndDoub);
PMinusDouble = PMinusDouble(sortIndDoub);
NPlusDouble = NPlusDouble(sortIndDoub);
NMinusDouble = NMinusDouble(sortIndDoub);

% Do the same for the neighboring bars--once again, use PPlusNeigh;
% PPlusNeigh might be empty when we're doing the 40 degree bars and it
% doesn't actually exist--in that case use NPlusNeigh
if isempty(PPlusNeigh)
    [~, sortIndNeigh] = sort(sortingMatrix(1, NPlusNeigh));
    NPlusNeigh = NPlusNeigh(sortIndNeigh);
    % At some point I realized that NMinusNeigh was just doubling up what
    % NPlusNeigh did in the scenario of bars masquerading as edges, so some
    % paramfiles might not have this...
    if ~isempty(NMinusNeigh)
        NMinusNeigh = NMinusNeigh(sortIndNeigh);
    end
else
    [~, sortIndNeigh] = sort(sortingMatrix(1, PPlusNeigh));
    PPlusNeigh = PPlusNeigh(sortIndNeigh);
    PMinusNeigh = PMinusNeigh(sortIndNeigh);
    NPlusNeigh = NPlusNeigh(sortIndNeigh);
    NMinusNeigh = NMinusNeigh(sortIndNeigh);
end

% Do the same for edges as for neighboring bars, as they are masquerading as
% neighboring bars--once again, use PPlusEdge; PPlusEdge might be empty,
% though, and in that case use NPlusEdge
if isempty(PPlusEdge)
    [~, sortIndEdge] = sort(sortingMatrix(1, NPlusEdge));
    NPlusEdge = NPlusEdge(sortIndEdge);
    % At some point I realized that NMinusNeigh was just doubling up what
    % NPlusNeigh did in the scenario of bars masquerading as edges, so some
    % paramfiles might not have this...
    if ~isempty(NMinusEdge)
        NMinusEdge = NMinusEdge(sortIndEdge);
    end
else
    [~, sortIndEdge] = sort(sortingMatrix(1, PPlusEdge));
    PPlusEdge = PPlusEdge(sortIndEdge);
    PMinusEdge = PMinusEdge(sortIndEdge);
    NPlusEdge = NPlusEdge(sortIndEdge);
    NMinusEdge = NMinusEdge(sortIndEdge);
end

% Repeat for edges that go to gray edges as for neighboring bars, as they are masquerading as
% neighboring bars--once again, use PPlusEdge; PPlusEdge might be empty,
% though, and in that case use NPlusEdge
[~, sortIndZEdge] = sort(sortingMatrix(1, ZPlusEdge));
ZPlusEdge = ZPlusEdge(sortIndZEdge);
ZMinusEdge = ZMinusEdge(sortIndZEdge);

% Align the gradients using GradientPrefIncreasing
[~, sortIndGrad] = sort(sortingMatrix(1, GPrefIncreasing));
GPrefIncreasing = GPrefIncreasing(sortIndGrad);
GNullIncreasing = GNullIncreasing(sortIndGrad);

% barToCenter = 0 is default... for directional ones anyway; not really
% defined for next-nearest anyway...
if barToCenter == 2
    % If we center bar 2, we're going to put the middle space of the next
    % nearest bars at bar 2's location, and we're going to put the single
    % bar in the location of bar 2 as well.
    if ~isempty(PPlusNull)
        bar2LocNull = sortingMatrix(7, PPlusNull);
        bar2LocPref = sortingMatrix(7, PPlusPref);
    elseif ~isempty(FlickPlusNull) && ~any(FlickPlusNull>length(roiAveragedResponses))
        bar2LocNull = sortingMatrix(7, FlickPlusNull);
        bar2LocPref = sortingMatrix(7, FlickPlusPref);
    elseif ~isempty(FlickPlusNull) && any(FlickPlusNull>length(roiAveragedResponses))
        % This happens for online kernel extraction.
        bar2LocNullT = sortingMatrix(7, FlickPlusNull(FlickPlusNull<=length(roiAveragedResponses)));
        bar2LocPrefT = sortingMatrix(7, FlickPlusPref(FlickPlusPref<=length(roiAveragedResponses)));
        bar2LocNull(FlickPlusNull<=length(roiAveragedResponses)) = bar2LocNullT;
        bar2LocPref(FlickPlusPref<=length(roiAveragedResponses)) = bar2LocPrefT;
        frstPresLocNull = find(FlickPlusNull<=length(roiAveragedResponses), 1, 'first');
        bar2LocNull(1:frstPresLocNull-1) = bar2LocNull(frstPresLocNull)-(frstPresLocNull-1):bar2LocNull(frstPresLocNull)-1;
        frstPresLocPref = find(FlickPlusPref<=length(roiAveragedResponses), 1, 'first');
        bar2LocPref(1:frstPresLocPref-1) = bar2LocPref(frstPresLocPref)-(frstPresLocPref-1):bar2LocPref(frstPresLocPref)-1;
        lstPresLocNull = find(FlickPlusNull<=length(roiAveragedResponses), 1, 'last');
        bar2LocNull(lstPresLocNull+1:numPhases) = mod(bar2LocNull(lstPresLocNull)+1:bar2LocNull(lstPresLocNull)+1+(numPhases-1-lstPresLocNull), numPhases);
        lstPresLocPref = find(FlickPlusPref<=length(roiAveragedResponses), 1, 'last');
        bar2LocPref(lstPresLocPref+1:numPhases) = mod(bar2LocPref(lstPresLocPref)+1:bar2LocPref(lstPresLocPref)+1+(numPhases-1-lstPresLocPref), numPhases);
    else
        bar2LocPref = sortingMatrix(7, PPlusPref);
        bar2LocNull = sortingMatrix(7, PPlusNull);
    end
    
    [~, bestAlign] = max(xcorr(bar2LocPref, bar2LocNull));
    nullShift = mod(bestAlign, numPhases);
    
    if ~isempty(bar2LocPref)
        % Now to the next nearest neighbor shift
        bar1LocNN = sortingMatrix(6, PPlusDouble);
        bar2LocNN = mod(bar1LocNN+1, numPhases);
        [~, bestAlign] = max(xcorr(bar2LocPref, bar2LocNN));
        nnShift = mod(bestAlign, numPhases);
        
        % Now to single bar shift
        bar1LocS = sortingMatrix(6, PlusSingle);
        [~, bestAlign] = max(xcorr(bar2LocPref, bar1LocS));
        sShift = mod(bestAlign, numPhases);
    else
        nnShift = 0;
        sShift = 0;
    end
    
    % Neighboring bar shifts will follow single bar shifts
    nShift = sShift;
    
    
    % Note that we're not looking at bar 2 location for gradients, but
    % at the positive-side or the negative-side location, depending on the
    % optimal bar
    if ~isempty(GPrefIncreasing)
        switch optimalBar
            case 'PlusSingle'
                gradLocPref = sortingMatrix(14, GPrefIncreasing);
                gradLocNull = sortingMatrix(14, GNullIncreasing);
                [~, bestAlign] = max(xcorr(gradLocPref, gradLocNull));
                gNullShift = mod(bestAlign, numPhases);
                gPrefShift = 0;
            case 'MinusSingle'
                gradLocPref = sortingMatrix(15, GPrefIncreasing);
                gradLocNull = sortingMatrix(15, GNullIncreasing);
                [~, bestAlign] = max(xcorr(gradLocPref, gradLocNull));
                gNullShift = 0;
                gPrefShift = -mod(bestAlign, numPhases);
        end
    else
        gNullShift = 0;
        gPrefShift = 0;
    end
elseif barToCenter == 1
    % If we center bar 1, we're also going to put the middle space of the
    % next nearest bars at bar 1's location, and we're going to put the
    % single bar in the location of bar 1 as well
    error('We''re not done with this yet!!');
end 

% We default these in case there are some epochs that are empty; this
% ensures that errors don't happen later on having to do with circshift and
% empty shifts
if isempty(nullShift)
    nullShift = 0;
end
if isempty(nnShift)
    nnShift = 0;
end
if isempty(sShift)
    sShift = 0;
end
if isempty(gNullShift)
    gNullShift = 0;
    gPrefShift = 0;
end




shift = 0;
% NOTE this optimal phase has to be well aligned with the
% PlotBarPairROISummary has so that the plotted responses can be aligned
% with the bar pair xt plots
optimalPhase = numPhases/2; % This is the middle phase of the plot, assuming there are as many single phases as there are total phases
%optimalPhase = 10;
if length(roiAveragedResponses) > size(sortingMatrix, 2)
    firstSingleEpoch = min([MinusSingle PlusSingle]);
    alignEpochsShift = size(sortingMatrix, 2) - firstSingleEpoch + 1;
    PlusSingleAlign = PlusSingle + alignEpochsShift;
    MinusSingleAlign = MinusSingle + alignEpochsShift;
else
    PlusSingleAlign = PlusSingle;
    MinusSingleAlign = MinusSingle;
end
if isempty(roiPhaseShift)
    warning('off', 'MATLAB:colon:nonIntegerIndex');
    switch optimalBar
        case 'PlusSingle'
            singleChecker = cat(2, roiAveragedResponses{circshift(PlusSingleAlign, sShift), 1})';
            if samplesAroundEpoch(1) || samplesAroundEpoch(2)
                meanPriorSingle = mean(singleChecker(:, samplesAroundEpoch(1)-samplesAroundEpoch(2):samplesAroundEpoch(1)-1), 2);
                meanPlusSingle = mean(singleChecker(:, samplesAroundEpoch(1):end-samplesAroundEpoch(3)), 2);
                if ~all(isnan(meanPriorSingle))
                    [~, maxLoc] = max(meanPlusSingle-meanPriorSingle);
                else
                    [~, maxLoc] = max(meanPlusSingle);
                end
            else
                meanPlusSingle = mean(singleChecker, 2);
                [~, maxLoc] = max(meanPlusSingle);
            end
            bestLoc = (maxLoc-1)/(numBootstraps+1)+1;
            shift = mod(optimalPhase - bestLoc, numPhases);
        case 'MinusSingle'
            singleChecker = cat(2, roiAveragedResponses{circshift(MinusSingleAlign, sShift), 1})';
            if samplesAroundEpoch(1) || samplesAroundEpoch(2)
                meanPriorSingle = mean(singleChecker(:, samplesAroundEpoch(1)-samplesAroundEpoch(2):samplesAroundEpoch(1)), 2);
                meanPlusSingle = mean(singleChecker(:, samplesAroundEpoch(1):end-samplesAroundEpoch(3)), 2);
                [~, maxLoc] = max(meanPlusSingle-meanPriorSingle);
            else
                meanMinusSingle = mean(singleChecker, 2);
                [~, maxLoc] = max(meanMinusSingle);
            end
            bestLoc = (maxLoc-1)/(numBootstraps+1)+1;
            shift = mod(optimalPhase - bestLoc, numPhases);
    end
    warning('off', 'MATLAB:colon:nonIntegerIndex');
else
    shift = roiPhaseShift; % In this case, we use this number, which came out from Juyue's functions as the RF center, as the actual shift to the RF center
end

% Adding a row of zeros here allows us to index those zeros if we want a
% blank answer (I'm currently thinking of flicker stimuli where only two
% phases are actually shown instead of all of them)
if ~isempty(FlickSingle) && any(FlickSingle>length(roiAveragedResponses))
    roiAveragedResponses{end+1} = nan(size(roiAveragedResponses{end}));
    % It's based on roiAveragedResponse because when there's an alignment
    % using half single bars, the lengths don't actually match
    sortingMatrix(:, length(roiAveragedResponses)+1) = nan;
end

nullShift = nullShift + shift;
nnShift = nnShift + shift;
nShift = nShift + shift;
sShift = sShift + shift;
gNullShift = gNullShift + shift;
gPrefShift = gPrefShift + shift;

PPlusPref = circshift(PPlusPref, shift);
pplusPrefResp = cat(2, roiAveragedResponses{PPlusPref, 1})';
% pplusPrefResp = circshift(pplusPrefResp, shift);

PMinusPref = circshift(PMinusPref, shift);
pminusPrefResp = cat(2, roiAveragedResponses{PMinusPref, 1})';
% pminusPrefResp = circshift(pminusPrefResp, shift);

NPlusPref = circshift(NPlusPref, shift);
nplusPrefResp = cat(2, roiAveragedResponses{NPlusPref, 1})';
% nplusPrefResp = circshift(nplusPrefResp, shift);

NMinusPref = circshift(NMinusPref, shift);
nminusPrefResp = cat(2, roiAveragedResponses{NMinusPref, 1})';
% nminusPrefResp = circshift(nminusPrefResp, shift);

PPlusNull = circshift(PPlusNull, nullShift);
pplusNullResp = cat(2, roiAveragedResponses{PPlusNull, 1})';
% pplusNullResp = circshift(pplusNullResp, nullShift);

PMinusNull = circshift(PMinusNull, nullShift);
pminusNullResp = cat(2, roiAveragedResponses{PMinusNull, 1})';
% pminusNullResp = circshift(pminusNullResp, nullShift);

NPlusNull = circshift(NPlusNull, nullShift);
nplusNullResp = cat(2, roiAveragedResponses{NPlusNull, 1})';
% nplusNullResp = circshift(nplusNullResp, nullShift);

NMinusNull = circshift(NMinusNull, nullShift);
nminusNullResp = cat(2, roiAveragedResponses{NMinusNull, 1})';
% nminusNullResp = circshift(nminusNullResp, nullShift);

PPlusDouble = circshift(PPlusDouble, nnShift);
pplusDoubleResp = cat(2, roiAveragedResponses{PPlusDouble, 1})';
% pplusDoubleResp = circshift(pplusDoubleResp, nnShift);

PMinusDouble = circshift(PMinusDouble, nnShift);
pminusDoubleResp = cat(2, roiAveragedResponses{PMinusDouble, 1})';
% pminusDoubleResp = circshift(pminusDoubleResp, nnShift);

NPlusDouble = circshift(NPlusDouble, nnShift);
nplusDoubleResp = cat(2, roiAveragedResponses{NPlusDouble, 1})';
% nplusDoubleResp = circshift(nplusDoubleResp, nnShift);

NMinusDouble = circshift(NMinusDouble, nnShift);
nminusDoubleResp = cat(2, roiAveragedResponses{NMinusDouble, 1})';
% nminusDoubleResp = circshift(nminusDoubleResp, nnShift);

FlickPlusPref = circshift(FlickPlusPref, shift);
plusPrefFlickResp = cat(2, roiAveragedResponses{FlickPlusPref, 1})';
% plusPrefFlickResp = circshift(plusPrefFlickResp, shift);

FlickMinusPref = circshift(FlickMinusPref, shift);
minusPrefFlickResp = cat(2, roiAveragedResponses{FlickMinusPref, 1})';
% minusPrefFlickResp = circshift(minusPrefFlickResp, shift);

FlickPlusNull = circshift(FlickPlusNull, nullShift);
plusNullFlickResp = cat(2, roiAveragedResponses{FlickPlusNull, 1})';
% plusNullFlickResp = circshift(plusNullFlickResp, nullShift);

FlickMinusNull = circshift(FlickMinusNull, nullShift);
minusNullFlickResp = cat(2, roiAveragedResponses{FlickMinusNull, 1})';
% minusNullFlickResp = circshift(minusNullFlickResp, nullShift);

FlickSingle = circshift(FlickSingle, sShift);
singleFlickResp = cat(2, roiAveragedResponses{FlickSingle, 1})';
% singleFlickResp = circshift(singleFlickResp, sShift);

FlickPlusPrefBs = circshift(FlickPlusPrefBs, shift);
plusPrefFlickBsResp = cat(2, roiAveragedResponses{FlickPlusPrefBs, 1})';
% plusPrefFlickBsResp = circshift(plusPrefFlickBsResp, shift);

FlickMinusPrefBs = circshift(FlickMinusPrefBs, shift);
minusPrefFlickBsResp = cat(2, roiAveragedResponses{FlickMinusPrefBs, 1})';
% minusPrefFlickBsResp = circshift(minusPrefFlickBsResp, shift);

FlickPlusNullBs = circshift(FlickPlusNullBs, nullShift);
plusNullFlickBsResp = cat(2, roiAveragedResponses{FlickPlusNullBs, 1})';
% plusNullFlickBsResp = circshift(plusNullFlickBsResp, nullShift);

FlickMinusNullBs = circshift(FlickMinusNullBs, nullShift);
minusNullFlickBsResp = cat(2, roiAveragedResponses{FlickMinusNullBs, 1})';
% minusNullFlickBsResp = circshift(minusNullFlickBsResp, nullShift);

FlickSingleBs = circshift(FlickSingleBs, sShift);
singleFlickBsResp = cat(2, roiAveragedResponses{FlickSingleBs, 1})';
% singleFlickBsResp = circshift(singleFlickBsResp, sShift);

% Gradients
GPrefIncreasing = circshift(GPrefIncreasing, gPrefShift);
gradientPrefIncreasingResp = cat(2, roiAveragedResponses{GPrefIncreasing, 1})';

GNullIncreasing = circshift(GNullIncreasing, gNullShift);
gradientNullIncreasingResp = cat(2, roiAveragedResponses{GNullIncreasing, 1})';

% Natural (static) images
NatImg = circshift(NatImg, shift);
if ~isempty(NatImg) && ~isnan(sortingMatrix(1, NatImg(find(~isnan(NatImg),1,'first')))) % this last check is to distinguish static natural images at a phase from moving natural images
    naturalImageResp = nan(numPhases, size(roiAveragedResponses{1}, 1));
    naturalImageRespInit = cat(2, roiAveragedResponses{NatImg(~isnan(NatImg)), 1})';
    naturalImageResp(~isnan(NatImg), :) = naturalImageRespInit;
    NatImg(isnan(NatImg)) = NatImgBlank;
else
    naturalImageResp = [];
end

% Moving square waves (aligned by end phase), and split by velocities
if ~isempty(MovingSquareWaves)
    for velNum = 1:length(MovingSquareWaves)
        MovingSquareWaves{velNum} = circshift(MovingSquareWaves{velNum}, sShift);
        movingSquareWavesResp{velNum} = cat(2, roiAveragedResponses{MovingSquareWaves{velNum}, 1})';
    end
else
    movingSquareWavesResp = cell(0);
end

PlusHalfSingle = circshift(PlusHalfSingle, sShift);
singlePlusHalfStillResp = cat(2, roiAveragedResponses{PlusHalfSingle, 1})';
% singlePlusHalfStillResp = circshift(singlePlusHalfStillResp, sShift);

MinusHalfSingle = circshift(MinusHalfSingle, sShift);
singleMinusHalfStillResp = cat(2, roiAveragedResponses{MinusHalfSingle, 1})';
% singleMinusHalfStillResp = circshift(singleMinusHalfStillResp, sShift);

PlusShortSingle = circshift(PlusShortSingle, sShift);
singlePlusShortStillResp = cat(2, roiAveragedResponses{PlusShortSingle, 1})';
% singlePlusShortStillResp = circshift(singlePlusShortStillResp, sShift);

MinusShortSingle = circshift(MinusShortSingle, sShift);
singleMinusShortStillResp = cat(2, roiAveragedResponses{MinusShortSingle, 1})';
% singleMinusShortStillResp = circshift(singleMinusShortStillResp, sShift);

PlusSingle = circshift(PlusSingle, sShift);
singlePlusStillResp = cat(2, roiAveragedResponses{PlusSingle, 1})';
% singlePlusStillResp = circshift(singlePlusStillResp, sShift);

MinusSingle = circshift(MinusSingle, sShift);
singleMinusStillResp = cat(2, roiAveragedResponses{MinusSingle, 1})';
% singleMinusStillResp = circshift(singleMinusStillResp, sShift);




% This might only work if barToCenter==2
switch optimalBar
    case 'PlusSingle'
        % first do the neighboring bars
        PMinusNeigh = circshift(PMinusNeigh, nShift);
        pminusNeighResp = cat(2, roiAveragedResponses{PMinusNeigh, 1})';
        
        NPlusNeigh = circshift(NPlusNeigh, nShift);
        nplusNeighResp = cat(2, roiAveragedResponses{NPlusNeigh, 1})';
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = nShift + 1;
        
        PPlusNeigh = circshift(PPlusNeigh, nShift);
        pplusNeighResp = cat(2, roiAveragedResponses{PPlusNeigh, 1})';
        
        NMinusNeigh = circshift(NMinusNeigh, nShift);
        nminusNeighResp = cat(2, roiAveragedResponses{NMinusNeigh, 1})';
        
        % then do the edges--but get nShift back to its starting position!
        nShift = nShift-1;
        PMinusEdge = circshift(PMinusEdge, nShift);
        pminusEdgeResp = cat(2, roiAveragedResponses{PMinusEdge, 1})';
        
        NPlusEdge = circshift(NPlusEdge, nShift);
        nplusEdgeResp = cat(2, roiAveragedResponses{NPlusEdge, 1})';
        
       
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = nShift + 1;
        
        PPlusEdge = circshift(PPlusEdge, nShift);
        pplusEdgeResp = cat(2, roiAveragedResponses{PPlusEdge, 1})';
        
        NMinusEdge = circshift(NMinusEdge, nShift);
        nminusEdgeResp = cat(2, roiAveragedResponses{NMinusEdge, 1})'; 
        
        % the Z's follow the N's
        ZPlusEdge = circshift(ZPlusEdge, nShift);
        zplusEdgeResp = cat(2, roiAveragedResponses{ZPlusEdge, 1})';
        
        ZMinusEdge = circshift(ZMinusEdge, nShift);
        zminusEdgeResp = cat(2, roiAveragedResponses{ZMinusEdge, 1})';
    case 'MinusSingle'
        % first do the neighboring bars
        NMinusNeigh = circshift(NMinusNeigh, nShift);
        nminusNeighResp = cat(2, roiAveragedResponses{NMinusNeigh, 1})';
        
        PPlusNeigh = circshift(PPlusNeigh, nShift);
        pplusNeighResp = cat(2, roiAveragedResponses{PPlusNeigh, 1})';
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = nShift + 1;
        
        NPlusNeigh = circshift(NPlusNeigh, nShift);
        nplusNeighResp = cat(2, roiAveragedResponses{NPlusNeigh, 1})';
        
        PMinusNeigh = circshift(PMinusNeigh, nShift);
        pminusNeighResp = cat(2, roiAveragedResponses{PMinusNeigh, 1})';
        
        % then do edges--but get nShift back to its starting position!
        nShift = nShift-1;
        NMinusEdge = circshift(NMinusEdge, nShift);
        nminusEdgeResp = cat(2, roiAveragedResponses{NMinusEdge, 1})';
        
        PPlusEdge = circshift(PPlusEdge, nShift);
        pplusEdgeResp = cat(2, roiAveragedResponses{PPlusEdge, 1})';
        
        
        % Dealing with the fact that neighboring bars have to be
        % differently shifted if they're to be offset
        nShift = nShift + 1;
        
        NPlusEdge = circshift(NPlusEdge, nShift);
        nplusEdgeResp = cat(2, roiAveragedResponses{NPlusEdge, 1})';
        
        PMinusEdge = circshift(PMinusEdge, nShift);
        pminusEdgeResp = cat(2, roiAveragedResponses{PMinusEdge, 1})';
        
        % the Z's follow the N's
        ZMinusEdge = circshift(ZMinusEdge, nShift);
        zminusEdgeResp = cat(2, roiAveragedResponses{ZMinusEdge, 1})';
        
        ZPlusEdge = circshift(ZPlusEdge, nShift);
        zplusEdgeResp = cat(2, roiAveragedResponses{ZPlusEdge, 1})';
end


out = [pplusPrefResp; pplusNullResp; pminusPrefResp; pminusNullResp; nplusPrefResp; nplusNullResp; nminusPrefResp;  nminusNullResp; pplusDoubleResp; pminusDoubleResp; nplusDoubleResp; nminusDoubleResp; pplusNeighResp; pminusNeighResp; nplusNeighResp; nminusNeighResp; pplusEdgeResp; pminusEdgeResp; nplusEdgeResp; nminusEdgeResp; zplusEdgeResp; zminusEdgeResp; plusPrefFlickResp; minusPrefFlickResp; plusNullFlickResp; minusNullFlickResp; singleFlickResp; plusPrefFlickBsResp; minusPrefFlickBsResp; plusNullFlickBsResp; minusNullFlickBsResp; singleFlickBsResp; gradientPrefIncreasingResp; gradientNullIncreasingResp; naturalImageResp; cat(1, movingSquareWavesResp{:}); singlePlusHalfStillResp; singleMinusHalfStillResp; singlePlusShortStillResp; singleMinusShortStillResp; singlePlusStillResp; singleMinusStillResp];
sortIndexes = [PPlusPref, PPlusNull, PMinusPref, PMinusNull, NPlusPref, NPlusNull, NMinusPref, NMinusNull, PPlusDouble, PMinusDouble, NPlusDouble, NMinusDouble, PPlusNeigh, PMinusNeigh, NPlusNeigh, NMinusNeigh, PPlusEdge, PMinusEdge, NPlusEdge, NMinusEdge, ZPlusEdge, ZMinusEdge, FlickPlusPref, FlickMinusPref, FlickPlusNull, FlickMinusNull, FlickSingle, FlickPlusPrefBs, FlickMinusPrefBs, FlickPlusNullBs, FlickMinusNullBs, FlickSingleBs, GPrefIncreasing, GNullIncreasing, NatImg, cat(2, MovingSquareWaves{:}), PlusHalfSingle, MinusHalfSingle, PlusShortSingle, MinusShortSingle, PlusSingle, MinusSingle];
outSortMat = sortingMatrix(:, sortIndexes);
availableDescriptions = [{'++ Prog Dir'}, '++ Reg Dir', '-- Prog Dir', '-- Reg Dir',... slick trick to allow the strcat below to concatenate individual cells instead of an array heh...
    '+- Prog Dir', '+- Reg Dir', '-+ Prog Dir', '-+ Reg Dir',...
    '+ + Still', '- - Still', '+ - Still', '- + Still'...
    '++ Still', '-- Still', '+- Still', '-+ Still'...
    '++ Edge', '-- Edge', '+- Edge', '-+ Edge', '+0 Edge', '-0 Edge'...
    '+ Prog Flickering', '- Prog Flickering', '+ Reg Flickering', '- Reg Flickering', 'Flickering Single'...
    '+ Prog Flickering Bootstrap', '- Prog Flickering Bootstrap', '+ Reg Flickering Bootstrap', '- Reg Flickering Bootstrap', 'Flickering Single Bootstrap'...
    'Gradient Prog Dir Increasing', 'Gradient Reg Dir Increasing',...
    'Natural Image Static',...
    strcat('Moving Square Waves vel=', arrayfun(@(x) num2str(x), vels, 'uni', 0)),...
    '+ Still Half', '- Still Half', '+ Still Short', '- Still Short'...
    '+ Still', '- Still']';
matsUsed = [{pplusPrefResp; pplusNullResp; pminusPrefResp;   pminusNullResp;   nplusPrefResp; nplusNullResp; nminusPrefResp;  nminusNullResp; pplusDoubleResp; pminusDoubleResp; nplusDoubleResp; nminusDoubleResp; pplusNeighResp; pminusNeighResp; nplusNeighResp; nminusNeighResp; pplusEdgeResp; pminusEdgeResp; nplusEdgeResp; nminusEdgeResp; zplusEdgeResp; zminusEdgeResp; plusPrefFlickResp; minusPrefFlickResp; plusNullFlickResp; minusNullFlickResp; singleFlickResp; plusPrefFlickBsResp; minusPrefFlickBsResp; plusNullFlickBsResp; minusNullFlickBsResp; singleFlickBsResp; gradientPrefIncreasingResp; gradientNullIncreasingResp; naturalImageResp}; movingSquareWavesResp'; {singlePlusHalfStillResp; singleMinusHalfStillResp; singlePlusShortStillResp; singleMinusShortStillResp; singlePlusStillResp; singleMinusStillResp}];
descriptionsUsed = cellfun(@(respMat) ~isempty(respMat), matsUsed);
rowsPerMat = cellfun(@(respMat) size(respMat, 1), matsUsed);
startingRows = cumsum([0; rowsPerMat]);
startingRows = startingRows(1:end-1)+1;
descriptionCell = [availableDescriptions num2cell(rowsPerMat) num2cell(startingRows)];
outDesc = descriptionCell(descriptionsUsed, :);

    
