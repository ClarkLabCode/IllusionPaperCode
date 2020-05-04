function [ stimArray ] = GenerateMovingEdges(params, barParam)

% This function generates moving edges used for T4/T5 identification

v = barParam.velocity; % deg/s
t = params.t;  % in s
x = params.x;  % in degrees
x = x - x(round(length(x)/2));  % shift so that the center is 0 deg

% calculate edge position (with centering) - positive velocity = rightward 
edgePos = v*(t - params.tOn/2);

% generate an edge
edge = -1+2*(repmat(edgePos,1,length(x)) > repmat(x,length(t),1));

% create full permutation of edges with sign and direction fliping
stimArray = [];
stimArray(:,:,1) = +edge;
stimArray(:,:,2) = -edge;
stimArray(:,:,3) = fliplr(+edge);
stimArray(:,:,4) = fliplr(-edge);

% contrast/luminance scaling & temporal masking
stimArray =  barParam.mlum + barParam.c .* stimArray;
end

