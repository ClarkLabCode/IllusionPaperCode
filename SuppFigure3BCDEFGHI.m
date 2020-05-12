function SuppFigure3BCDEFGHI(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Supp Figures 3BCDEFGHI of Agrochao,
% Tanaka et al (2020) Mechanism for analogous illusory motion perception in
% flies and humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4a responses, 2-T4b
% responses, 3-T5a responses, 4-T5b responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

cellTypes={'T4a','T4b','T5a','T5b'};
output.analysis=cell(1,length(cellTypes));
for k=1:length(cellTypes)
    nonResponsiveFlies = cellfun('isempty', flyResp(k, :));
    currFly=flyResp(k,~nonResponsiveFlies);
    if ~isempty(currFly)
        currEpochs=stimulusInfo.epochs(k,~nonResponsiveFlies);
        currParams=stimulusInfo.params(k,~nonResponsiveFlies);
        currEpochsForSelection=stimulusInfo.epochsForSelection(k,~nonResponsiveFlies);
        currEyes=stimulusInfo.flyEyes(k,~nonResponsiveFlies);
        
        output.analysis{1,k}= BarPairRoiAnalysis(...
            currFly,currEpochs,currParams,...
            general_parameters.dataRateImaging,...
            'epochsForSelectivity', stimulusInfo.epochsForSelectivity,...
            'epochsForSelection',currEpochsForSelection,...
            'flyEyes',currEyes,...
            'figureName', cellTypes{k},...
            'iteration',k);
    end
end


numSingleBarStimsPerRow=1;
numNonSingleBarStims=8;
conditionNames{1}={'single white','white prog',...
    'black prog','white reg','black reg'};
conditionNames{2}=conditionNames{1};
conditionNames{3}={'single black','black prog',...
    'white prog','black reg','white reg'};
conditionNames{4}=conditionNames{3};
cenaMn=[];
cenaSem=[];
timeAveragedStimPres=[];

colors = [ 35, 31, 32;
    103,194,165;
    246,150,109;
    139,159,202;
    226,138,185]/255;

output=output.analysis;
for g=1:length(output)
    
    roiSummaryMatrix=output{g}.realResps;
    switch g
        case {1,2}
            centPol=1;
        case {3,4}
            centPol=2;
    end
    respsWithCenter = roiSummaryMatrix(:, :, centPol, :, :, :);
    respsWithCentMn = squeeze(nanmean(respsWithCenter, 1));
    respsWithCentSem = squeeze(NanSem(respsWithCenter, 1));
    
    periodToAverage=round((size(respsWithCenter,6)/4):(3*size(respsWithCenter,6)/4));
    respsWithCentMn2 = squeeze(nanmean(respsWithCenter(:,:,:,:,:,periodToAverage), 6));
    
    sizeMat=size(roiSummaryMatrix);
    counter=1;
    for stims=[1 6:9]
        if stims==1
            barDistInd = 1;
            adjSide = 1;
            adjPol = 1;
        else
            barDist = (stims-numSingleBarStimsPerRow>numNonSingleBarStims/(sizeMat(2)-1))+1; % +1 because we want it 1-indexed
            adjSide = (mod(stims-numSingleBarStimsPerRow-1, sizeMat(4)*sizeMat(5))>=numNonSingleBarStims/(sizeMat(2)-1)/sizeMat(4))+1;
            adjPol = (mod(stims-numSingleBarStimsPerRow-1, sizeMat(4)) >=numNonSingleBarStims/(sizeMat(2)-1)/sizeMat(4)/sizeMat(5))+1;
            barDistInd = barDist + 1;
        end
        cenaMn{g}(:,counter)=squeeze(respsWithCentMn(barDistInd, adjSide, adjPol, :));
        cenaSem{g}(:,counter)=squeeze(respsWithCentSem(barDistInd, adjSide, adjPol, :));
        timeAveragedStimPres{g}(:,counter)=squeeze(respsWithCentMn2(:,barDistInd, adjSide, adjPol));
        counter=counter+1;
    end
end

taxis = linspace(general_parameters.snipShift,...
    general_parameters.snipShift+general_parameters.duration-1000/general_parameters.dataRateImaging,...
    length(cenaMn{g}));
taxis=taxis/1000;

subp={'BC','FG','DE','HI'};

for g=[1 3 2 4]
    MakeFigure('Name',['SuppFigure 3' subp{g}],'NumberTitle','off')
    switch g
        case {1,2}
            subplot(1,2,1)
            PlotXvsY(taxis',cenaMn{g},...
                'error', cenaSem{g},'color',colors);
            hold on
            axis tight
            xlabel('time (s)')
            ylabel('^{\Delta F}/_{F}')
            title(cellTypes{g},'FontSize',16)
            ax=gca;
            set(ax,'XTick',[0 0.5 1 1.5])
            line([0 0],ax.YLim,'Color','k','LineWidth',1)
            line([1 1],ax.YLim,'Color','k','LineWidth',1)
            legend(conditionNames{g},'Location','NorthEastOutside')
            
            subplot(1,2,2)
            easyBar(timeAveragedStimPres{g},'FontSize',12,'conditionNames',...
                conditionNames{g},'doSignrank',0,'colors',colors)
            xtickangle(45)
            ylabel('^{\Delta F}/_{F}')
            
            switch g
                case 1
                    pairsToDoStats(1,:)=[1 2]; % single bar vs white prog bar
                    pairsToDoStats(2,:)=[1 3]; % single bar vs black prog bar
                    pairsToDoStats(3,:)=[1 4]; % single bar vs white reg bar
                    pairsToDoStats(4,:)=[2 4]; % white prog bar vs white reg bar
                case 2
                    pairsToDoStats(1,:)=[1 2]; % single bar vs white prog bar
                    pairsToDoStats(2,:)=[1 4]; % single bar vs black prog bar
                    pairsToDoStats(3,:)=[1 5]; % single bar vs white reg bar
                    pairsToDoStats(4,:)=[2 4]; % white prog bar vs white reg bar
            end
            for b=1:size(pairsToDoStats,1)
                curr=pairsToDoStats(b,:);
                e1=timeAveragedStimPres{g}(:,curr(1));
                e2=timeAveragedStimPres{g}(:,curr(2));
                [p,~]=signrank(e1,e2);
                text_p{b}=['stim ' num2str(curr(1)) ' - stim ' num2str(curr(2)) ': p=' num2str(p)];
            end
            text(0.1,0.8,text_p,'units','normalized',...
                'HorizontalAlignment','left','VerticalAlignment','bottom',...
                'Interpreter','none')
            
        case {3,4}
            subplot(1,2,1)
            cenaMn{g}=cenaMn{g}(:,[1 3 2 5 4]);
            cenaSem{g}=cenaSem{g}(:,[1 3 2 5 4]);
            PlotXvsY(taxis',cenaMn{g},...
                'error', cenaSem{g},'color',colors);
            hold on
            axis tight
            xlabel('time (s)')
            ylabel('^{\Delta F}/_{F}')
            title(cellTypes{g},'FontSize',16)
            ax=gca;
            set(ax,'XTick',[0 0.5 1 1.5])
            line([0 0],ax.YLim,'Color','k','LineWidth',1)
            line([1 1],ax.YLim,'Color','k','LineWidth',1)
            legend(conditionNames{g},'Location','NorthEastOutside')
            timeAveragedStimPres{g}=timeAveragedStimPres{g}(:,([1 3 2 5 4]));
            
            subplot(1,2,2)
            easyBar(timeAveragedStimPres{g},'FontSize',12,'conditionNames',...
                conditionNames{g},'doSignrank',0,'colors',colors)
            xtickangle(45)
            ylabel('^{\Delta F}/_{F}')
            
            switch g
                case 3
                    pairsToDoStats(1,:)=[1 2]; % single bar vs white prog bar
                    pairsToDoStats(2,:)=[1 3]; % single bar vs black prog bar
                    pairsToDoStats(3,:)=[1 4]; % single bar vs white reg bar
                    pairsToDoStats(4,:)=[2 4]; % white prog bar vs white reg bar
                case 4
                    pairsToDoStats(1,:)=[1 2]; % single bar vs white prog bar
                    pairsToDoStats(2,:)=[1 4]; % single bar vs black prog bar
                    pairsToDoStats(3,:)=[1 5]; % single bar vs white reg bar
                    pairsToDoStats(4,:)=[2 4]; % white prog bar vs white reg bar
            end
            for b=1:size(pairsToDoStats,1)
                curr=pairsToDoStats(b,:);
                e1=timeAveragedStimPres{g}(:,curr(1));
                e2=timeAveragedStimPres{g}(:,curr(2));
                [p,~]=signrank(e1,e2);
                text_p{b}=['stim ' num2str(curr(1)) ' - stim ' num2str(curr(2)) ': p=' num2str(p)];
            end
            text(0.1,0.8,text_p,'units','normalized',...
                'HorizontalAlignment','left','VerticalAlignment','bottom',...
                'Interpreter','none')
    end
end

closeAllExceptIllusionPaperFigures()