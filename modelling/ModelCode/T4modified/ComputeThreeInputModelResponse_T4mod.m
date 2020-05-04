function [meanResp, voltageResp, calciumResp, meanNumResp, meanDenResp, meanNumRespLN ] =...
    ComputeThreeInputModelResponse_T4mod(stimArray, p, f)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Compute photoreceptor responses

thres = p.thres; % overwrite thres

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
    relu_Mi9=@(f)(f .* (f>0));
    relu_Mi1=@(f)(f .* (f>0));
    %relu_Mi1=@(f)((f-thres(1)) .* (f>thres(1)));
    relu_Mi4=@(f) ((f-thres(1)) .* (f>thres(1)));
else
    relu = @(f) f.*(erf(p.inputRectBeta * f)+1)/2;
end

% Define the output half-quadratic
if isinf(p.outputRectBeta)
    halfsquare = @(f) ((f-thres(2)).^2 .* (f>thres(2)));
else
    halfsquare = @(f) (f.*(erf(p.outputRectBeta*f)+1)/2).^2;
end

% Compute each postsynaptic conductance
% Input 1 ~ Mi9
% Input 2 ~ Mi1
% Input 3 ~ Mi4
g1 = p.g1 .* relu_Mi9(-resp1);
g2 = p.g2 .* relu_Mi1(+resp2);
g3 = p.g3 .* relu_Mi4(+resp3);

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




%% plot intermediate steps

% if plotsMA
%     
%     txt{1}='black white';
%     txt{2}='white gray';
%     txt{3}='black gray';
%     
%     for n=1:3
% 
%         nSubX=3;
%         nSubY=11;
%         
%         figure('Name',['threshold ' num2str(thres)],'position',[1 1 1080 500])
%         subplot(nSubY,nSubX,2);
%         
%         currStim=stimArray(:,:,n);
%         imagesc(currStim)
%         title('stim')
%         xlabel('space')
%         ylabel('time')
%         box off
%         colormap gray
%         maxi=max(max(currStim));
%         mini=min(min(currStim));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,5)
%         curr=blurArray(:,:,n);
%         imagesc(curr)
%         title('blur in space')
%         axis off
%         ylabel('time')
%         colormap gray
%         maxi=max(max(currStim));
%         mini=min(min(currStim));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,7)
%         curr=lpArray(:,:,n);
%         imagesc(curr)
%         title('Mi9')
%         ylabel('blur in time')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,8)
%         curr=hpArray(:,:,n);
%         imagesc(curr)
%         title('Mi1')
%         axis off
%         ylabel('time')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,9)
%         curr=lpArray(:,:,n);
%         imagesc(curr)
%         title('Mi4')
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,10)
%         curr=resp1(:,:,n);
%         imagesc(curr)
%         ylabel('space shift')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,11)
%         curr=resp2(:,:,n);
%         imagesc(curr)
%         axis off
%         ylabel('time')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,12)
%         curr=resp3(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,13)
%         curr=-resp1(:,:,n);
%         imagesc(curr)
%         ylabel('pre-rect')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,14)
%         curr=+resp2(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,15)
%         curr=+resp3(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,16)
%         Mi9_rect=g1;
%         curr=Mi9_rect(:,:,n);
%         imagesc(curr)
%         ylabel('rect')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,17)
%         Mi1_rect=g2;
%         curr=Mi1_rect(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,18)
%         Mi4_rect=g3;
%         curr=Mi4_rect(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,19)
%         Mi9_weighted=p.V1 .* g1;
%         curr=Mi9_weighted(:,:,n);
%         imagesc(Mi9_weighted(:,:,n))
%         colormap gray
%         ylabel('weighted')
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,20)
%         Mi1_weighted=p.V2 .* g2;
%         curr=Mi1_weighted(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,21)
%         Mi4_weighted=p.V3 .* g3;
%         curr=Mi4_weighted(:,:,n);
%         imagesc(curr)
%         axis off
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
%         subplot(nSubY,nSubX,23)
%         num=Mi9_weighted(:,:,n)+Mi1_weighted(:,:,n)+Mi4_weighted(:,:,n);
%         imagesc(num)
%         ylabel('num')
%         colormap gray
%         maxi=max(max(num));
%         mini=min(min(num));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
% 
%         subplot(nSubY,nSubX,26)
%         den=p.gleak+g1(:,:,n)+g2(:,:,n)+g3(:,:,n);
%         imagesc(den)
%         ylabel('den')
%         colormap gray
%         maxi=max(max(den));
%         mini=min(min(den));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%         
% 
%         subplot(nSubY,nSubX,29)
%         curr=voltageResp(:,:,n);
%         imagesc(curr)
%         ylabel('voltage')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
% 
%         subplot(nSubY,nSubX,32)
%         curr=calciumResp(:,:,n);
%         imagesc(curr)
%         ylabel('calcium')
%         colormap gray
%         maxi=max(max(curr));
%         mini=min(min(curr));
%         absi=max([abs(maxi),abs(mini)]);
%         caxis([-absi,absi])
%     end
%     
% %     figure('Name',['threshold ' num2str(th)],'position',[1 1 1080 500])
% %     counter=1;
% %     for k=1:2:5
% %         subplot(6,1,k)
% %         stim=stimArray(:,:,counter);
% %         imagesc(stim)
% %         ylabel('calcium')
% %         colormap gray
% %         maxi=max(max(max(stim)));
% %         mini=min(min(min(stim)));
% %         absi=max([abs(maxi),abs(mini)]);
% %         caxis([-absi,absi])
% %         colormap gray
% %         
% %         subplot(6,1,k+1)
% %         resp=calciumResp(:,:,counter);
% %         imagesc(resp)
% %         colormap gray
% % %         maxi=max(max(max(calciumResp)));
% % %         mini=min(min(min(calciumResp)));
% % %         absi=max([abs(maxi),abs(mini)]);
% % %         caxis([-absi,absi])
% % %         title(txt{counter})
% % %         colormap(b2r(-absi,absi))
% %         counter=counter+1;
% %     end
%     linkaxes
% end




