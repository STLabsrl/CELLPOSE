function [AngleEst, t0_idx] = mseRotationEstimationComparison(Cell,settings)
RefinedCell = Cell;
RadiusCells = settings.RadiusCells;
numFrames = settings.numFrames;
ifplot = settings.ifplot;


max_shift = 10; % Number of different comparisons (Frame1 vs Frame2, Frame1 vs Frame3, etc.)
angle_step = 3; % Estimated max rotation per frame (adjustable)

% Creazione Maschera Circolare
[N1,N2] = meshgrid(-floor(size(RefinedCell(:,:,1),1)/2):floor(size(RefinedCell(:,:,1),1)/2),-floor(size(RefinedCell(:,:,1),2)/2):floor(size(RefinedCell(:,:,1),2)/2));
CircularMask = double((N1.^2 +N2.^2)<(RadiusCells).^2);
IM = RefinedCell(:,:,1).*CircularMask;
if ifplot imagesc(IM); axis image; axis off; colormap gray; end
AngleEst =  zeros(1, numFrames-1);
Frame1 = RefinedCell(:,:,1) .* CircularMask;
t0_idx = NaN; % Initialize t0_idx as NaN in case no valid frame is found

AngleEst = NaN(size(RefinedCell, 3) - 1, max_shift); % Store rotation estimates

for shift = 1:max_shift
    for i = 2:size(RefinedCell, 3) - shift
        Frame2 = RefinedCell(:,:,i + shift - 1) .* CircularMask;
        mse_fun = @(Angle) mse(Frame1, imrotate(Frame2, Angle, 'bicubic', 'crop'));
        
        max_angle = max(angle_step, shift * angle_step); % Adjust range based on shift
        AngleEst(i-1, shift) = fminbnd(mse_fun, 0, max_angle);
        
        if AngleEst(i-1, shift) > 0 && AngleEst(i-1, shift) <= 1
            if isnan(t0_idx)  % Only set t0_idx once
                t0_idx = i - 1;  % Store the frame index
                fprintf('Rotation starts at frame %d (AngleEst = %.3f)\n', t0_idx, AngleEst(i-1, shift));
            end
        end

        if settings.verbose
            fprintf('Frame1 vs Frame%d: Estimated Rotation Angle (MSE): %.2f degrees\n', i + shift - 1, AngleEst(i-1, shift));
        end
    end
end

figure;
hold on; % Allow multiple plots on the same figure
for shift = 1:size(AngleEst, 2)
    plot(1:size(AngleEst, 1), AngleEst(:, shift), '-o', 'LineWidth', 1.5, 'DisplayName', sprintf('Shift = %d', shift));
end
hold off;

xlabel('Frame Index');
ylabel('Estimated Rotation Angle (degrees)');
title('Rotation Angle Estimates Over Time');
legend show; % Show shift labels
grid on;

end

