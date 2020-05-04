function ThreeInputModelBarPairsResponses_T4orig()

% This function generates figures showing the response of our "modified"
% minimal synaptic model of T4 (that has baseline excitation in the
% preferred-side arm).


%% Set overal model parameters

fontSize=16;
[ params ]  = SetModelParameters('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
[ filters ] = MakeModelFilters(params);
load('blueRedColorMap.mat');

%% Set stimulus parameters

barParam.mlum = 0;        % mean luminance
barParam.c = 1;           % contrast (scaling factor)
barParam.width = 5;       % bar width (in degrees)
barParam.interval = 10;   % interval between two bars (in degrees)

%% Make the stimulus
% The three dimensions correspond to time, space, and stimulus types.
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

legendStr = {'-L-','-D-','-LL','-LD','LL-','DL-','-DL','-DD','LD-','DD-'};
[ stimArray ] = GenerateBarPairs(params, barParam);

% These are the only pairs we care in T4
IndToShow = [1,3,4,5,6];
% Line colors used in the corresponding physiology figure
colors = [ 35, 31, 32;
          103,194,165;
          246,150,109;
          139,159,202;
          226,138,185]/255;


%% Compute the response

[ ~, ~, calciumResp ] =  ComputeThreeInputModelResponse(stimArray, params, filters);

%% Extract center model unit to create a comparable figure as the physiological results

centerResp = permute(calciumResp(:,round(length(params.x)/2),IndToShow),[1,3,2]);
integResp  = mean(centerResp(params.mask,:),1);

%% visualization
MakeFigure;
subplot(1,2,1); hold on
plotStimulusArea([0,1],[0,max(centerResp(:))*1.1]);
PlotXvsY(params.t,centerResp,'color',colors);
ConfAxis('labelX','time (s)','labelY',{'response';'(arb. unit)'},'figLeg',legendStr(IndToShow));
ylim([0,max(centerResp(:))*1.1]);

subplot(1,2,2);
easyBar(integResp,'conditionNames',legendStr(IndToShow),'newFigure',0,'colors',colors);
ConfAxis('labelY',{'response';'(arb. unit)'});
ylim([0,max(integResp(:))*1.1]);


end
