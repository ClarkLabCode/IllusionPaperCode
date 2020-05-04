function setLims(cellTypeList,targetList)

allFigures=findobj('Type','Figure');

for k=1:length(cellTypeList)
    currCellType=cellTypeList{k};
    currTarget=targetList{k};
    
    for f=1:length(allFigures)
        if strcmpi(allFigures(f).Name,['Edges ' currCellType])
            idxFigsIm=f;
        elseif strcmpi(allFigures(f).Name,['Edges time avg ' currCellType])
            idxFigsTrace=f;
        end       
    end

    currFigIm=allFigures(idxFigsIm);
    allAxesIm=findall(currFigIm,'type','axes');
    
    currFigTrace=allFigures(idxFigsTrace);
    allAxesTrace=findall(currFigTrace,'type','axes');
    
    for ax=1:length(allAxesIm)
        if strcmpi(allAxesIm(ax).Title.String,currTarget)
            idxFigsIm=ax;
        end
    end
    
    for ax=1:length(allAxesTrace)
        if strcmp(allAxesTrace(ax).Title.String,currTarget)
            idxAxesTrace=ax;
        end
    end
    
    currAxesIm=allAxesIm(idxFigsIm);
    im=findobj(currAxesIm,'type','Image');
    max_im=max(im.CData(:));
    min_im=min(im.CData(:));
    
    currAxesTrace=allAxesTrace(idxAxesTrace);
    traceLims= currAxesTrace.YLim;
    
    for s=1:length(allAxesIm)
        if ~isempty(allAxesIm(s).Title.String)
            allAxesIm(s).Parent.Colormap=b2r(min_im,max_im);
            allAxesIm(s).CLim=[min_im max_im];
            colorbar(allAxesIm(s))
        end
    end
    
    for s=1:length(allAxesTrace)
        if ~isempty(allAxesTrace(s).Title.String)
            allAxesTrace(s).YLim=traceLims;
        end
    end
    
end
