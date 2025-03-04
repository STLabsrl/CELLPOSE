function [valCC] = corrRotationEstimation(Cell,settings)

if settings.ifQuadrant
    rowRange = 1:round(settings.Cellrows/2);
    colRange = 1:round(settings.Cellcols/2);
else
    rowRange = 1:settings.Cellrows;
    colRange = 1:settings.Cellcols;
end

% Preallocate memory for correlation values
valCC = zeros(1, settings.numFrames);

% Extract reference frame only once
ReferenceFrame = Cell(rowRange, colRange, 1);

% Compute correlation for each frame
for i = 2:settings.numFrames
    CC1 = corrcoef(ReferenceFrame, Cell(rowRange, colRange, i));
    
    % Ensure correlation calculation is valid before storing
    if numel(CC1) > 1
        valCC(i) = CC1(1,2);
    else
        valCC(i) = NaN; % Handle cases where correlation is not computable
    end
end

if settings.ifplot
    figure;
    plot(2:settings.numFrames, valCC(2:end), '-o', 'LineWidth', 1.5, 'MarkerSize', 5);
    xlabel('Frame Number');
    ylabel('Correlation Coefficient');
    title('Correlation Over Time');
    grid on;
end

end