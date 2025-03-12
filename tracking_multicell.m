function [Cells] = tracking_multicell(settings)
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
    settings.XX = XX;
    settings.YY = YY;
else
    %close all;
    XX = settings.XX;
    YY = settings.YY;
end

%% tracking
if settings.ifFrameEnd
    FrameEnd = settings.FrameEnd;
else
    FrameEnd = min(FrameInit + NumFrameEx - 1, NumFrameEx);  % Ensure the end frame does not exceed total frames
end
global Cells;
Cells = cell(NumCells, 1);

for i=1:NumCells
    Trajectory = [];
    % inizializzazione ROI per cellula
    MaskIni = imfill(double(FrameVideo>Thrs)); %Binary Mask Initialization
    MaskIni = (imerode(imfill(imdilate(MaskIni,se)),se)); %Morphological Operations (clean up noise and smooth boundaries)
    if ~settings.ifcellpose
        MMM = bwlabel(MaskIni); %labeling similar components
        MMMnew = zeros(size(MMM));
        MMMnew(MMM == MMM(YY(i),XX(i)))=1;
        disp(MMM(YY(i),XX(i)));  % Check which label is assigned to selected centroids
        MMMnew = imdilate(MMMnew,se);
        s = regionprops(bwlabel(MMMnew),'MajorAxisLength');
        MaxAx = round(cat(1,s.MajorAxisLength));
        radius = round(MaxAx/2+settings.marginCell);
        if radius > 10^2
            error('[Error: Cell Radius Computed Too Big]: Consider adjust the analysis threshold.');
        end
        if(size(radius,1)>1)
            radius = min(radius);
        end
    else
        cpCyto = cellpose(Model="cyto2");
        cellThreshold = -6;
        flowThreshold = 3;
        averageCellDiameter=60;
        MMM = segmentCells2D(cpCyto,FrameVideo, ...
        ImageCellDiameter=averageCellDiameter, ...
        CellThreshold=cellThreshold, ...
        FlowErrorThreshold=flowThreshold);
        MMMnew = zeros(size(MMM));
        MMMnew(MMM == MMM(YY(i),XX(i)))=1;
        MMMnew = imdilate(MMMnew,se);
        s = regionprops(bwlabel(MMMnew),'MajorAxisLength');
        MaxAx = round(cat(1,s.MajorAxisLength));

        radius = round(MaxAx/2+settings.marginCell);
        settings.radius = radius;
    end
    
    Cell = zeros(2*radius+1,2*radius+1,NumFrameEx-FrameInit+1);
    for r1=FrameInit:FrameEnd
        progress = ((r1-FrameInit+1)/(FrameEnd - FrameInit +1))*100;
        fprintf('Processing Cell %d frame %d of %d (%.2f%% complete)\n', i, r1, FrameEnd, progress);
        Im = read(VideoP,r1);
        FrameVideo = double(rgb2gray(Im(PixelInitY:PixelInitY-1+FrameSizeY,PixelInitX:PixelInitX-1+FrameSizeX,:)));

        Mask = imfill(double(FrameVideo>Thrs));
        Mask = (imerode(imfill(imdilate(Mask,se)),se));
        if ~settings.ifcellpose
            MMM = bwlabel(Mask); %labeling similar components
        else
            cellThreshold = -6;
            flowThreshold = 3;
            averageCellDiameter=radius*2;
            MMM = segmentCells2D(cpCyto,FrameVideo, ...
            ImageCellDiameter=averageCellDiameter, ...
            CellThreshold=cellThreshold, ...
            FlowErrorThreshold=flowThreshold);
        end
        %pause(0.3);
        s = regionprops(MMM,FrameVideo,'WeightedCentroid');
        Centri = cat(1,s.WeightedCentroid);
        Centri = round(Centri);

        %CALCOLO DELLA TRAIETTORIA
        Dist1 = zeros(1,size(Centri,1));

        for nn1=1:size(Centri,1)
            Dist1(nn1)=sqrt((Centri(nn1,1)-XX(i)).^2+(Centri(nn1,2)-YY(i)).^2);
        end
        [A1,B1]=min(Dist1);

        XX_ = Centri(B1,1);
        YY_ = Centri(B1,2);
        Traj1(r1-FrameInit+1,:) = [YY_(1),XX_(1)-1];

        MMMnew = zeros(size(MMM));
        MMMnew(MMM==B1)=1;
        %imshow(label2rgb(MMMnew));

        
        frameIdx = r1-FrameInit+1;
        Mask = imdilate(MMMnew,se);
        LabeledFrames(:, :, :, frameIdx) = label2rgb(MMMnew);

        xCenter = Traj1(frameIdx, 1);
        yCenter = Traj1(frameIdx, 2);

        % Check if the ROI is within the frame boundaries
        if (xCenter - radius < 1) || (xCenter + radius > FrameWidth) || ...
                (yCenter - radius < 1) || (yCenter + radius > FrameHeight)
            warning('ROI is out of bounds for frame %d. Skipping.', frameIdx);
            break; % Exit without performing the assignment
        end

        % ESTRAZIONE DELLA ROI contenente la cellula trackata
        Cell(:,:,frameIdx)=FrameVideo(xCenter-radius:xCenter+radius,yCenter-radius:yCenter+radius);
        if mod(r1, 5) == 0  % Display every 5 frames
            imagesc(Cell(:,:,frameIdx)); colormap gray; axis image; axis off;
            drawnow;
        end
        Trajectory = [Trajectory; [xCenter, yCenter]];
    end
    Cells{i}.Settings = settings;
    Cells{i}.Cell= Cell;
    Cells{i}.LabeledFrames=LabeledFrames;
    Cells{i}.Trajectory = Trajectory;
end

end