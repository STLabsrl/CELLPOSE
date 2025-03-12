function [t0] = estimateInitTimeAnalysis(settings)

nsamples = 40;
settings.FrameEnd = settings.FrameInit + nsamples;
Cell = tracking_multicell(settings);
[settings.Cellrows, settings.Cellcols, settings.numFrames] = size(Cell);
RefinedCell = refine_cellpose(Cell, settings);
AngleEst = mseRotationEstimation(RefinedCell, settings);

t0 = find(AngleEst ~= 0, 1);

end