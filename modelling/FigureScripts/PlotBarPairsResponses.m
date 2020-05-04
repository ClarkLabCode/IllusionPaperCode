function PlotBarPairsResponses(modelName)

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

barParam.mlum = 0;        % mean luminance
barParam.c = 1;           % contrast (scaling factor)
barParam.width = 5;       % bar width (in degrees)
barParam.interval = 10;   % interval between two bars (in degrees)

%% Make the stimulus% The three dimensions correspond to time, space, and stimulus types.
% This array contains:
% 1.  Light bar at the center
% 2.  Dark  bar at the center
% 3.  Light bar at the center + light bar to the right
% 4.  Light bar at the center + dark  bar to the right
% 5.  Light bar at the center + light bar to the left
% 6.  Light bar at the center + dark  bar to the left
% 7.  Dark  bar at the center + light bar to the right
% 8.  Dark  bar at the center + dark  bar to the right
% 9.  Dark  bar at the center + light bar to the left
% 10. Dark  bar at the center + dark  bar to the left

stimNames = {'-L-','-D-','-LL','-LD','LL-','DL-','-DL','-DD','LD-','DD-'};
[ stimArray ] = GenerateBarPairs(params, barParam);

% Indices for condition pairs tested in imaging experiments (Fig. 3B-E)
T4showInd = [1,3,4,5,6];  % for T4 (Fig. 3B, C)
T5showInd = [2,8,7,10,9]; % for T5 (Fig. 3D, E)

% Line colors used in the corresponding physiology figure
colors = [ 35, 31, 32;
          103,194,165;
          246,150,109;
          139,159,202;
          226,138,185]/255;
      
%% Compute the response

switch modelName
    case 'T4original'
        [ ~, ~, calciumResp ] = ComputeThreeInputModelResponse_T4orig(stimArray, params, filters);
    case 'T4modified'
        [ ~, ~, calciumResp ] = ComputeThreeInputModelResponse_T4mod(stimArray, params, filters);
    case 'T5'
        [ ~, ~, calciumResp ] = ComputeThreeInputModelResponse_T5(stimArray, params, filters);
    case 'Barlow-Levick'
        [ ~, calciumResp ] = ComputeBLModelResponse(stimArray, params, filters);
    case 'MotionEnergy'
        [ ~, calciumResp ] = ComputeMotionEnergyModelResponse(stimArray, params, filters);
end

%% Extract response of center model unit to create a comparable figure as the physiological results
centerResp = permute(calciumResp(:,round(length(params.x)/2),:),[1,3,2]);
% average over time during stimulus presentation
integResp  = mean(centerResp(params.mask,:),1);

%% Visualization
% Extract response range for consistent scaling
mxc = max(centerResp(:));
mnc = min(centerResp(:));
mxi = max(integResp(:));
mni = min(integResp(:));

switch modelName
    case 'T4original'
        MakeFigure('Name','Figure 4C','NumberTitle','off')
    case 'T4modified'
        MakeFigure('Name','Figure 4G','NumberTitle','off')
    case 'T5'
        MakeFigure('Name','SuppFigure 5C','NumberTitle','off')
    otherwise
        MakeFigure('Name',[modelName,' Bar Pairs Responses'],'NumberTitle','off')
end

% "Light bar at the center" stimulus (for T4 case)
subplot(2,2,1);  % prepare axis
title('Light bar at the center');
hold on
plotStimulusArea([0,1],[0,max(centerResp(:))*1.1]); % show the time during which stimulus was presented
PlotXvsY(params.t,centerResp(:,T4showInd),'color',colors); % plot responses
ConfAxis('labelX','time (s)','labelY',{'response';'(arb. unit)'},'figLeg',stimNames(T4showInd));
xlim([-0.5,1.5]); % only show time around stimulus presentation
ylim([mnc,mxc*1.1]);

subplot(2,2,2);
easyBar(integResp(T4showInd),'conditionNames',stimNames(T4showInd),'newFigure',0,'colors',colors);
ConfAxis('labelY',{'response';'(arb. unit)'});
ylim([mni,mxi*1.1]);

% "Dark bar at the center" stimulus (for T5 case)
subplot(2,2,3); 
title('Dark bar at the center');
hold on
plotStimulusArea([0,1],[0,max(centerResp(:))*1.1]);
PlotXvsY(params.t,centerResp(:,T5showInd),'color',colors);
ConfAxis('labelX','time (s)','labelY',{'response';'(arb. unit)'},'figLeg',stimNames(T5showInd));
xlim([-0.5,1.5]); % only show time around stimulus presentation
ylim([mnc,mxc*1.1]);

subplot(2,2,4);
easyBar(integResp(T5showInd),'conditionNames',stimNames(T5showInd),'newFigure',0,'colors',colors);
ConfAxis('labelY',{'response';'(arb. unit)'});
ylim([mni,mxi*1.1]);

end
