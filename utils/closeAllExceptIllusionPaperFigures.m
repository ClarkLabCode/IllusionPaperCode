function closeAllExceptIllusionPaperFigures()

all_figs = findobj(0, 'type', 'figure');
for j=1:length(all_figs)
    if ~(contains(all_figs(j).Name,'Figure ') || contains(all_figs(j).Name,'SuppFigure '))
        close(all_figs(j))
    end
end