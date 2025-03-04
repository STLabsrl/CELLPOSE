function [AngleRegionProps] = regionpropsRotationEstimation(Cell, settings)
    RefinedCell = Cell;
    RadiusCells = settings.RadiusCells;
    numFrames = settings.numFrames;
    ifplot = settings.ifplot;

    % Create Circular Mask
    [N1, N2] = meshgrid(-floor(size(RefinedCell(:,:,1),1)/2):floor(size(RefinedCell(:,:,1),1)/2), ...
                        -floor(size(RefinedCell(:,:,1),2)/2):floor(size(RefinedCell(:,:,1),2)/2));
    CircularMask = double((N1.^2 + N2.^2) < (RadiusCells/1.8).^2);
    IM = RefinedCell(:,:,1) .* CircularMask;
    
    if ifplot
        imagesc(IM);
        axis image; axis off; colormap gray;
    end
    
    AngleRegionProps = zeros(1, numFrames-1);
    
    Frame1 = RefinedCell(:,:,1) .* CircularMask;
    
    % Compute initial orientation using regionprops
    stats1 = regionprops(imbinarize(Frame1), 'Orientation');
    if ~isempty(stats1)
        prev_orientation = stats1(1).Orientation; % Initial orientation
    else
        prev_orientation = 0; % Default if no object detected
    end
    
    for i = 2:length(RefinedCell)
        Frame2 = RefinedCell(:,:,i) .* CircularMask;
      
        % **Regionprops-based estimation**
        stats2 = regionprops(imbinarize(Frame2), 'Orientation');
        if ~isempty(stats2)
            current_orientation = stats2(1).Orientation;
            AngleRegionProps(i-1) = current_orientation - prev_orientation;
            prev_orientation = current_orientation;
        else
            AngleRegionProps(i-1) = 0; % If no object detected, assume no rotation
        end

        if settings.verbose
            fprintf('Frame %d: RegionProps Angle: %.2f°\n', ...
                    i, AngleRegionProps(i-1));
        end
    end
    
    if ifplot
        % Plot Estimated Rotation Angles
        figure;
        plot(1:length(AngleEst), AngleEst, 'b', 'LineWidth', 1.5);
        hold on;
        plot(1:length(AngleRegionProps), AngleRegionProps, 'r--', 'LineWidth', 1.5);
        xlabel('Frame Index');
        ylabel('Rotation Angle (degrees)');
        legend('MSE Estimation', 'RegionProps Estimation');
        title('Estimated Rotation Angle per Frame');
        grid on;
    end
end
