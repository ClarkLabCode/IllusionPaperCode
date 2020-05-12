function Figure2E(flyResp,stimulusInfo,general_parameters)
% This function plots the data in Figure 2E of Agrochao, Tanaka et al.
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
            'crossValidateCentRF',0,...
            'figureName', cellTypes{k},...
            'iteration',k);
    end
end

%% set all color limits to the color limits of gradients (for each cell type)

targetList={'Grad Up Prog','Grad Up Reg','Grad Up Reg','Grad Up Prog'};
setLims(cellTypes,targetList)

%% Build figure to be imported to illustrator

MakeFigure('Name','Figure 2E','NumberTitle','off');

numPhases={stimulusInfo.params{1}.phase};
numPhases=max(cell2mat(cellfun(@(x) max(x),numPhases,'UniformOutput',false)))+1;
barWidth=stimulusInfo.params{1}(46).barWd;
 
s1 = subplot(2,12,1); % stim
s2 = subplot(2,12,2); % T4 response to white bar xt plot
s3 = subplot(2,12,3); % T4 response to white bar time averaged
s4 = subplot(2,12,4); % stim
s5 = subplot(2,12,5); % T4 response to black bar xt plot
s6 = subplot(2,12,6); % T4 response to black bar time averaged
s7 = subplot(2,12,7); % stim
s8 = subplot(2,12,8); % T4 response to black bar time averaged
s9 = subplot(2,12,9); % T4 response to black bar time averaged
s10 = subplot(2,12,10); % stim
s11 = subplot(2,12,11); % white bar
s12 = subplot(2,12,12); % T4 response to white bar xt plot
s13 = subplot(2,12,13); % T4 response to white bar time averaged
s14 = subplot(2,12,14); % stim
s15 = subplot(2,12,15); % T4 response to black bar xt plot
s16 = subplot(2,12,16); % T4 response to black bar time averaged
s17 = subplot(2,12,17); % stim
s18 = subplot(2,12,18); % T4 response to black bar time averaged
s19 = subplot(2,12,19); % T4 response to white bar time averaged
s20 = subplot(2,12,20); % stim
s21 = subplot(2,12,21); % T4 response to black bar xt plot
s22 = subplot(2,12,22); % T4 response to black bar time averaged
s23 = subplot(2,12,23); % stim
s24 = subplot(2,12,24); % T4 response to black bar time averaged

curr=findobj('type','figure','Name','Edges T4a');
all_ax_fig1 = findall(curr,'type','axes');
all_children_ax_fig1 = get(all_ax_fig1,'children'); 

copyobj(all_children_ax_fig1{4},s1);
s1.XLim=all_ax_fig1(4).XLim;
s1.YLim=all_ax_fig1(4).YLim;
s1.YTick=[-numPhases/2 0 numPhases/2];
s1.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s1,'gray')
ylabel(s1,{'stimulus','location (deg)'})
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
title(s2,'T4a','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig1{3},s13); 
s13.XLim=all_ax_fig1(3).XLim;
s13.YLim=all_ax_fig1(3).YLim;
s13.YTick=[-numPhases/2 0 numPhases/2];
s13.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s13,'gray')
ylabel(s13,{'stimulus','location (deg)'})
xlabel(s13,'time(s)')

copyobj(all_children_ax_fig1{8},s14); 
s14.XLim=all_ax_fig1(8).XLim;
s14.YLim=all_ax_fig1(8).YLim;
colormap(s14,colormap(all_ax_fig1(8)));
s14.YDir='reverse';
s14.CLim=all_ax_fig1(8).CLim;
s14.YTick=[];
colorbar(s14);
xlabel(s14,'time(s)')



curr=findobj('type','figure','Name','Edges T4b');
all_ax_fig2 = findall(curr,'type','axes');
all_children_ax_fig2 = get(all_ax_fig2,'children');
copyobj(all_children_ax_fig2{4},s4); 
s4.XLim=all_ax_fig2(4).XLim;
s4.YLim=all_ax_fig2(4).YLim;
s4.YTick=[-numPhases/2 0 numPhases/2];
s4.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s4,'gray')
xlabel(s4,'time(s)')

