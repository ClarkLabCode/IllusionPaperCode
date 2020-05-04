function output=PlotResponsesToEdges(flyResp,epochs,params,figureName,stimsToPlot)

colors=[1 0 0;0 1 0; 0 0 1; 1 1 0];

numFlies = length(flyResp);
output=cell(1,numFlies);
for ff=1:numFlies
    roiTimeTraces=flyResp{ff};
    currParams=params{ff};
    allEpochNames={currParams.epochName};
    MakeFigure('Name',['fly ' num2str(ff) ' ' figureName ' ROIs'],'NumberTitle','off')
    set(gcf,'visible','off')
    for d=1:length(stimsToPlot)
        idx=cellfun(@(x) contains(x,stimsToPlot{d}),allEpochNames,'UniformOutput',0);
        currEpoch=stimsToPlot(cell2mat(idx));
        epochLocations = ismember(epochs{ff}(:,1), find(cell2mat(idx)));
        a=diff(epochLocations);
        b=find(a~=0);
        if length(b)<6
            if epochLocations(1)==1
                b=[1; b];
            elseif epochLocations(end)==1
                b=[b; length(epochLocations)];
            end
        end
        counter=1;
        roiTimeTracesEpoch=[];
        mini=min(diff(b));
        for k=1:2:length(b)
            roiTimeTracesEpoch(:,:,counter) = roiTimeTraces(b(k):(b(k)+mini), :);
            counter=counter+1;
        end
        roiTimeTracesEpochMn=nanmean(roiTimeTracesEpoch,3);
        roiTimeTracesEpochSem=NanSem(roiTimeTracesEpoch,3);
        fieldName=currEpoch{1};
        fieldName(strfind(fieldName,' '))='_';
        output{ff}.(fieldName)=roiTimeTracesEpoch;
        
        for r=1:size(roiTimeTracesEpoch,2)
            ax(r)=subplot(3,3,r);
            PlotXvsY((1:size(roiTimeTracesEpoch,1))',...
                roiTimeTracesEpochMn(:,r),'error',...
                roiTimeTracesEpochSem(:,r),'color',colors(d,:));
            title(['roi ' num2str(r)])
            hold on
            axis tight
        end
    end
    legend(stimsToPlot,'Location','best')
end

