function BLModelMonocomponentSinusoidPowerMap(varargin)

%% Either load data from cache or run simulation

tic;

% Set overall parameters
[ params ] = SetModelParametersBL('tInt', 0, 'tAv', 1, 'tOn', 5, varargin{:});

% Make the filters
[ filters ] = MakeModelFiltersBL(params);

% Contrast
c = 1/2;

% Base-2 log temporal and spatial frequency vectors
logTf = (-2:1/2:5)';
invSf = [120;90;60;45;30;15];

% Temporal and spatial frequency vectors
tf = 2.^logTf;
sf = 1./invSf;
%
%     % Base-2 log temporal and spatial frequency label vectors
%     logTfLabels = (-4:2:8)';
%     invSfLabels = (120;90;60;45;30;15)';

% Number of TFs and SFs
numT = length(tf);
numS = length(sf);

% Compute monocomponent grating power maps
meanResp = nan(numT,numS,2);
meanNumResp = nan(numT,numS,2);
meanDenResp = nan(numT,numS,2);
meanNumLnResp = nan(numT,numS,2);

% Iterate over temporal frequencies in serial
for indT = 1:numT
    
    % Iterate over spatial frequencies in parallel
    parfor indS = 1:numS
        tic;
        
        % Make the stimulus array
        [ stimArray ] = MonocomponentSinusoidalGratings(params, c, tf(indT), sf(indS));
        
        % Compute the response
        meanResp(indT,indS,:) = ComputeBLModelResponse(stimArray, params, filters);
        
        % Print a status update
        fprintf('TF %d of %d, SF %d of %d: %f s\n', indT, numT, indS, numS, toc);
    end
end

% Print a status update
fprintf('Completed simulation in %f seconds\n', toc);

%% Set options for plotting

% Set colormap
%load('utils/blueRedColorMap.mat', 'cmpRed','cmpBlueRed');

% Set options for overlaid contours
contourOpts = {-1:0.1:1,'EdgeColor', 'k', 'linewidth', 2};

% Spacing between PD and ND power maps, hand-tuned for asthetics
centerSpacing = 2;

% Legend
legendStr = {'PD','ND'};

%% Plot PD and ND power maps together

% This may not be the most elegant way to achieve the desired result, but it works
numT = length(tf);
numS = length(sf);
xx = (1:2*numS+centerSpacing)';
yy = logTf;
xLabelStr = [cellstr(num2str(num2str(flipud([120;60;30]), '-1/{%d}'))); cellstr(num2str(num2str([120;60;30], '1/{%d}')))];
ss = [-flipud(invSf); nan(centerSpacing,1); invSf];
idx = ismember(abs(ss), [120;60;30]);
pdnd = [fliplr(meanResp(:,:,2)), nan(numT, centerSpacing), meanResp(:,:,1)];

maxResp = max(abs(pdnd(:)));
cMax = max(1, 10*ceil(maxResp/10)*(maxResp>1));

MakeFigure;
imagesc(xx,yy,pdnd);
hold on;
contour(xx,yy, pdnd / maxResp, 0:0.1:1, 'EdgeColor', 'k', 'linewidth', 2);
[ ~, maxLocs ] = max(pdnd, [], 1);
plot(xx, yy(maxLocs), 'ok','MarkerSize', 10, 'MarkerFaceColor','k', 'MarkerEdgeColor','none');
xticks(xx(idx));
xticklabels(xLabelStr);
yticks([-1,1,3,5]);
yticklabels(num2str([0.5;2;8;32], '%0.1f'));
xlabel('spatial frequency (1/\circ)');
ylabel('temporal frequency (Hz)');
cbar = colorbar;
%colormap([0.8,0.8,0.8; cmpRed]);
caxis([-1 cMax]);
cbar.Limits = [0 cMax];
ylabel(cbar, 'response (arb. units)');
axis('xy','square');
ConfAxis('titleFontSize',16);

%% Plot PD and ND power maps together for LNLN factorization numerator

% This may not be the most elegant way to achieve the desired result, but it works
numT = length(tf);
numS = length(sf);
xx = (1:2*numS+centerSpacing)';
yy = logTf;
xLabelStr = [cellstr(num2str(num2str(flipud([120;60;30]), '-1/{%d}'))); cellstr(num2str(num2str([120;60;30], '1/{%d}')))];
ss = [-flipud(invSf); nan(centerSpacing,1); invSf];
idx = ismember(abs(ss), [120;60;30]);
pdnd = [fliplr(meanNumResp(:,:,2)), nan(numT, centerSpacing), meanNumResp(:,:,1)];

maxResp = max(abs(pdnd(:)));
cMax = max(1, 10*ceil(maxResp/10)*(maxResp>1));

MakeFigure;
imagesc(xx,yy,pdnd);
hold on;
contour(xx,yy, pdnd / maxResp, 0:0.1:1, 'EdgeColor', 'k', 'linewidth', 2);
[ ~, maxLocs ] = max(pdnd, [], 1);
plot(xx, yy(maxLocs), 'ok','MarkerSize', 10, 'MarkerFaceColor','k', 'MarkerEdgeColor','none');
xticks(xx(idx));
xticklabels(xLabelStr);
yticks([-1,1,3,5]);
yticklabels(num2str([0.5;2;8;32], '%0.1f'));
xlabel('spatial frequency (1/\circ)');
ylabel('temporal frequency (Hz)');
cbar = colorbar;
%colormap([0.8,0.8,0.8; cmpRed]);
caxis([-1 cMax]);
cbar.Limits = [0 cMax];
ylabel(cbar, 'response (arb. units)');
axis('xy','square');
ConfAxis('titleFontSize',16);

