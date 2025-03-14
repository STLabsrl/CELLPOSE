cellsCellpose = cellData.Cell;
% Extract region of interest (ROI)
roiRange = (41-30):(41+30);  
roiExtracted = cellsCellpose(:, :, :);  

% Ensure both datasets have the same number of frames
numFrames = size(roiExtracted, 3);

ifsavegif = 0;
if ifsavegif
    gifFileName = 'CellPose_Comparison.gif';
end
% Display images side by side
for i = 1:numFrames
        clf;  % Clear previous figure content
    tiledlayout(1,1);  % Create a 1-row, 2-column layout
    
    % Right: CellPose
    nexttile;
    imagesc(roiExtracted(:, :, i));
    colormap gray; axis image;
    title('CellPose');
    
    % Add frame number as super title
    sgtitle(sprintf('Frame %d', i), 'FontSize', 14, 'FontWeight', 'bold');
    if ifsavegif
        % Capture the current frame as an image
        frame = getframe(gcf); % Get figure frame
        img = frame2im(frame); % Convert to image
        [A, map] = rgb2ind(img, 256); % Convert to indexed image

        % Write to GIF file
        if i == 1
            imwrite(A, map, gifFileName, 'gif', 'LoopCount', Inf, 'DelayTime', 0.1);
        else
            imwrite(A, map, gifFileName, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
        end
    end
    if waitforbuttonpress  % Wait for a key press
        pause;  % Pause indefinitely until another key is pressed
    end
    % Update the display
    drawnow;  
end