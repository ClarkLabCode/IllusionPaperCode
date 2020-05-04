function BLModelStaticEdgeResponses()


%% Set overal model parameters

fontSize=12;
[ params ] = SetModelParametersBL('tInt', 1, 'tAv', 0, 'tOn', 1, 'dx', 0.1);
[ filters ] = MakeModelFiltersBL(params);
load('blueRedColorMap.mat');

%% Set stimulus parameters

barParam.mlum = 0;
barParam.c = 1;

% barParam.mlum = 1/2;
% barParam.c = 1;

% barParam.barPeriod = 45;
barParam.barPeriod = 90;

%% Make the stimulus

legendStr = {'white-black','sawtoothUp','sawtoothDown'};
[ staticEdgeStimArray ] = StaticEdges(params, barParam ,legendStr);


%% Compute the response

[ staticEdgeMeanResp, staticEdgeCalciumResp ] = ComputeBLModelResponse(staticEdgeStimArray, params, filters);

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
    %colormap(cmpBlueRed);
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

MakeFigure('Name','Supplementary Figure 3D','NumberTitle','off')
s1 = subplot(3,2,1);
s2 = subplot(3,2,2);
s3 = subplot(3,2,3);
s4 = subplot(3,2,4);
s5 = subplot(3,2,5);
s6 = subplot(3,2,6);

curr=findobj('type','figure','Name','white-black');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{2},s1); %copy children to new parent axes i.e. the subplot axes
s1.XLim=all_ax_fig1(2).XLim;
s1.YLim=all_ax_fig1(2).YLim;
colormap(s1,'gray')
s1.YDir='reverse';
ylabel(s1,'<--- progressive is down')

copyobj(all_children_ax_fig1{1},s2); %copy children to new parent axes i.e. the subplot axes
s2.XLim=all_ax_fig1(1).XLim;
s2.YLim=all_ax_fig1(1).YLim;
s2.Colormap=all_ax_fig1(1).Colormap;
s2.CLim=all_ax_fig1(1).CLim;
s2.YDir='reverse';

curr=findobj('type','figure','Name','sawtoothUp');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{2},s3); %copy children to new parent axes i.e. the subplot axes
s3.XLim=all_ax_fig1(2).XLim;
s3.YLim=all_ax_fig1(2).YLim;
colormap(s3,'gray')
s3.YDir='reverse';
ylabel(s3,'<--- progressive is down')

copyobj(all_children_ax_fig1{1},s4); %copy children to new parent axes i.e. the subplot axes
s4.XLim=all_ax_fig1(1).XLim;
s4.YLim=all_ax_fig1(1).YLim;
s4.Colormap=all_ax_fig1(1).Colormap;
s4.CLim=all_ax_fig1(1).CLim;
s4.YDir='reverse';

curr=findobj('type','figure','Name','sawtoothDown');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{2},s5); %copy children to new parent axes i.e. the subplot axes
s5.XLim=all_ax_fig1(2).XLim;
s5.YLim=all_ax_fig1(2).YLim;
colormap(s5,'gray')
s5.YDir='reverse';
ylabel(s5,'<--- progressive is down')

copyobj(all_children_ax_fig1{1},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig1(1).XLim;
s6.YLim=all_ax_fig1(1).YLim;
s6.Colormap=all_ax_fig1(1).Colormap;
s6.CLim=all_ax_fig1(1).CLim;
s6.YDir='reverse';

figsToDelete={'white-black','sawtoothUp','sawtoothDown'};
allFigs=findobj('type','figure');
for k=1:length(allFigs)
    if any(strcmp(allFigs(k).Name,figsToDelete))
        close(allFigs(k))
    end
end
end
