function Figure1D(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 1D of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (1 x number of flies in dataset). Each
% entry in flyResp has dimensions (number of time points recorded x 1 x 2).
% The 3rd dimension in each entry in flyResp contains the turning response
% and the walking response of flies. If A is an entry in flyResp, the
% turning response if A(:,1,1) and the walking response is A(:,1,2).

% Parameters

cellTypes={'WT'};
epochs=stimulusInfo.epochs;
params=stimulusInfo.params;
dataRate=general_parameters.dataRateBehavior;

%% Process raw turning data of fly-on-the-ball experiments

% Time traces of turning
timeTraceLims=[-500 7000];
tt.analysis = TimeTraces(flyResp,epochs,params,dataRate,...
    'snipShift',timeTraceLims(1),...
    'ttDuration',timeTraceLims(2)-timeTraceLims(1));

% Time average of turning during stimulus presentation
intervalToIntegrateOver=5000;
delayToStartIntegration=0;
bp_on.analysis=TimeAveraged(flyResp,epochs,params,dataRate,...
    'duration',intervalToIntegrateOver,...
    'snipShift',delayToStartIntegration);

% Time average of turning at stimulus offset
intervalToIntegrateOver=2000;
delayToStartIntegration=5000;
bp_off.analysis=TimeAveraged(flyResp,epochs,params,dataRate,...
    'duration',intervalToIntegrateOver,...
    'snipShift',delayToStartIntegration);


%% Plot processed data (hidden figures)

% Plot turning time trace (hidden figure)
figName{1}='time trace';
stimDuration=5000;
timeTracesGenotypeCombo({tt},cellTypes,stimDuration,timeTraceLims,figName{1})
set(gca,'XTick',[0 2500 5000]);
set(gca,'XTickLabel',[0 2.5 5]);
ylim([-10 10])
set(gca,'YTick',[-10 -5 0 5 10]);
set(gca,'YTickLabel',[-10 -5 0 5 10]);

% Plot time average turning during stimulus presentation (hidden figure)
pairsToDoStats=1;
figName{2}='stim onset';
barPlotGenotypeCombo({bp_on},cellTypes,pairsToDoStats,figName{2})
set(gca,'YTick',[0 5 10]);
set(gca,'YTickLabel',[0 5 10]);

% Plot time average turning at stimulus offset (hidden figure)
figName{3}='stim offset';
pairsToDoStats=1;
barPlotGenotypeCombo({bp_off},cellTypes,pairsToDoStats,figName{3})
set(gca,'YTick',[-10 -5 0]);
set(gca,'YTickLabel',[-10 -5 0]);

%% Organize figure 

MakeFigure('Name','Figure 1D','Position',[1 1 1182 433],...
    'NumberTitle','off');

s1 = subplot(1,3,1);
s2 = subplot(1,3,2);
s3 = subplot(1,3,3);

curr=findobj('type','figure','Name','time trace');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
copyobj(curr_ax_child,s1);
axis(s1,'tight')
set(s1,'XTick',[0 2500 5000]);
set(s1,'XTickLabel',[0 2.5 5]);
ylim(s1,[-10 10])
set(s1,'YTick',[-10 -5 0 5 10]);
set(s1,'YTickLabel',[-10 -5 0 5 10]);
hold on
ax=gca;
line([ax.XLim(1) ax.XLim(end)],[0 0])
xlabel(s1,'time (s)')
ylabel(s1,['turning (' char(176) '/s)'])
title(s1,'time trace')

curr=findobj('type','figure','Name','stim onset');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
copyobj(curr_ax_child,s2);
ylim([0 10])
set(s2,'YTick',[0 5 10]);
set(s2,'YTickLabel',[0 5 10]);
set(s2,'XColor','none')
title(s2,'stim presentation')

curr=findobj('type','figure','Name','stim offset');
curr_ax = findall(curr(1),'type','axes');
curr_ax_child = get(curr_ax,'children');
copyobj(curr_ax_child,s3);
ylim([-11 0])
set(s3,'YTick',[-10 -5 0]);
set(s3,'YTickLabel',[-10 -5 0]);
set(s3,'XColor','none')
title(s3,'stim offset')

closeAllExceptIllusionPaperFigures()

