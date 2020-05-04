function ThreeInputModelStaticEdgeResponses_T5()

%% Set overal model parameters

fontSize=16;
[ params ] = SetModelParameters_T5('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
[ filters ] = MakeModelFilters_T5(params);
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
[ staticEdgeStimArray ] = StaticEdges(params, barParam, legendStr);

%% Compute the response

[ staticEdgeMeanResp, staticEdgeVoltageResp, staticEdgeCalciumResp ] = ComputeThreeInputModelResponse_T5(staticEdgeStimArray, params, filters);

%% Plot the stimulus as a false-color plot

% Plot at full resolution
for ind = 1:size(staticEdgeStimArray,3)
    MakeFigure;
    imagesc(params.t, params.x, staticEdgeStimArray(:,:,ind)');
    axis('xy','square','tight');
    xlabel('time (s)');
    ylabel('spatial position (\circ)');
    ylim([0 params.xExtent]);
    cbar = colorbar;
    ylabel(cbar, 'input contrast');
    cbar.Ticks = [-1,0,1];
    colormap([0,0,0;1/2,1/2,1/2;1,1,1]);
    % colormap(cmpBlueRed);
    ConfAxis('titleFontSize',fontSize);
    caxis([-barParam.c,barParam.c]+barParam.mlum);
    title(legendStr{ind});
end

%% Plot the response as a false-color plot
for ind = 1:size(staticEdgeStimArray,3)
    MakeFigure;
    imagesc(params.t, params.x, staticEdgeCalciumResp(:,:,ind)');
    axis('xy','square','tight');
    xlabel('time (s)');
    ylabel('spatial position (\circ)');
    cbar = colorbar;
    ylabel(cbar, 'response (arb. units)');
    mx=max(max(staticEdgeCalciumResp(:,:,ind)));
    mn=min(min(staticEdgeCalciumResp(:,:,ind)));
    colormap(b2r(mn,mx));    
    ConfAxis('titleFontSize',fontSize);
    title(legendStr{ind});
    xlim([-0.5,1.5])
end

%% Plot integrated response

% for ind = 1:size(staticEdgeStimArray,3)
%     
%     meanStimOverTime = squeeze(mean(staticEdgeStimArray(params.averagingMask, :, ind),1));
%     
%     meanStaticEdgeRespOverTime = squeeze(mean(staticEdgeCalciumResp(params.averagingMask, :, ind),1));
%     
%     MakeFigure;
%     yyaxis('right');
%     plot(params.x, meanStimOverTime, 'linewidth', 2, 'color', [0.5 0.5 0.5]);
%     set(gca, 'ycolor', [0.5 0.5 0.5]);
%     ylim([-1,1]);
%     yticks([-1,0,1]);
%     ylabel('input contrast');
%     
%     yyaxis('left');
%     cc = [0.9153    0.2816    0.2878];
%     plot(params.x, meanStaticEdgeRespOverTime , '-', 'linewidth', 2, 'color', cc);
%     xlim([0 params.xExtent]);
%     ConfAxis('titleFontSize',fontSize);
%     set(gca, 'ycolor', cc);
%     %ylim([-1,1]);
%     %yticks([-1,0,1]);
%     ylabel('response (arb. units)');
%     xlabel('spatial position (\circ)');
%     title(legendStr{ind});
% end

end
