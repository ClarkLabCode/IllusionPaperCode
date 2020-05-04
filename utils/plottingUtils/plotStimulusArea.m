function plotStimulusArea(xrange,yrange,varargin)
if nargin<2 
    yrange = get(gca,'YLim');
elseif isempty(yrange)
    yrange = get(gca,'YLim');
end

color = ones(3,1)/2;
alpha = 0.25;
for ii = 1:length(varargin)/2
    eval([varargin{2*ii-1},'=',varargin{2*ii}]);
end

h = area(xrange,[yrange(2),yrange(2)],yrange(1),'FaceColor',color,'FaceAlpha',alpha,'LineStyle','none');
hAnnotation = get(h,'Annotation');
hLegendEntry = get(hAnnotation,'LegendInformation');
set(hLegendEntry,'IconDisplayStyle','off');
end