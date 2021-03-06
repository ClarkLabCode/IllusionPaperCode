function Figure6C(data)
% This function plots the data in Figure 6C of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% Create a figure panel
MakeFigure('Name','Figure 6C','NumberTitle','off')

% define color scheme
pcols = [90/255,90/255,90/255;...
    33/255,121/255,180/255;...
    246/255,151/255,153/255];

% define condition names
cnames = {'no adaptor','ON adaptor','OFF adaptor'};

% for each example subject
for ss = 1:length(data)
    subplot(2,1,ss); hold on
    % for each condition
    for ii = 1:length(cnames)
        % Use a custom QUEST function to pull out posterior distribution
        [~,~,pdf2d(:,:,ii,ss),T,log2k] = QuestBetaAnalysisLogistic(data{ss}.q{ii},0,3.5,3);
        % Plot PMF by randomly resampling from the posterior distribution
        % error area corresponds to 68% credible interval
        sampleBayesianLogisticPMF(pdf2d(:,:,ii,ss),T,log2k,pcols(ii,:),1000);
    end
    title([' example subject ',num2str(ss)]); hold on
    PlotConstLine(0.5);PlotConstLine(0,2);
    legend(cnames);
    xlabel('rotational velocity deg/s');
    ylabel('P(toward light shade)');
end

closeAllExceptIllusionPaperFigures()