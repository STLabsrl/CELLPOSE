clear;
clc;
close all;

%% Conditions Setup
ifplot = 1;
ifsave = 1;
ifFrameEnd = 1;
set_centroid_manually = 0;
ifcellpose = 0;
%%
if set_centroid_manually
    XX = [-1];
    YY = [-1];
else
    XX = [423 232];
    YY = [193 406];
end

% Setting
VideoPath = './';
VideoP = VideoReader(strcat(VideoPath,'Prova_8.avi'));
% Cells selection
NumCells = 2;
se = strel('disk',5); %a disk-shaped kernel
Thrs = 100; % Threshold for binary processing (might need adjustment for each cell)
FrameInit =1; % Frame to start from (could be dynamic based on needs
FrameEnd = 570;
NumSeconds = 2; % Duration of frames to process (in seconds)
FrameSizeY = VideoP.Height;
FrameSizeX = VideoP.Width;
PixelInitY = 1;
PixelInitX = 1;
NumFrameEx = FrameEnd - FrameInit; % % Total number of frames
frame_rate = 57;
if ifcellpose
    thresholds = -2:2:-2;
    thresholds = -6;
else
    %thresholds = 100:20:180;
    thresholds = 80;
end



%if FrameInit + round(NumSeconds * VideoP.FrameRate) > NumFrameEx
%    error('The frame range exceeds the total number of frames in the video.');
%end

settings.VideoP = VideoP;
settings.NumCells=NumCells;
settings.se=se;
%settings.Thrs=Thrs;
settings.FrameInit=FrameInit;
settings.NumSeconds=NumSeconds;
settings.FrameSizeY=FrameSizeY;
settings.FrameSizeX=FrameSizeX;
settings.PixelInitY=PixelInitY;
settings.PixelInitX=PixelInitX;
settings.NumFrameEx = NumFrameEx;
settings.frame_rate = frame_rate;
settings.plot = ifplot;
settings.ifFrameEnd = ifFrameEnd;
settings.FrameEnd = FrameEnd;

% Cell Centroid
settings.manual = set_centroid_manually;


k = 1;
out = zeros(length(XX) * length(thresholds), 5);
for m = 1:length(XX)
    settings.XX = XX(m);
    settings.YY = YY(m);
    for i=thresholds
        settings.Thrs = i;
        settings.FrameInit = FrameInit;
        if ifcellpose
         [result, Cellula] = metrics_cellpose(settings);
        else
         [result, Cellula] = metrics_multicell(settings);
        end
        out(k,1) = result.Thrs;
        out(k,2) = result.total_distance;
        out(k,3) = result.bounding_box_area;
        out(k,4) = result.convex_hull_area;
        out(k,5) = result.max_distance;
        out(k,6) = result.time;
        k = k + 1;
    end
end

if ifsave
    currentDate = datestr(now, 'yyyy_mm_dd_HH_MM_SS'); % Format date as YYYY_MM_DD
    filename = sprintf('various_ths_%s.mat', currentDate);
    % Save results with the new filename
    save(filename);
end



