function ThreeInputModelMovingEdgeResponses_T5()

% This function generates figures showing the response of our "modified"
% minimal synaptic model of T4 (that has baseline excitation in the
% preferred-side arm).


%% Set overal model parameters

fontSize=16;
[ params ]  = SetModelParameters_T5('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
[ filters ] = MakeModelFilters_T5(params);

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


legendStr = {'Light R','Dark R','Light L','Dark L'};
[ stimArray ] = GenerateMovingEdges(params, barParam);


% Line colors used in the corresponding physiology figure
colors = [1,0,0;0,0,1;0.5,0,0;0,0,0.5];


%% Compute the response

[ ~, ~, calciumResp ] =  ComputeThreeInputModelResponse_T5(stimArray, params, filters);

%% Extract center model unit to create a comparable figure as the physiological results

centerResp = permute(calciumResp(:,round(length(params.x)/2),:),[1,3,2]);

%% visualization
MakeFigure; hold on
PlotXvsY(params.t,centerResp,'color',colors);
PlotConstLine(0);
ConfAxis('labelX','time (s)','labelY',{'response';'(arb. unit)'},'figLeg',legendStr);
ylim(max(centerResp(:))*[-0.2,1.1]);

end
