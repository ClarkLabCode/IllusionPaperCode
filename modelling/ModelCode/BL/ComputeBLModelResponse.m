function [meanResp, calciumResp] = ComputeBLModelResponse(stimArray, p, f)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Compute photoreceptor responses

% Blur the filter in space (assumes periodic boundary conditions)
if p.useSpatialFilter
    blurArray = fftshift(ifft(fft(f.spatialFilter,[],2) .* fft(stimArray,[],2), [], 2),2);
else
    blurArray = stimArray;
end

% Filter the spatially-blurred stimulus in time
lpArray = filter(f.lp, 1, blurArray, [], 1);
hpArray = filter(f.hp, 1, blurArray, [], 1);

% Shift the stimulus to get each of the photoreceptor inputs
% Note that signs of circshifts are reversed relative to index notation
prShift = floor(p.photoreceptorSpacing / p.dx);
resp2 = circshift(lpArray, -prShift, 2);
resp1 = hpArray;

%% Compute three-input conductance nonlinearity model response

% Define the input rectifiers
if isinf(p.inputRectBeta)
    relu = @(f)(f .* (f>0));
else
    relu = @(f) f.*(erf(p.inputRectBeta * f)+1)/2;
end

% Divisive
% calciumResp = relu(relu(resp1) ./ (1 + relu(resp2)));
% Subtractive
calciumResp = relu(relu(resp1) - p.inhibitionWeight*relu(resp2));
meanResp = squeeze(nanmean(nanmean(nanmean(calciumResp(p.averagingMask,:,:,:),4),2),1));

end




