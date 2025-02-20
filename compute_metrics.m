clear all;
close all;
load('coords.mat');
% Number of points
n_points = length(x_coords);

% Initialize metrics
distances = zeros(n_points-1, 1);  % Euclidean distances between consecutive points
angles = zeros(n_points-1, 1);     % Angles of movement
angular_changes = zeros(n_points-2, 1); % Changes in angles
total_distance = 0;                % Total distance
velocities = zeros(n_points-1, 1); % Instantaneous velocity

% Parameters
frame_rate = 60;
time_interval = 1/frame_rate; % Assuming equal time intervals between points

% Compute metrics
for i = 1:n_points-1
    % Euclidean distance
    distances(i) = sqrt((x_coords(i+1) - x_coords(i))^2 + (y_coords(i+1) - y_coords(i))^2);
    total_distance = total_distance + distances(i);
    
    % Instantaneous velocity
    velocities(i) = distances(i) / time_interval;
end

% Compute displacement
displacement = sqrt((x_coords(end) - x_coords(1))^2 + (y_coords(end) - y_coords(1))^2);

% Net-to-total distance ratio
efficiency_ratio = displacement / total_distance;

% Bounding box area
x_min = min(x_coords);
x_max = max(x_coords);
y_min = min(y_coords);
y_max = max(y_coords);
bounding_box_area = (x_max - x_min) * (y_max - y_min);

% Convex hull area
k = convhull(x_coords, y_coords);
convex_hull_area = polyarea(x_coords(k), y_coords(k));

% Display metrics
disp('Metrics:');
disp(['Total Distance: ', num2str(total_distance)]);
disp(['Displacement: ', num2str(displacement)]);
disp(['Net-to-Total Distance Ratio: ', num2str(efficiency_ratio)]);
disp(['Bounding Box Area: ', num2str(bounding_box_area)]);
disp(['Convex Hull Area: ', num2str(convex_hull_area)]);

% Plot instantaneous velocity
%figure;
%plot(1:n_points-1, velocities, '-o');
%title('Instantaneous Velocity');
%xlabel('Step');
%ylabel('Velocity');
%grid on;

% Plot bounding box
figure;
plot(x_coords, y_coords, '-o');
hold on;
rectangle('Position', [x_min, y_min, x_max - x_min, y_max - y_min], 'EdgeColor', 'r');
plot(x_coords(k), y_coords(k), 'g-');
title('Trajectory with Bounding Box - Convex Hull');
xlabel('X');
ylabel('Y');
grid on;

%% Max Displacement
% Starting point
x_start = x_coords(1);
y_start = y_coords(1);
% Compute distances from the starting point to all other points
distances_from_start = sqrt((x_coords - x_start).^2 + (y_coords - y_start).^2);

% Find the maximum and minimum distances
[max_distance, max_index] = max(distances_from_start); % Max distance and index
[min_distance, min_index] = min(distances_from_start); % Min distance and index

% Coordinates of the farthest and closest points
max_point = [x_coords(max_index), y_coords(max_index)];

% Display results
disp('Maximum Distance Metrics:');
disp(['Maximum Distance from Start: ', num2str(max_distance)]);
disp(['Coordinates of Farthest Point: (', num2str(max_point(1)), ', ', num2str(max_point(2)), ')']);
% Plot trajectory with min and max points
figure;
plot(x_coords, y_coords, '-o'); % Plot trajectory
hold on;
plot(x_start, y_start, 'go', 'MarkerSize', 10, 'DisplayName', 'Starting Point'); % Starting point
plot(max_point(1), max_point(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'Farthest Point'); % Farthest point
%plot(min_point(1), min_point(2), 'bo', 'MarkerSize', 10, 'DisplayName', 'Closest Point'); % Closest point
legend show;
title('Trajectory with Min and Max Distance Points');
xlabel('X');
ylabel('Y');
grid on;
