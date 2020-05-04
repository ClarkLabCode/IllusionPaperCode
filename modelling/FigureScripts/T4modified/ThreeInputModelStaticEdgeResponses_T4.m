function ThreeInputModelStaticEdgeResponses_T4()


%% Set overal model parameters

fontSize=16;
[ params ] = SetModelParameters_T4('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
[ filters ] = MakeModelFilters_T4(params);
load('blueRedColorMap.mat');

%% Set stimulus parameters

barParam.mlum = 0;
barParam.c = 1;

% barParam.mlum = 1/2;
% barParam.c = 1;

% barParam.barPeriod = 45;
barParam.barPeriod = 90;

%% Make the stimulus

legendStr = {'white-black','white-gray','gray-black'};
[ staticEdgeStimArray ] = StaticEdges(params, barParam,legendStr);


%% Compute the response

[ staticEdgeMeanResp, staticEdgeVoltageResp, staticEdgeCalciumResp ] =...
    ComputeThreeInputModelResponse_T4(staticEdgeStimArray, params, filters);

%% Plot the stimulus as a false-color plot

onoffIdx = find(diff(any(staticEdgeStimArray(:,:,1)')));
% use the consistent colormap for all figures, ignoring offset response
mx=max(max(max(staticEdgeCalciumResp(onoffIdx(1)+1:onoffIdx(2),:,:))));
mn=min(min(min(staticEdgeCalciumResp(onoffIdx(1)+1:onoffIdx(2),:,:)))); 

%Plot at full resolution
for ind = 1:size(staticEdgeStimArray,3)
    MakeFigure('Name',legendStr{ind})
    ax1=subplot(1,2,1);
    imagesc(params.t, params.x, staticEdgeStimArray(:,:,ind)');
    axis('xy','square','tight');
    xlabel('time (s)');
    ylabel('spatial position (\circ)');
    ylim([0 params.xExtent]);
    cbar = colorbar;
    ylabel(cbar, 'input contrast');
    cbar.Ticks = [-1,0,1];
    colormap(ax1,[0,0,0;1/2,1/2,1/2;1,1,1]);
    % colormap(cmpBlueRed);
    ConfAxis('titleFontSize',fontSize);
    caxis([-barParam.c,barParam.c]+barParam.mlum);
    title(legendStr{ind});
    
    ax2=subplot(1,2,2);
    imagesc(params.t, params.x, staticEdgeCalciumResp(:,:,ind)');
    axis('xy','square','tight');
    xlabel('time (s)');
    ylabel('spatial position (\circ)');
    cbar = colorbar;
    ylabel(cbar, 'response (arb. units)');
    %     mx=max(max(staticEdgeCalciumResp(:,:,ind)));
    %     mn=min(min(staticEdgeCalciumResp(:,:,ind)));
    colormap(ax2,b2r(mn,mx));
    ConfAxis('titleFontSize',fontSize);
    %title(legendStr{ind});
    xlim([-0.5,1.5])
end
end
