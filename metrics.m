function [out, Cellula1] = metrics(settings)
close all;
VideoP = settings.VideoP;
FrameInit = settings.FrameInit;
PixelInitY = settings.PixelInitY;
PixelInitX = settings.PixelInitX;
FrameSizeY = settings.FrameSizeY;
FrameSizeX = settings.FrameSizeX;
NumCells = settings.NumCells;
se = settings.se;
Thrs = settings.Thrs;
NumFrameEx = settings.NumFrameEx;

Im = read(VideoP,FrameInit);
[FrameHeight, FrameWidth, ~] = size(Im);
FrameVideo = double(rgb2gray(Im(PixelInitY:PixelInitY-1+FrameSizeY,PixelInitX:PixelInitX-1+FrameSizeX,:)));
imagesc(FrameVideo);colormap gray;axis image;axis off;

% select centroid for starting the cell tracking
if settings.manual
    [XX,YY] = ginput(NumCells);
    XX = round(XX)
    YY = round(YY)
else
%close all;
    XX = settings.XX;
    YY = settings.YY;
end

MaskIni = imfill(double(FrameVideo>Thrs)); %Binary Mask Initialization
MaskIni = (imerode(imfill(imdilate(MaskIni,se)),se)); %Morphological Operations (clean up noise and smooth boundaries)
MMM = bwlabel(MaskIni); %labeling similar components
MMMnew = zeros(size(MMM));
for r1=1:NumCells
    MMMnew(MMM == MMM(YY(r1),XX(r1)))=1;
end
MMMnew = imdilate(MMMnew,se);
s = regionprops(bwlabel(MMMnew),'MajorAxisLength');
MaxAx = round(cat(1,s.MajorAxisLength));
RadiusCells = round(MaxAx/2+10);

if RadiusCells > 10^2
    error('[Error: Cell Radius Computed Too Big]: Consider adjust the analysis threshold.');
end

% inizializzazione ROI per cellula
Cellula1 = zeros(2*RadiusCells(1)+1,2*RadiusCells(1)+1,NumFrameEx-FrameInit+1);

%% tracking
if settings.ifFrameEnd
    FrameEnd = settings.FrameEnd;
else
    FrameEnd = min(FrameInit + NumFrameEx - 1, NumFrameEx);  % Ensure the end frame does not exceed total frames
end

tic;
for r1=FrameInit:FrameEnd
    r1
    Im = read(VideoP,r1);
    FrameVideo = double(rgb2gray(Im(PixelInitY:PixelInitY-1+FrameSizeY,PixelInitX:PixelInitX-1+FrameSizeX,:)));

    Mask = imfill(double(FrameVideo>Thrs));
    Mask = (imerode(imfill(imdilate(Mask,se)),se));
    MMM = bwlabel(Mask);

    s = regionprops(MMM,FrameVideo,'WeightedCentroid');
    Centri = cat(1,s.WeightedCentroid);
    Centri = round(Centri);

    %CALCOLO DELLA TRAIETTORIA
    Dist1 = zeros(1,size(Centri,1));

    for nn1=1:size(Centri,1)
        Dist1(nn1)=sqrt((Centri(nn1,1)-XX(1)).^2+(Centri(nn1,2)-YY(1)).^2);
    end
    [A1,B1]=min(Dist1);

    XX = Centri(B1,1);
    YY = Centri(B1,2);
    Traj1(r1-FrameInit+1,:) = [YY(1),XX(1)-1];

    MMMnew = zeros(size(MMM));
    MMMnew(MMM==B1)=1;

    Mask = imdilate(MMMnew,se);
    frameIdx = r1-FrameInit+1;
    xCenter = Traj1(frameIdx, 1);
    yCenter = Traj1(frameIdx, 2);
    radius = RadiusCells(1);
    % ESTRAZIONE DELLA ROI contenente la cellula trackata
    Cellula1(:,:,frameIdx)=FrameVideo(xCenter-radius:xCenter+radius,yCenter-radius:yCenter+radius);
    imagesc(Cellula1(:,:,frameIdx));colormap gray;axis image;axis off;
    drawnow
end
time = toc;
% Extract x and y coordinates from Traj1
x_coords = Traj1(:, 2);  % The second column of Traj1 (x-coordinates)
y_coords = Traj1(:, 1);  % The first column of Traj1 (y-coordinates)

if settings.plot
    % Plot the trajectory in the x,y plane
    figure;
    plot(x_coords, y_coords, '-o');  % Plot with circular markers
    xlabel('X');  % Label x-axis
    ylabel('Y');  % Label y-axis
    title('Trajectory Plot');  % Title of the plot
    axis equal;  % Equal scaling of x and y axes
    grid on;  % Display grid
end

% TempoProcessingSec = Tempo/NumSeconds;

%save('CellulaRot1','Cellula1');

n_points = length(x_coords);

% Initialize metrics
distances = zeros(n_points-1, 1);  % Euclidean distances between consecutive points
total_distance = 0;                % Total distance
velocities = zeros(n_points-1, 1); % Instantaneous velocity

% Parameters
frame_rate = settings.frame_rate;
time_interval = 1/frame_rate; % Assuming equal time intervals between points

% Compute metrics
for i = 1:n_points-1
    % Euclidean distance
    distances(i) = sqrt((x_coords(i+1) - x_coords(i))^2 + (y_coords(i+1) - y_coords(i))^2);
    total_distance = total_distance + distances(i);
    
    % Instantaneous velocity
    velocities(i) = distances(i) / time_interval;
end

% Bounding box area
x_min = min(x_coords);
x_max = max(x_coords);
y_min = min(y_coords);
y_max = max(y_coords);
bounding_box_area = (x_max - x_min) * (y_max - y_min);

% Convex hull area
unique_points = unique([x_coords(:), y_coords(:)], 'rows');

if rank(unique_points) < 2
    convex_hull_area = NaN; % Collinear points have no area
    warning('Not enough unique points for convex hull calculation.');
else
    k = convhull(x_coords, y_coords);
    convex_hull_area = polyarea(x_coords(k), y_coords(k));
end


% Display metrics
disp('Metrics:');
disp(['Total Distance: ', num2str(total_distance)]);
disp(['Bounding Box Area: ', num2str(bounding_box_area)]);
disp(['Convex Hull Area: ', num2str(convex_hull_area)]);

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

x_start = x_coords(1);
y_start = y_coords(1);
% Compute distances from the starting point to all other points
distances_from_start = sqrt((x_coords - x_start).^2 + (y_coords - y_start).^2);

% Find the maximum and minimum distances
[max_distance, max_index] = max(distances_from_start); % Max distance and index

% Coordinates of the farthest and closest points
max_point = [x_coords(max_index), y_coords(max_index)];

% Display results
disp('Maximum Distance Metrics:');
disp(['Maximum Distance from Start: ', num2str(max_distance)]);
disp(['Coordinates of Farthest Point: (', num2str(max_point(1)), ', ', num2str(max_point(2)), ')']);
if(settings.plot)
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
end
out.Thrs = settings.Thrs;
out.total_distance = total_distance;
out.bounding_box_area = bounding_box_area;
out.convex_hull_area = convex_hull_area;
out.max_distance = max_distance;
out.time = time;


end