title('Numerator LNLN');

%% Plot PD and ND power maps together for LNLN factorization denominator

% This may not be the most elegant way to achieve the desired result, but it works
numT = length(tf);
numS = length(sf);
xx = (1:2*numS+centerSpacing)';
yy = logTf;
xLabelStr = [cellstr(num2str(num2str(flipud([120;60;30]), '-1/{%d}'))); cellstr(num2str(num2str([120;60;30], '1/{%d}')))];
ss = [-flipud(invSf); nan(centerSpacing,1); invSf];
idx = ismember(abs(ss), [120;60;30]);
pdnd = [fliplr(meanDenResp(:,:,2)), nan(numT, centerSpacing), meanDenResp(:,:,1)];

maxResp = max(abs(pdnd(:)));
cMax = max(1, 10*ceil(maxResp/10)*(maxResp>1));

MakeFigure;
imagesc(xx,yy,pdnd);
hold on;
contour(xx,yy, pdnd / maxResp, 0:0.1:1, 'EdgeColor', 'k', 'linewidth', 2);
[ ~, maxLocs ] = max(pdnd, [], 1);
plot(xx, yy(maxLocs), 'ok','MarkerSize', 10, 'MarkerFaceColor','k', 'MarkerEdgeColor','none');
xticks(xx(idx));
xticklabels(xLabelStr);
yticks([-1,1,3,5]);
yticklabels(num2str([0.5;2;8;32], '%0.1f'));
xlabel('spatial frequency (1/\circ)');
ylabel('temporal frequency (Hz)');
cbar = colorbar;
%colormap([0.8,0.8,0.8; cmpRed]);
caxis([-1 cMax]);
cbar.Limits = [0 cMax];
ylabel(cbar, 'response (arb. units)');
axis('xy','square');
ConfAxis('titleFontSize',16);

title('Denominator LNLN');

%% Plot PD and ND power maps together for LN approximation of numerator

% This may not be the most elegant way to achieve the desired result, but it works
numT = length(tf);
numS = length(sf);
xx = (1:2*numS+centerSpacing)';
yy = logTf;
xLabelStr = [cellstr(num2str(num2str(flipud([120;60;30]), '-1/{%d}'))); cellstr(num2str(num2str([120;60;30], '1/{%d}')))];
ss = [-flipud(invSf); nan(centerSpacing,1); invSf];
idx = ismember(abs(ss), [120;60;30]);
pdnd = [fliplr(meanNumLnResp(:,:,2)), nan(numT, centerSpacing), meanNumLnResp(:,:,1)];

maxResp = max(abs(pdnd(:)));
cMax = max(1, 10*ceil(maxResp/10)*(maxResp>1));

MakeFigure;
imagesc(xx,yy,pdnd);
hold on;
contour(xx,yy, pdnd / maxResp, 0:0.1:1, 'EdgeColor', 'k', 'linewidth', 2);
[ ~, maxLocs ] = max(pdnd, [], 1);
plot(xx, yy(maxLocs), 'ok','MarkerSize', 10, 'MarkerFaceColor','k', 'MarkerEdgeColor','none');
xticks(xx(idx));
xticklabels(xLabelStr);
yticks([-1,1,3,5]);
yticklabels(num2str([0.5;2;8;32], '%0.1f'));
xlabel('spatial frequency (1/\circ)');
ylabel('temporal frequency (Hz)');
cbar = colorbar;
%colormap([0.8,0.8,0.8; cmpRed]);
caxis([-1 cMax]);
cbar.Limits = [0 cMax];
ylabel(cbar, 'response (arb. units)');
axis('xy','square');
ConfAxis('titleFontSize',16);
title('Numerator LN');


%% Plot SVD of power maps

% Compute SVDs
rawSV = nan(min(numT, numS), size(meanResp,3));
for ind = 1:size(meanResp,3)
    [~,s,~] = svd(meanResp(:,:,ind));
    rawSV(:,ind) = diag(s);
end

% Compute percentage of variance captured from squared singular values
sqSV = rawSV.^2;
normSV = sqSV ./ sum(sqSV, 1);

MakeFigure;
plot(1:min(numT, numS), normSV, '-o','linewidth',2);
xlim([0 min(numT, numS)+1]);
ylim([0 1]);
yticks(0:0.2:1);
xlabel('rank');
ylabel('percentage of total variance');
axis('square');
ConfAxis('titleFontSize',16);
legend(legendStr);

MakeFigure;
imagesc(1:2, 1:4, normSV(1:4,:))
cbar = colorbar;
ylabel(cbar, 'percentage of total variance');
xticks(1:2);
xticklabels(legendStr);
xlabel('stimulus');
yticks(1:4);
ylabel('singular value');
caxis([0 1]);
%colormap(cmpRed);
axis('ij','square','tight');
for ind = 1:size(meanResp,3)
    text(ind*ones(4,1), (1:4)', num2str(normSV(1:4,ind), '%0.3e'),'HorizontalAlignment', 'center','FontSize', 16);
end
ConfAxis('titleFontSize',16);

end

