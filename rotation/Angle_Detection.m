clear;
close all;

addPaths;

load('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/2025_02_20_15_12_30/Cell1_data.mat');
load('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/2025_02_20_15_12_30/workspace.mat');

settings.ifrefining = 1;
settings.ifplot = 0;
settings.verbose = 1;
settings.RadiusCells = 30;
% Reusable Variables
Cell = cellData.Cell;
[settings.Cellrows, settings.Cellcols, settings.numFrames] = size(Cell);

RefinedCell = refine_cellpose(Cell, settings);
%%
settings.ifMSE = 0;
settings.ifCorr = 0;
settings.ifPXI = 0;
settings.ifRegionprops=1;
% Select Rotation Estimation Method Based on Settings
if settings.ifMSE
    AngleEst = mseRotationEstimation(RefinedCell, settings);
elseif settings.ifCorr
    AngleEst = corrRotationEstimation(RefinedCell, settings);
elseif settings.ifPXI
    AngleEst = pxiRotationEstimation(RefinedCell, settings);
elseif settings.ifRegionprops
    AngleEst = regionpropsRotationEstimation(RefinedCell, settings);
else
    warning('No valid rotation estimation method selected. Check settings.');
    AngleEst = [];
end