copyobj(all_children_ax_fig2{9},s5); 
s5.XLim=all_ax_fig2(9).XLim;
s5.YLim=all_ax_fig2(9).YLim;
colormap(s5,colormap(all_ax_fig2(9)));
s5.YDir='reverse';
s5.CLim=all_ax_fig2(9).CLim;
s5.YTick=[];
colorbar(s5);
xlabel(s5,'time(s)')
title(s5,'T4b','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig2{3},s16); 
s16.XLim=all_ax_fig2(3).XLim;
s16.YLim=all_ax_fig2(3).YLim;
s16.YTick=[-numPhases/2 0 numPhases/2];
s16.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s16,'gray')
xlabel(s16,'time(s)')

copyobj(all_children_ax_fig2{8},s17); 
s17.XLim=all_ax_fig2(8).XLim;
s17.YLim=all_ax_fig2(8).YLim;
colormap(s17,colormap(all_ax_fig2(8)));
s17.YDir='reverse';
s17.CLim=all_ax_fig2(8).CLim;
s17.YTick=[];
colorbar(s17);
xlabel(s17,'time(s)')



curr=findobj('type','figure','Name','Edges T5a');
all_ax_fig3 = findall(curr,'type','axes');
all_children_ax_fig3 = get(all_ax_fig3,'children'); 

copyobj(all_children_ax_fig3{4},s7); 
s7.XLim=all_ax_fig3(4).XLim;
s7.YLim=all_ax_fig3(4).YLim;
s7.YTick=[-numPhases/2 0 numPhases/2];
s7.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s7,'gray')
xlabel(s7,'time(s)')

