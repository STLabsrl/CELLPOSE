function [out] = pxiRotationEstimation(Cell,settings)

rowRange = 1:floor(settings.Cellrows/2);
colRange = 1:floor(settings.Cellcols/2);

%Compute mean over the first quadrant
signalRaw = mean(Cell(1:rowRange, 1:colRange, :), [1, 2]);

filteredSignal = filter(Lowpass_filter(settings.frame_rate, 10, 8), signalRaw(:)); 

% Remove first 10 samples to reduce filter transients
filteredSignal = filteredSignal(10:end);

out = normalize(filteredSignal, "range");

end