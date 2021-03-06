function [meanResp, voltageResp, calciumResp, meanNumResp, meanDenResp, meanNumRespLN ] = ComputeThreeInputModelResponse_T4orig(stimArray, p, f)
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
resp1 = circshift(lpArray, +prShift, 2);
resp2 = hpArray;
resp3 = circshift(lpArray, -prShift, 2);

%% Compute three-input conductance nonlinearity model response

% Define the input rectifiers
if isinf(p.inputRectBeta)
    relu = @(f) (f .* (f>0));
else
    relu = @(f) f.*(erf(p.inputRectBeta * f)+1)/2;
end

% Define the output half-quadratic
if isinf(p.outputRectBeta)
    halfsquare = @(f) (f .* (f>0)).^2;
else
    halfsquare = @(f) (f.*(erf(p.outputRectBeta*f)+1)/2).^2;
end

% Compute each postsynaptic conductance
% Input 1 ~ ? off inhibitory
% Input 2 ~ Tm2/Tm4 off excitatory
% Input 3 ~ ? off inhibitory
g1 = p.g1 .* relu(-resp1);
g2 = p.g2 .* relu(+resp2);
g3 = p.g3 .* relu(+resp3);

% Compute the numerator and denominator of the three-input model
numResp = p.V1 .* g1 + p.V2 .* g2 + p.V3 .* g3;
denResp = p.gleak + g1 + g2 + g3;

% Compute the voltage response of the full model
voltageResp = numResp ./ denResp;

% Model the transformation from membrane voltage to calcium concentration
% as a half-quadratic
calciumResp = halfsquare(voltageResp);

%% Compute averaged numerator and denominator LNLN responses, if desired

% Factorization into a product of LNLN models
if nargout > 3
    meanNumResp = squeeze(nanmean(nanmean(nanmean(halfsquare(numResp(p.averagingMask,:,:,:)),4),2),1));
    meanDenResp = squeeze(nanmean(nanmean(nanmean(1./halfsquare(denResp(p.averagingMask,:,:,:)),4),2),1));
end

% Numerator LN model without intermediate rectification
if nargout > 5
    numRespLN = -p.V1*p.g1*resp1 + p.V2*p.g2*resp2 + p.V3*p.g3*resp3;
    meanNumRespLN = squeeze(nanmean(nanmean(nanmean(halfsquare(numRespLN(p.averagingMask,:,:,:)),4),2),1));
end

%% Average model responses over time and phase

meanResp = squeeze(nanmean(nanmean(nanmean(calciumResp(p.averagingMask,:,:,:),4),2),1));

end

