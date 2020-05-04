function PlotStaticEdgeResponses(modelName)

%% This function plot responses of motion detector models to stationary
%% sawtooth gradients and full-contrast square wave gratings.

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
% define font size for visualization
fontSize=16;

% define model parameters according to model name provided
switch modelName
    case 'T4original'
        [ params ]  = SetModelParameters_T4orig('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T4orig(params);
    case 'T4modified'
        [ params ]  = SetModelParameters_T4mod('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T4mod(params);
    case 'T5'
        [ params ]  = SetModelParameters_T5('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
        [ filters ] = MakeModelFilters_T5(params);
    case 'Barlow-Levick'
        [ params ]  = SetModelParametersBL('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
        [ filters ] = MakeModelFiltersBL(params);
    case 'MotionEnergy'
        [ params ]  = SetModelParametersMotionEnergy('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
        [ filters ] = MakeModelFiltersMotionEnergy(params);
end



%% Set stimulus parameters

barParam.mlum = 0;       % luminance offset
barParam.c = 1;          % scaling of contrast
barParam.barPeriod = 90; % periodicity of stimulus (in degree)
                         % note that we are modeling only 180º of visual
                         % space

%% Make the stimulus
% names of stimuli (these are used inside StaticEdges function)
stimNames = {'sawtoothUp','sawtoothDown','white-black'};
[ stimArray ] = StaticEdges(params, barParam,stimNames);

%% Compute the response
% All the models are rightward tuned. We get leftward tuned model response
% by feeding them flipped stimulus and flipping the outputs.
switch modelName
    case 'T4original'
        [ ~, ~, calciumResp ]     = ComputeThreeInputModelResponse_T4orig(stimArray, params, filters);
        [ ~, ~, calciumRespFlip ] = ComputeThreeInputModelResponse_T4orig(fliplr(stimArray), params, filters);
    case 'T4modified'
        [ ~, ~, calciumResp ]    = ComputeThreeInputModelResponse_T4mod(stimArray, params, filters);
        [ ~, ~, calciumRespFlip ] = ComputeThreeInputModelResponse_T4mod(fliplr(stimArray), params, filters);
    case 'T5'
        [ ~, ~, calciumResp ]     = ComputeThreeInputModelResponse_T5(stimArray, params, filters);
        [ ~, ~, calciumRespFlip ] = ComputeThreeInputModelResponse_T5(fliplr(stimArray), params, filters);
    case 'Barlow-Levick'
        [ ~, calciumResp ]     = ComputeBLModelResponse(stimArray, params, filters);
        [ ~, calciumRespFlip ] = ComputeBLModelResponse(fliplr(stimArray), params, filters);
    case 'MotionEnergy'
        [ ~, calciumResp ]     = ComputeMotionEnergyModelResponse(stimArray, params, filters);
        [ ~, calciumRespFlip ] = ComputeMotionEnergyModelResponse(fliplr(stimArray), params, filters);
end
calciumRespR = calciumResp;
calciumRespL = fliplr(calciumRespFlip);

%% Visualization
switch modelName
    case 'T4original'
        MakeFigure('Name','Figure 4B','NumberTitle','off')
    case 'T4modified'
        MakeFigure('Name','Figure 4F','NumberTitle','off')
    case 'Barlow-Levick'
        MakeFigure('Name','SuppFigure 4B','NumberTitle','off')
    case 'MotionEnergy'
        MakeFigure('Name','SuppFigure 4D','NumberTitle','off')
    case 'T5'
        MakeFigure('Name','SuppFigure 5B','NumberTitle','off')
    otherwise
        MakeFigure('Name',[modelName,' Static Edge Responses'],'NumberTitle','off')
end
Nstim = size(stimArray,3); % #stimulus conditions 


% get response range
mx = max(max(max(calciumRespR(params.mask,:,:))));
mn = min(min(min(calciumRespR(params.mask,:,:))));

for ii = 1:Nstim
    %% Visualize stimulus
    subplot(3,Nstim,ii);  % prepare axis
    imagesc(params.x,params.t,stimArray(:,:,ii)); % show the stimulus pattern
    axis('ij','square','tight'); % configure axis
    xlabel('spatial position (\circ)'); % label x axis
    ylabel('time (s)');                 % label y axis
    xlim([0 params.xExtent]);           % configure extent of xa xis
    set(gca,'XTick',0:90:180,'YTick',[0,1]); % simplify ticks
    
    hold on
    PlotConstLine(0); % plot dotted lines to delineate beginning/end of stimulus
    PlotConstLine(1);
    PlotConstLine(90,2);  % plot dotted lines to delineate edges in stimulus
    if ii==3 % more edge lines for square wave stimulus
        PlotConstLine(45,2);
        PlotConstLine(135,2);
    end
    
    cbar = colorbar;                    % show colorbar
    ylabel(cbar, 'input contrast');     % name colorbar
    cbar.Ticks = [-1,0,1];              % set ticks of colorbar
    caxis(barParam.c*[-1,1]+barParam.mlum);  % scale the color
    colormap(gca,'gray');               % change color to grayscale
    ylim([-0.25,1.25]); % only show response around stimuli 
    title(stimNames{ii}); % provide name of the stimulus
    ConfAxis('titleFontSize',fontSize); % change title font size
    
    
    
    %% Visualize model response (rightward tuned)
    subplot(3,Nstim,ii+Nstim); % prepare axis
    imagesc(params.x, params.t, calciumRespR(:,:,ii)); % show model response

    axis('ij','square','tight'); % configure axis
    xlabel({'spatial position (\circ)';'--> preferred direction'}); % show x label
    ylabel('time (s)'); % show y label
    set(gca,'XTick',0:90:180,'YTick',[0,1]); % simplify ticks
    
    hold on
    PlotConstLine(0); % plot dotted lines to delineate beginning/end of stimulus
    PlotConstLine(1);
    PlotConstLine(90,2);  % plot dotted lines to delineate edges in stimulus
    if ii==3 % more edge lines for square wave stimulus
        PlotConstLine(45,2);
        PlotConstLine(135,2);
    end
    
    cbar = colorbar; % show colorbar
    ylabel(cbar, 'response (arb. units)'); % name color bar
    colormap(gca,b2r(mn,mx)); % use consistent color scale across stimuli
    ylim([-0.5,1.5]); % only show response around stimuli
    ConfAxis();

    
    %% Visualize model response (leftward tuned)
    subplot(3,Nstim,ii+Nstim*2); % prepare axis
    imagesc(params.x, params.t, calciumRespL(:,:,ii)); % show model response
    axis('ij','square','tight'); % configure axis
    xlabel({'spatial position (\circ)';'<-- preferred direction'}); % show x label
    ylabel('time (s)'); % show y label
    set(gca,'XTick',0:90:180,'YTick',[0,1]); % simplify ticks
    
    hold on
    PlotConstLine(0); % plot dotted lines to delineate beginning/end of stimulus
    PlotConstLine(1);
    PlotConstLine(90,2);  % plot dotted lines to delineate edges in stimulus
    if ii==3 % more edge lines for square wave stimulus
        PlotConstLine(45,2);
        PlotConstLine(135,2);
    end
    
    cbar = colorbar; % show colorbar
    ylabel(cbar, 'response (arb. units)'); % name color bar
    colormap(gca,b2r(mn,mx)); % use consistent color scale across stimuli
    ylim([-0.5,1.5]); % only show response around stimuli
    ConfAxis();
  
end
end
