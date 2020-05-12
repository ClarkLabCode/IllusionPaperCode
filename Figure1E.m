function Figure1E(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 1E of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (1 x number of flies in dataset). Each
% entry in flyResp has dimensions (number of time points recorded x 1 x 2).
% The 3rd dimension in each entry in flyResp contains the turning response
% and the walking response of flies. If A is an entry in flyResp, the
% turning response if A(:,1,1) and the walking response is A(:,1,2).

% Parameters

cellTypes=fieldnames(flyResp);
dataRate=general_parameters.dataRateBehavior;

%% Process raw turning data of fly-on-the-ball experiments

timeTraceLims=[-500 7000];
for k=1:length(cellTypes)
    currResp=getfield(flyResp,cellTypes{k});
    currEpochs=getfield(stimulusInfo.epochs,cellTypes{k});
    currParams=getfield(stimulusInfo.params,cellTypes{k});
    
    % Time traces of turning
    tt{k}.analysis = TimeTraces(currResp,currEpochs,currParams,...
        dataRate,...
        'snipShift',timeTraceLims(1),...
        'ttDuration',timeTraceLims(2)-timeTraceLims(1));
    
    % Time average of turning during stimulus presentation
    intervalToIntegrateOver=5000;
    delayToStartIntegration=0;
    bp_on{k}.analysis=TimeAveraged(currResp,currEpochs,currParams,...
        dataRate,...
        'duration',intervalToIntegrateOver,...
        'snipShift',delayToStartIntegration);
        
    % Time average of turning at stimulus offset
    intervalToIntegrateOver=2000;
    delayToStartIntegration=5000;
    bp_off{k}.analysis=TimeAveraged(currResp,currEpochs,currParams,...
        dataRate,...
        'duration',intervalToIntegrateOver,...
        'snipShift',delayToStartIntegration);

end

%% Plot processed data (hidden figures)

% Plot turning time trace (hidden figure)
stimDuration=5000;
figName{1}='T4T5 silenced & ctrls-time trace';
timeTracesGenotypeCombo(tt,cellTypes,stimDuration,timeTraceLims,figName{1})
set(gca,'XTick',[0 2500 5000]);
set(gca,'XTickLabel',[0 2.5 5]);
ylim([-10 10])
set(gca,'YTick',[-10 -5 0 5 10]);
set(gca,'YTickLabel',[-10 -5 0 5 10]);

% Plot time average turning during stimulus presentation (hidden figure)
pairsToDoStats=[1 2;1 3];
figName{2}='T4T5 silenced & ctrls-bar plot-stim';
barPlotGenotypeCombo(bp_on,cellTypes,pairsToDoStats,figName{2})

% Plot time average turning at stimulus offset (hidden figure)
pairsToDoStats=[1 2;1 3];
figName{3}='T4T5 silenced & ctrls-bar plot-offset';
barPlotGenotypeCombo(bp_off,cellTypes,pairsToDoStats,figName{3})

%% Organize figure 

MakeFigure('Name','Figure 1E',...
    'Position',[1 1 1182 433],'NumberTitle','off');

s1 = subplot(1,3,1);
s2 = subplot(1,3,2);
s3 = subplot(1,3,3);

curr=findobj('type','figure','Name','T4T5 silenced & ctrls-time trace');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
curr_leg = findobj(curr(1),'type','legend');
copyobj(curr_ax_child,s1);
legend(s1,curr_leg.String{1:3},'interpreter','none'); 
axis(s1,'tight')
ylim(s1,[-10 10])
PlotConstLine(0)
set(s1,'XTick',[0 2500 5000])
set(s1,'XTickLabel',[0 2.5 5])
set(s1,'YTick',[-10 -5 0 5 10])
set(s1,'YTickLabel',[-10 -5 0 5 10])
xlabel(s1,'time (s)')
ylabel(s1,['turning ' char(176) '/s'])

curr=findobj('type','figure','Name','T4T5 silenced & ctrls-bar plot-stim');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
copyobj(curr_ax_child,s2);
ylim(s2,[-10 10])
set(s2,'YTick',[-10 -5 0 5 10])
set(s2,'YTickLabel',[-10 -5 0 5 10])
box(s2,'off')
set(s2,'XColor','none')
title(s2,'stim presentation')

curr=findobj('type','figure','Name','T4T5 silenced & ctrls-bar plot-offset');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
copyobj(curr_ax_child,s3);
ylim(s3,[-10 10])
set(s3,'YTick',[-10 -5 0 5 10])
set(s3,'YTickLabel',[-10 -5 0 5 10])
box(s3,'off')
set(s3,'XColor','none')
title(s3,'stim offset')

closeAllExceptIllusionPaperFigures()
