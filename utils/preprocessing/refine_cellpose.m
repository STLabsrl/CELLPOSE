function [RefinedCell,RefinedMask] = refine_cellpose(Cell, settings)
numFrames = settings.numFrames;
RadiusMask = settings.RadiusCells - 10;
RefinedCell = zeros(2*RadiusMask+1,2*RadiusMask+1,numFrames);
RefinedMask = zeros(2*RadiusMask+1,2*RadiusMask+1,numFrames);
% Tracking
Traj1 = [];
XX = [];
YY = [];
cp = cellpose(Model="cyto2");
if settings.ifrefining
    k=0;
    for r1=1:length(Cell)
        progress = ((r1)/(length(Cell)))*100;
        fprintf('Processing Cell frame %d of %d(%.2f%% complete)\n', r1, length(Cell), progress);
        IMAGE = Cell(:,:,r1);
        labels = segmentCells2D(cp,IMAGE);
        s = regionprops(labels,IMAGE,'WeightedCentroid');
        if(isempty(s)==1)
            k=k+1;
        else
            Centri = cat(1,s.WeightedCentroid);
            Centri = round(Centri);
            XX = Centri(1);
            YY = Centri(2);
        end
        RefinedCell(:,:,r1)=Cell(YY-RadiusMask:YY+RadiusMask, XX-RadiusMask:XX+RadiusMask, r1);
        RefinedMask(:,:,r1)=labels(YY-RadiusMask:YY+RadiusMask, XX-RadiusMask:XX+RadiusMask);
        imagesc(Cell(:,:,r1)); colormap gray; axis image; axis off;
        drawnow;
    end
else
    warning('Set refining to true to refine the cell, refining not performed.');
    RefinedCell = Cell; % Return unmodified data
end
end

