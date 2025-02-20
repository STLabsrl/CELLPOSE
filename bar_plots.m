%%
clear all;
close all;

load("./results/prova_3/various_ths.mat")
% Create a figure for the bar plot
figure;

% Set up the bar plot
bar_data = out(:, 2:5);  % Get the columns for total_distance, bounding_box_area, convex_hull_area, max_distance
thresholds = out(:,1);
% Plot the data as grouped bar charts
bar(thresholds, bar_data, 'grouped');

% Add labels and title
xlabel('Thresholds');
ylabel('Values');
title('Metrics for Different Thresholds');
legend({'Total Distance', 'Bounding Box Area', 'Convex Hull Area', 'Max Distance'}, 'Location', 'Best');

% Display the grid for better readability
grid on;