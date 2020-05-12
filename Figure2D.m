function Figure2D(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 2D of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4P responses, 2-T4R
% responses, 3-T5P responses, 4-T5R responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

repeatSection=0;
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
            'figureName', cellTypes{k},...
            'iteration',k,...
            'repeatSection',repeatSection);
    end
end

%% 2 - Combine responses from progressive and regressive cell types

% The responses to progressive and regressive cell types to single bars are
% identical. Here we combine them and plot, in hidden figures, the x-t
% plots of responses and the time-averaged traces of responses.

stimuli={'+ Still','- Still'};
combineProgressiveAndRegressive(output,stimuli,general_parameters,repeatSection)

%% 3 - Set colorscale limits

% Set the limits of the colorscale of the x-t plots and the limits of the
% y-axis of the time-averaged traces. For T4, we set the limits to those
% of the responses to the white bar, and for T5 to those of the responses
% to the black bar.

cellTypes={'T4 combined','T5 combined'};
setLims(cellTypes,stimuli)

%% 4 - Organize figure

MakeFigure('Name','Figure 2D','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;

s1 = subplot(2,5,1); % white bar stimulus
s2 = subplot(2,5,2); % T4 response to white bar xt plot
s3 = subplot(2,5,3); % T4 response to white bar time averaged
s4 = subplot(2,5,4); % T5 response to white bar xt plot
s5 = subplot(2,5,5); % T5 response to white bar time averaged
s6 = subplot(2,5,6); % black bar stimulus
s7 = subplot(2,5,7); % T4 response to black bar xt plot
s8 = subplot(2,5,8); % T4 response to black bar time averaged
s9 = subplot(2,5,9); % T5 response to black bar xt plot
s10 = subplot(2,5,10); % T5 response to black bar time averaged

curr=findobj('type','figure','Name','Edges T4 combined');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children');

copyobj(all_children_ax_fig1{2},s1);
s1.XLim=all_ax_fig1(2).XLim;
s1.YLim=all_ax_fig1(2).YLim;
s1.YTick=[-numPhases/4 -numPhases/8 0 numPhases/8 numPhases/4];
s1.YTickLabel=[-numPhases/4 -numPhases/8 0 numPhases/8 numPhases/4]*barWidth;
ylabel(s1,{'offset from', 'RF center (deg)'})
xlabel(s1,'time(s)')
title(s1,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{7},s2);
s2.XLim=all_ax_fig1(7).XLim;
s2.YLim=all_ax_fig1(7).YLim;
s2.Colormap=all_ax_fig1(7).Colormap;
s2.YDir='reverse';
s2.CLim=all_ax_fig1(7).CLim;
s2.YTick=[];
colorbar(s2)
xlabel(s2,'time(s)')
title(s2,'T4','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{1},s6);
s6.XLim=all_ax_fig1(1).XLim;
s6.YLim=all_ax_fig1(1).YLim;
s6.YTick=[-numPhases/4 -numPhases/8 0 numPhases/8 numPhases/4];
s6.YTickLabel=[-numPhases/4 -numPhases/8 0 numPhases/8 numPhases/4]*barWidth;
ylabel(s6,{'offset from', 'RF center (deg)'})
xlabel(s6,'time(s)')

copyobj(all_children_ax_fig1{6},s7);
s7.XLim=all_ax_fig1(6).XLim;
s7.YLim=all_ax_fig1(6).YLim;
s7.Colormap=all_ax_fig1(6).Colormap;
s7.YDir='reverse';
s7.CLim=all_ax_fig1(6).CLim;
s7.YTick=[];
colorbar(s7)
xlabel(s7,'time(s)')

curr=findobj('type','figure','Name','Edges time avg T4 combined');
all_ax_fig2 = findall(curr,'type','axes');
all_children_ax_fig2 = get(all_ax_fig2,'children');

copyobj(all_children_ax_fig2{7},s3);
s3.XLim=all_ax_fig2(7).XLim;
s3.YLim=all_ax_fig2(7).YLim;
view(s3,90,-90)
s3.XTick=[];
ylabel(s3,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig2{6},s8);
s8.XLim=all_ax_fig2(6).XLim;
s8.YLim=all_ax_fig2(6).YLim;
view(s8,90,-90)
s8.XTick=[];
ylabel(s8,'^{\Delta F}/_{F}')

curr=findobj('type','figure','Name','Edges T5 combined');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children');

copyobj(all_children_ax_fig1{7},s4);
s4.XLim=all_ax_fig1(7).XLim;
s4.YLim=all_ax_fig1(7).YLim;
s4.Colormap=all_ax_fig1(7).Colormap;
s4.YDir='reverse';
s4.CLim=all_ax_fig1(7).CLim;
s4.YTick=[];
colorbar(s4)
xlabel(s4,'time(s)')
title(s4,'T5','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{6},s9);
s9.XLim=all_ax_fig1(6).XLim;
s9.YLim=all_ax_fig1(6).YLim;
s9.Colormap=all_ax_fig1(6).Colormap;
s9.YDir='reverse';
s9.CLim=all_ax_fig1(6).CLim;
s9.YTick=[];
colorbar(s9)
xlabel(s9,'time(s)')

curr=findobj('type','figure','Name','Edges time avg T5 combined');
all_ax_fig2 = findall(curr,'type','axes');
all_children_ax_fig2 = get(all_ax_fig2,'children');

copyobj(all_children_ax_fig2{6},s5);
s5.XLim=all_ax_fig2(6).XLim;
s5.YLim=all_ax_fig2(6).YLim;
view(s5,90,-90)
s5.XTick=[];
ylabel(s5,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig2{7},s10);
s10.XLim=all_ax_fig2(7).XLim;
s10.YLim=all_ax_fig2(7).YLim;
view(s10,90,-90)
s10.XTick=[];
ylabel(s10,'^{\Delta F}/_{F}')

closeAllExceptIllusionPaperFigures()
