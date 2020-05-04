function SuppFigure1(data)
% This function plots the data in Supp Figure 1 of Agrochao, Tanaka et al.
% (2020) Mechanism for analogous illusory motion perception in flies and
% humans. margarida.agrochao@yale.edu

numFlies=length(data);
bothGrads=zeros(length(data{1}.p6_averagedTrials.snipMat)/2,numFlies);
for fly=1:numFlies
    curr=data{fly}.p6_averagedTrials.snipMat;
    grad1=curr(1:2:end); %ramp up
    grad2=curr(2:2:end); %ramp down
    grad1TimeAvg=cellfun(@(p) mean(p(:,:,1),1),grad1,'UniformOutput',false); %time avg
    grad2TimeAvg=cellfun(@(p) mean(p(:,:,1),1),grad2,'UniformOutput',false); % time avg
    grad1TimeAvg=cell2mat(grad1TimeAvg);
    grad2TimeAvg=cell2mat(grad2TimeAvg);
    bothGrads(:,fly)=mean([grad1TimeAvg,-(flipud(grad2TimeAvg))],2); % combine ramps
end

% speed of stimuli tested (deg/s)
x=[-6 -4 -2 0 2 4 6];

%average across flies
y=mean(bothGrads,2); 


% fit a line to data
beta=nlinfit(x,y,@(a,x) (a(1)+a(2)*x)', [0 0]);

% find x intersect: motion nulling velocity
mn=-beta(1)/beta(2);

% estimating the confidence intervals of the x intercept with bootstraping.

rng default
nboot=1000;
x_intercepts=zeros(nboot,1);
for k=1:nboot
    idx=randi(numFlies,numFlies,1);
    newData=bothGrads(:,idx);
    newY(:,k)=mean(newData,2);
    newBetas=nlinfit(x,newY(:,k),@(b,x) (b(1)+b(2)*x)', [0 0]);
    hold on
    %plot(x',newBetas(1)+newBetas(2)*x','LineWidth',1,'Color',[0,0,0,0.01]);
    x_intercepts(k)=-newBetas(1)/newBetas(2);
end

% Nonparametric confidence interval (68%) for x intersect 
CI_percent=68;
x_intercept_sorted=sort(x_intercepts);
alpha=(1-(CI_percent/100))/2;
lower_bound=round((alpha/2)*nboot);
upper_bound=round((1-(alpha/2))*nboot);
CI_lower=x_intercept_sorted(lower_bound);
CI_upper=x_intercept_sorted(upper_bound);

MakeFigure('Name','SuppFigure 1','NumberTitle','off')

PlotXvsY(x',y,'error',NanSem(bothGrads,2),'MarkerType','o','color',[1 0 0]);
xticks(x)
xticklabels(x)
line([x(1) x(end)],[0 0],'Color','k','LineStyle','--','LineWidth',1.5)
xlabel(['velocity of sawtooth (' char(176) '/s)'])
ylabel(['turning (' char(176) '/s)']);
hold on

PlotXvsY(x',beta(1)+beta(2)*x','error',[],'LineWidth',2,'color',[0 1 0])
title(['motion nulling velocity: ' num2str(mn),...
    ' 68% CI [' num2str(CI_lower) ' ' num2str(CI_upper) '] deg/s'])

axis tight

closeAllExceptIllusionPaperFigures()