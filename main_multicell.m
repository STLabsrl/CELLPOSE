clear all;
clc;
close all;

%% Conditions Setup
ifplot = 1;
ifsave = 1;
ifFrameEnd = 1;
set_centroid_manually = 0;
% How many cells? 
NumCells = 3; % Cell selection
ifcellpose = 1;

% Setting
VideoPath = './';
VideoP = VideoReader(strcat(VideoPath,'Prova_4.avi'));
%%
if set_centroid_manually
    XX = [-1];
    YY = [-1];
else
    %XX = [381; 353; 180];% 177]; %Prova7
    %YY = [101; 132;  220];% 220]; %Prova7
    XX = [383;290;138];
    YY = [236;317;369];
    settings.XX = XX;
    settings.YY = YY;
end
se = strel('disk',5); %a disk-shaped kernel
Thrs = 30; % Threshold for binary processing (might need adjustment for each cell)
FrameInit =570; % Frame to start from (could be dynamic based on needs
NumSeconds = 20; % Duration of frames to process (in seconds)
frame_rate = 57;
FrameEnd = FrameInit + NumSeconds * frame_rate;
FrameSizeY = VideoP.Height;
FrameSizeX = VideoP.Width;
PixelInitY = 1;
PixelInitX = 1;
NumFrameEx = FrameEnd - FrameInit; % % Total number of frames

if ifcellpose
    thresholds = -2:2:-2;
    thresholds = -6;
else
    %thresholds = 100:20:180;
    thresholds = 86;
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
settings.ifcellpose = ifcellpose;

% Cell Centroid
settings.manual = set_centroid_manually;
for i=thresholds
    settings.Thrs = i;
    settings.FrameInit = FrameInit;
    [Cell] = tracking_multicell(settings);
end

if ifsave
    currentDate = datestr(now, 'yyyy_mm_dd_HH_MM_SS'); % Format date as YYYY_MM_DD
    %filename = sprintf('prova7_%s.mat', currentDate);
    folderPath = sprintf('./results/%s', currentDate);
    if ~exist(folderPath, 'dir')
       mkdir(folderPath);
    end
    % Assuming Cells contains 3 cells (each with 'Cell' and 'LabeledFrames' fields)
    for j = 1:NumCells
        % Create a struct for each cell's data
        cellData.Cell = Cell{j}.Cell;
        cellData.LabeledFrames = Cell{j}.LabeledFrames;
        
        % Define the filename for each cell
        filename = sprintf('./results/%s/Cell%d_data.mat', currentDate, j);
        % Save the data to a .mat file
        save(filename, 'cellData');

    end
end
clear Cell cellData;
filename = sprintf('./results/%s/workspace.mat', currentDate);
save(filename);


