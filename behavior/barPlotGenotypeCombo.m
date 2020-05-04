function timeTraces=barPlotGenotypeCombo(timeTraces,cellTypes,pairsToDoStats,figName)

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
dotSize=40;
for m=1:numGenos
    if ~isempty(timeTraces{m})
        currAvg0=timeTraces{m};
        currAvg1=currAvg0.analysis;
        color=colors(m,:);
        currAvg2=currAvg1.respMatPlot(:,1,1);
        currSem=currAvg1.respMatSemPlot(:,1,1);
        
        a=bar(m,currAvg2,0.5,'FaceColor',(color+1)/2,'EdgeColor','none');
        hold on
        XYPos = scatterBar(currAvg1.respMatIndPlot(:,:,1)');
        scatter(XYPos(:,1)+m,XYPos(:,2),dotSize,'MarkerEdgeColor',color,'MarkerFaceColor','none')
        errorbar(m,currAvg2,currSem,'Color','k','CapSize',0)
        super_min(m)=min(currAvg1.respMatIndPlot(:,:,1));
        super_max(m)=max(currAvg1.respMatIndPlot(:,:,1));
        lineHandles(m)=a;
    end
    legend(lineHandles,cellTypesForLegend_numFlies,'Location','northeast','box','off','interpreter','none')
end
title(figName,'FontSize',14)

auxY1=round(1.1*min(super_min));
auxY2=round(1.1*max(super_max));
ylim([auxY1 auxY2])
box off
xlim([0 numGenos+1])
a.BaseLine.LineStyle = 'none';
PlotConstLine(0)
ConfAxis('tickX',1:numGenos,'tickLabelX','',...
    'tickY',unique([auxY1 0 auxY2]),'tickLabelY',unique([auxY1 0 auxY2]),...
    'labelX','time (s)','labelY','turning (deg/s)',...
    'rotateLabels',45,'useLatex',false);
set(gca,'XColor','none')


if ~isempty(pairsToDoStats)
    if length(pairsToDoStats)==1
        curr=pairsToDoStats(1,:);
        e1=timeTraces{curr(1)}.analysis.respMatIndPlot(:,:,1);
        [p,~]=signrank(e1);
        text_p=['genotype ' num2str(curr(1)) ': p=' num2str(p)];
    else
        for b=1:size(pairsToDoStats,1)
            curr=pairsToDoStats(b,:);
            e1=timeTraces{curr(1)}.analysis.respMatIndPlot(:,:,1);
            e2=timeTraces{curr(2)}.analysis.respMatIndPlot(:,:,1);
            [p,~]=ranksum(e1,e2);
            text_p{b}=['genotype ' num2str(curr(1)) ' - genotype ' num2str(curr(2)) ': p=' num2str(p)];
        end
    end
    text(0.1,0.8,text_p,'units','normalized',...
        'HorizontalAlignment','left','VerticalAlignment','bottom',...
        'Interpreter','none')

end



