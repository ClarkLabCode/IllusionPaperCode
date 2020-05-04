function [ stimArray ] = StaticEdges(params, barParam,stimsToUse)

% generate one-dimensional stationary patterns
s = square(2*pi*params.x / barParam.barPeriod);
sawtoothUp=repmat(linspace(-barParam.c,barParam.c,length(s)/2),1,2);
sawtoothDown=repmat(linspace(barParam.c,-barParam.c,length(s)/2),1,2);
%stimArray = cat(3, s, s/2+1/2, s/2-1/2,sawtoothUp,sawtoothDown);
stimArray=[];
for ii = 1:length(stimsToUse)
    thisStimName = stimsToUse{ii};
    switch thisStimName
        case 'white-black'
            stimArray = cat(3,stimArray, s);
        case 'white-gray'
            stimArray = cat(3, stimArray, s/2+1/2);
        case 'gray-black'
            stimArray = cat(3, stimArray, s/2-1/2);
        case 'sawtoothUp'
            stimArray = cat(3, stimArray, sawtoothUp);
        case 'sawtoothDown'
            stimArray = cat(3, stimArray, sawtoothDown);
    end
end
% expand 1D stationary stimulus array over time by multiplying it with
% temporal mask (params.mask)
stimArray =  barParam.mlum + barParam.c .* params.mask .* stimArray;
end

