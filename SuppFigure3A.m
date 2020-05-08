function SuppFigure3A(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Supp Figure 3A of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4a responses, 2-T4b
% responses, 3-T5a responses, 4-T5b responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

cellTypes={'T4a','T4b','T5a','T5b'};
output.analysis=cell(1,length(cellTypes));
for k=1:length(cellTypes)
    nonResponsiveFlies = cellfun('isempty', flyResp(k, :));
    currFly=flyResp(k,~nonResponsiveFlies);
    if ~isempty(currFly)
        currEpochs=stimulusInfo.epochs(k,~nonResponsiveFlies);
        currParams=stimulusInfo.params(k,~nonResponsiveFlies);
        currEpochsForSelection=stimulusInfo.epochsForSelection(k,~nonResponsiveFlies);
        currEyes=stimulusInfo.flyEyes(k,~nonResponsiveFlies);

        output.analysis{1,k}= EdgesRoiAnalysis(...
            currFly,currEpochs,currParams,...
            general_parameters.dataRateImaging,...
            'epochsForSelectivity', stimulusInfo.epochsForSelectivity,...
            'epochsForSelection',currEpochsForSelection,...
            'flyEyes',currEyes,...
            'crossValidateCentRF', 0,...
            'figureName', cellTypes{k},...
            'iteration',k);
    end
end

stimuli={'-0 Edge','-0 Edge','-0 Edge','-0 Edge'};
cellTypes={'T4a','T4b','T5a','T5b'};
setLims(cellTypes,stimuli)

MakeFigure('Name','SuppFigure 3A','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;

s1 = subplot(2,12,1); % stimulus black gray
s2 = subplot(2,12,2); % T4a response xt plot
s3 = subplot(2,12,3); % T4a response time averaged
s4 = subplot(2,12,4); % stimulus black gray
s5 = subplot(2,12,5); % T4b response xt plot
s6 = subplot(2,12,6); % T4b response time averaged
s7 = subplot(2,12,7); % stimulus white gray
s8 = subplot(2,12,8); % T4a response xt plot
s9 = subplot(2,12,9); % T4a response time averaged
s10 = subplot(2,12,10); % stimulus white gray
s11 = subplot(2,12,11); % T4b response xt plot
s12 = subplot(2,12,12); % T4b response time averaged
s13 = subplot(2,12,13); % stimulus black gray
s14 = subplot(2,12,14); % T5a response xt plot
s15 = subplot(2,12,15); % T5a response time averaged
s16 = subplot(2,12,16); % stimulus black gray
s17 = subplot(2,12,17); % T5b response xt plot
s18 = subplot(2,12,18); % T5b response time averaged
s19 = subplot(2,12,19); % stimulus white gray
s20 = subplot(2,12,20); % T5a response xt plot
s21 = subplot(2,12,21); % T5a response time averaged
s22 = subplot(2,12,22); % stimulus white gray
s23 = subplot(2,12,23); % T5b response xt plot
s24 = subplot(2,12,24); % T5b response time averaged

curr=findobj('type','figure','Name','Edges T4a');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{4},s1); % T4 P GB stim
s1.XLim=all_ax_fig1(4).XLim;
s1.YLim=all_ax_fig1(4).YLim;
s1.YTick=[-numPhases/2 0 numPhases/2];
s1.YTickLabel=linspace(0,2*numPhases,length(s1.YTick))*barWidth;
colormap(s1,'gray')
ylabel(s1,{'offset from', 'RF center (deg)'})
xlabel(s1,'time(s)')
title(s1,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s2); % T4 P GB xtplot
s2.XLim=all_ax_fig1(9).XLim;
s2.YLim=all_ax_fig1(9).YLim;
colormap(s2,colormap(all_ax_fig1(9)));
s2.YDir='reverse';
s2.CLim=all_ax_fig1(9).CLim;
s2.YTick=[];
colorbar(s2);
xlabel(s2,'time(s)')
title(s2,'T4a','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{3},s4); % T4 P GW stim
s4.XLim=all_ax_fig1(3).XLim;
s4.YLim=all_ax_fig1(3).YLim;
s4.YTick=[-numPhases/2 0 numPhases/2];
s4.YTickLabel=linspace(0,2*numPhases,length(s4.YTick))*barWidth;
colormap(s4,'gray')
xlabel(s4,'time(s)')
title(s4,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s5); % T4 P GW xt plot
s5.XLim=all_ax_fig1(8).XLim;
s5.YLim=all_ax_fig1(8).YLim;
colormap(s5,colormap(all_ax_fig1(8)));
s5.YDir='reverse';
s5.CLim=all_ax_fig1(8).CLim;
s5.YTick=[];
colorbar(s5);
xlabel(s5,'time(s)')
title(s5,'T4a','FontSize',12,'FontWeight','bold')

curr=findobj('type','figure','Name','Edges T4b');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{4},s7); % T4 R GB stim
s7.XLim=all_ax_fig1(4).XLim;
s7.YLim=all_ax_fig1(4).YLim;
s7.YTick=[-numPhases/2 0 numPhases/2];
s7.YTickLabel=linspace(0,2*numPhases,length(s7.YTick))*barWidth;
colormap(s7,'gray')
xlabel(s7,'time(s)')
title(s7,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s8); % T4 R GB xtplot
s8.XLim=all_ax_fig1(9).XLim;
s8.YLim=all_ax_fig1(9).YLim;
colormap(s8,colormap(all_ax_fig1(9)));
s8.YDir='reverse';
s8.CLim=all_ax_fig1(9).CLim;
s8.YTick=[];
colorbar(s8);
xlabel(s8,'time(s)')
title(s8,'T4b','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{3},s10); % T4 R GW stim
s10.XLim=all_ax_fig1(3).XLim;
s10.YLim=all_ax_fig1(3).YLim;
s10.YTick=[-numPhases/2 0 numPhases/2];
s10.YTickLabel=linspace(0,2*numPhases,length(s4.YTick))*barWidth;
colormap(s10,'gray')
xlabel(s10,'time(s)')
title(s10,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s11); % T4 P GW xt plot
s11.XLim=all_ax_fig1(8).XLim;
s11.YLim=all_ax_fig1(8).YLim;
colormap(s11,colormap(all_ax_fig1(8)));
s11.YDir='reverse';
s11.CLim=all_ax_fig1(8).CLim;
s11.YTick=[];
colorbar(s11);
xlabel(s11,'time(s)')
title(s11,'T4b','FontSize',12,'FontWeight','bold')

curr=findobj('type','figure','Name','Edges T5a');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{3},s13); % T5 P GB stim
s13.XLim=all_ax_fig1(3).XLim;
s13.YLim=all_ax_fig1(3).YLim;
s13.YTick=[-numPhases/2 0 numPhases/2];
s13.YTickLabel=linspace(0,2*numPhases,length(s1.YTick))*barWidth;
colormap(s13,'gray')
ylabel(s13,{'offset from', 'RF center (deg)'})
xlabel(s13,'time(s)')
title(s13,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s14); % T5 P GB xtplot
s14.XLim=all_ax_fig1(8).XLim;
s14.YLim=all_ax_fig1(8).YLim;
colormap(s14,colormap(all_ax_fig1(8)));
s14.YDir='reverse';
s14.CLim=all_ax_fig1(8).CLim;
s14.YTick=[];
colorbar(s14);
xlabel(s14,'time(s)')
title(s14,'T5a','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{4},s16); % T5 P GW stim
s16.XLim=all_ax_fig1(4).XLim;
s16.YLim=all_ax_fig1(4).YLim;
s16.YTick=[-numPhases/2 0 numPhases/2];
s16.YTickLabel=linspace(0,2*numPhases,length(s16.YTick))*barWidth;
colormap(s16,'gray')
xlabel(s16,'time(s)')
title(s16,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s17); % T5 P GW xt plot
s17.XLim=all_ax_fig1(9).XLim;
s17.YLim=all_ax_fig1(9).YLim;
colormap(s17,colormap(all_ax_fig1(9)));
s17.YDir='reverse';
s17.CLim=all_ax_fig1(9).CLim;
s17.YTick=[];
colorbar(s17);
xlabel(s17,'time(s)')
title(s17,'T5a','FontSize',12,'FontWeight','bold')

curr=findobj('type','figure','Name','Edges T5b');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{3},s19); % T5 R GB stim
s19.XLim=all_ax_fig1(3).XLim;
s19.YLim=all_ax_fig1(3).YLim;
s19.YTick=[-numPhases/2 0 numPhases/2];
s19.YTickLabel=linspace(0,2*numPhases,length(s19.YTick))*barWidth;
colormap(s19,'gray')
xlabel(s19,'time(s)')
title(s19,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s20); % T5 R GB xtplot
s20.XLim=all_ax_fig1(8).XLim;
s20.YLim=all_ax_fig1(8).YLim;
colormap(s20,colormap(all_ax_fig1(8)));
s20.YDir='reverse';
s20.CLim=all_ax_fig1(9).CLim;
s20.YTick=[];
colorbar(s20);
xlabel(s20,'time(s)')
title(s20,'T5b','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{4},s22); % T5 R GW stim
s22.XLim=all_ax_fig1(4).XLim;
s22.YLim=all_ax_fig1(4).YLim;
s22.YTick=[-numPhases/2 0 numPhases/2];
s22.YTickLabel=linspace(0,2*numPhases,length(s22.YTick))*barWidth;
colormap(s22,'gray')
xlabel(s22,'time(s)')
title(s22,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s23); % T5 R GW xt plot
s23.XLim=all_ax_fig1(9).XLim;
s23.YLim=all_ax_fig1(9).YLim;
colormap(s23,colormap(all_ax_fig1(8)));
s23.YDir='reverse';
s23.CLim=all_ax_fig1(9).CLim;
s23.YTick=[];
colorbar(s23);
xlabel(s23,'time(s)')
title(s23,'T5b','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges time avg T4a');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s3,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s3,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s3,'tight')
view(s3,90,-90)
s3.XTick=[];
box(s3,'off')
ylabel(s3,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{8},s6); %copy children to new parent axes i.e. the subplot axes
plot(s6,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s6,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s6,'tight')
s6.YLim(2)=s3.YLim(2);
view(s6,90, -90)
s6.XTick=[];
box(s6,'off')
ylabel(s6,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T4b');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s9,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s9,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s9,'tight')
view(s9,90,-90)
s9.XTick=[];
box(s9,'off')
ylabel(s9,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{8},s12); %copy children to new parent axes i.e. the subplot axes
plot(s12,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s12,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s12,'tight')
s12.YLim(2)=s3.YLim(2);
view(s12,90, -90)
s12.XTick=[];
box(s12,'off')
ylabel(s12,'^{\Delta f}/_{f}')



curr=findobj('type','figure','Name','Edges time avg T5a');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig5{8},s15); %copy children to new parent axes i.e. the subplot axes
s15.XLim=all_ax_fig5(8).XLim;
s15.YLim=all_ax_fig5(8).YLim;
s15.XTick=[];
view(s15,90, -90)
ylabel(s15,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{9},s18); %copy children to new parent axes i.e. the subplot axes
s18.XLim=all_ax_fig5(9).XLim;
s18.YLim=all_ax_fig5(9).YLim;
s18.XTick=[];
view(s18,90, -90)
ylabel(s18,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T4a');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s3,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s3,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s3,'tight')
view(s3,90,-90)
s3.XTick=[];
box(s3,'off')
ylabel(s3,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{8},s6); %copy children to new parent axes i.e. the subplot axes
plot(s6,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s6,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s6,'tight')
s6.YLim(2)=s3.YLim(2);
view(s6,90, -90)
s6.XTick=[];
box(s6,'off')
ylabel(s6,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T4b');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s9,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s9,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s9,'tight')
view(s9,90,-90)
s9.XTick=[];
box(s9,'off')
ylabel(s9,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{8},s12); %copy children to new parent axes i.e. the subplot axes
plot(s12,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{9}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s12,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{9}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s12,'tight')
s12.YLim(2)=s3.YLim(2);
view(s12,90, -90)
s12.XTick=[];
box(s12,'off')
ylabel(s12,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T5a');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s15,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{8}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s15,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{8}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s15,'tight')
view(s15,90,-90)
s15.XTick=[];
box(s15,'off')
ylabel(s15,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{9},s18); %copy children to new parent axes i.e. the subplot axes
plot(s18,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{8}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s18,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{8}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s18,'tight')
s18.YLim(2)=s15.YLim(2);
view(s18,90, -90)
s18.XTick=[];
box(s18,'off')
ylabel(s18,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T5b');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

plot(s21,all_children_ax_fig5{8}(1).XData,...
    all_children_ax_fig5{8}(1).YData/max(all_children_ax_fig5{8}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s21,'XData',all_children_ax_fig5{8}(2).XData,...
    'YData',all_children_ax_fig5{8}(2).YData/max(all_children_ax_fig5{8}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s21,'tight')
view(s21,90,-90)
s21.XTick=[];
box(s21,'off')
ylabel(s21,'^{\Delta f}/_{f}')

copyobj(all_children_ax_fig5{9},s24); %copy children to new parent axes i.e. the subplot axes
plot(s24,all_children_ax_fig5{9}(1).XData,...
    all_children_ax_fig5{9}(1).YData/max(all_children_ax_fig5{8}(1).YData)) %copy children to new parent axes i.e. the subplot axes
patch(s24,'XData',all_children_ax_fig5{9}(2).XData,...
    'YData',all_children_ax_fig5{9}(2).YData/max(all_children_ax_fig5{8}(1).YData),...
    'FaceColor',lines(1),'FaceAlpha',0.25,'EdgeColor','none')
axis(s24,'tight')
s24.YLim(2)=s3.YLim(2);
view(s24,90, -90)
s24.XTick=[];
box(s24,'off')
ylabel(s24,'^{\Delta f}/_{f}')

closeAllExceptIllusionPaperFigures()