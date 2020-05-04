function Figure6D(data)

% Create a figure panel
MakeFigure('Name','Figure 6D','NumberTitle','off')

% define color scheme
pcols = [90/255,90/255,90/255;...
    33/255,121/255,180/255;...
    246/255,151/255,153/255];

% define condition names
cnames = {'no adaptor','ON adaptor','OFF adaptor'};

% extract the number of subjects
nSub = length(data);

% prepare matrices to hold point estimates of parameters
ET = []; 
% for each subject
for ss = 1:nSub
    % for eaach condition
    for ii = 1:length(cnames)
      % Use a custom QUEST function to pull out posterior distribution
      [~,ET(ss,ii),pdf2d(:,:,ii,ss),T,~] = QuestBetaAnalysisLogistic(data{ss}.q{ii},0,3.5,3);  
    end
end


%% show bar graphs with errorbars around each individual data
% calculate 68% credible interval (1SD) of T based on marginal distribution
ETerror = nan(nSub,3,2); 
for ss = 1:nSub
    for ii = 1:length(cnames)
        margpdf = mean(pdf2d(:,:,ii,ss),1);
        margpdf = margpdf/sum(margpdf);
        cmargdis = cumsum(margpdf);
        [~,indlow] = min(abs(cmargdis-0.16));
        [~,indhigh] = min(abs(cmargdis-0.84));
        ETerror(ss,ii,1) = T(indlow);
        ETerror(ss,ii,2) = T(indhigh);
    end
end

% plot results

easyBarIndivError(ET,ETerror,'newFigure',0,'connectPaired',1,'colors',pcols,'conditionNames',cnames);
title('Estimated Threshold');

%% Calculate within individual significance of nulling velocity
confmat = [];
% for each individual,
for ss = 1:size(pdf2d,4)
    thispdf = pdf2d(:,:,:,ss);
    margpdf = squeeze(sum(thispdf,1));
    margpdf = margpdf./sum(margpdf);
    margcdf = cumsum(margpdf);
    % for each pair of conditions, calculate probability that T in
    % condition 1 is larger than T in condition 2 
    for ii=1:length(cnames)
        for jj=1:length(cnames)
            confmat(ii,jj,ss) = sum(margpdf(:,ii).*margcdf(:,jj));
        end
    end
end
% calculate pdiff (see Methods)
% columns correspond to subjects
% Row1: no adaptor VS ON adaptor
% Row2: no adaptor VS OFF adaptor
% Row3: ON adaptor VS OFF adaptor
pdiff = 1-2*abs(squeeze([confmat(1,2,:),confmat(1,3,:),confmat(2,3,:)])-0.5);
disp(pdiff);

