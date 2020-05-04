function easyBar(M,varargin)
% Created Jan 23 2019 by RT
% This function creates bar plot + scatter plot given a data matrix M whose
% columns are different measurements and rows are subjects (flies, ROIs).
% This function depends on scatterBar function which is apparently only on
% twoPhoton branch.

doSignrank = 0;
drawLines = 0;
numCol = size(M,2);
% plot colors
colors = colormap('lines');
colors = colors(1:numCol,:);
conditionNames = {};

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

if isempty(conditionNames)
    for ii=1:numCol
        conditionNames{ii} = ['condition #',num2str(ii)];
    end
end

%MakeFigure;
meanM = nanmean(M,1);
semM  = NanSem(M,1);

% draw bars
b = bar(1:numCol,meanM,'LineStyle','none','FaceColor','flat'); hold on
% prepare scatter positions
sbar = scatterBar(M);
% prepare statistics
pval = ones(numCol,1);

% draw lines
if drawLines == 1
    line([sbar(:,1,1),sbar(:,1,2)]'+1,[sbar(:,2,1),sbar(:,2,2)]','Color',[0.8,0.8,0.8],'LineWidth',0.5);
end

% prettification
for ii = 1:numCol
    % change colors
    b.CData(ii,:) = (colors(ii,:)+1)/2; % make bars brighter
    % add individual data
    scatter(sbar(:,1,ii)+1,sbar(:,2,ii),20,'filled','MarkerFaceColor',colors(ii,:),'MarkerEdgeColor','none');
    if doSignrank==1
        pval(ii) = signrank(M(:,ii));
        text(ii,max(M(:))*1.2,num2str(pval(ii)),'HorizontalAlignment','center');
    end
end
% draw error bars
e = errorbar(1:numCol,meanM',semM','CapSize',0);
e.Color = [0,0,0];
e.Marker = 'none';
e.LineStyle = 'none';

xlim([0,numCol+1]);
if min(M(:))<max(M(:))
    ylim([min(M(:)),max(M(:))]*1.2);
end
box off
b.BaseLine.LineStyle = 'none';
PlotConstLine(0)
ConfAxis('tickX',1:numCol,'tickLabelX',conditionNames,'fontSize',10);
end


