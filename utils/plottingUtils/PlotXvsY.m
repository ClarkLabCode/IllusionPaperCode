function plotHandles = PlotXvsY(x,y,varargin)
    %set up default values. all default values can be changed by varargin
    %by putting them in the command line like so
    %plotXvsY(...,'color','[0,0,1]');
    if(size(x,1) > 1)
        graphType = 'line';
    else
        graphType = 'scatter';
    end
    
    color = lines(size(y,2));
    error = [];
    significance = [];
    lineStyle = '-';
    hStat = ishold;
    connect = false;
    LineWidth = 1;
    plotHandles = [];
    centerStat = [];
    boxPlotWhisker = inf; % no outliers for boxplot
    
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end

    switch graphType
        case 'line'
            if isempty(error)
%                 set(gca, 'ColorOrder', color, 'NextPlot', 'add');
                plotHandles = plot(x,y,'lineStyle',lineStyle, 'LineWidth', LineWidth);
                colorCell = mat2cell(color, ones(size(color, 1),1), 3);
                [plotHandles.Color] = deal(colorCell{:});
                caxis([0 size(color,1)]);
            else
                plotHandles = PlotErrorPatch(x,y,error,color, 'LineWidth', LineWidth);
                if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
                    pThresh = 0.05;
                    pThreshStrict = 0.01;
                    maxY = max(y(:));
                    maxPlot = barPlot.Parent.YLim(end);
                    astHeight = mean([maxY maxPlot]);
                    text(x(significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
                    text(x(significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
                end
            end
        case 'scatter'
            if isempty(error)
                scatter(x,y,50,color);
            else
                if ~hStat, hold on; end
                for c = 1:size(x,2)
                    scatter(x(:,c),y(:,c),50,color(c,:));
                    errorbar(x(:,c),y(:,c),error(:,c),'color',color(c,:),'LineStyle','none');
                end
                if ~hStat, hold off; end
            end
        case {'bar', 'stackedbar'}
            colormap(color);
            if strcmp(graphType, 'bar')
                barPlot = bar(x,y);
            elseif strcmp(graphType, 'stackedbar')
                barPlot = bar(x, y, 'stacked');
            end
            
            plotHandles = [plotHandles barPlot];
            
            if ~isempty(error)
                set(gca, 'ColorOrder', color, 'NextPlot', 'replace');
                hold on;
                numbars = length(x);
                groupwidth = min(0.8, numbars/(numbars+1.5));
                relBarPos = 1:size(y, 2);
                groupShift = -groupwidth/(2*numbars) + (2*(relBarPos)-1) * groupwidth / (2*numbars);
                x = repmat(x,[1 ceil(size(y,2)/size(x,2))]);
                x = x(:,1:size(y,2));
                groupShift = repmat(groupShift, [size(x, 1), 1]);
                x = x + groupShift;
                if size(error, 3) == 1
                    errorbar(x,y,error,'LineStyle','none', 'Color', 'k');
                else
                    errorbar(x,y,error(:, :, 1), error(:, :, 2),'LineStyle','none');
                end
                if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
                    pThresh = 0.05;
                    pThreshStrict = 0.01;
                    maxY = max(y(:));
                    maxPlot = barPlot.Parent.YLim(end);
                    astHeight = mean([maxY maxPlot]);
                    text(x(significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
                    text(x(significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '**', 'FontSize', 10, 'HorizontalAlignment', 'center', 'Color', [1 0 0]);
                end
            end
            
            if ~hStat, hold off; end
        case 'spread'
            if ~hStat, hold on; end
            if connect
                color = repmat(color,[ceil(size(x,1)/size(color,1)) 1]);
                color = color(1:size(x,1),:);
                if isempty(centerStat)
                    centerStat = nanmean(y, 1);
                end
                for r = 1:size(x, 1)
                    plot(x(r, :), y(r, :), 'o-', 'Color', color(r, :));
                end
                plotHandles = errorbar(x(1, :),centerStat,error,'Color', [0 0 0], 'LineStyle','none');
            else
                color = repmat(color,[ceil(size(x,2)/size(color,1)) 1]);
                color = color(1:size(x,2),:);
                for c = 1:size(x,2)
                    if isempty(centerStat)
                        centerStat(c) = nanmean(y(:,c));
                    end
                    spreadScatter = scatterBar(y(:,c)); % 3 sigma in .2, which is where the MAD will be
                    spreadScatter(:, 1) = x(:, c) + spreadScatter(:, 1); % comes out centered around 0
                    scatter(spreadScatter(:, 1),spreadScatter(:, 2),50,color(c,:), '.');
                    if size(x, 2) == 1
                        plotMeanDist = .2;
                    else
                        plotMeanDist = 0.2*mean(diff(x(1, :)));
                    end
                    plotHandles = errorbar(x(1, c)+plotMeanDist,centerStat(c),error(c),'Color', color(c, :), 'LineStyle','none');
                end
            end
            if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
                pThresh = 0.05;
                pThreshStrict = 0.01;
                if size(color, 1) >= 3
                    colorSigPca = pca(color);
                    [~, bestPca] = min(sum(color*colorSigPca'));
                    colorSig = abs(colorSigPca(bestPca, :)); % Honestly just an attempt to have a color that's different...
                else
                    colorSig = [0 0 0];
                end
                maxY = max(y(:));
                maxPlot = plotHandles.Parent.YLim(end);
                astHeight = mean([maxY maxPlot]);
                text(x(1, significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
                text(x(1, significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '**', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
            end

            if ~hStat, hold off; end
        case 'boxplot'
            if ~hStat, hold on; end
            boxplot(y, 'Whisker', boxPlotWhisker);
            
            ax = gca;
            
            if ~isempty(significance) % Draw asterisks for significance--** for <0.01 and * for <0.05
                pThresh = 0.05;
                pThreshStrict = 0.01;
                if size(color, 1) >= 3
                    colorSigPca = pca(color);
                    [~, bestPca] = min(sum(color*colorSigPca'));
                    colorSig = abs(colorSigPca(bestPca, :)); % Honestly just an attempt to have a color that's different...
                else
                    colorSig = [0 0 0];
                end
                maxY = max(y(:));
                maxPlot = ax.YLim(end);
                astHeight = mean([maxY maxPlot]);
                text(x(1, significance<pThresh & significance>pThreshStrict), astHeight*ones(sum(significance<pThresh & significance>pThreshStrict), 1), '*', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
                text(x(1, significance<pThreshStrict), astHeight*ones(sum(significance<pThreshStrict), 1), '**', 'FontSize', 15, 'HorizontalAlignment', 'center', 'Color', colorSig);
            end
            
            if ~hStat, hold off; end
            
    end
    
%     ConfAxis();
end