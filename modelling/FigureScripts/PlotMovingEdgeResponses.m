function PlotMovingEdgeResponses(modelName)

%% This function plot responses of motion detector models to moving
%% light and darke edges we use to classify T4/T5 * a/b in our experiments

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
barParam.mlum = 0;        % mean luminance
barParam.c = 1;           % contrast (scaling factor)
barParam.velocity = 30;   % velocity of edges (deg/s)

%% Make the stimulus
% The three dimensions correspond to time, space, and stimulus types.
% This array contains:
% 1.  Light edges moving towards right
% 2.  Dark  edges moving towards right
% 3.  Light edges moving towards left
% 4.  Dark  edges moving towards left


stimNames = {'Light R','Dark R','Light L','Dark L'};
[ stimArray ] = GenerateMovingEdges(params, barParam);


% Line colors used in the corresponding physiology figure
colors = [255,0,0;
          61,73,165;
          202,54,157;
          48,199,70]/255;
      
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

%% Visualization (in the style of Fig. 1C in Zavatone-Veth et al. 2020)
respRange = max(centerResp(:)) - min(centerResp(:));
% define sizes of scale bars for response and time
respunit = round(respRange/(10^floor(log10(respRange)))/2)*(10^floor(log10(respRange)));
timeunit = 2;

plott = params.t(params.mask); % only plot response during stimlus presentation 
plotResp = centerResp(params.mask,:) + [3, 2, 1, 0]*respunit; % shift baselines for each condition

switch modelName
    case 'T4original'
        MakeFigure('Name','SuppFigure 5E (bottom)','NumberTitle','off')
    case 'T4modified'
        MakeFigure('Name','SuppFigure 5F (bottom)','NumberTitle','off')
    case 'T5'
        MakeFigure('Name','SuppFigure 5G (bottom)','NumberTitle','off')
    otherwise
        MakeFigure('Name',[modelName,' Moving Edge Responses'],'NumberTitle','off'); hold on
end

PlotXvsY(plott,plotResp,'color',colors); % plot response
hold on
h = plot([-0.5,-0.5,0.5]*timeunit,[0.5,-0.5,-0.5]*respunit,'k'); % plot scale bar
hAnnotation = get(h,'Annotation'); % don't show legend for scale bar
hLegendEntry = get(hAnnotation,'LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off');
tx1 = text(-0.5*timeunit,0.6*respunit,[num2str(respunit),' arb. units']);
tx2 = text(0.6*timeunit,-0.5*respunit,[num2str(timeunit),' s']);
set(tx1,'Rotation',90,'Fontsize',16);
set(tx2,'Rotation', 0,'Fontsize',16);

axis off
ConfAxis('figLeg',stimNames);
xlim([-1,7]);

end
