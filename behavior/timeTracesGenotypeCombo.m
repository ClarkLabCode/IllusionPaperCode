function timeTracesGenotypeCombo(timeTraces,cellTypes,stimDuration,timeTraceLims,figName)


beforeStimDuration=-timeTraceLims(1);
afterStimDuration=timeTraceLims(2);
dataRate=60;
numGenos=length(cellTypes);
colors=lines(numGenos);

f=MakeFigure('Name',figName,'NumberTitle','off');
set(f,'visible','off');

nflies=zeros(1,numGenos);
for l=1:length(timeTraces)
    if ~isempty(timeTraces{l})
        nflies(l)=length(timeTraces{l}.analysis.indFly);
    else
        nflies(l)=0;
    end
end
cellTypesForLegend_numFlies=cell(size(cellTypes));
for tr=1:length(cellTypes)
    cellTypesForLegend_numFlies{tr}=[cellTypes{tr} ' (' num2str(nflies(tr)) ')'];
end

n=length(timeTraces{1}.analysis.respMatPlot);
totalTime=n*1000/60;
time = ((1:round(totalTime*dataRate/1000))'+round(-beforeStimDuration*dataRate/1000))*1000/dataRate;

a=rectangle('Position',[0 -10 stimDuration 20],'FaceColor',[0.5 0.5 0.5 0.2],'EdgeColor','none');
hold on
for m=1:length(timeTraces)
    if ~isempty(timeTraces{m})
        currTimeTraces0=timeTraces{m};
        currTimeTraces1=currTimeTraces0.analysis;
        color=colors(m,:);
        curr11=currTimeTraces1.respMatPlot(:,1,1);
        curr12=currTimeTraces1.respMatSemPlot(:,1,1);
        
        PlotXvsY(time,curr11,'error',curr12,'color',color);
        
        super_min(m)=min(curr11)-max(curr12);
        super_max(m)=max(curr11)+max(curr12);
    end
    legend(cellTypesForLegend_numFlies,'Location','northeast','box','off','interpreter','none')
end
title(figName,'FontSize',14)

xlim([-beforeStimDuration afterStimDuration])
auxY1=round(1.1*min(super_min));
auxY2=round(1.1*max(super_max));
ylim([auxY1 auxY2])
a.Position=[0 auxY1 stimDuration auxY2-auxY1];
box off
PlotConstLine(0)

timePlot=0:1000:(totalTime-beforeStimDuration);
xTickLabel=0:1000:(totalTime-beforeStimDuration);

ConfAxis('tickX',timePlot,'tickLabelX',xTickLabel/1000,'labelX','time (s)',...
    'tickY',[auxY1 0 auxY2],'tickLabelY',[auxY1 0 auxY2],...
    'labelX','time (s)','labelY','turning (deg/s)',...
    'rotateLabels',0,'useLatex',false);


