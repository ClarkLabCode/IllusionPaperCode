function Figure2B(flyResp,stimulusInfo)
% This function plots the data in Figure 2B of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

% The input flyResp has dimensions (number of cell types x number of flies
% in dataset). Rows of flyResp are as follows: 1-T4P responses, 2-T4R
% responses, 3-T5P responses, 4-T5R responses. Empty cells in flyResp mean
% that no responses of a given cell type were recorded.

cellTypes={'T4P','T4R','T5P','T5R'};

stimsToPlot{1}='Right Light Edge';
stimsToPlot{2}='Left Light Edge';
stimsToPlot{3}='Right Dark Edge';
stimsToPlot{4}='Left Dark Edge';

output=cell(1,length(cellTypes));
for k=1:length(cellTypes)
    nonResponsiveFlies = cellfun('isempty', flyResp(k, :));
    currFly=flyResp(k,~nonResponsiveFlies);
    if ~isempty(currFly)
        currEpochs=stimulusInfo.epochs(k,~nonResponsiveFlies);
        currParams=stimulusInfo.params(k,~nonResponsiveFlies);
        
        output{k}= PlotResponsesToEdges(...
            currFly,currEpochs,currParams,cellTypes{k},...
            stimsToPlot);
    end
end

MakeFigure('Name','Figure 2B' ,'NumberTitle','off')

s1=subplot(1,4,1);
s2=subplot(1,4,2);
s3=subplot(1,4,3);
s4=subplot(1,4,4);

curr=findobj('type','figure','Name','fly 10 T4P ROIs');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 
copyobj(all_children_ax_fig1{6},s1);
axis(s1,'tight')
xlabel(s1,'time (s)')
ylabel(s1,'^{\Delta f}/_{f}')
title(s1,'example T4a ROI')

curr=findobj('type','figure','Name','fly 8 T4R ROIs');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 
copyobj(all_children_ax_fig1{3},s2); 
axis(s2,'tight')
xlabel(s2,'time (s)')
ylabel(s2,'^{\Delta f}/_{f}')
title(s2,'example T4b ROI')

curr=findobj('type','figure','Name','fly 7 T5P ROIs');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 
copyobj(all_children_ax_fig1{3},s3);
axis(s3,'tight')
xlabel(s3,'time (s)')
ylabel(s3,'^{\Delta f}/_{f}')
title(s3,'example T5a ROI')

curr=findobj('type','figure','Name','fly 6 T5R ROIs');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 
copyobj(all_children_ax_fig1{5},s4);
axis(s4,'tight')
xlabel(s4,'time (s)')
ylabel(s4,'^{\Delta f}/_{f}')
title(s4,'example T5b ROI')
a=legend(stimsToPlot);
a.Position=a.Position+[0.01 0 0 0];

closeAllExceptIllusionPaperFigures()
