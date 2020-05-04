function Figure5E(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 5E of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (1 x number of flies in dataset). Each
% entry in flyResp has dimensions (number of time points recorded x 1 x 2).
% The 3rd dimension in each entry in flyResp contains the turning response
% and the walking response of flies. If A is an entry in flyResp, the
% turning response if A(:,1,1) and the walking response is A(:,1,2).

dataRate=general_parameters.dataRateBehavior;
timeTraceLims=[-500 7000];

cellTypes=fieldnames(flyResp);

for k=1:length(cellTypes)
    currResp=getfield(flyResp,cellTypes{k});
    currEpochs=getfield(stimulusInfo.epochs,cellTypes{k});
    currParams=getfield(stimulusInfo.params,cellTypes{k});
    tt{k}.analysis = TimeTraces(currResp,currEpochs,currParams,...
        dataRate,...
        'snipShift',timeTraceLims(1),...
        'ttDuration',timeTraceLims(2)-timeTraceLims(1));
    
    intervalToIntegrateOver=5000;
    delayToStartIntegration=0;
    bp_on{k}.analysis=TimeAveraged(currResp,currEpochs,currParams,...
        dataRate,...
        'duration',intervalToIntegrateOver,...
        'snipShift',delayToStartIntegration);
        
end

% time trace

stimDuration=5000;
figName={'T4 silenced & ctrls-time trace'};

timeTracesGenotypeCombo(tt,cellTypes,stimDuration,timeTraceLims,figName{1})
set(gca,'XTick',[0 2500 5000]);
set(gca,'XTickLabel',[0 2.5 5]);
ylim([-10 10])
set(gca,'YTick',[-10 -5 0 5 10]);
set(gca,'YTickLabel',[-10 -5 0 5 10]);

% bar plot

pairsToDoStats=[1 2;1 3];
figName{2}='T4 silenced & ctrls-bar plot';
barPlotGenotypeCombo(bp_on,cellTypes,pairsToDoStats,figName{2})

%% put everything in subplots 

MakeFigure('Name','Figure 5E','NumberTitle','off'); %create new figure
s1 = subplot(1,2,1); %create and get handle to the subplot axes
s2 = subplot(1,2,2);

curr=findobj('type','figure','Name','T4 silenced & ctrls-time trace');
curr_ax = findall(curr(1),'type','axes'); % get handle to axes of figure
curr_ax_child = get(curr_ax,'children'); %get handle to all the children in the figure
curr_leg = findobj(curr(1),'type','legend'); % get handle to axes of figure
copyobj(curr_ax_child,s1); %copy children to new parent axes i.e. the subplot axes
legend(s1,curr_leg.String{1:3},'interpreter','none'); %copy children to new parent axes i.e. the subplot axes
axis(s1,'tight')
ylim(s1,[-10 10])
PlotConstLine(0)
set(s1,'XTick',[0 2500 5000]);
set(s1,'XTickLabel',[0 2.5 5]);
set(s1,'YTick',[-10 -5 0 5 10]);
set(s1,'YTickLabel',[-10 -5 0 5 10]);
xlabel(s1,'time (s)')
ylabel(s1,['turning ' char(176) '/s'])

curr=findobj('type','figure','Name','T4 silenced & ctrls-bar plot');
curr_ax = findall(curr(1),'type','axes'); % get handle to axes of figure
curr_ax_child = get(curr_ax,'children'); %get handle to all the children in the figure
copyobj(curr_ax_child,s2); %copy children to new parent axes i.e. the subplot axes
ylim(s2,[-6 11])
set(s2,'YTick',[-5 0 5  10]);
set(s2,'YTickLabel',[-5 0 5  10]);
box(s2,'off')
set(s2,'XColor','none')

closeAllExceptIllusionPaperFigures()