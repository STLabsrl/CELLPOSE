function CellSegments = extractFrequencySections(RefinedCell,settings)
% Extract frequency change points
start_frames = settings.frequency_change_points(1, :);
end_frames = settings.frequency_change_points(2, :);
num_segments = length(start_frames);  % Number of frequency segments
frequency_labels = settings.labels;  % Get frequency labels

% Initialize cell array to store segmented frames
CellSegments = cell(1, num_segments);

% Loop through each frequency segment
for i = 1:num_segments
    start_frame = start_frames(i);
    end_frame = end_frames(i);
    frequency_label = frequency_labels(i);  % Get the corresponding frequency label

    fprintf('Processing segment %d: Frames %d to %d (Frequency Label: %s)\n', ...
        i, start_frame, end_frame, frequency_label);

    % Initialize an array to store frames for this segment
    %segment_frames = cell(1, end_frame - start_frame + 1);

    % Extract and process each segment separately
    for frame_idx = start_frame:end_frame
        frame = RefinedCell(:, :, frame_idx); % Read frame

        % Store frame in the segment cell array
        segment_frames = RefinedCell(:, :, start_frame:end_frame);
    end

    % Store extracted frames for this frequency label in CellSegments
    CellSegments{i} = struct('Frames', segment_frames, 'Label', frequency_label);
end

% Optional: Save CellSegments to a .mat file for later use
save('CellSegments.mat', 'CellSegments');
end