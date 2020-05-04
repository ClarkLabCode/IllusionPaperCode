function [meanResp, calciumResp] = ComputeMotionEnergyModelResponse(stimArray, p, f)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Compute photoreceptor responses

% Convolve the filter in space (assumes periodic boundary conditions)
oddArray  = fftshift(ifft(fft(f.spatialFilterOdd,[],2) .* fft(stimArray,[],2), [], 2),2);
evenArray = fftshift(ifft(fft(f.spatialFilterEven,[],2) .* fft(stimArray,[],2), [], 2),2);

% Filter the spatially-blurred stimulus in time
lpOddArray = filter(f.lp, 1, oddArray, [], 1);
hpEvenArray = filter(f.hp, 1, evenArray, [], 1);

%% Compute output

% Define the output half-quadratic
if isinf(p.outputRectBeta)
    halfsquare = @(f) (f .* (f>0)).^2;
else
    halfsquare = @(f) (f.*(erf(p.outputRectBeta*f)+1)/2).^2;
end

% Model the transformation from membrane voltage to calcium concentration
% as a half-quadratic
calciumResp = halfsquare(lpOddArray + hpEvenArray);

%% Compute averaged numerator and denominator LNLN responses, if desired
%% Average model responses over time and phase
meanResp = squeeze(nanmean(nanmean(nanmean(calciumResp(p.averagingMask,:,:,:),4),2),1));

end

