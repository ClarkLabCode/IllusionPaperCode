function [barPairSortingStructure, numPhases, epochsOfInterestFirst] = SortBarPairBarLocations(params, epochsOfInterestFirst)

if nargin<2
    epochNames = {params.epochName};
    epochsOfInterestFirstLeft = find(~cellfun('isempty', strfind(epochNames, 'L++')), 1, 'first');
    epochsOfInterestFirstRight = find(~cellfun('isempty', strfind(epochNames, 'R++')), 1, 'first');
    if ~isempty(epochsOfInterestFirstLeft)
        if epochsOfInterestFirstLeft < epochsOfInterestFirstRight
            epochsOfInterestFirst = epochsOfInterestFirstLeft;
        else
            epochsOfInterestFirst = epochsOfInterestFirstRight;
        end
    else
        epochsOfInterestFirst = 1; % Just use all the passed params
    end
end

if isfield(params, 'phase')
    epPhCell = {params(epochsOfInterestFirst:end).phase};
    epPhCell(cellfun('isempty', epPhCell)) = {nan};
    epochPhases = [epPhCell{:}];
else
    epochPhases = nan(size(params));
end

epDirCell = {params(epochsOfInterestFirst:end).direction};
epDirCell(cellfun('isempty', epDirCell)) = {nan};
epochDirections = [epDirCell{:}];

if isfield(params, 'firstBarContrast')
    epC1Cell = {params(epochsOfInterestFirst:end).firstBarContrast};
    epC1Cell(cellfun('isempty', epC1Cell)) = {nan};
    epochContrastBar1 = [epC1Cell{:}];
else
    epochContrastBar1 = nan(size(epochPhases));
end

if isfield(params, 'secondBarContrast')
    epC2Cell = {params(epochsOfInterestFirst:end).secondBarContrast};
    epC2Cell(cellfun('isempty', epC2Cell)) = {nan};
    epochContrastBar2 = [epC2Cell{:}];
else
    epochContrastBar2 = nan(size(epochPhases));
end

if isfield(params, 'secondBarDelay')
    epDel2Cell = {params(epochsOfInterestFirst:end).secondBarDelay};
    epDel2Cell(cellfun('isempty', epDel2Cell)) = {nan};
    epochDelayBar2 = [epDel2Cell{:}];
else
    epochDelayBar2 = nan(size(epochPhases));
end

if isfield(params, 'barWd')
    bWCell = {params(epochsOfInterestFirst:end).barWd};
    bWCell(cellfun('isempty', bWCell)) = {nan};
    barWidth = [bWCell{:}];
else
    barWidth = nan(size(epochPhases));
end

if isfield(params, 'spaceWidth')
    sWCell = {params(epochsOfInterestFirst:end).spaceWd};
    sWCell(cellfun('isempty', sWCell)) = {nan};
    spaceWidth = [sWCell{:}];
else
    spaceWidth = nan(size(epochPhases));
end

if isfield(params, 'phaseShift')
    phSCell = {params(epochsOfInterestFirst:end).phaseShift};
    phSCell(cellfun('isempty', phSCell)) = {nan};
    phaseWidth = [phSCell{:}];
else
    phaseWidth = barWidth;
end

if isfield(params, 'firstBarDelay')
    epDel1Cell = {params(epochsOfInterestFirst:end).firstBarDelay};
    epDel1Cell(cellfun('isempty', epDel1Cell)) = {nan};
    epochDelayBar1 = [epDel1Cell{:}];
else
    epochDelayBar1 = zeros(size(epochDelayBar2)); % It was always 0 before this parameter was here...
end

if isfield(params, 'firstBarOff')
    epochBar1Off = [params(epochsOfInterestFirst:end).firstBarOff];
    epochBar2Off = [params(epochsOfInterestFirst:end).secondBarOff];
else
    epochBar1Off = [params(epochsOfInterestFirst:end).duration]/60; % They always turned off together, at the end, before there was a firstBarOff field
    epochBar2Off = [params(epochsOfInterestFirst:end).duration]/60;
end

if isfield(params, 'polarity')
    polarity = [params(epochsOfInterestFirst:end).polarity];
    % NOTE: here we're assuming that polarity will never have a reason to
    % be set to zero in the gradient stim function--'tis dangerous
    epochContrastBar1(polarity~=0) = nan;
    epochContrastBar2(polarity~=0) = nan;
else
    polarity = nan(size(epochBar1Off));
end

if isfield(params, 'imgNum')
    epImgNumCell = {params(epochsOfInterestFirst:end).imgNum};
    epImgNumCell(cellfun('isempty', epImgNumCell)) = {nan};
    epochImgNum = [epImgNumCell{:}];
else
    epochImgNum = nan(size(epochPhases));
end
    
phase = sort(unique(epochPhases(~isnan(epochPhases))));
numPhases = length(phase);

% On all but leftward AM directions, the first bar is at the given phase
bar1Location = epochPhases;
% We add 1 to these values because that sets overflow phases to 0,
% correctly wrapping them
bar1Location(epochDirections==-1) = mod(bar1Location(epochDirections==-1)+1, max(phase)+1);
if ~isempty(phase)
    bar2Location = mod(epochPhases+1, max(phase)+1);
else
    bar2Location = nan(size(bar1Location));
