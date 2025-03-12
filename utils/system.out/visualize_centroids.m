load('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/2025_03_04_20_29_20/Cell1_data.mat')
load('/home/dsanalit/OneDrive/Work/Software/CELLPOSE/results/2025_03_04_20_29_20/workspace.mat')

Cells = cellData;
cellData.Cell = RefinedCell;

for r1=FrameInit:FrameEnd
    Im = read(settings.VideoP, r1);
    FrameVideo = double(rgb2gray(Im(settings.PixelInitY:settings.PixelInitY-1+settings.FrameSizeY, settings.PixelInitX:settings.PixelInitX-1+settings.FrameSizeX,:)));

    % Display the frame
    imagesc(FrameVideo);
    colormap gray;
    axis image;
    axis off;
    hold on;
    
    title(sprintf('Frame %d', r1));

    % Overlay centroids and trajectories from all tracked cells
    for i = 1:length(Cells)
        if isfield(Cells(i), 'Trajectory') && ~isempty(Cells(i).Trajectory)
            Traj = Cells(i).Trajectory;
            
            % Find the index of the current frame in trajectory
            frameIdx = r1 - settings.FrameInit + 1;
            if frameIdx > size(Traj, 1)
                continue; % Skip if frame index is out of bounds
            end
            
            % Plot past trajectory (up to the current frame)
            plot(Traj(1:frameIdx, 2), Traj(1:frameIdx, 1), 'r-', 'LineWidth', 1.5);

            % Plot the current centroid as a red circle
            plot(Traj(frameIdx, 2), Traj(frameIdx, 1), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
        end
    end

    hold off;
    drawnow;
    pause(0.1); % Small pause for smooth visualization
end