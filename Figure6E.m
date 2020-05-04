function Figure6E(data)

MakeFigure('Name','Figure 6E','NumberTitle','off')

% define color scheme
pcols = [90/255,90/255,90/255;...
    33/255,121/255,180/255;...
    246/255,151/255,153/255];

% define condition names
cnames = {'no adaptor','ON adaptor','OFF adaptor'};

% extract the number of subjects
nSub = length(data);

% prepare matrices to hold point estimates of parameters
Ek = [];
% for each subject
for ss = 1:nSub
    % for each condition
    for ii = 1:length(cnames)
      % Use a custom QUEST function to pull out posterior distribution
      [Ek(ss,ii),~,pdf2d(:,:,ii,ss),~,log2k] = QuestBetaAnalysisLogistic(data{ss}.q{ii},0,3.5,3);  
    end
end


%% show bar graphs with errorbars around each individual data

% calculate 68% credible interval (1SD) of log2k (slope)
Elog2kerror = nan(nSub,3,2); 
for ss = 1:nSub
    for ii = 1:length(cnames)
        margpdf = mean(pdf2d(:,:,ii,ss),2);
        margpdf = margpdf/sum(margpdf);
        cmargdis = cumsum(margpdf);
        [~,indlow] = min(abs(cmargdis-0.16));
        [~,indhigh] = min(abs(cmargdis-0.84));
        Elog2kerror(ss,ii,1) = log2k(indlow);
        Elog2kerror(ss,ii,2) = log2k(indhigh);
    end
end

% plot results

easyBarIndivError(Ek,2.^Elog2kerror,'newFigure',0,'connectPaired',1,'colors',pcols,'conditionNames',cnames);
title('Estimated Slope');


