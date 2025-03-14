function [AngleEst, t0_idx] = mseRotationEstimationComparison(Cell,settings)
RefinedCell = Cell;
RadiusCells = settings.RadiusCells;
numFrames = settings.numFrames;
ifplot = settings.ifplot;

max_shift = settings.max_shift; % Number of different comparisons (Frame1 vs Frame2, Frame1 vs Frame3, etc.)
angle_step = 10; % Estimated max rotation per frame (adjustable)

pairs = [];
for k = 1:max_shift-1
    for h = k+1:min(k+max_shift, angle_step) % Ensure h > k and within max_shift
        pairs = [pairs; k, h];
    end
end

% Creazione Maschera Circolare
[N1,N2] = meshgrid(-floor(size(RefinedCell(:,:,1),1)/2):floor(size(RefinedCell(:,:,1),1)/2),-floor(size(RefinedCell(:,:,1),2)/2):floor(size(RefinedCell(:,:,1),2)/2));
CircularMask = double((N1.^2 +N2.^2)<(RadiusCells).^2);
IM = RefinedCell(:,:,1).*CircularMask;
if ifplot imagesc(IM); axis image; axis off; colormap gray; end
%AngleEst =  zeros(1, numFrames-1);
Frame1 = RefinedCell(:,:,1) .* CircularMask;
t0_idx = NaN; % Initialize t0_idx as NaN in case no valid frame is found

AngleEst = cell(size(pairs, 1), 1);
% Perform the comparisons for each pair
for idx = 1:size(pairs, 1)
    Frame1_idx = pairs(idx, 1); % Get the index for Frame1
    Frame2_idx = pairs(idx, 2); % Get the index for Frame2
    
    % Extract the corresponding frames and apply the circular mask
    Frame1 = RefinedCell(:,:,Frame1_idx) .* CircularMask;
    Frame2 = RefinedCell(:,:,Frame2_idx) .* CircularMask;

    % Define the Mean Squared Error (MSE) function for optimization
    mse_fun = @(Angle) mse(Frame1, imrotate(Frame2, Angle, 'bicubic', 'crop'));

    shift = Frame2_idx - Frame1_idx;
    max_angle = max(angle_step, shift * angle_step);

    % Find the optimal rotation angle that minimizes the MSE
    angleEst = fminbnd(mse_fun, 0, max_angle);

    % Store the result as a struct in the cell array
    AngleEst{idx} = struct( ...
        'Frames', [Frame1_idx, Frame2_idx], ...
        'Rotation', angleEst/shift);
end

end

