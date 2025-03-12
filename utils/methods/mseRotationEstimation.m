function [AngleEst, t0_idx] = mseRotationEstimation(Cell,settings)
RefinedCell = Cell;
RadiusCells = settings.RadiusCells;
numFrames = settings.numFrames;
ifplot = settings.ifplot;
% Creazione Maschera Circolare
[N1,N2] = meshgrid(-floor(size(RefinedCell(:,:,1),1)/2):floor(size(RefinedCell(:,:,1),1)/2),-floor(size(RefinedCell(:,:,1),2)/2):floor(size(RefinedCell(:,:,1),2)/2));
CircularMask = double((N1.^2 +N2.^2)<(RadiusCells).^2);
IM = RefinedCell(:,:,1).*CircularMask;
if ifplot imagesc(IM); axis image; axis off; colormap gray; end
AngleEst =  zeros(1, numFrames-1);
Frame1 = RefinedCell(:,:,1) .* CircularMask;
t0_idx = NaN; % Initialize t0_idx as NaN in case no valid frame is found
angle_step = 15; 
for i=2:size(RefinedCell, 3)-1
    Frame2 = RefinedCell(:,:,i) .* CircularMask;
    mse_fun = @(Angle) mse(Frame1, imrotate(Frame2, Angle, 'bicubic', 'crop'));
    AngleEst(i-1) = fminbnd(mse_fun, 0, angle_step);
    if AngleEst(i-1) > 0 && AngleEst(i-1) <= angle_step
        if isnan(t0_idx)  % Only set t0_idx once
            t0_idx = i - 1;  % Store the frame index
            fprintf('Rotation starts at frame %d (AngleEst = %.3f)\n', t0_idx, AngleEst(i-1));
        end
    end

    if settings.verbose
        fprintf('Estimated Rotation Angle (MSE): %.2f degrees\n', AngleEst(i-1));
    end
end
if isnan(t0_idx) && settings.verbose
    warning('No valid rotation detected (0 < AngleEst ≤ 1)');
end

if ifplot
    % Plot Estimated Rotation Angles
    figure;
    plot(1:length(AngleEst), AngleEst, 'LineWidth', 1.5);
    xlabel('Frame Index');
    ylabel('Rotation Angle');
    title('Estimated Rotation Angle per Frame');
    grid on;
end
end

