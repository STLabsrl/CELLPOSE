function [AngleEst] = mseRotationEstimation(Cell,settings)
RefinedCell = Cell;
RadiusCells = settings.RadiusCells;
numFrames = settings.numFrames;
ifplot = settings.ifplot;
% Creazione Maschera Circolare
[N1,N2] = meshgrid(-floor(size(RefinedCell(:,:,1),1)/2):floor(size(RefinedCell(:,:,1),1)/2),-floor(size(RefinedCell(:,:,1),2)/2):floor(size(RefinedCell(:,:,1),2)/2));
CircularMask = double((N1.^2 +N2.^2)<(RadiusCells/1.8).^2);
IM = RefinedCell(:,:,1).*CircularMask;
if ifplot imagesc(IM); axis image; axis off; colormap gray; end
AngleEst =  zeros(1, numFrames-1);
Frame1 = RefinedCell(:,:,1) .* CircularMask;
for i=2:length(RefinedCell)
    Frame2 = RefinedCell(:,:,i) .* CircularMask;
    mse_fun = @(Angle) mse(Frame1, imrotate(Frame2, Angle, 'bicubic', 'crop'));
    AngleEst(i-1) = fminbnd(mse_fun, 0, 0.5);
    if settings.verbose
        fprintf('Estimated Rotation Angle: %.2f degrees\n', AngleEst(i-1));
    end
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