copyobj(all_children_ax_fig3{9},s8); 
s8.XLim=all_ax_fig3(9).XLim;
s8.YLim=all_ax_fig3(9).YLim;
colormap(s8,colormap(all_ax_fig3(9)));
s8.YDir='reverse';
s8.CLim=all_ax_fig3(9).CLim;
s8.YTick=[];
colorbar(s8);
xlabel(s8,'time(s)')
title(s8,'T5a','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig3{3},s19); 
s19.XLim=all_ax_fig3(3).XLim;
s19.YLim=all_ax_fig3(3).YLim;
s19.YTick=[-numPhases/2 0 numPhases/2];
s19.YTickLabel=linspace(0,2*numPhases,length(s19.YTick))*barWidth;
colormap(s19,'gray')
xlabel(s19,'time(s)')

copyobj(all_children_ax_fig3{8},s20); 
s20.XLim=all_ax_fig3(8).XLim;
s20.YLim=all_ax_fig3(8).YLim;
colormap(s20,colormap(all_ax_fig3(8)));
s20.YDir='reverse';
s20.CLim=all_ax_fig3(8).CLim;
s20.YTick=[];
colorbar(s20);
xlabel(s20,'time(s)')



curr=findobj('type','figure','Name','Edges T5b');
all_ax_fig4 = findall(curr,'type','axes');
all_children_ax_fig4 = get(all_ax_fig4,'children'); 

copyobj(all_children_ax_fig4{4},s10); 
s10.XLim=all_ax_fig4(4).XLim;
s10.YLim=all_ax_fig4(4).YLim;
s10.YTick=[-numPhases/2 0 numPhases/2];
s10.YTickLabel=linspace(0,2*numPhases,length(s10.YTick))*barWidth;
colormap(s10,'gray')
xlabel(s10,'time(s)')

copyobj(all_children_ax_fig4{9},s11);
s11.XLim=all_ax_fig4(9).XLim;
s11.YLim=all_ax_fig4(9).YLim;
colormap(s11,colormap(all_ax_fig4(9)));
s11.YDir='reverse';
s11.CLim=all_ax_fig4(9).CLim;
s11.YTick=[];
colorbar(s11);
xlabel(s11,'time(s)')
title(s11,'T5b','FontSize',12,'FontWeight','bold')

copyobj(all_children_ax_fig4{3},s22);
s22.XLim=all_ax_fig4(3).XLim;
s22.YLim=all_ax_fig4(3).YLim;
s22.YTick=[-numPhases/2 0 numPhases/2];
s22.YTickLabel=linspace(0,2*numPhases,3)*barWidth;
colormap(s22,'gray')
xlabel(s22,'time(s)')

copyobj(all_children_ax_fig4{8},s23); 
s23.XLim=all_ax_fig4(8).XLim;
s23.YLim=all_ax_fig4(8).YLim;
colormap(s23,colormap(all_ax_fig4(8)));
s23.YDir='reverse';
s23.CLim=all_ax_fig4(8).CLim;
s23.YTick=[];
colorbar(s23);
xlabel(s23,'time(s)')


% TIME AVERAGES
curr=findobj('type','figure','Name','Edges time avg T4a');
all_ax_fig5 = findall(curr,'type','axes'); 
all_children_ax_fig5 = get(all_ax_fig5,'children');

copyobj(all_children_ax_fig5{9},s3); 
s3.XLim=all_ax_fig5(9).XLim;
s3.YLim=all_ax_fig5(9).YLim;
s3.XTick=[];
view(s3,90, -90)
ylabel(s3,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig5{8},s15); 
s15.XLim=all_ax_fig5(8).XLim;
s15.YLim=all_ax_fig5(8).YLim;
s15.XTick=[];
view(s15,90, -90)
ylabel(s15,'^{\Delta F}/_{F}')

curr=findobj('type','figure','Name','Edges time avg T4b');
all_ax_fig6 = findall(curr,'type','axes'); 
all_children_ax_fig6 = get(all_ax_fig6,'children');
copyobj(all_children_ax_fig6{9},s6); 
s6.XLim=all_ax_fig6(9).XLim;
s6.YLim=all_ax_fig6(9).YLim;
s6.XTick=[];
view(s6,90, -90)
ylabel(s6,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig6{8},s18); s
s18.XLim=all_ax_fig6(8).XLim;
s18.YLim=all_ax_fig6(8).YLim;
s18.XTick=[];
view(s18,90, -90)
ylabel(s18,'^{\Delta F}/_{F}')

curr=findobj('type','figure','Name','Edges time avg T5a');
all_ax_fig7 = findall(curr,'type','axes');
all_children_ax_fig7 = get(all_ax_fig7,'children'); 

copyobj(all_children_ax_fig7{9},s9);
s9.XLim=all_ax_fig7(9).XLim;
s9.YLim=all_ax_fig7(9).YLim;
s9.XTick=[];
view(s9,90, -90)
ylabel(s9,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig7{8},s21);
s21.XLim=all_ax_fig7(8).XLim;
s21.YLim=all_ax_fig7(8).YLim;
s21.XTick=[];
view(s21,90, -90)
ylabel(s21,'^{\Delta F}/_{F}')

curr=findobj('type','figure','Name','Edges time avg T5b');
all_ax_fig8 = findall(curr,'type','axes'); 
all_children_ax_fig8 = get(all_ax_fig8,'children'); 

copyobj(all_children_ax_fig8{9},s12);
s12.XLim=all_ax_fig8(9).XLim;
s12.YLim=all_ax_fig8(9).YLim;
s12.XTick=[];
view(s12,90, -90)
ylabel(s12,'^{\Delta F}/_{F}')

copyobj(all_children_ax_fig8{8},s24);
s24.XLim=all_ax_fig8(8).XLim;
s24.YLim=all_ax_fig8(8).YLim;
s24.XTick=[];
view(s24,90, -90)
ylabel(s24,'^{\Delta F}/_{F}')

closeAllExceptIllusionPaperFigures()