end
% In leftward direction, bar2 is at the location of the phase
bar2Location(epochDirections==-1) = epochPhases(epochDirections==-1);
% When split is by 2, the bar2 location is one next to the previous bar 2
% location
bar2Location(epochDirections==2) = mod(bar2Location(epochDirections==2)+1, max(phase)+1);

% When we're looking at gradients, the edge is adjacent to (to the left of)
% the phase--that means the gradientPositive location is at the phase for
% gradients decreasing to the right (negative polarity value), or one less
% than the phase for leftwards-decreasing gradients (positive polarity
% value; where the gradientNegative location is now at the phase)
%
% NOTE: here we're assuming that polarity will never have a reason to
% be set to zero in the gradient stim function--'tis dangerous
if ~all(isnan(polarity))
    gradientPositiveLocation = epochPhases;
    gradientPositiveLocation(polarity == 1) = mod(epochPhases(polarity == 1)-1, max(phase)+1);
    gradientPositiveLocation(polarity == 0) = nan;
    gradientNegativeLocation = epochPhases;
    gradientNegativeLocation(polarity == -1) = mod(epochPhases(polarity == -1)-1, max(phase)+1);
    gradientNegativeLocation(polarity == 0) = nan;
    epochDirections(polarity~=0) = polarity(polarity~=0);
else
    gradientPositiveLocation = nan(size(epochPhases));
    gradientNegativeLocation = nan(size(epochPhases));
end

endPhases = epochPhases;
if isfield(params, 'phaseEnd')
    endPhCell = {params(epochsOfInterestFirst:end).phaseEnd};
    endPhCell(cellfun('isempty', endPhCell)) = num2cell(epochPhases(cellfun('isempty', endPhCell)));
    endPhases = [endPhCell{:}];
end

if numPhases==0
    unqEndPhase = sort(unique(endPhases(~isnan(endPhases))));
    numPhases = length(unqEndPhase);
end

if isfield(params, 'vel')
    velCell = {params(epochsOfInterestFirst:end).vel};
    velCell(cellfun('isempty', velCell)) = {nan}; % default is zero velocity, but this is also used to distinguish moving square waves from still ones, so NaN it will be!
    vels = [velCell{:}];
end

barPairSortingStructure.description = sprintf(['The columns of the matrix are sequential epochs from interleave.\n'...
                        'The rows of the matrix are as follows:\n'...
                        '1: bar phase\n'...
                        '2: direction of motion/gradient\n'...
                        '3: bar 1 contrast\n'...
                        '4: bar 2 contrast\n'...
                        '5: bar 2 delay\n'...
                        '6: bar 1 location\n'...
                        '7: bar 2 location\n'...
                        '8: bar width\n'...
                        '9: space width\n'...
                        '10: phase width\n'...
                        '11: bar 1 delay\n'...
                        '12: bar 1 off\n'...
                        '13: bar 2 off\n'...
                        '14: gradient positive location\n'...
                        '15: gradient negative location\n'...
                        '16: image number\n'...
                        '17: end phases\n'...
                        '18: velocities']);
barPairSortingStructure.matrix = [epochPhases; epochDirections; epochContrastBar1; epochContrastBar2; epochDelayBar2; bar1Location; bar2Location; barWidth; spaceWidth; phaseWidth; epochDelayBar1; epochBar1Off; epochBar2Off; gradientPositiveLocation; gradientNegativeLocation; epochImgNum; endPhases; vels];
barPairSortingStructure.phase = epochPhases;
barPairSortingStructure.direction = epochDirections;
barPairSortingStructure.bar1contrast = epochContrastBar1;
barPairSortingStructure.bar2contrast = epochContrastBar2;
barPairSortingStructure.bar1delay = epochDelayBar1;
barPairSortingStructure.bar2delay = epochDelayBar2;
barPairSortingStructure.bar1Location = bar1Location;
barPairSortingStructure.bar2Location = bar2Location;
barPairSortingStructure.barWidth = barWidth;
barPairSortingStructure.spaceWidth = spaceWidth;
barPairSortingStructure.phaseWidth = phaseWidth;
barPairSortingStructure.epochBar1Off = epochBar1Off;
barPairSortingStructure.epochBar2Off = epochBar2Off;
barPairSortingStructure.gradientPositiveLocation = gradientPositiveLocation;
barPairSortingStructure.gradientNegativeLocation = gradientNegativeLocation;
barPairSortingStructure.imgNum = epochImgNum;
barPairSortingStructure.endPhase = endPhases;
barPairSortingStructure.vel = vels;

% We may (i.e. natural images) have interleaves that are present in the
% matrix but need to be removed
if isfield(params, 'entryPoint')
    epEntryPtsInterleave = {params(epochsOfInterestFirst:end).entryPoint};
    epEntryPtsInterleave(cellfun('isempty', epEntryPtsInterleave)) = {nan};
    epochEntryPoints = [epEntryPtsInterleave{:}];
    epochEntryPoints = logical(epochEntryPoints);
    
    sortingFlds = fieldnames(barPairSortingStructure);
    
    for fldInd = 1:length(sortingFlds)
        fld = sortingFlds{fldInd};
        if isequal(fld, 'description')
            continue
        end
        fieldToChange = barPairSortingStructure.(fld);
        fieldToChange(:, epochEntryPoints) = nan;
        barPairSortingStructure.(fld) = fieldToChange;
    end
    
end