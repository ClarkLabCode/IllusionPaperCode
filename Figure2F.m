function Figure2F(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 2F of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4P responses, 2-T4R
% responses, 3-T5P responses, 4-T5R responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

cellTypes={'T4P','T4R','T5P','T5R'};
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
            'crossValidateCentRF',0,...
            'figureName', cellTypes{k},...
            'iteration',k);
    end
end

%% 4 - Organize figure

MakeFigure('Name','Figure 2F','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;

s1 = subplot(1,12,1); % stimulus
s2 = subplot(1,12,2); % T4P response xt plot
s3 = subplot(1,12,3); % T4P response time averaged
s4 = subplot(1,12,4); % stimulus
s5 = subplot(1,12,5); % T4R response xt plot
s6 = subplot(1,12,6); % T4R response time averaged
s7 = subplot(1,12,7); % stimulus
s8 = subplot(1,12,8); % T5P response xt plot
s9 = subplot(1,12,9); % T5P response time averaged
s10 = subplot(1,12,10); % stimulus
s11 = subplot(1,12,11); % T5R response xt plot
s12 = subplot(1,12,12); % T5R response time averaged

curr=findobj('type','figure','Name','Edges T4P');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{5},s1); %copy children to new parent axes i.e. the subplot axes
s1.XLim=all_ax_fig1(5).XLim;
s1.YLim=all_ax_fig1(5).YLim;
s1.YTick=[-numPhases/2 0 numPhases/2];
s1.YTickLabel=linspace(0,2*numPhases,length(s1.YTick))*barWidth;
colormap(s1,'gray')
ylabel(s1,{'offset from', 'RF center (deg)'})
xlabel(s1,'time(s)')
title(s1,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{10},s2); %copy children to new parent axes i.e. the subplot axes
s2.XLim=all_ax_fig1(10).XLim;
s2.YLim=all_ax_fig1(10).YLim;
s2.Colormap=all_ax_fig1(10).Colormap;
s2.YDir='reverse';
s2.CLim=all_ax_fig1(10).CLim;
s2.YTick=[];
colorbar(s2);
xlabel(s2,'time(s)')
title(s2,'T4P','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges T4R');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{5},s4); %copy children to new parent axes i.e. the subplot axes
s4.XLim=all_ax_fig1(5).XLim;
s4.YLim=all_ax_fig1(5).YLim;
s4.YTick=[-numPhases/2 0 numPhases/2];
s4.YTickLabel=linspace(0,2*numPhases,length(s4.YTick))*barWidth;
colormap(s4,'gray')
xlabel(s4,'time(s)')
title(s4,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{10},s5); %copy children to new parent axes i.e. the subplot axes
s5.XLim=all_ax_fig1(10).XLim;
s5.YLim=all_ax_fig1(10).YLim;
s5.Colormap=all_ax_fig1(10).Colormap;
s5.YDir='reverse';
s5.CLim=all_ax_fig1(10).CLim;
colorbar(s5);
s5.YTick=[];
xlabel(s5,'time(s)')
title(s5,'T4R','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges T5P');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{5},s7); %copy children to new parent axes i.e. the subplot axes
s7.XLim=all_ax_fig1(5).XLim;
s7.YLim=all_ax_fig1(5).YLim;
s7.YTick=[-numPhases/2 0 numPhases/2];
s7.YTickLabel=linspace(0,2*numPhases,length(s7.YTick))*barWidth;
colormap(s7,'gray')
xlabel(s7,'time(s)')
title(s7,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{10},s8); %copy children to new parent axes i.e. the subplot axes
s8.XLim=all_ax_fig1(10).XLim;
s8.YLim=all_ax_fig1(10).YLim;
s8.Colormap=all_ax_fig1(10).Colormap;
s8.YDir='reverse';
s8.CLim=all_ax_fig1(10).CLim;
s8.YTick=[];
colorbar(s8);
xlabel(s8,'time(s)')
title(s8,'T5P','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges T5R');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{5},s10); %copy children to new parent axes i.e. the subplot axes
s10.XLim=all_ax_fig1(5).XLim;
s10.YLim=all_ax_fig1(5).YLim;
s10.YTick=[-numPhases/2 0 numPhases/2];
s10.YTickLabel=linspace(0,2*numPhases,length(s10.YTick))*barWidth;
colormap(s10,'gray')
xlabel(s10,'time(s)')
title(s10,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{10},s11); %copy children to new parent axes i.e. the subplot axes
s11.XLim=all_ax_fig1(10).XLim;
s11.YLim=all_ax_fig1(10).YLim;
s11.Colormap=all_ax_fig1(10).Colormap;
s11.YDir='reverse';
s11.CLim=all_ax_fig1(10).CLim;
s11.YTick=[];
colorbar(s11);
xlabel(s11,'time(s)')
title(s11,'T5R','FontSize',12,'FontWeight','bold')

% time tracees

curr=findobj('type','figure','Name','Edges time avg T4P');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig5{10},s3); %copy children to new parent axes i.e. the subplot axes
s3.XLim=all_ax_fig5(10).XLim;
s3.YLim=all_ax_fig5(10).YLim;
s3.XTick=[];
view(s3,90, -90)
ylabel(s3,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T4R');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig5{10},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig5(10).XLim;
s6.YLim=all_ax_fig5(10).YLim;
s6.XTick=[];
view(s6,90, -90)
ylabel(s6,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T5P');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig5{10},s9); %copy children to new parent axes i.e. the subplot axes
s9.XLim=all_ax_fig5(10).XLim;
s9.YLim=all_ax_fig5(10).YLim;
s9.XTick=[];
view(s9,90, -90)
ylabel(s9,'^{\Delta f}/_{f}')

curr=findobj('type','figure','Name','Edges time avg T5R');
all_ax_fig5 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig5 = get(all_ax_fig5,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig5{10},s12); %copy children to new parent axes i.e. the subplot axes
s12.XLim=all_ax_fig5(10).XLim;
s12.YLim=all_ax_fig5(10).YLim;
s12.XTick=[];
view(s12,90, -90)
ylabel(s12,'^{\Delta f}/_{f}')

closeAllExceptIllusionPaperFigures()