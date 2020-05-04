function PlotSinusoidPowerMap(modelName)

%% This function plot spatiotemporal frequency tuning maps of the models
%% using sinusoidal gratings.

models = {'T4original','T4modified','T5','Barlow-Levick','MotionEnergy'};
if nargin < 1
    modelIndex = listdlg('PromptString','Select Model','SelectionMode','single','ListString',models);
    modelName = models{modelIndex};
else
    if ~any(strcmp(models,modelName))
        error('Invalid model name!');
    end
end


%% Set overal model parameters

% define model parameters according to model name provided
switch modelName
    case 'T4original'
        [ params ]  = SetModelParameters_T4orig('tInt', 1, 'tAv', 0, 'tOn', 6, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T4orig(params);
    case 'T4modified'
        [ params ]  = SetModelParameters_T4mod('tInt', 1, 'tAv', 0, 'tOn', 6, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T4mod(params);
    case 'T5'
        [ params ]  = SetModelParameters_T5('tInt', 1, 'tAv', 0, 'tOn', 6, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T5(params);
    case 'Barlow-Levick'
        [ params ]  = SetModelParametersBL('tInt', 1, 'tAv', 0, 'tOn', 6, 'dx', 0.1);
        [ filters ] = MakeModelFiltersBL(params);
    case 'MotionEnergy'
        [ params ]  = SetModelParametersMotionEnergy('tInt', 1, 'tAv', 0, 'tOn', 6, 'dx', 0.1);
        [ filters ] = MakeModelFiltersMotionEnergy(params);
end



%% Set stimulus parameters
c = 1/2; % Contrast
% Base-2 log temporal and spatial frequency vectors
logTf = (-2:1/2:5)';
invSf = [120;90;60;45;30;15];%% Make the stimulus
% Temporal and spatial frequency vectors
tf = 2.^logTf;
sf = 1./invSf;
% Number of TFs and SFs
numT = length(tf);
numS = length(sf);
% Prepare structure to hold time-avreaged responses
meanResp = nan(numT,numS,2);


%% Compute the response
% iterate over temporal/spatial frequencies
for indT = 1:numT
    % parallelize iteration over spatial frequencies, if possible
    parfor indS = 1:numS
        % generate stimulus
        tic;
        [ stimArray ] = MonocomponentSinusoidalGratings(params, c, tf(indT), sf(indS));
        % compute responses
        switch modelName
            case 'T4original'
                meanResp(indT,indS,:) =  ComputeThreeInputModelResponse_T4orig(stimArray, params, filters);
            case 'T4modified'
                meanResp(indT,indS,:) =  ComputeThreeInputModelResponse_T4mod(stimArray, params, filters);
            case 'T5'
                meanResp(indT,indS,:) =  ComputeThreeInputModelResponse_T5(stimArray, params, filters);
            case 'Barlow-Levick'
                meanResp(indT,indS,:) =  ComputeBLModelResponse(stimArray, params, filters);
            case 'MotionEnergy'
                meanResp(indT,indS,:) =  ComputeMotionEnergyModelResponse(stimArray, params, filters);
        end
        
        % Print a status update
        fprintf('TF %d of %d, SF %d of %d: %f s\n', indT, numT, indS, numS, toc);
    end
end

% Print a status update
fprintf('Completed simulation in %f seconds\n', toc);

%% Prepare Visualization
centerSpacing = 2;
% prepare axis scale
xx = (1:2*numS+centerSpacing)';
yy = logTf;
% prepare labels fof x axis
xLabelStr = [cellstr(num2str(num2str(flipud([120;60;30]), '-1/{%d}'))); cellstr(num2str(num2str([120;60;30], '1/{%d}')))];
% decide where to put ticks
ss = [-flipud(invSf); nan(centerSpacing,1); invSf];
idx = ismember(abs(ss), [120;60;30]);
% flatten PD and ND responses into 2D matrix
pdnd = [fliplr(meanResp(:,:,2)), nan(numT, centerSpacing), meanResp(:,:,1)];
% decide color scale of heatmap
maxResp = max(abs(pdnd(:)));
cMax = max(1, 10*ceil(maxResp/10)*(maxResp>1));

%% Plot results
% plot heatmap

switch modelName
    case 'T4original'
        MakeFigure('Name','SuppFigure 5E (top)','NumberTitle','off')
    case 'T4modified'
        MakeFigure('Name','SuppFigure 5F (top)','NumberTitle','off')
    case 'T5'
        MakeFigure('Name','SuppFigure 5G (top)','NumberTitle','off')
    otherwise
        MakeFigure('Name',[modelName,' Sinusoidal Power Map'],'NumberTitle','off')

end
imagesc(xx,yy,pdnd);
hold on;
% add contour (to make it easier to see TF/velocity tuning)
contour(xx,yy, pdnd / maxResp, 0:0.1:1, 'EdgeColor', 'k', 'linewidth', 2);
% plot preferred TF for each SF (should be roughly constant for TF tuned models)
[ ~, maxLocs ] = max(pdnd, [], 1);
plot(xx, yy(maxLocs), 'ok','MarkerSize', 10, 'MarkerFaceColor','k', 'MarkerEdgeColor','none');

% prettify axes
xticks(xx(idx));
xticklabels(xLabelStr);
yticks([-1,1,3,5]);
yticklabels(num2str([0.5;2;8;32], '%0.1f'));
xlabel('spatial frequency (1/\circ)');
ylabel('temporal frequency (Hz)');
cbar = colorbar;

caxis([-1 cMax]);
cbar.Limits = [0 cMax];
ylabel(cbar, 'response (arb. units)');
axis('xy','square');
ConfAxis('titleFontSize',16);


end
