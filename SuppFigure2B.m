function SuppFigure2B(flyResp,stimulusInfo,natImageProjection,general_parameters)
% This function plots the data in Supp Figure 2B of Agrochao, Tanaka et al.
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
        
        output.analysis{1,k}= NaturalImageRoiAnalysis(...
            currFly,currEpochs,currParams,...
            general_parameters.dataRateImaging,...
            'epochsForSelectivity', stimulusInfo.epochsForSelectivity,...
            'epochsForSelection',currEpochsForSelection,...
            'flyEyes',currEyes,...
            'figureName', cellTypes{k},...
            'iteration',k,...
            'natImageProjection',natImageProjection);
    end
end

%% 2 - Organize figure

MakeFigure('Name','SuppFigure 2B','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;

s1 = subplot(1,12,1); % stimulus
s2 = subplot(1,12,2:3); % T4a response xt plot
s3 = subplot(1,12,4:5); % T4b response xt plot
s4 = subplot(1,12,6:7); % T5a response xt plot
s5 = subplot(1,12,8:9); % T5b response xt plot
s6 = subplot(1,12,10:12); % time traces all cell types

curr=findobj('type','figure','Name','Natural T4a');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{1},s1); %copy children to new parent axes i.e. the subplot axes
s1.XLim=all_ax_fig1(1).XLim;
s1.YLim=all_ax_fig1(1).YLim;
s1.YTick=[-numPhases/2 0 numPhases/2];
s1.YTickLabel=linspace(0,2*numPhases,length(s1.YTick))*barWidth;
colormap(s1,'gray')
ylabel(s1,'stimulus position (deg)')
xlabel(s1,'time(s)')
title(s1,'stimulus','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{3},s2); %copy children to new parent axes i.e. the subplot axes
s2.XLim=all_ax_fig1(3).XLim;
s2.YLim=all_ax_fig1(3).YLim;
colormap(s2,colormap(all_ax_fig1(3)));
s2.CLim=all_ax_fig1(3).CLim;
s2.YTick=[];
colorbar(s2);
xlabel(s2,'time(s)')
title(s2,'T4a','FontSize',12,'FontWeight','bold')

l=findobj(all_children_ax_fig1{2},'Type','Line');
l.Color=[0 0 0];
p=findobj(all_children_ax_fig1{2},'Type','Patch');
p.FaceColor=[0 0 0];
copyobj(all_children_ax_fig1{2},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig1(2).XLim;
s6.YLim=all_ax_fig1(2).YLim;
s6.XTick=[];
view(s6,90, -90)
ylabel(s6,'^{\Delta f}/_{f}')
hold(s6,'on')

curr=findobj('type','figure','Name','Natural T4b');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{3},s3); %copy children to new parent axes i.e. the subplot axes
s3.XLim=all_ax_fig1(3).XLim;
s3.YLim=all_ax_fig1(3).YLim;
colormap(s3,colormap(all_ax_fig1(3)));
s3.CLim=all_ax_fig1(3).CLim;
colorbar(s3);
s3.YTick=[];
xlabel(s3,'time(s)')
title(s3,'T4b','FontSize',12,'FontWeight','bold')

l=findobj(all_children_ax_fig1{2},'Type','Line');
l.Color=[1 0 0];
p=findobj(all_children_ax_fig1{2},'Type','Patch');
p.FaceColor=[1 0 0];

copyobj(all_children_ax_fig1{2},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig1(2).XLim;
s6.YLim=all_ax_fig1(2).YLim;
s6.XTick=[];
ylabel(s6,'^{\Delta f}/_{f}')
hold(s6,'on')

curr=findobj('type','figure','Name','Natural T5a');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{3},s4); %copy children to new parent axes i.e. the subplot axes
s4.XLim=all_ax_fig1(3).XLim;
s4.YLim=all_ax_fig1(3).YLim;
colormap(s4,colormap(all_ax_fig1(3)));
s4.CLim=all_ax_fig1(3).CLim;
s4.YTick=[];
colorbar(s4);
xlabel(s4,'time(s)')
title(s4,'T5a','FontSize',12,'FontWeight','bold')

l=findobj(all_children_ax_fig1{2},'Type','Line');
l.Color=[0 1 0];
p=findobj(all_children_ax_fig1{2},'Type','Patch');
p.FaceColor=[0 1 0];
copyobj(all_children_ax_fig1{2},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig1(2).XLim;
s6.YLim=all_ax_fig1(2).YLim;
s6.XTick=[];
ylabel(s6,'^{\Delta f}/_{f}')
hold(s6,'on')

curr=findobj('type','figure','Name','Natural T5b');
all_ax_fig1 = findall(curr,'type','axes'); % get handle to axes of figure
all_children_ax_fig1 = get(all_ax_fig1,'children'); %get handle to all the children in the figure

copyobj(all_children_ax_fig1{3},s5); %copy children to new parent axes i.e. the subplot axes
s5.XLim=all_ax_fig1(3).XLim;
s5.YLim=all_ax_fig1(3).YLim;
colormap(s5,colormap(all_ax_fig1(3)));
s5.CLim=all_ax_fig1(3).CLim;
s5.YTick=[];
colorbar(s5);
xlabel(s5,'time(s)')
title(s5,'T5b','FontSize',12,'FontWeight','bold')

l=findobj(all_children_ax_fig1{2},'Type','Line');
l.Color=[0 0 1];
p=findobj(all_children_ax_fig1{2},'Type','Patch');
p.FaceColor=[0 0 1];
copyobj(all_children_ax_fig1{2},s6); %copy children to new parent axes i.e. the subplot axes
s6.XLim=all_ax_fig1(2).XLim;
s6.YLim=all_ax_fig1(2).YLim;
s6.XTick=[];
ylabel(s6,'^{\Delta f}/_{f}')
hold(s6,'on')
a=legend(cellTypes);
a.Position=a.Position+[0.01 0 0 0];

close(findobj('type','figure','visibility', 'off'))