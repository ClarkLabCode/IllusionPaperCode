function Figure3A(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 3A of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4a responses, 2-T4b
% responses, 3-T5a responses, 4-T5b responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

repeatSection = 1;
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
            'iteration',k,...
            'repeatSection',repeatSection);
    end
end

stimuli={'+0 Edge', '-0 Edge'};
combineProgressiveAndRegressive(output,stimuli,general_parameters,repeatSection)

stimuli={'-0 Edge','-0 Edge'};
cellTypes={'T4 combined','T5 combined'};
setLims(cellTypes,stimuli)

MakeFigure('Name','Figure 3A','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;

s1 = subplot(2,6,1); % stimulus black gray
s2 = subplot(2,6,2); % T4 response xt plot
s3 = subplot(2,6,3); % T4 response time averaged
s4 = subplot(2,6,4); % stimulus black gray
s5 = subplot(2,6,5); % T5 response xt plot
s6 = subplot(2,6,6); % T5 response time averaged
s7 = subplot(2,6,7); % stimulus white gray
s8 = subplot(2,6,8); % T4 response xt plot
s9 = subplot(2,6,9); % T4 response time averaged
s10 = subplot(2,6,10); % stimulus white gray
s11 = subplot(2,6,11); % T5 response xt plot
s12 = subplot(2,6,12); % T5 response time averaged

curr=findobj('type','figure','Name','Edges T4 combined');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 

copyobj(all_children_ax_fig1{4},s1); 
s1.XLim=all_ax_fig1(4).XLim;
s1.YLim=all_ax_fig1(4).YLim;
s1.YTick=[-numPhases/2 0 numPhases/2];
s1.YTickLabel=linspace(0,2*numPhases,length(s1.YTick))*barWidth;
colormap(s1,'gray')
ylabel(s1,{'offset from', 'RF center (deg)'})
xlabel(s1,'time(s)')
title(s1,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s2);
s2.XLim=all_ax_fig1(9).XLim;
s2.YLim=all_ax_fig1(9).YLim;
colormap(s2,colormap(all_ax_fig1(9)));
s2.YDir='reverse';
s2.CLim=all_ax_fig1(9).CLim;
s2.YTick=[];
colorbar(s2);
xlabel(s2,'time(s)')
title(s2,'T4','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{3},s7);
s7.XLim=all_ax_fig1(3).XLim;
s7.YLim=all_ax_fig1(3).YLim;
s7.YTick=[-numPhases/2 0 numPhases/2];
s7.YTickLabel=linspace(0,2*numPhases,length(s7.YTick))*barWidth;
colormap(s7,'gray')
ylabel(s7,{'offset from', 'RF center (deg)'})
xlabel(s7,'time(s)')
title(s7,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s8);
s8.XLim=all_ax_fig1(8).XLim;
s8.YLim=all_ax_fig1(8).YLim;
colormap(s8,colormap(all_ax_fig1(8)));
s8.YDir='reverse';
s8.CLim=all_ax_fig1(8).CLim;
s8.YTick=[];
colorbar(s8);
xlabel(s8,'time(s)')
title(s8,'T4','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges T5 combined');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children');

copyobj(all_children_ax_fig1{3},s4);
s4.XLim=all_ax_fig1(3).XLim;
s4.YLim=all_ax_fig1(3).YLim;
s4.YTick=[-numPhases/2 0 numPhases/2];
s4.YTickLabel=linspace(0,2*numPhases,length(s4.YTick))*barWidth;
colormap(s4,'gray')
ylabel(s4,{'offset from', 'RF center (deg)'})
xlabel(s4,'time(s)')
title(s4,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{8},s5);
s5.XLim=all_ax_fig1(8).XLim;
s5.YLim=all_ax_fig1(8).YLim;
colormap(s5,colormap(all_ax_fig1(8)));
s5.YDir='reverse';
s5.CLim=all_ax_fig1(8).CLim;
s5.YTick=[];
colorbar(s5);
xlabel(s5,'time(s)')
title(s5,'T5','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{4},s10);
s10.XLim=all_ax_fig1(4).XLim;
s10.YLim=all_ax_fig1(4).YLim;
s10.YTick=[-numPhases/2 0 numPhases/2];
s10.YTickLabel=linspace(0,2*numPhases,length(s10.YTick))*barWidth;
colormap(s10,'gray')
ylabel(s10,{'offset from', 'RF center (deg)'})
xlabel(s10,'time(s)')
title(s10,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{9},s11);
s11.XLim=all_ax_fig1(9).XLim;
s11.YLim=all_ax_fig1(9).YLim;
colormap(s11,colormap(all_ax_fig1(9)));
s11.YDir='reverse';
s11.CLim=all_ax_fig1(9).CLim;
s11.YTick=[];
colorbar(s11);
xlabel(s11,'time(s)')
title(s11,'T5','FontSize',12,'FontWeight','bold')


curr=findobj('type','figure','Name','Edges time avg T4 combined');
all_ax_fig5 = findall(curr,'type','axes');
all_children_ax_fig5 = get(all_ax_fig5,'children');

copyobj(all_children_ax_fig5{9},s3);
s3.XLim=all_ax_fig5(9).XLim;
s3.YLim=all_ax_fig5(9).YLim;
s3.XTick=[];
view(s3,90, -90)
ylabel(s3,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig5{8},s9);
s9.XLim=all_ax_fig5(8).XLim;
s9.YLim=all_ax_fig5(8).YLim;
s9.XTick=[];
view(s9,90, -90)
ylabel(s9,'^{\Delta F}/_{F}')

curr=findobj('type','figure','Name','Edges time avg T5 combined');
all_ax_fig5 = findall(curr,'type','axes');
all_children_ax_fig5 = get(all_ax_fig5,'children'); 

copyobj(all_children_ax_fig5{8},s6); 
s6.XLim=all_ax_fig5(8).XLim;
s6.YLim=all_ax_fig5(8).YLim;
s6.XTick=[];
view(s6,90, -90)
ylabel(s6,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig5{9},s12);
s12.XLim=all_ax_fig5(9).XLim;
s12.YLim=all_ax_fig5(9).YLim;
s12.XTick=[];
view(s12,90, -90)
ylabel(s12,'^{\Delta F}/_{F}')

closeAllExceptIllusionPaperFigures()