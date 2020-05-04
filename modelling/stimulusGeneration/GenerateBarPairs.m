function [ stimArray ] = GenerateBarPairs(params, barParam)

% This function generates full combination of bar pair stimuli 
% to be used for simulation in the models of motion detectors.
% This is a bit redundant in that some of the stimulus pairs are just
% spatially shifted version, but it makes downstream comparison simpler

x = params.x;                   % in degrees
x = x - x(round(length(x)/2));  % shift so that the center is 0 deg

w   = barParam.width;          % bar width (in degree)
ivl = barParam.interval; % bar interval (in degree);

% binary masks for the three possible bar locations
LbarMask = -w/2-ivl <= x & x < w/2-ivl;
CbarMask = -w/2     <= x & x < w/2;
RbarMask = -w/2+ivl <= x & x < w/2+ivl;

stimArray = [];

% Single bars
stimArray = cat(3, stimArray, +1*CbarMask); % single light bar
stimArray = cat(3, stimArray, -1*CbarMask); % single dark  bar

% Center light bar + second bar
stimArray = cat(3, stimArray, +1*CbarMask + RbarMask); % light on right
stimArray = cat(3, stimArray, +1*CbarMask - RbarMask); % dark  on right
stimArray = cat(3, stimArray, +1*CbarMask + LbarMask); % light on left
stimArray = cat(3, stimArray, +1*CbarMask - LbarMask); % dark  on left

% Center dark bar + second bar
stimArray = cat(3, stimArray, -1*CbarMask + RbarMask); % light on right
stimArray = cat(3, stimArray, -1*CbarMask - RbarMask); % dark  on right
stimArray = cat(3, stimArray, -1*CbarMask + LbarMask); % light on left
stimArray = cat(3, stimArray, -1*CbarMask - LbarMask); % dark  on left

% expand stimulus in time using params.mask
stimArray =  barParam.mlum + barParam.c .* params.mask .* stimArray;
end

