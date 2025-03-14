clear;
close all;

addPaths;

exp = '2025_03_12_16_44_52';
cell_name = '/Cell1_data.mat';
workspace_name = '/workspace.mat';
load(strcat('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/',exp,cell_name));
load(strcat('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/',exp,workspace_name));

settings.viewcell=0;
if settings.viewcell
    visualize_cell;
end

settings.ifplot = 1;
settings.verbose = 1;
if isfield(cellData, 'Settings') && isfield(cellData.Settings, 'radius')
    settings.RadiusCells = cellData.Settings.radius;
else
    settings.RadiusCells = 30;
    warning('Radius field is missing in cellData.Settings. Setting it manually');
end
% Reusable Variables
Cell = cellData.Cell;
[settings.Cellrows, settings.Cellcols, settings.numFrames] = size(Cell);
%
settings.extractFrequencySections = 1;

if settings.extractFrequencySections
    settings.delay = 47; % delay between one input frequency and another
    settings.frequency_change_points = [116, 394, 670; 340 620 799]; % Adjust based on your data in seconds
    settings.labels = ["30 Hz", "40 Hz", "50 Hz"]; % Corresponding frequency labels
    CellSegments = extractFrequencySections(Cell, settings);
end
%%

%settings.analyzeSegments = {'30 Hz', '50 Hz'};  % Example: Analyze only '30Hz' and '50Hz'
settings.analyzeSegments = {'30 Hz'};
settings.ifMSE = 1;
settings.ifCorr = 0;
settings.ifPXI = 0;
settings.ifRegionprops=1;
settings.max_shift = 10;

% Loop through selected segments
if ~isempty(settings.analyzeSegments)
    for i = 1:length(settings.analyzeSegments)
        label = settings.analyzeSegments{i};  % Get label of the segment to analyze

        % Find the corresponding segment in CellSegments
        idx = find(strcmp(settings.labels, label)); % Get index of the label

        if isempty(idx)
            warning('Segment %s not found in CellSegments. Skipping...', label);
            continue;
        end

        fprintf('Analyzing segment: %s\n', label);

        % Get segment frames
        Cell = CellSegments{idx}.Frames;

        % Select Rotation Estimation Method Based on Settings
        if settings.ifMSE
            [AngleEst, t0] = mseRotationEstimationComparison(Cell, settings);
        elseif settings.ifCorr
            settings.ifQuadrant = 1;
            AngleEst = corrRotationEstimation(Cell, settings);
        elseif settings.ifPXI
            AngleEst = pxiRotationEstimation(Cell, settings);
        elseif settings.ifRegionprops
            AngleEst = regionpropsRotationEstimation(Cell, settings);
        else
            warning('No valid rotation estimation method selected. Check settings.');
            AngleEst = [];
        end
        % Store the angle estimation results in the struct
        CellSegments{idx}.AngleEst = AngleEst;
    end
else

    if settings.ifMSE
        [AngleEst, t0] = mseRotationEstimationComparison(Cell, settings);
        computeAutoCorrelation(AngleEst,settings);
    elseif settings.ifCorr
        settings.ifQuadrant = 1;
        AngleEst = corrRotationEstimation(Cell, settings);
    elseif settings.ifPXI
        AngleEst = pxiRotationEstimation(Cell, settings);
        computeAutoCorrelation(AngleEst,settings);
    elseif settings.ifRegionprops
        AngleEst = regionpropsRotationEstimation(Cell, settings);
    else
        warning('No valid rotation estimation method selected. Check settings.');
        AngleEst = [];
    end

end

if ~isempty(AngleEst)
    % Extract rotation values from AngleEst
    allRotations = cellfun(@(x) x.Rotation, AngleEst); 

    % Compute the mean rotation, ignoring NaNs
    meanRotation = mean(allRotations, 'omitnan');

    % Display the result
    disp(['Mean Rotation: ', num2str(meanRotation)]);
else
    disp('AngleEst is empty. No rotation values found.');
end


